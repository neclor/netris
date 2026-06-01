namespace NetrisServer;

#pragma warning disable CA1812
internal sealed class LeaderboardOptions {
#pragma warning restore CA1812
	public const string SectionName = "Leaderboard";

	public string FilePath { get; init; } = "leaderboard.csv";
	public int MaxEntries { get; init; } = 200;
}
