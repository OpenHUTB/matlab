function project = createProject( varargin )

if nargin > 1
    project = createFromNameValuePairs( varargin{ : } );
else
    project = createFromSingleArgument( varargin{ : } );
end
end

function project = createFromNameValuePairs( args )
arguments
    args.Name( 1, 1 )string{ mustBeNonzeroLengthText } = getDefaultName(  );
    args.Folder( 1, 1 )string{ mustBeNonzeroLengthText } = getDefaultLocation(  );
end

project = createBlankProject( args.Name, args.Folder );
end

function project = createFromSingleArgument( projectLocation )
arguments
    projectLocation( 1, : )char = '';
end

if isempty( projectLocation )
    projectLocation = getDefaultLocation(  );
else
    if isstring( projectLocation )
        projectNameCharVec = char( projectLocation );
        projectName = projectLocation;
    else
        projectNameCharVec = projectLocation;
        projectName = string( projectNameCharVec );
    end
    if ~( projectName.contains( filesep ) || projectName.contains( '/' ) )
        projectLocation = getDefaultLocation( projectNameCharVec );
        project = createBlankProject( projectNameCharVec, projectLocation );
        return ;
    end
end

if isstring( projectLocation )
    projectLocation = char( projectLocation );
end

project = createBlankProject( getDefaultName(  ), projectLocation );
end

function name = getDefaultName(  )
name = 'blank_project';
end

function location = getDefaultLocation( folderName )
arguments
    folderName( 1, : )char = getString( message( 'MATLAB:project:api:DefaultProjectFolderName' ) );
end

defaultFolder = matlab.internal.project.util.getDefaultProjectFolder(  );
location = matlab.internal.project.util.generateFolderGroupNames( { defaultFolder }, folderName );
end

function projectManager = createBlankProject( projectName, projectFolder )
if matlab.internal.project.util.useWebFrontEnd
    projectManager = matlab.internal.project.api.createProject( projectFolder, projectName );
    return
end


error( javachk( 'jvm', 'MATLAB Projects' ) );

resolvedFolder = matlab.internal.project.util.PathUtils.resolveFileAgainstFileSystem( projectFolder, false );
projectManager = createBlankProjectUsingJava( projectName, resolvedFolder );
end

function projectManager = createBlankProjectUsingJava( projectName, projectFolder )



try
    if ~exist( projectFolder, 'dir' )
        mkdir( projectFolder );
    end

    creator = com.mathworks.toolbox.slproject.project.creation.ProjectCreator.createWithGlobalCMProvider;

    creator.setProjectName( java.lang.String( projectName ) );
    creator.setProjectDirectory( java.io.File( projectFolder ) );

    creator.create( true );

    projectManager = matlab.project.loadProject( projectFolder );

catch e
    i_handleProjectException( e );
end
end

function i_handleProjectException( exception )
if isa( exception, 'matlab.exception.JavaException' ) &&  ...
        isa( exception.ExceptionObject, 'com.mathworks.toolbox.slproject.Exceptions.CoreProjectException' )

    throw( MException( 'project:creation:failure', char( exception.ExceptionObject.getMessage(  ) ) ) );
else

    throw( exception );
end
end

