using Microsoft.AspNetCore.Mvc;

namespace NetrisServer.Controllers;

[ApiController]
[Route("[controller]")]
#pragma warning disable CA1812
internal sealed class LeaderboardController(LeaderboardService leaderboard) : ControllerBase {
#pragma warning restore CA1812

	[HttpGet]
	public async Task<IActionResult> Get(CancellationToken cancellationToken) =>
		Ok(await leaderboard.GetScoresAsync(cancellationToken).ConfigureAwait(false));

	[HttpPost]
	public async Task<IActionResult> Post([FromBody] SubmitScoreRequest request) {
		if (!IsValidRequest(request)) return BadRequest();

		await leaderboard.AddScoreAsync(request.Name!.Trim(), request.Score).ConfigureAwait(false);

		return Ok();
	}

	private static bool IsValidRequest(SubmitScoreRequest request) =>
		!string.IsNullOrWhiteSpace(request.Name) && request.Name.Length <= 32 && request.Score > 0;

#pragma warning disable CA1812
	internal sealed record SubmitScoreRequest(string? Name, int Score);
#pragma warning restore CA1812
}
