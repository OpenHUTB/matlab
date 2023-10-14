classdef FromFileUi < dependencies.internal.widget.WindowHandle

    properties ( Access = private )
        EndSubscription;
        ReadySubscription;
    end

    methods
        function this = FromFileUi( sourceFiles, requiredFiles,  ...
                shortcuts, options )
            arguments
                sourceFiles( 1, : )string
                requiredFiles( 1, : )string
                shortcuts( 1, : )string
                options.Debug( 1, 1 )logical = false
                options.OpenProject( 1, 1 )logical = true
                options.ProjectCreatedCallback( 1, 1 )function_handle
            end

            uuid = matlab.lang.internal.uuid;

            baseChannel = "/project_fromfile/" + uuid + "/";

            initialSize = [ 500, 340 ];

            this@dependencies.internal.widget.WindowHandle(  ...
                i_getBaseUrl( options.Debug ) + "?uuid=" + uuid,  ...
                "Title", i_getTitle(  ),  ...
                "InitialSize", initialSize );

            readyChannel = baseChannel + "ready";
            filesChannel = baseChannel + "files";
            this.ReadySubscription = message.subscribe(  ...
                readyChannel, @( ~ )i_publishFiles(  ...
                filesChannel, sourceFiles, requiredFiles, shortcuts ) );

            window = this.Window;

            endChannel = baseChannel + "end";
            this.EndSubscription = message.subscribe(  ...
                endChannel,  ...
                @( projectRoot )i_closeWindowOpenProjectAndRunCallback(  ...
                window, projectRoot, options ) );
        end

        function delete( this )
            message.unsubscribe( this.EndSubscription );
            message.unsubscribe( this.ReadySubscription );
        end
    end
end



function i_publishFiles( channel, sourceFiles, requiredFiles, shortcuts )
theMessage = struct(  ...
    "sourceFiles", sourceFiles,  ...
    "requiredFiles", requiredFiles,  ...
    "fileSeparator", string( filesep ),  ...
    "shortcuts", shortcuts );
message.publish( channel, theMessage );
end

function i_closeWindowOpenProjectAndRunCallback( window, projectRoot, options )
window.close(  );

if isempty( projectRoot )
    return
end

if options.OpenProject
    matlab.project.loadProject( projectRoot );
    if matlab.internal.project.util.useWebFrontEnd
        matlab.internal.project.view.showWelcomeGuide( projectRoot );
    else
        com.mathworks.toolbox.slproject.project.GUI.createfromfile.ShowWelcomeToolAction.show( java.io.File( projectRoot ) );
    end
end

if isfield( options, "ProjectCreatedCallback" )
    options.ProjectCreatedCallback( projectRoot );
end
end

function title = i_getTitle(  )
title = string( message( "MATLAB:project:view_fromfile:Title" ) );
end

function baseUrl = i_getBaseUrl( debug )
baseUrl = "/toolbox/matlab/project/views/fromfile_web/index";
if debug
    baseUrl = baseUrl + "-debug";
end
baseUrl = baseUrl + ".html";
end

% Decoded using De-pcode utility v1.2 from file /tmp/tmptHnwAO.p.
% Please follow local copyright laws when handling this file.

