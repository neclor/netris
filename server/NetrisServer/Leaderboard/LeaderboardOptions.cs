namespace NetrisServer;

#pragma warning disable CA1515
public sealed class LeaderboardOptions {
#pragma warning restore CA1515
	public const string SectionName = "Leaderboard";

	public string FilePath { get; init; } = "leaderboard.csv";
	public int MaxEntries { get; init; } = 200;
}
