ARG DOTNET_SDK_IMAGE=dhi.io/dotnet:8-sdk-alpine3.22
ARG ASPNET_RUNTIME_IMAGE=dhi.io/aspnetcore:8-alpine3.22

FROM ${DOTNET_SDK_IMAGE} AS build

WORKDIR /workspace
COPY src/Lab02.Api.csproj ./src/Lab02.Api.csproj
RUN dotnet restore ./src/Lab02.Api.csproj
COPY src/ ./src/
RUN dotnet publish ./src/Lab02.Api.csproj \
    --configuration Release \
    --output /app/publish \
    --no-restore

FROM ${ASPNET_RUNTIME_IMAGE} AS runtime

WORKDIR /app
COPY --from=build /app/publish/ ./
ENV ASPNETCORE_HTTP_PORTS=8080
USER 10001
EXPOSE 8080
ENTRYPOINT ["dotnet", "Lab02.Api.dll"]
