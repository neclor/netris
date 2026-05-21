namespace NetrisServer;

internal sealed class Program {

	public static void Main(string[] args) {
		WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

		_ = builder.Services.AddControllers();
		_ = builder.Services.AddSingleton<LeaderboardService>();
		_ = builder.Services.Configure<LeaderboardOptions>(builder.Configuration.GetSection(LeaderboardOptions.SectionName));

		WebApplication app = builder.Build();

		_ = app.MapControllers();

		app.Run();
	}
}
