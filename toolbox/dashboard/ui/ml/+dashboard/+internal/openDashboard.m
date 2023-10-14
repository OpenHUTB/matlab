function openDashboard( layoutId, pathToResolve, elementIdentifier, promptUser )

arguments
    layoutId{ isKnownLayout( layoutId ) }
    pathToResolve{ isPrjOrPath( pathToResolve ) } = ''
    elementIdentifier string = ""
    promptUser{ islogical( promptUser ) } = false
end

if ~dig.isProductInstalled( 'Simulink Check' )
    error( message( 'dashboard:api:SLCheckNotInstalled' ) );
end

if ~license( 'checkout', 'SL_Verification_Validation' )
    error( message( 'dashboard:api:LicenseError' ) );
end

if nargin == 1
    cp = dashboard.internal.ProjectController.getCurrentProject(  );
    uiService = dashboard.UiService.get(  );
    window = uiService.defaultWindowForProject( cp.Path );
    window.open( 'LayoutId', layoutId );
    return ;
end

if isProject( pathToResolve )
    pathToResolve = pathToResolve.RootFolder;
end


f = alm.internal.GlobalProjectFactory.get(  );
projectPath = f.findProjectRoot( pathToResolve );

if f.isProject( projectPath )
    if ~f.isProjectLoaded( projectPath )


        doOpen = false;
        prj = matlab.project.currentProject(  );
        if ~isempty( prj )
            if promptUser
                answer = questdlg(  ...
                    message( 'dashboard:metricsdashboard:ChangeProjectQuestion', projectPath ).getString(  ),  ...
                    message( 'dashboard:metricsdashboard:OpenDashboard' ).getString(  ),  ...
                    message( 'dashboard:metricsdashboard:Continue' ).getString(  ),  ...
                    message( 'dashboard:metricsdashboard:Cancel' ).getString(  ),  ...
                    message( 'dashboard:metricsdashboard:Cancel' ).getString(  ) );

                if strcmp( answer, message( 'dashboard:metricsdashboard:Continue' ).getString(  ) )
                    doOpen = true;
                end
            else
                error( message( 'dashboard:metricsdashboard:OtherProjectLoaded', pathToResolve, prj.RootFolder ) );
            end
        else
            doOpen = true;
        end

        if doOpen
            openProject( projectPath );
        else
            error( message( 'dashboard:metricsdashboard:ProjectMustBeLoaded', projectPath ) );
        end
    end


    [ ~, fileName, ext ] = fileparts( pathToResolve );
    ext = char( ext );
    uuid = [  ];
    if strcmpi( ext, '.slx' )
        as = alm.internal.ArtifactService.get( projectPath );
        storageFactory = alm.StorageFactory;
        storageHandler = storageFactory.createHandler(  ...
            as.getGraph(  ).getStorageByCustomId( "ProjectRoot" ) );
        G = as.getGraph(  );


        if strlength( elementIdentifier ) == 0
            elementIdentifier = fileName;
        end
        art = G.getArtifactByAddress(  ...
            "",  ...
            storageHandler.getRelativeAddress( pathToResolve ).Value,  ...
            string( elementIdentifier ) );

        if ~isempty( art )
            uuid = art.UUID;
        end
    end

    uiService = dashboard.UiService.get(  );
    window = uiService.defaultWindowForProject( projectPath );
    if ~isempty( uuid )
        window.open( 'Artifact', uuid, 'LayoutId', layoutId );
    else
        window.open( 'LayoutId', layoutId );
    end

else
    if isfile( pathToResolve )
        error( message( 'dashboard:metricsdashboard:NotInsideProject', pathToResolve ) );
    else
        error( message( 'dashboard:metricsdashboard:NoPathToProject', pathToResolve ) );
    end
end
end

function res = isPrjOrPath( x )
res = false;
if isProject( x )
    res = true;
    return ;
end
if isCharOrString( x )

    if isempty( x )
        res = true;
        return ;
    end
    switch exist( x, 'file' )

        case { 2, 4 }


            [ ~, ~, ext ] = fileparts( x );
            if strcmpi( ext, '.slx' ) || strcmpi( ext, '.prj' )
                res = true;
            end

        case 7
            res = true;
    end
end
if res == false
    error( message( 'dashboard:metricsdashboard:NoPrjOrPath', x ) );
end
end

function res = isProject( x )
res = isa( x, 'matlab.project.Project' ) || isa( x, 'slproject.ProjectManager' );
end

function res = isCharOrString( x )
res = ( isa( x, 'char' ) || isa( x, 'string' ) ) & ( numel( string( x ) ) <= 1 );
end

function res = isKnownLayout( x )
fn = fieldnames( dashboard.internal.LayoutConstants );
for i = 1:numel( fn )
    if strcmp( dashboard.internal.LayoutConstants.( fn{ i } ), x )
        res = true;
        return ;
    end
end
res = false;
end


