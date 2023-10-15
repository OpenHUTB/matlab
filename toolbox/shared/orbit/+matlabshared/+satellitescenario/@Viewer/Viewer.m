classdef Viewer < handle & matlab.mixin.SetGet




    properties ( Access = { ?satelliteScenario, ?matlabshared.satellitescenario.ScenarioGraphic, ?tplay } )


        CZMLFileID = {  }
        CZMLFile = {  }


        NeedToSimulate = true
    end

    properties ( Hidden )
        ScenarioGraphicsVisibility = struct
        DeclutterMap = struct
        UIFigure
        Labels
    end

    properties ( Hidden, SetObservable )

        UIWaitBar
    end

    properties ( Hidden, SetAccess = ?satelliteScenario )
        GlobeViewer
    end

    properties ( Hidden, SetAccess = private )
        GeographicGlobe
    end

    properties ( Access = private, Constant )
        AppDataName = 'managed_satelliteScenarioViewers'
    end

    properties ( Access = private )
        pCameraReferenceFrame = 'ECEF'
        DefaultPlaybackSpeedMultiplier = 50
        PlayListener = event.listener.empty
        TimelineListener = event.listener.empty
        FocusListener = event.listener.empty
        pScenario
    end

    properties ( Access = { ?tDeclutterVisuals, ?SCTester.SatScenarioViewerTester } )
        ClickListener = event.listener.empty
    end

    properties ( Dependent, Hidden )

        IsDynamic
        Scenario
    end

    properties ( Hidden )
        pShowDetails = false
    end

    properties ( Dependent, Access = ?satelliteScenario )
        pCurrentTime
    end

    properties ( Dependent )




        Name{ mustBeTextScalar }






        Position( 1, 4 )double{ mustBeReal, mustBeFinite, mustBeNonsparse }
















        Basemap



        PlaybackSpeedMultiplier( 1, 1 )double{ mustBeFinite, mustBeReal, mustBeNonsparse }








        CameraReferenceFrame{ mustBeMember( CameraReferenceFrame, { 'ECEF', 'Inertial' } ) }






        CurrentTime( 1, 1 )datetime








        ShowDetails( 1, 1 )logical
    end

    properties ( SetAccess = immutable )



        Dimension{ mustBeMember( Dimension, { '3D', '2D' } ) } = '3D'
    end

    methods
        function delete( viewer )



            viewer.CZMLFileID = [  ];


            for idx = 1:numel( viewer.CZMLFile )
                if isfile( viewer.CZMLFile{ idx } )
                    delete( viewer.CZMLFile{ idx } );
                end
            end


            if isa( viewer.UIWaitBar, 'matlab.ui.dialog.ProgressDialog' )
                delete( viewer.UIWaitBar );
            end


            if ~isempty( viewer.UIFigure ) && isvalid( viewer.UIFigure )
                delete( viewer.UIFigure );
            end




            scenario = viewer.Scenario;
            if ( isa( scenario, 'satelliteScenario' ) && isvalid( scenario ) )
                scenario.Viewers( scenario.Viewers == viewer ) = [  ];
                if ( scenario.CurrentViewer == viewer )
                    if ( isempty( scenario.Viewers ) )
                        scenario.CurrentViewer = matlabshared.satellitescenario.Viewer.empty;
                    else
                        scenario.CurrentViewer = scenario.Viewers( end  );
                    end
                end
            end


            if ( isvalid( viewer.TimelineListener ) )
                delete( viewer.TimelineListener );
            end

            if ( isvalid( viewer.PlayListener ) )
                delete( viewer.PlayListener );
            end

            if ( isvalid( viewer.FocusListener ) )
                delete( viewer.FocusListener );
            end

            if ( isvalid( viewer.ClickListener ) )
                delete( viewer.ClickListener );
            end

        end

        function viewerstruct = saveobj( viewer )

            if ( isempty( viewer ) || isempty( viewer.GlobeViewer ) )
                viewerstruct = [  ];
            else
                scenario = viewer.Scenario;
                viewerstruct = struct(  ...
                    'Scenario', scenario,  ...
                    'Simulator', scenario.Simulator,  ...
                    'Args', { {  ...
                    'Name', viewer.Name,  ...
                    'Position', viewer.Position,  ...
                    'Basemap', viewer.Basemap,  ...
                    'Dimension', viewer.Dimension,  ...
                    'PlaybackSpeedMultiplier', viewer.PlaybackSpeedMultiplier,  ...
                    'CameraReferenceFrame', viewer.CameraReferenceFrame,  ...
                    'ScenarioGraphicsVisibility', viewer.ScenarioGraphicsVisibility,  ...
                    'ShowDetails', viewer.ShowDetails,  ...
                    'DeclutterMap', viewer.DeclutterMap,  ...
                    'CurrentTime', viewer.CurrentTime } } );
            end
        end


        function basemap = get.Basemap( viewer )
            basemap = viewer.GeographicGlobe.Basemap;
        end

        function set.ShowDetails( viewer, showDetails )
            if showDetails ~= viewer.pShowDetails


                primaryAssets = fieldnames( viewer.DeclutterMap );
                graphics = {  };
                queuePlots( viewer.GlobeViewer );
                for k = 1:numel( primaryAssets )
                    toggleAssetChildrenVisibility( viewer, primaryAssets{ k }, showDetails );
                end

                sats = viewer.Scenario.Satellites.Handles;
                gses = viewer.Scenario.GroundStations.Handles;
                if viewer.IsDynamic


                    for k = 1:numel( sats )
                        assetHandle = sats{ k };
                        for czmlidx = 1:numel( viewer.CZMLFileID )
                            viewer.GlobeViewer.toggleCZMLVisibility( { { assetHandle.LabelGraphic } }, viewer.CZMLFileID{ czmlidx }, showDetails )
                        end
                        assetHandle.pShowLabel = showDetails;
                    end
                    for k = 1:numel( gses )
                        assetHandle = gses{ k };
                        for czmlidx = 1:numel( viewer.CZMLFileID )
                            viewer.GlobeViewer.toggleCZMLVisibility( { { assetHandle.LabelGraphic } }, viewer.CZMLFileID{ czmlidx }, showDetails )
                        end
                        assetHandle.pShowLabel = showDetails;
                    end
                else
                    if ~isempty( viewer.Scenario.Satellites )
                        set( viewer.Scenario.Satellites, 'ShowLabel', showDetails );
                    end
                    if ~isempty( viewer.Scenario.GroundStations )
                        set( viewer.Scenario.GroundStations, 'ShowLabel', showDetails );
                    end
                end
                submitPlots( viewer.GlobeViewer, "WaitForResponse", true, "Animation", 'none' )
                viewer.pShowDetails = showDetails;
                viewer.ClickListener.Enabled = ~showDetails;
            end
        end

        function showDetails = get.ShowDetails( viewer )
            showDetails = viewer.pShowDetails;
        end

        function set.Basemap( viewer, basemap )
            viewer.GeographicGlobe.Basemap = basemap;
            figure( viewer.UIFigure );
        end

        function name = get.Name( viewer )
            name = viewer.UIFigure.Name;
        end

        function set.Name( viewer, name )
            viewer.UIFigure.Name = name;
        end

        function pos = get.Position( viewer )
            pos = viewer.UIFigure.Position;
        end

        function set.Position( viewer, pos )
            viewer.UIFigure.Position = pos;
        end

        function set.PlaybackSpeedMultiplier( viewer, speed )
            viewer.GlobeViewer.setPlaybackSpeed( speed );
            figure( viewer.UIFigure );
        end

        function speed = get.PlaybackSpeedMultiplier( viewer )
            speedStruct = viewer.GlobeViewer.getPlaybackSpeed(  );
            speed = speedStruct.Speed;
        end

        function set.pCurrentTime( viewer, time )



            if ( isempty( time.TimeZone ) )
                time.TimeZone = 'UTC';
            end



            if time < viewer.pScenario.StartTime || time > viewer.pScenario.StopTime
                msg = message(  ...
                    'shared_orbit:orbitPropagator:CurrentTimeOutsideBounds' );
                error( msg );
            end

            if ( viewer.IsDynamic )
                if isOutOfSimulatorTimeBounds( viewer, time )
                    viewer.makeViewStatic;
                    show( viewer.Scenario, "Viewer", viewer, "Time", time, "Animation", 'none' );
                else
                    viewer.GlobeViewer.setDate( time );
                end
            else


                show( viewer.Scenario, "Viewer", viewer, "Time", time, "Animation", 'none' );
            end
            figure( viewer.UIFigure );
        end

        function time = get.pCurrentTime( viewer )
            time = viewer.GlobeViewer.getDate(  );
        end

        function set.CurrentTime( viewer, time )



            coder.internal.errorIf( ~viewer( 1 ).Scenario.AutoSimulate,  ...
                'shared_orbit:orbitPropagator:InvalidManualSimPropertySet',  ...
                'CurrentTime' );

            viewer.pCurrentTime = time;
        end

        function time = get.CurrentTime( viewer )


            time = viewer.pCurrentTime;
        end

        function varargout = campos( viewer, varargin )




























































            arguments
                viewer( 1, 1 )matlabshared.satellitescenario.Viewer
            end
            arguments( Repeating )
                varargin
            end
            [ varargout{ 1:nargout } ] = viewer.GeographicGlobe.campos( varargin{ : } );
            figure( viewer.UIFigure );
        end

        function outHeight = camheight( viewer, varargin )












































            arguments
                viewer( 1, 1 )matlabshared.satellitescenario.Viewer
            end
            arguments( Repeating )
                varargin
            end
            outHeight = viewer.GeographicGlobe.camheight( varargin{ : } );
            figure( viewer.UIFigure );
        end

        function outHeading = camheading( viewer, varargin )










































            arguments
                viewer( 1, 1 )matlabshared.satellitescenario.Viewer
            end
            arguments( Repeating )
                varargin
            end
            if strcmp( viewer.Dimension, '2D' )
                msg = message( 'shared_orbit:orbitPropagator:SatelliteScenarioViewerUnsupportedRotation' );
                error( msg );
            end
            outHeading = viewer.GeographicGlobe.camheading( varargin{ : } );
            figure( viewer.UIFigure );
        end

        function outRoll = camroll( viewer, varargin )










































            arguments
                viewer( 1, 1 )matlabshared.satellitescenario.Viewer
            end
            arguments( Repeating )
                varargin
            end
            if strcmp( viewer.Dimension, '2D' )
                msg = message( 'shared_orbit:orbitPropagator:SatelliteScenarioViewerUnsupportedRotation' );
                error( msg );
            end
            outRoll = viewer.GeographicGlobe.camroll( varargin{ : } );
            figure( viewer.UIFigure );
        end

        function outPitch = campitch( viewer, varargin )










































            arguments
                viewer( 1, 1 )matlabshared.satellitescenario.Viewer
            end
            arguments( Repeating )
                varargin
            end
            if strcmp( viewer.Dimension, '2D' )
                msg = message( 'shared_orbit:orbitPropagator:SatelliteScenarioViewerUnsupportedRotation' );
                error( msg );
            end
            outPitch = viewer.GeographicGlobe.campitch( varargin{ : } );
            figure( viewer.UIFigure );
        end

        function camtarget( viewer, graphic )
            arguments
                viewer( 1, 1 )matlabshared.satellitescenario.Viewer
                graphic( 1, 1 ){ mustBeA( graphic, { 'matlabshared.satellitescenario.Satellite', 'matlabshared.satellitescenario.GroundStation' } ) }
            end
            if ( viewer.IsDynamic )


                viewer.GlobeViewer.setCameraTarget( graphic.getGraphicID, viewer.CZMLFileID{ end  } );
            else
                viewer.GlobeViewer.setCameraTarget( graphic.getGraphicID );
            end
            figure( viewer.UIFigure );
        end

        function set.CameraReferenceFrame( viewer, reference )
            reference = validatestring( reference, { 'Inertial', 'ECEF' },  ...
                'set.CameraReferenceFrame' );
            if ( strcmp( viewer.Dimension, '2D' ) && strcmp( reference, 'Inertial' ) )
                msg = message( 'shared_orbit:orbitPropagator:SatelliteScenarioViewerInertialUnsupported' );
                error( msg );
            end
            viewer.pCameraReferenceFrame = reference;
            setInertial = strcmpi( reference, 'Inertial' );
            viewer.GlobeViewer.setInertialCamera( setInertial );
        end

        function reference = get.CameraReferenceFrame( viewer )
            reference = viewer.pCameraReferenceFrame;
        end

        function isDynamic = get.IsDynamic( viewer )
            isDynamic = ~isempty( viewer.CZMLFileID );
        end

        function play( viewer )





































































            play( viewer.Scenario, "Viewer", viewer );
        end

        function hideAll( viewer )






























            czmlFileExisted = ~isempty( viewer.CZMLFileID );


            clear( viewer, true );





            if isempty( viewer.CZMLFileID ) && czmlFileExisted && viewer.Scenario.AutoSimulate
                viewer.GlobeViewer.setTimelineWidget( true );
                viewer.GlobeViewer.setAnimationWidget( true );
            end


            graphics = fieldnames( viewer.ScenarioGraphicsVisibility );
            numGraphics = numel( graphics );
            for k = 1:numGraphics
                viewer.ScenarioGraphicsVisibility.( graphics{ k } ) = false;
            end
        end

        function showAll( viewer )




































            graphics = fieldnames( viewer.ScenarioGraphicsVisibility );
            numGraphics = numel( graphics );
            for k = 1:numGraphics
                viewer.ScenarioGraphicsVisibility.( graphics{ k } ) = true;
            end


            makeViewStatic( viewer );


            show( viewer.Scenario, "Viewer", viewer );
        end

        function set.Scenario( viewer, scenario )
            viewer.pScenario = scenario;
        end

        function scenario = get.Scenario( viewer )
            scenario = viewer.pScenario;
        end
    end

    methods ( Static, Hidden )
        function viewer = loadobj( viewerstruct )
            if ( isempty( viewerstruct ) )
                viewer = matlabshared.satellitescenario.Viewer.empty;
            else
                scenario = viewerstruct.Scenario;
                if ( isempty( scenario.Simulator ) )
                    scenario.Simulator = viewerstruct.Simulator;
                end



                invalidViewers = [  ];
                for k = 1:numel( scenario.Viewers )
                    if isempty( scenario.Viewers( k ).GlobeViewer )
                        invalidViewers( end  + 1 ) = k;%#ok<AGROW>
                    end
                end
                scenario.Viewers( invalidViewers ) = [  ];





                currentTime = NaT( 1, 0 );
                for idx = 1:numel( viewerstruct.Args )
                    if isequal( viewerstruct.Args{ idx }, 'CurrentTime' )
                        currentTime = viewerstruct.Args{ idx + 1 };
                        viewerstruct.Args( idx:idx + 1 ) = [  ];
                        break
                    end
                end



                viewer = matlabshared.satellitescenario.Viewer( scenario, viewerstruct.Args{ : } );


                if ~isempty( currentTime )
                    if currentTime < scenario.StartTime
                        viewer.pCurrentTime = scenario.StartTime;
                    elseif currentTime > scenario.StopTime
                        viewer.pCurrentTime = scenario.StopTime;
                    else
                        viewer.pCurrentTime = currentTime;
                    end
                end

                scenario.Viewers( end  + 1 ) = viewer;
                scenario.CurrentViewer = viewer;
            end
        end
    end

    methods ( Access = { ?satelliteScenario, ?matlabshared.satellitescenario.ScenarioGraphic,  ...
            ?tViewer, ?SCTester.SatScenarioViewerTester } )
        clear( viewer, deleteCZMLFile )

        function initializeGraphicVisibility( viewer, objs, visibility )
            for k = 1:numel( objs )
                if iscell( objs )


                    obj = objs{ k };
                else


                    obj = objs( k );
                end
                id = obj.getGraphicID;
                if ~graphicExists( viewer, id )
                    addGraphic( viewer, id, visibility );

                    viewer.initializeGraphicVisibility( obj.getChildObjects, visibility );
                end
            end
        end

        function initializeDeclutterMap( viewer, objs, initialShowDetails )
            numObjs = numel( objs );
            for k = 1:numObjs
                if iscell( objs )


                    obj = objs{ k };
                else


                    obj = objs( k );
                end
                addGraphicToClutterMap( obj, viewer );
            end




            if ~initialShowDetails
                primaryAssets = fieldnames( viewer.DeclutterMap );

                for k = 1:numel( primaryAssets )
                    currentAsset = primaryAssets{ k };
                    viewer.DeclutterMap.( currentAsset ).childVisibility = false;
                    childGraphics = fieldnames( viewer.DeclutterMap.( currentAsset ) );

                    for k2 = 1:numel( childGraphics )
                        if ~strcmp( childGraphics{ k2 }, 'childVisibility' )
                            setGraphicVisibility( viewer, childGraphics{ k2 }, false );
                        end
                    end
                end



                if ~isempty( viewer.Scenario.Satellites )
                    numSats = numel( viewer.Scenario.Satellites.Handles );
                    satHandles = viewer.Scenario.Satellites.Handles;
                else
                    numSats = 0;
                end
                if ~isempty( viewer.Scenario.GroundStations )
                    numGS = numel( viewer.Scenario.GroundStations.Handles );
                    gsHandles = viewer.Scenario.GroundStations.Handles;
                else
                    numGS = 0;
                end
                for k = 1:numSats
                    satHandles{ k }.pShowLabel = false;
                end
                for k = 1:numGS
                    gsHandles{ k }.pShowLabel = false;
                end
            end
        end


        function doesGraphicExist = graphicExists( viewer, graphicID )
            doesGraphicExist = isfield( viewer.ScenarioGraphicsVisibility, graphicID );
        end


        function addGraphic( viewer, graphicID, visibility )
            viewer.ScenarioGraphicsVisibility.( graphicID ) = visibility;
        end

        function removeGraphic( viewer, graphicID )
            if isfield( viewer.ScenarioGraphicsVisibility, graphicID )
                viewer.ScenarioGraphicsVisibility =  ...
                    rmfield( viewer.ScenarioGraphicsVisibility, graphicID );
            end
        end




        function setGraphicVisibility( viewer, graphicID, visibility )
            if ( ~graphicExists( viewer, graphicID ) )
                addGraphic( viewer, graphicID, visibility );
            else
                viewer.ScenarioGraphicsVisibility.( graphicID ) = visibility;
            end
        end




        function visibility = getGraphicVisibility( viewer, graphicID )
            if ( isfield( viewer.ScenarioGraphicsVisibility, graphicID ) )
                visibility = viewer.ScenarioGraphicsVisibility.( graphicID );
            else




                visibility = false;
            end
        end
    end

    methods ( Access = { ?satelliteScenario } )
        function viewer = Viewer( scenario, varargin )




            opt = globe.internal.GlobeOptions;
            opt.EnableHomeButton = true;
            opt.EnableDayNightLighting = true;
            opt.EnableInfoBox = false;
            opt.EnableBaseLayerPicker = true;
            opt.EnableOSM = false;
            opt.EnableNavigationHelpButton = true;



            [ viewer.Dimension, args ] = matlabshared.satellitescenario.ScenarioGraphic.extractParamFromVarargin(  ...
                'Dimension', '3D', @( d )true, varargin{ : } );
            opt.Enable2DLaunch = strcmp( viewer.Dimension, '2D' );



            [ viewer.ScenarioGraphicsVisibility, args ] =  ...
                matlabshared.satellitescenario.ScenarioGraphic.extractParamFromVarargin(  ...
                'ScenarioGraphicsVisibility', struct, @( d )true, args{ : } );




            [ viewer.pShowDetails, args ] =  ...
                matlabshared.satellitescenario.ScenarioGraphic.extractParamFromVarargin(  ...
                'ShowDetails', true, @( d )true, args{ : } );


            position = globe.internal.getCenterPosition( [ 800, 600 ] );
            fig = uifigure( "Visible", false, "Position", position );




            fig.AutoResizeChildren = false;
            fig.Name = getString( message( "shared_orbit:orbitPropagator:SatelliteScenarioViewerTitle" ) );
            gl = globe.graphics.GeographicGlobe( "Parent", fig,  ...
                "Terrain", "none", "GlobeOptions", opt );
            fig.Visible = true;


            viewer.GlobeViewer = gl.GlobeViewer;
            viewer.Scenario = scenario;
            viewer.UIFigure = fig;
            viewer.GeographicGlobe = gl;



            if scenario.AutoSimulate
                time = scenario.StartTime;
            else
                time = scenario.Simulator.Time;
            end
            viewer.GlobeViewer.setDate( time );
            viewer.GlobeViewer.setPlaybackSpeed( viewer.DefaultPlaybackSpeedMultiplier );

            addFocusGainedCallback( viewer );
            addClosingCallback( viewer );





            viewer.Labels = struct( "NeedsUpdate", false );





            viewer.initializeGraphicVisibility( scenario.ScenarioGraphics, true );
            viewer.initializeDeclutterMap( scenario.ScenarioGraphics, viewer.pShowDetails );




            globe.internal.setObjectNameValuePairs( viewer, args );



            if scenario.AutoSimulate
                viewer.GlobeViewer.setAnimationWidget( true );
                viewer.GlobeViewer.setTimelineWidget( true );

                viewer.GlobeViewer.setClockBounds( scenario.StartTime, scenario.StopTime );
            end



            viewer.PlayListener = addlistener( viewer.GlobeViewer, 'MouseClickPlay', @( ~, ~ )viewer.resimulateCurrentScenario );
            viewer.TimelineListener = addlistener( viewer.GlobeViewer, 'MouseClickTimeline', @( ~, ~ )viewer.resimulateCurrentScenario );
            viewer.ClickListener = addlistener( viewer.GlobeViewer, 'LeftMouseClick', @( ~, data )viewer.processDeclutteredVisuals( data.MouseData ) );
            viewer.ClickListener.Enabled = ~viewer.pShowDetails;
        end
    end

    methods ( Access = private )
        function addFocusGainedCallback( viewer )
            viewer.FocusListener = addlistener( viewer.UIFigure,  ...
                'FigureActivated', @( src, evt )FocusGained( viewer ) );
        end

        function FocusGained( viewer )
            viewer.Scenario.CurrentViewer = viewer;
        end

        function addClosingCallback( viewer )
            viewer.UIFigure.CloseRequestFcn = @( ~, ~ )delete( viewer );
        end

        function resimulateCurrentScenario( viewer )

            if ( ~isempty( viewer ) && ( viewer.NeedToSimulate ) )



                currentTime = viewer.CurrentTime;
                if ( isOutOfSimulatorTimeBounds( viewer, currentTime ) )
                    currentTime = viewer.Scenario.Simulator.StartTime;
                end
                play( viewer.Scenario, "Viewer", viewer );
                viewer.pCurrentTime = currentTime;
                viewer.NeedToSimulate = false;
            end
        end


        function toggleAssetChildrenVisibility( viewer, primaryAssetID, setVisible )
            graphics = {  };
            asset = viewer.DeclutterMap.( primaryAssetID );
            childGraphics = fieldnames( asset );
            for k = 1:numel( childGraphics )
                if ~strcmp( childGraphics{ k }, "childVisibility" ) && isvalid( asset.( childGraphics{ k } ) )


                    if ~strcmp( asset.( childGraphics{ k } ).VisibilityMode, 'manual' )
                        graphics{ end  + 1 } = asset.( childGraphics{ k } );
                    end
                end
            end
            if setVisible
                if viewer.IsDynamic
                    ids = strings( 0 );
                    for k = 1:numel( graphics )
                        ids = [ ids, graphics{ k }.getGraphicID, graphics{ k }.getChildGraphicsIDs ];
                        setGraphicVisibility( viewer, graphics{ k }.getGraphicID, true );
                    end
                    if numel( ids ) == 1
                        ids = { { ids } };
                    end
                    for czmlidx = 1:numel( viewer.CZMLFileID )
                        viewer.GlobeViewer.toggleCZMLVisibility( ids, viewer.CZMLFileID{ czmlidx }, true )
                    end
                else
                    for k = 1:numel( graphics )
                        setGraphicVisibility( viewer, graphics{ k }.getGraphicID, true );
                        updateVisualizations( graphics{ k }, viewer );
                    end
                end
            else
                matlabshared.satellitescenario.ScenarioGraphic.hideGraphics( graphics, viewer );
            end
            viewer.DeclutterMap.( primaryAssetID ).childVisibility = setVisible;
        end
    end

    methods ( Access = { ?tDeclutterVisuals, ?SCTester.SatScenarioViewerTester } )
        function processDeclutteredVisuals( viewer, data )
            if ~isfield( data, 'Selection' )
                return
            end
            selection = data.Selection;
            if ~iscell( selection )
                selection = { selection };
            end
            numSelections = numel( selection );
            primaryAssets = fieldnames( viewer.DeclutterMap );
            numPrimaryAssets = numel( primaryAssets );
            queuePlots( viewer.GlobeViewer );
            for k = 1:numSelections
                for k2 = 1:numPrimaryAssets
                    if strcmp( primaryAssets{ k2 }, selection{ k } )
                        asset = primaryAssets{ k2 };

                        visibility = viewer.DeclutterMap.( asset ).childVisibility;
                        toggleAssetChildrenVisibility( viewer, asset, ~visibility );



                        assetObj = [  ];
                        satHandles = viewer.Scenario.Satellites.Handles;
                        numSats = numel( satHandles );
                        for k3 = 1:numSats
                            if strcmp( satHandles{ k3 }.getGraphicID, asset )
                                assetObj = satHandles{ k3 };
                                break ;
                            end
                        end
                        if isempty( assetObj )
                            gsHandles = viewer.Scenario.GroundStations.Handles;
                            numGses = numel( gsHandles );
                            for k3 = 1:numGses
                                if strcmp( gsHandles{ k3 }.getGraphicID, asset )
                                    assetObj = gsHandles{ k3 };
                                    break ;
                                end
                            end
                        end
                        if viewer.IsDynamic
                            for czmlidx = 1:numel( viewer.CZMLFileID )
                                viewer.GlobeViewer.toggleCZMLVisibility( { { assetObj.LabelGraphic } }, viewer.CZMLFileID{ czmlidx }, ~visibility )
                            end
                            assetObj.pShowLabel = ~visibility;
                        else
                            assetObj.ShowLabel = ~visibility;
                        end
                    end
                end
            end
            submitPlots( viewer.GlobeViewer, 'Animation', 'none' );
        end
    end

    methods ( Access = { ?satelliteScenario } )
        [ czmlFile, czmlFileID ] = writeCZML( viewer )
        playback( viewer, waitForResponse )
        function toggleWidgetListeners( viewer, onOrOff )
            viewer.TimelineListener.enabled = onOrOff;
            viewer.PlayListener.enabled = onOrOff;
        end
    end

    methods ( Access = { ?satelliteScenario, ?matlabshared.satellitescenario.ScenarioGraphic,  ...
            ?tViewer } )
        addWaitBar( viewer, msg )
        removeWaitBar( viewer )
        function makeViewStatic( viewer )


            if ~viewer.Scenario.AutoSimulate
                showAnimationAndTimelineWidget = false;
            else
                showAnimationAndTimelineWidget = true;
            end
            for idx = 1:numel( viewer.CZMLFileID )
                data = struct(  ...
                    'ID', { viewer.CZMLFileID( idx ) },  ...
                    'EnableDayNightLighting', true,  ...
                    'ShowAnimationAndTimelineWidget', showAnimationAndTimelineWidget,  ...
                    'EnableWindowLaunch', true,  ...
                    'Animation', 'none' );
                viewer.GlobeViewer.Controller.visualRequest( 'remove', data );
            end
            viewer.NeedToSimulate = true;
            viewer.CZMLFileID = {  };
        end
    end
end


function isOutside = isOutOfSimulatorTimeBounds( viewer, time )
scenario = viewer.Scenario;
simulator = scenario.Simulator;
isOutside = time < simulator.StartTime || time > simulator.StopTime;
end
