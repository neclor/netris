FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["NetrisServer/NetrisServer.csproj", "NetrisServer/"]
RUN dotnet restore "./NetrisServer/NetrisServer.csproj"
COPY . .
WORKDIR "/src/NetrisServer"
RUN dotnet build "./NetrisServer.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./NetrisServer.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
LABEL org.opencontainers.image.title="Netris Server" \
      org.opencontainers.image.description="Netris leaderboard API" \
      org.opencontainers.image.url="https://github.com/neclor/netris"
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "NetrisServer.dll"]
