function [ fileStatuses ] = status( repo, options )

arguments
    repo( 1, 1 )matlab.git.GitRepository

    options.Files( 1, : )string{ matlab.internal.git.validators.mustBeFileOrFolder, mustBeNonempty };
    options.IncludeUntrackedFiles( 1, 1 )logical;
    options.IncludeIgnoredFiles( 1, 1 )logical;
    options.IncludeUnmodifiedFiles( 1, 1 )logical;
end

if isfield( options, "Files" )
    if any( isfield( options, [ "IncludeUntrackedFiles", "IncludeIgnoredFiles", "IncludeUnmodifiedFiles" ] ) )
        error( message( "shared_cmlink:git:IncompatibleStatusOptions" ) );
    end
    [ statuses, files ] = matlab.internal.git.refreshStatusCache(  ...
        repo,  ...
        @(  )matlab.internal.git.statusFiles( repo.WorkingFolder, options.Files ) );
else
    nvOptions = namedargs2cell( options );
    [ statuses, files ] = statusAll( repo, nvOptions{ : } );
end

fileStatuses = table(  ...
    matlab.sourcecontrol.Status( statuses ),  ...
    VariableNames = "Status", RowNames = files );

fileStatuses.Properties.DimensionNames{ 1 } = 'File';
fileStatuses.Properties.Description = string( message( "shared_cmlink:git:FileStatusTableDescription" ) );
end

function [ statuses, files ] = statusAll( repo, options )
arguments
    repo( 1, 1 )matlab.git.GitRepository

    options.IncludeUntrackedFiles( 1, 1 )logical = true;
    options.IncludeIgnoredFiles( 1, 1 )logical = false;
    options.IncludeUnmodifiedFiles( 1, 1 )logical = false;
end

[ statuses, files ] = matlab.internal.git.refreshStatusCache(  ...
    repo,  ...
    @(  )matlab.internal.git.statusAll( repo.WorkingFolder,  ...
    options.IncludeUntrackedFiles, options.IncludeIgnoredFiles, options.IncludeUnmodifiedFiles ) );
end
