# start with a base image with all the necessary tooling to compile our app
FROM mcr.microsoft.com/dotnet/framework/sdk:4.7.2 AS build
# set the working directory inside compilation container to c:\app
WORKDIR \app
 
# copy everything from solution dir into the c:\app
COPY . .
# restore nuget packages
RUN nuget restore
# use msbuild to publish project in /FramworkApp folder to c:\publish, which includes only binaries and content files (no sources)
RUN msbuild "MyApp\MyApp.csproj" /p:DeployOnBuild=true /p:PublishUrl="c:\publish" /p:WebPublishMethod=FileSystem /p:DeployDefaultTarget=WebPublish
 
# start with new base image for running asp.net apps (which contains IIS)
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.2 AS runtime
# set default work folder to c:\inetpub\wwwroot (IIS root)
WORKDIR /inetpub/wwwroot
# copy files from bin/publish in our sdk container into c:\inetpub\wwwroot
COPY --from=build /publish. ./