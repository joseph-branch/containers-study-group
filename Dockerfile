# **Stage 1: Build Stage**
# Use the official .NET SDK image for building the application.
# This image includes all necessary tools for compiling and building .NET applications.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory inside the container to /app.
# This will be the context where the build operations occur.
WORKDIR /app

# **Copy Project Files and Restore Dependencies**
# Copy the project (.csproj) file(s) into the working directory.
# Only the project files are copied at this stage to take advantage of Docker's caching mechanism.
COPY *.csproj ./

# Restore NuGet packages specified in the project file(s).
# This step resolves and downloads dependencies from NuGet, ensuring they are ready for the build step.
# Caching is used so that if dependencies haven't changed, this step will be skipped during subsequent builds.
RUN dotnet restore

# **Copy Remaining Source Files and Build the Application**
# Copy the rest of the application source files into the working directory.
COPY . ./

# Build the application in Release configuration and publish the compiled output.
# The `dotnet publish` command compiles the source code, resolves runtime dependencies,
# and outputs the results to the specified directory (`out`).
RUN dotnet publish -c Release -o out

# **Stage 2: Runtime Stage**
# Use the official smaller runtime image for running the application.
# This image is optimized for production and only contains the necessary runtime libraries.
FROM mcr.microsoft.com/dotnet/aspnet:8.0

# Set the working directory inside the container to /app.
# This ensures the app files are organized in a consistent directory.
WORKDIR /app

# Copy the published application files from the build stage into the runtime stage.
# The `--from=build` flag references the build stage defined earlier, allowing
# artifacts from the first stage to be reused in the second stage.
COPY --from=build /app/out .

# Set the environment variable for the .NET runtime.
# This controls the runtime environment for the application. Possible values:
# - Development: Includes detailed error messages and additional runtime checks.
# - Production: Optimized for performance and minimal output.
ENV DOTNET_ENVIRONMENT=Development

# **Expose Ports**
# Expose port 8080: Default HTTP port for the application.
EXPOSE 8080

# **Run the Application**
# Specify the command to start the application when the container runs.
# `dotnet DojoApi.dll` launches the .NET application defined by the compiled output.
ENTRYPOINT ["dotnet", "DojoApi.dll"]