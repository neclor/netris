using Microsoft.Extensions.Options;

namespace NetrisServer;

#pragma warning disable CA1515
public sealed class LeaderboardService(IOptions<LeaderboardOptions> options) : IDisposable {
#pragma warning restore CA1515

	private readonly SemaphoreSlim _semaphore = new(1, 1);
	private readonly LeaderboardOptions _options = options.Value;
	private List<ScoreEntry>? _scores;

	public async Task<List<ScoreEntry>> GetScoresAsync(CancellationToken cancellationToken) {
		await _semaphore.WaitAsync(cancellationToken).ConfigureAwait(false);
		try {
			return _scores ??= await ReadFromFileAsync(cancellationToken).ConfigureAwait(false);
		} finally {
			_ = _semaphore.Release();
		}
	}

	public async Task AddScoreAsync(string name, int score) {
		await _semaphore.WaitAsync().ConfigureAwait(false);
		try {
			List<ScoreEntry> current = _scores ??= await ReadFromFileAsync(CancellationToken.None).ConfigureAwait(false);
			List<ScoreEntry> updated = GetTopScores([.. current, new(name, score)]);
			await WriteAtomicAsync(updated.Select(s => $"{s.Score},{s.Name}")).ConfigureAwait(false);
			_scores = updated;
		} finally {
			_ = _semaphore.Release();
		}
	}

	public void Dispose() => _semaphore.Dispose();

	private List<ScoreEntry> GetTopScores(List<ScoreEntry> scores) =>
		[.. scores
			.GroupBy(s => s.Name, StringComparer.Ordinal)
			.Select(g => g.OrderByDescending(x => x.Score).First())
			.OrderByDescending(x => x.Score)
			.Take(_options.MaxEntries)];

	private async Task<List<ScoreEntry>> ReadFromFileAsync(CancellationToken cancellationToken) {
		if (!File.Exists(_options.FilePath)) return [];

		List<ScoreEntry> scores = [];
		string[] lines = await File.ReadAllLinesAsync(_options.FilePath, cancellationToken).ConfigureAwait(false);
		foreach (string line in lines) {
			string[] parts = line.Split(',', 2);
			if (parts.Length == 2 && int.TryParse(parts[0], out int parsedScore))
				scores.Add(new(parts[1], parsedScore));
		}
		return scores;
	}

	private async Task WriteAtomicAsync(IEnumerable<string> lines) {
		string? dir = Path.GetDirectoryName(_options.FilePath);
		if (!string.IsNullOrEmpty(dir)) {
			_ = Directory.CreateDirectory(dir);
		}
		string tempPath = _options.FilePath + ".tmp";
		await File.WriteAllLinesAsync(tempPath, lines).ConfigureAwait(false);
		File.Move(tempPath, _options.FilePath, overwrite: true);
	}
}
