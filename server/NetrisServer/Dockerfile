FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
# A new volume mounted here takes this owner, so the app can write to it
RUN mkdir data && chown $APP_UID:$APP_UID data
USER $APP_UID
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["NetrisServer/NetrisServer.csproj", "NetrisServer/"]
RUN dotnet restore "./NetrisServer/NetrisServer.csproj"
COPY . .
WORKDIR "/src/NetrisServer"

FROM build AS publish
RUN dotnet publish "./NetrisServer.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
LABEL org.opencontainers.image.title="Netris Server" \
      org.opencontainers.image.description="Netris leaderboard API" \
      org.opencontainers.image.url="https://github.com/neclor/netris"
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "NetrisServer.dll"]
