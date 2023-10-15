classdef SLSlicer < SLSlicerAPI.SLSlicerOptions




    properties ( Dependent )
        Model;
        isInEditableHighlight;
    end
    properties ( Access = private )
        modelH;
        termListener = [  ];
        paramDependence = [  ];
    end
    properties ( Access = public, Hidden = true )
        showFastRestartMessage = true;
    end

    methods
        function obj = SLSlicer( mdl, varargin )
            if nargin == 1
                scfg = SlicerConfiguration.getConfiguration( mdl );
                varargin{ 1 } = scfg;
            end

            obj@SLSlicerAPI.SLSlicerOptions( varargin{ : } );

            obj.modelH = get_param( mdl, 'Handle' );



            if isa( obj.internalCfg, 'SlicerConfiguration' )
                modelslicerprivate( 'slicerMapper', 'set', obj.modelH, obj.internalCfg.modelSlicer );
                obj.internalCfg.storeConfiguration(  );
            end
        end

        function activate( obj, addHighlight )
            arguments
                obj
                addHighlight = true;
            end

            if ~isModelAvailable( obj )
                error( 'ModelSlicer:API:StaleModelHandle', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:ModelHandleAssociatedWith' ) ) )
            end

            obj.showFastRestartNotif(  );
            if ~isCompiled( obj )



                allStartsHandles = [ obj.StartingPoint.Handle ];
                allExclusionHandles = [ obj.ExclusionPoint.Handle ];


                commonHandles = intersect( allStartsHandles, allExclusionHandles );

                if ~isempty( commonHandles )
                    error( 'ModelSlicer:API:ConflictStartsAndExclusion', getString( message( 'Sldv:ModelSlicer:Analysis:ConflictStartsAndExclusions' ) ) )
                end

                try
                    obj.internalCfg.modelSlicer.checkCompatibility( 'CheckType', 'PreCompile' );
                    ms = obj.internalCfg.modelSlicer;
                    if obj.isInEditableHighlight
                        ms.compileModelAfterEditableHighlight;
                    else
                        ms.compileModel;
                    end
                    if addHighlight
                        obj.internalCfg.createSessionIfNeeded(  );
                    end
                catch mex
                    throw( mex )
                end
                checkAndUpdateSeeds( obj );
                obj.addTermListener(  );
            else

            end
        end

        function addTermListener( obj )
            simHandler = obj.internalCfg.modelSlicer.simHandler;
            ms = obj.internalCfg.modelSlicer;
            obj.termListener = addlistener( simHandler,  ...
                'eventModelTerminatedExternal',  ...
                @( ~, ~ )ms.terminateModelForEditableHighlighting(  ) );
        end

        function removeTermListener( obj )
            delete( obj.termListener );
            obj.termListener = [  ];
        end

        function unlock( obj )

            if isCompiled( obj )
                obj.internalCfg.modelSlicer.terminateModelForEditableHighlighting(  );
            end
        end
        function terminate( obj )


            if ~isCompiled( obj ) && ~obj.isInEditableHighlight
                error( 'ModelSlicer:API:ModelIsAlreadyTerminated',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:ModelIsAlreadyTerminated' ) ) );
            end

            try
                obj.removeTermListener(  );
                if isCompiled( obj )
                    obj.internalCfg.modelSlicer.terminateModel;
                end

                sc = obj.internalCfg.sliceCriteria;
                if ~isempty( obj.internalCfg.session )
                    for i = 1:length( sc )
                        if ~isempty( sc( i ).overlay )
                            sc( i ).overlay.removeFromEditor(  );
                            sc( i ).overlay.clearAll(  );
                            sc( i ).overlay = [  ];
                        end
                    end
                end
                obj.internalCfg.modelSlicer.removeHighlighting(  );
                obj.internalCfg.session = [  ];
                obj.internalCfg.modelSlicer.clearSimHandler;

            catch mex
                if isCompiled( obj )
                    simHandler = obj.internalCfg.modelSlicer.simHandler;
                    simHandler.terminate;
                    sc.modelSlicer.setModelSlicerActive( ModelSlicer.Terminated );
                end
                throw( mex );
            end
        end

        function highlight( obj, idx )
            if ~isCompiled( obj )

                activate( obj );
            end

            if ~exist( 'idx', 'var' )




                idx = obj.ActiveConfig;
            elseif numel( idx ) > 3
                error( 'ModelSlicer:API:UptoThreeConfig', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:UptoThreeConfig' ) ) );
            elseif max( idx ) > numel( obj.cfg ) || min( idx ) < 1
                error( 'ModelSlicer:API:InvalidConfigIdx', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidConfigIdx', numel( obj.cfg ) ) ) );
            end


            highlightIdx = union( idx, setdiff( idx, obj.DisplayedConfig ) );


            obj.internalCfg.allDisplayed = unique( idx );
            unhighlightIdx = setdiff( obj.DisplayedConfig, idx );
            for n = 1:length( unhighlightIdx )
                obj.cfg( unhighlightIdx( n ) ).unhighlight;
            end
            for n = 1:length( highlightIdx )
                obj.cfg( highlightIdx( n ) ).highlight;
            end

            obj.internalCfg.addOverlapRules(  );
            obj.internalCfg.resetRulesForSingleCriteriaOverlapHighlighting(  );
        end

        function setTimeWindow( obj, starTime, stopTime )
            obj.Configuration( obj.ActiveConfig ).setTimeWindow( starTime, stopTime );
            wasHighlighted = obj.Configuration( obj.ActiveConfig ).highlighted;
            if wasHighlighted
                obj.highlight;
            end
        end
        function timeIntervals = getConstraintTimeIntervals( obj )
            timeIntervals = obj.Configuration( obj.ActiveConfig ).getConstraintTimeIntervals(  );
        end

        function [ startTime, stopTime ] = getTimeWindow( obj )
            [ startTime, stopTime ] = obj.Configuration( obj.ActiveConfig ).getTimeWindow(  );
        end

        function out = ActiveBlocks( obj, NameValueArgs )
            arguments
                obj
                NameValueArgs.IncludeVirtual = false;
            end
            out = [  ];
            configIdx = obj.DisplayedConfig;
            if isempty( configIdx )
                configIdx = obj.ActiveConfig;
            end
            if ~isempty( configIdx )
                if obj.internalCfg.highlightCommonBlocksVal
                    out = obj.Configuration( configIdx( 1 ) ).ActiveBlocks( NameValueArgs.IncludeVirtual );
                    for idx = 2:length( configIdx )
                        out = intersect( out, obj.Configuration( configIdx( idx ) ).ActiveBlocks( NameValueArgs.IncludeVirtual ) );
                    end
                else
                    for idx = 1:length( configIdx )
                        out = union( out, obj.Configuration( configIdx( idx ) ).ActiveBlocks( NameValueArgs.IncludeVirtual ) );
                    end
                end
            end
        end

        function out = slice( obj, varargin )
            if ~isCompiled( obj )

                activate( obj );
            end
            out = obj.Configuration( obj.ActiveConfig ).slice( varargin{ : } );
            if ~isCompiled( obj )
                ms = obj.internalCfg.modelSlicer;
                ms.setModelSlicerActive( ModelSlicer.EditableHighlight );
            end
        end
        function simulate( obj, varargin )
            obj.showFastRestartNotif(  );
            obj.Configuration( obj.ActiveConfig ).simulate( varargin{ : } );
            obj.highlight;
        end

        function yesno = isFastRestartEnabled( obj )
            yesno = strcmp( get_param( obj.modelH, 'FastRestart' ), 'on' );
        end

        function report( obj )
            if ~isCompiled( obj )

                activate( obj );
            end
            if ~isSLReportGenLicenseAvailable(  )
                error( 'ModelSlicer:API:NoReportGeneratorLicense',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:NoReportGeneratorLicense' ) ) );
            elseif ~isReportGeneratorInstalled(  )
                error( 'ModelSlicer:API:NoReportGeneratorInstalled',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:NoReportGeneratorInstalled' ) ) );
            else
                highlighted = false;
                for n = obj.DisplayedConfig
                    if obj.cfg( n ).highlighted
                        highlighted = true;
                    end
                end
                if ~highlighted
                    error( 'ModelSlicer:API:CannotReportWithoutHighlight',  ...
                        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:CannotReportWithoutHighlight' ) ) )
                else


                    activeSysH = [  ];
                    for n = obj.DisplayedConfig
                        activeSysH = [ activeSysH;obj.cfg( n ).sc.getActiveSystemHandles ];%#ok<AGROW>
                    end
                    activeSysH = unique( activeSysH );



                    obj.internalCfg.allDisplayed = obj.DisplayedConfig;
                    origConfigMap = SlicerConfiguration.configurationMapper( 'get', obj.modelH );
                    SlicerConfiguration.configurationMapper( 'set', obj.modelH, obj.internalCfg );

                    if isReportGeneratorInstalled(  )
                        slwebview_slicer( obj.modelH, 'IncludeSystems', activeSysH,  ...
                            'InlineOptions', obj.internalCfg.options.InlineOptions );
                    end


                    SlicerConfiguration.configurationMapper( 'set', obj.modelH, origConfigMap );
                end
            end
            function yesno = isSLReportGenLicenseAvailable(  )
                yesno = license( 'test', 'SIMULINK_Report_Gen' );
            end
            function yesno = isReportGeneratorInstalled(  )
                yesno = exist( 'slwebview_slicer', 'file' );
            end
        end
        function out = get.Model( obj )
            out = get_param( obj.modelH, 'Name' );
        end

        function out = get.isInEditableHighlight( obj )
            if isModelAvailable( obj )
                out = get_param( obj.modelH, 'ModelSlicerActive' ) ==  ...
                    ModelSlicer.EditableHighlight;
            else
                out = false;
            end
        end
        function delete( obj )
            if isModelAvailable( obj ) && ( isCompiled( obj ) || obj.isInEditableHighlight )
                obj.terminate;
            end
            if ishandle( obj.modelH ) && get_param( obj.modelH, 'ModelSlicerActive' ) ~= ModelSlicer.Terminated

                obj.internalCfg.modelSlicer.setModelSlicerActive( ModelSlicer.Terminated )
            end
            SlicerConfiguration.configurationMapper( 'set', obj.modelH, [  ] );
            modelslicerprivate( 'slicerMapper', 'set', obj.modelH, [  ] )
        end
        function pd = parameterDependence( obj )

            if isempty( obj.paramDependence ) || ( isa( obj.paramDependence, 'handle' ) && ~isvalid( obj.paramDependence ) )


                obj.paramDependence = SLSlicerAPI.ParameterDependence( obj );
            end
            pd = obj.paramDependence;
        end
    end
    methods ( Access = private )
        function yesno = isCompiled( obj )
            yesno = slslicer.internal.checkDesiredSimulationStatus( obj.modelH,  ...
                'isSimStatusPausedOrCompiled' );
        end

        function out = isModelAvailable( obj )
            out = true;
            try
                name = get_param( obj.modelH, 'Name' );%#ok<NASGU>
            catch
                out = false;
            end
        end
        function checkAndUpdateSeeds( obj )


            if ~isCompiled( obj )
                assert( false, 'checkAndUpdateSeeds should be called for compiled model.' );
                return ;
            end
            modelName = get_param( obj.modelH, 'Name' );
            msObj = obj.internalCfg.modelSlicer;
            obj.cfg.validateSeeds( modelName, msObj );
        end
        function ActivateEventHandler( obj, eventSrc, eventData )%#ok<INUSD>
            if ~isCompiled( obj )
                activate( obj );
            end
        end

    end

    methods ( Access = public, Hidden = true )

        function compute( obj, idx )
            arguments
                obj
                idx = obj.ActiveConfig;
            end
            if ~isCompiled( obj )

                activate( obj, false );
            end

            obj.Configuration( idx ).compute(  );
        end

        function tags = getDisplayedOverlayTags( obj )
            tags = [  ];
            for n = obj.DisplayedConfig
                tags{ end  + 1 } = obj.cfg( n ).sc.getOverlayTag;%#ok<AGROW>
            end
        end
        function simHandler = getSimulationHandler( obj )
            msObj = obj.internalCfg.modelSlicer;
            simHandler = msObj.simHandler;
        end

        function setCriteriaTag( obj, tag )
            obj.internalCfg.CurrentCriteria.updateCriterionTag( tag );
        end

        function refreshHighlight( obj )
            obj.internalCfg.CurrentCriteria.dirty = 1;
            obj.internalCfg.CurrentCriteria.refresh;
        end

        function deleteCriterionByTag( obj, tag )
            obj.internalCfg.deleteCriterionByTag( tag );
            obj.internalCfg.saveConfigurationToFile;
        end

        function showFastRestartNotif( obj )
            if strcmp( get_param( obj.modelH, 'FastRestart' ), 'off' ) && obj.showFastRestartMessage
                if SlicerConfiguration.getFastRestartNotifSetting(  )
                    FastRestartMsg = getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:LaunchWithFastRestartTip' ) );
                    modelslicerprivate( 'MessageHandler', 'info', FastRestartMsg );
                end
                obj.showFastRestartMessage = false;
            end
        end
    end
end

