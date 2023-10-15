classdef SLSlicerConfig < handle & matlab.mixin.CustomDisplay




    properties ( Access = public )
        Name = 'untitled';
        Description = '';
        Color = [ 0, 1, 1 ];
        SignalPropagation = 'upstream';
        UseTimeWindow = false;
        UseDeadLogic = false;
        CoverageFile = '';
        DeadLogicFile = '';
    end
    properties ( GetAccess = public, SetAccess = private )
        highlighted = false;
    end
    properties ( Access = protected )
        start = SLSlicerAPI.SLSlicerItem.empty(  );
        exclude = SLSlicerAPI.SLSlicerItem.empty(  );
        cnstrnt = SLSlicerAPI.SLSlicerItem.empty(  );
        slicesys = SLSlicerAPI.SLSlicerItem.empty(  );
    end
    properties ( Access = private )
        modelH;
        mdlAndRefs;
        internalSC;
        internalCfg;
    end
    properties ( Dependent )
        StartingPoint;
        ExclusionPoint;
        Constraint;
        SliceComponent;
    end
    properties ( Dependent = true, GetAccess = public, SetAccess = private )
        StartTime;
        StopTime;
    end
    properties ( Access = private, Constant = true )

        colorValueList = { [ 0, 1, 1 ], [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ], [ 1, 0, 1 ],  ...
            [ 1, 1, 0 ], [ .67, .84, .9 ], [ 1, 0.5, 0 ], [ .42, .59, .24 ] }
        preSetColorMap = containers.Map(  ...
            { 'cyan', 'red', 'green', 'blue', 'magenta',  ...
            'yellow', 'lightblue', 'orange', 'darkgreen' },  ...
            { [ 0, 1, 1 ], [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ], [ 1, 0, 1 ],  ...
            [ 1, 1, 0 ], [ .67, .84, .9 ], [ 1, 0.5, 0 ], [ .42, .59, .24 ] } );
    end
    methods
        function obj = SLSlicerConfig( varargin )
            if nargin == 0

            elseif nargin == 2
                in = varargin{ 1 };
                obj.internalCfg = varargin{ 2 };
                if isa( in, 'SliceCriterion' )
                    obj.applySliceCriterion( in );
                elseif isstruct( in ) && isfield( in, 'Elements' )
                    obj.applySLMSStruct( in );
                else
                    error( 'ModelSlicer:API:InvalidInput',  ...
                        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidInputIsSpecified' ) ) );
                end
            else
                error( 'ModelSlicer:API:InvalidInput',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidInputIsSpecified' ) ) );
            end
        end


        function highlight( obj )
            if isempty( obj.modelH )
                error( 'ModelSlicer:API:CannotHighlight',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:MethodCalledOnly', 'highlight' ) ) );
            elseif ~obj.isCompiled




                error( 'ModelSlicer:API:NotActivated4Highlight',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:NotActivated4Highlight' ) ) );
            end
            obj.internalCfg.createSessionIfNeeded;
            obj.checkCoverage(  );



            if strcmp( get_param( obj.modelH, 'Dirty' ), 'on' ) ...
                    && ~isempty( obj.sc.overlay )
                obj.sc.overlay.clearAll(  );
                obj.sc.overlay = [  ];
            end

            obj.internalCfg.session.remove_overlap_rules(  );
            obj.sc.dirty = true;
            obj.sc.refresh(  );
            obj.highlighted = true;
        end

        function unhighlight( obj )
            if isempty( obj.modelH )
                error( 'ModelSlicer:API:CannotUnhighlight',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:MethodCalledOnly', 'unhighlight' ) ) );
            else
                if ~isempty( obj.sc.overlay )
                    obj.sc.overlay.removeFromEditor(  );
                end
                if ~isempty( obj.internalCfg.session )
                    obj.internalCfg.session.remove_overlap_rules(  );
                end
            end
            obj.highlighted = false;
        end

        function compute( obj )
            obj.sc.computeDependencies(  );
        end

        function name = slice( obj, fileName )

            obj.checkCoverage(  );
            ms = obj.sc.modelSlicer;

            if isempty( obj.modelH )
                error( 'ModelSlicer:API:CannotSlice',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:MethodCalledOnly', 'slice' ) ) )
            elseif ~obj.isCompiled
                error( 'ModelSlicer:API:NotActivated4Slice',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:NotActivated4Slice' ) ) );
            elseif ~strcmp( obj.SignalPropagation, 'upstream' )
                error( 'ModelSlicer:API:OnlyDownStreamSliceSupported',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:GenSliceTooltipNeedBack' ) ) );
            elseif ~isempty( obj.sc.constraints.keys ) || ~isempty( obj.sc.covConstraints.keys )
                error( 'ModelSlicer:API:ConstraintsNotSupported4Slicing',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:GenSliceTooltipHaveConstraints' ) ) );
            end

            ms.options = obj.internalCfg.options;

            if ~exist( 'fileName', 'var' )
                fileName = obj.sc.getSuggestedSliceFileName(  );
            else
                fileName = convertStringsToChars( fileName );
            end
            [ thePath, name, ~ ] = fileparts( fileName );
            if isempty( thePath )
                thePath = pwd;
            end
            obj.sc.validateStarts(  );
            obj.sc.exportSliceHandler( name, thePath );
        end

        function simulate( obj, varargin )
            if isempty( obj.modelH )
                error( 'ModelSlicer:API:CannotSimulate',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:MethodCalledOnly', 'simulate' ) ) )
            end



            simulationInput = [  ];


            if ( nargin == 1 )
                startTime = locEval( get_param( obj.modelH, 'StartTime' ) );
                stopTime = locEval( get_param( obj.modelH, 'StopTime' ) );
            elseif ( nargin == 2 )
                if isa( varargin{ 1 }, 'Simulink.SimulationInput' )

                    simulationInput = varargin{ 1 };
                    in = varargin{ 1 };


                    startTime = locEval( get_param( obj.modelH, 'StartTime' ) );
                    inStopTime = in.ModelParameters( strcmp( { in.ModelParameters( : ).Name }, 'StopTime' ) );
                    if ~isempty( inStopTime )
                        stopTime = locEval( inStopTime.Value );
                    else
                        stopTime = locEval( get_param( obj.modelH, 'StopTime' ) );
                    end

                else


                    startTime = locEval( get_param( obj.modelH, 'StartTime' ) );
                    stopTime = varargin{ 1 };
                end

            elseif ( nargin == 3 )

                startTime = varargin{ 1 };
                stopTime = varargin{ 2 };

            else
                error( 'ModelSlicer:API:InvalidInput',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidInputArgumentIsGiven' ) ) );
            end

            if ~isValidWindow( startTime, stopTime )
                error( 'ModelSlicer:InvalidTimeWindow',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:InvalidTimeWindow' ) ) );
            end
            sc = obj.sc;
            scfg = obj.internalCfg;
            if isempty( scfg )
                scfg = SlicerConfiguration( sc.modelSlicer.modelH );
                scfg.sliceCriteria = sc;
            end
            ms = scfg.modelSlicer;
            if ~scfg.initialized && isempty( ms.simHandler )
                ms.setModelSlicerActive( ModelSlicer.UsingCovTool );
            end

            ms = obj.internalCfg.modelSlicer;
            origActiveVal = get_param( obj.modelH, 'ModelSlicerActive' );
            if ~origActiveVal

                ms.setModelSlicerActive( ModelSlicer.UsingCovTool );
                cleanupObj = onCleanup( @(  )ms.setModelSlicerActive( origActiveVal ) );
            end

            if strcmp( get_param( scfg.modelH, 'FastRestart' ), 'on' )
                sc.collectCoverage( scfg, startTime, stopTime, simulationInput, obj.getSimulationHandler );
            else
                sc.collectCoverage( scfg, startTime, stopTime, simulationInput, scfg.modelH );
            end

            obj.UseTimeWindow = true;
            obj.CoverageFile = sc.cvFileName;

            function val = locEval( evalStr )
                val = modelslicerprivate( 'evalinModel',  ...
                    getfullname( obj.modelH ), evalStr );
            end
        end

        function simHandler = getSimulationHandler( obj )
            modelSlicer = obj.internalCfg.modelSlicer;
            simHandler = modelSlicer.simHandler;
            if isempty( simHandler )
                modelSlicer.compileModel;
                obj.internalCfg.createSessionIfNeeded;
                simHandler = modelSlicer.simHandler;
            end
        end

        function showPortLabel( obj )

            if ( ~( obj.internalCfg.modelSlicer.inSteppingMode(  ) ) )
                error( 'Sldv:ModelSlicer:SLSlicerAPI:ModelNotSimulatingError', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:ModelNotSimulatingError' ) ) );
            end
            obj.internalCfg.refreshPortValueLabels(  );

        end

        function hidePortLabel( obj )

            if ( ~( obj.internalCfg.modelSlicer.inSteppingMode(  ) ) )
                error( 'Sldv:ModelSlicer:SLSlicerAPI:ModelNotSimulatingError', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:ModelNotSimulatingError' ) ) );
            end
            sc = obj.sc;
            sc.removePortsLabelled(  );

        end

        function runAndPause( obj, time )

            if ( ( get_param( bdroot, 'TimeOfMajorStep' ) >= time ) )

                error( 'Sldv:ModelSlicer:SLSlicerAPI:PauseTimeBeforeCurrentStepError', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:PauseTimeBeforeCurrentStepError' ) ) );
            end

            if ( str2num( get_param( bdroot, 'StopTime' ) ) < time )
                error( 'Sldv:ModelSlicer:SLSlicerAPI:PauseTimeExceedsStopTimeError', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:PauseTimeExceedsStopTimeError' ) ) );
            end

            simHandler = getSimulationHandler( obj );
            simHandler.runAndPause( time );


        end

        function continueSimulation( obj )
            simHandler = getSimulationHandler( obj );
            simHandler.continueSim(  );
        end

        function stopSimulation( obj )
            simHandler = getSimulationHandler( obj );
            simHandler.stopSim(  );
        end

        function stepForward( obj )
            simHandler = getSimulationHandler( obj );
            simHandler.stepForward(  );
        end

        function stepBack( obj )
            simHandler = getSimulationHandler( obj );
            simHandler.stepBack(  );
        end

        function applySimInToModel( obj, simIn )
            simHandler = getSimulationHandler( obj );
            simHandler.applySimInToModel( simIn );
        end

        function unsetPauseTime( obj, time )
            simHandler = getSimulationHandler( obj );
            simHandler.unsetPauseTime( time );
        end
        function rollBackAndPause( obj, time )
            simHandler = getSimulationHandler( obj );
            simHandler.rollBackAndPause( time );
        end
        function setTimeWindow( obj, startTime, stopTime )
            obj.checkCoverage(  );
            sc = obj.sc;
            if isempty( sc.cvd )
                error( 'ModelSlicer:API:EmptyCovForTimeWindow',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:EmptyCovForTimeWindow' ) ) );
            end
            if ~isValidWindow( startTime, stopTime )
                error( 'ModelSlicer:InvalidTimeWindow',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:InvalidTimeWindow' ) ) );
            end
            if windowOutOfBounds( sc.cvd, startTime, stopTime )
                recordedStart = sc.cvd.streamStartTime;
                recordedStop = sc.cvd.streamStopTime;



                overlap = ( startTime <= recordedStop ) && ( stopTime >= recordedStart );
                if overlap
                    startTime = max( startTime, recordedStart );
                    stopTime = min( stopTime, recordedStop );
                    warning( 'ModelSlicer:API:windowAdjusted',  ...
                        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:windowAdjusted', num2str( startTime ), num2str( stopTime ) ) ) );
                else
                    error( 'ModelSlicer:API:windowOutOfBounds',  ...
                        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:windowOutOfBounds' ) ) );
                end
            end
            [ currStartTime, currStopTime ] = sc.cvd.getStartStopTime(  );
            valid = sc.cvd.setStartStopTime( startTime, stopTime );
            if ~valid


                sc.cvd.setStartStopTime( currStartTime, currStopTime );
                error( 'ModelSlicer:API:EmptyInterval',  ...
                    getString( message( 'Sldv:ModelSlicer:Coverage:EmptyDerivedInterval' ) ) );
            end
        end

        function [ startTime, stopTime ] = getTimeWindow( obj )
            obj.checkCoverage(  );
            sc = obj.sc;
            if isempty( sc.cvd )
                error( 'ModelSlicer:API:EmptyCovForTimeWindow',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:EmptyCovForTimeWindow' ) ) );
            end
            [ startTime, stopTime ] = sc.cvd.getStartStopTime(  );
        end
        function timeIntervals = getConstraintTimeIntervals( obj )
            obj.checkCoverage(  );
            sc = obj.sc;
            if isempty( sc.cvd )
                error( 'ModelSlicer:API:EmptyCovForTimeWindow',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:EmptyCovForTimeWindow' ) ) );
            end
            timeIntervals = sc.cvd.getConstraintTimeIntervals(  );
        end

        function activeBlkH = ActiveBlocks( obj, includeVirtual )
            arguments
                obj
                includeVirtual logical = false;
            end
            if isempty( obj.modelH )
                error( 'ModelSlicer:API:ActiveBlocksMethodCalledOnly',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:MethodCalledOnly', 'ActiveBlock' ) ) )
            else
                activeBlkH = obj.sc.getActiveBlockList( includeVirtual );
            end
        end

        function report( ~ )

            error( 'ModelSlicer:API:ReportMethodCannotBeCalled',  ...
                getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:ReportMethodCannotBeCalled' ) ) );
        end
        function addStartingPoint( obj, item, busElementPath )
            arguments
                obj
                item
                busElementPath = [  ]
            end
            try
                item = convertStringsToChars( item );
                item = filterValidModelElements( obj.mdlAndRefs, item,  ...
                    busElementPath );
                if obj.needSync
                    item = scAddStartingPoint( obj, item, busElementPath );
                end
                if ~isempty( item )
                    obj.start = loc_addItem( 'StartingPoint', obj.start, item,  ...
                        [  ], busElementPath );
                end
            catch mx
                throw( mx )
            end
        end
        function addExclusionPoint( obj, item )
            try
                item = convertStringsToChars( item );
                item = filterValidModelElements( obj.mdlAndRefs, item );
                if obj.needSync
                    item = scAddExclusionPoint( obj, item );
                end
                if ~isempty( item )
                    obj.exclude = loc_addItem( 'ExclusionPoint',  ...
                        obj.exclude, item, [  ], [  ] );
                end
            catch mx
                throw( mx )
            end
        end

        function addConstraint( obj, item, varargin )
            try
                item = convertStringsToChars( item );
                item = filterValidModelElements( obj.mdlAndRefs, item );
                if nargin > 2
                    dataPorts = varargin{ 1 };
                else
                    dataPorts = {  };
                end
                if obj.needSync


                    [ sfObjs, slObjs, sfIdx ] = filterSfObj( item );
                    obj.addCovConstraint( sfObjs );

                    item = slObjs;
                    if ~isempty( dataPorts )
                        dataPorts = dataPorts( ~sfIdx );
                    end

                    if isempty( item )
                        return ;
                    end
                    item = scAddConstraint( obj, item, dataPorts );
                end
                if ~isempty( item )
                    if isstruct( item )
                        dataPorts = [  ];
                    end
                    obj.cnstrnt = loc_addItem( 'Constraint', obj.cnstrnt,  ...
                        item, dataPorts, [  ] );
                end
            catch mx
                throw( mx )
            end
        end
        function addSliceComponent( obj, item )
            try
                item = convertStringsToChars( item );
                item = filterValidModelElements( obj.mdlAndRefs, item );
                if obj.needSync
                    scSetSliceSubSystem( obj, item );
                end
                if ~isempty( item )
                    obj.slicesys = loc_addItem( 'SliceSubSystem', [  ],  ...
                        item, [  ], [  ] );
                end
            catch mx
                throw( mx )
            end
        end
        function removeStartingPoint( obj, item, busElementPath )
            arguments
                obj
                item
                busElementPath = [  ]
            end
            try
                item = convertStringsToChars( item );
                removeItem( obj, 'StartingPoint', item, busElementPath );
            catch ex
                throw( ex )
            end
        end
        function removeExclusionPoint( obj, item )
            try
                item = convertStringsToChars( item );
                removeItem( obj, 'ExclusionPoint', item );
            catch ex
                throw( ex )
            end
        end
        function removeConstraint( obj, item )
            try
                item = convertStringsToChars( item );
                removeItem( obj, 'Constraint', item );
            catch ex
                throw( ex )
            end
        end

        function removeSliceComponent( obj )
            if obj.needSync
                obj.sc.deleteSliceSubsystem(  );
            end
            obj.slicesys = SLSlicerAPI.SLSlicerItem.empty(  );
        end

        function refineDeadLogic( obj, sysH, varargin )
            if nargin < 3
                analysisTime = 300;
            else
                analysisTime = varargin{ 1 };
            end
            if nargin < 4
                saveFile = obj.sc.getSlicexArtifactName(  );
            else
                saveFile = convertStringsToChars( varargin{ 2 } );
            end
            obj.sc.refineForDeadLogic( sysH, analysisTime, saveFile );
            obj.DeadLogicFile = obj.sc.sldvFileName;
            obj.UseDeadLogic = true;
        end

        function sys = getSysRefinedForDeadLogic( obj )
            if ~isempty( obj.sc.deadLogicData )
                sys = obj.sc.deadLogicData.getAllRefinedSys(  );
            end
        end

        function removeDeadLogic( obj, sysH )
            if ~isempty( obj.sc.deadLogicData )
                obj.sc.deadLogicData.remove( sysH );
            end
        end

        function s = get.StartingPoint( obj )
            s = getReturn( obj.start, 'StartingPoint', obj.modelH );
        end
        function e = get.ExclusionPoint( obj )
            e = getReturn( obj.exclude, 'ExclusionPoint', obj.modelH );
        end
        function c = get.Constraint( obj )
            c = getReturn( obj.cnstrnt, 'Constraint', obj.modelH );
        end
        function t = get.SliceComponent( obj )
            t = getReturn( obj.slicesys, 'SliceSubSystem', obj.modelH );
        end
        function set.StartingPoint( obj, s )%#ok<INUSD>
            error( 'ModelSlicer:API:SetMethodNotAvailable',  ...
                getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:SetMethodNotAvailable',  ...
                'addStartingPoint', 'removeStartingPoint' ) ) )
        end
        function set.ExclusionPoint( obj, e )%#ok<INUSD>
            error( 'ModelSlicer:API:SetMethodNotAvailable',  ...
                getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:SetMethodNotAvailable',  ...
                'addExclusionPoint', 'removeExclusionPoint' ) ) )
        end
        function set.Constraint( obj, c )%#ok<INUSD>
            error( 'ModelSlicer:API:SetMethodNotAvailable',  ...
                getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:SetMethodNotAvailable',  ...
                'addConstraint', 'removeConstraint' ) ) )
        end
        function set.SliceComponent( obj, c )%#ok<INUSD>
            error( 'ModelSlicer:API:SetMethodNotAvailable',  ...
                getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:SetMethodNotAvailable',  ...
                'addSliceComponent', 'removeSliceComponent' ) ) )
        end
        function set.Color( obj, c )
            c = convertStringsToChars( c );
            if ischar( c ) && isKey( obj.preSetColorMap, lower( c ) )
                obj.Color = obj.preSetColorMap( lower( c ) );
            elseif isnumeric( c ) && numel( c ) == 3 && all( 0 <= c ) && all( c <= 1 )
                obj.Color = lower( c );
            else
                error( 'ModelSlicer:API:InvalidColorSpecified',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidColorSpecified' ) ) );
            end
            if obj.needSync
                obj.scSetColor( obj.Color );
            end
        end
        function set.Name( obj, n )
            n = convertStringsToChars( n );
            if ischar( n )
                obj.Name = n;
            else
                error( 'ModelSlicer:API:NamePropertyMustAString',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:NamePropertyMustAString' ) ) );
            end
            if obj.needSync
                obj.scSetName( obj.Name );
            end
        end
        function set.Description( obj, d )
            d = convertStringsToChars( d );
            if ischar( d )
                obj.Description = d;
            else
                error( 'ModelSlicer:API:NamePropertyMustAString',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:DescriptionPropertyMustAString' ) ) );
            end
            if obj.needSync
                scSetDescription( obj, d );
            end
        end
        function set.CoverageFile( obj, c )
            c = convertStringsToChars( c );
            if ischar( c )
                obj.CoverageFile = c;
            else
                error( 'ModelSlicer:API:NamePropertyMustAString',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:CoverageFilePropertyMustAString' ) ) );
            end
            if obj.needSync
                scCvFileName( obj, obj.CoverageFile );
            end
        end
        function set.UseTimeWindow( obj, c )
            if islogical( c )
                obj.UseTimeWindow = c;
            else
                error( 'ModelSlicer:API:NamePropertyMustALogical',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:UseTimeWindowType' ) ) );
            end
            if obj.needSync
                scSetUseCvd( obj, c );
            end
            if ~obj.UseTimeWindow
                obj.CoverageFile = '';%#ok<MCSUP>
            end
        end
        function set.DeadLogicFile( obj, c )
            if ischar( c )
                obj.DeadLogicFile = c;
            else
                error( 'ModelSlicer:API:NamePropertyMustAString',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:DeadLogicFilePropertyMustAString' ) ) );
            end
            if obj.needSync
                scDvFileName( obj, obj.DeadLogicFile );
            end
        end
        function set.UseDeadLogic( obj, c )
            if islogical( c )
                obj.UseDeadLogic = c;
            else
                error( 'ModelSlicer:API:NamePropertyMustALogical',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:UseDeadLogicType' ) ) );
            end
            if obj.needSync
                scSetUseDeadLogic( obj, c );
            end
            if ~obj.UseDeadLogic
                obj.DeadLogicFile = '';%#ok<MCSUP>
            end
        end
        function set.SignalPropagation( obj, sp )
            sp = convertStringsToChars( sp );

            if any( strcmpi( sp, { 'upstream', 'downstream', 'bidirectional' } ) )
                obj.SignalPropagation = sp;
            else
                error( 'ModelSlicer:API:InvalidSignalPropagation',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidSignalPropagationSpecified' ) ) );
            end
            if obj.needSync
                obj.scSetDirection( obj.SignalPropagation );
            end
        end
        function tstart = get.StartTime( obj )
            tstart = [  ];
            if obj.needSync
                if obj.internalSC.useCvd && isa( obj.internalSC.cvd, 'Coverage.CovData' )
                    tstart = obj.internalSC.cvd.getStartStopTime( obj.sc.modelSlicer );
                end
            end
        end
        function tstop = get.StopTime( obj )
            tstop = [  ];
            if obj.needSync
                if obj.internalSC.useCvd && isa( obj.internalSC.cvd, 'Coverage.CovData' )
                    [ ~, tstop ] = obj.internalSC.cvd.getStartStopTime( obj.sc.modelSlicer );
                end
            end
        end

        function m = get.mdlAndRefs( obj )
            if ~isempty( obj.sc ) && ~isempty( obj.sc.modelSlicer )
                m = obj.sc.modelSlicer.preCompileMdlAndRefs;
            else
                m = [  ];
            end
        end
    end
    methods ( Hidden )
        function setDefaultColor( obj, cfgNum )


            idx = mod( cfgNum, numel( obj.colorValueList ) ) + 1;
            obj.Color = obj.colorValueList{ idx };
        end
        function clearCvd( obj )


            if ~isempty( obj.sc )
                obj.sc.cvd = [  ];
            end
        end
        function clearDeadLogic( obj )


            if ~isempty( obj.sc )
                obj.sc.deadLogicData = [  ];
            end
        end
        function addCovConstraint( obj, item )
            try
                constrStruct = [  ];
                if obj.needSync
                    [ item, constrStruct ] = scAddCovConstraint( obj, item );
                end
                if ~isempty( item )
                    obj.cnstrnt = loc_addItem( 'Constraint', obj.cnstrnt,  ...
                        item, [  ], [  ], constrStruct );
                end
            catch mx
                throw( mx )
            end
        end
        function removeCovConstraint( obj, item )
            try
                removeItem( obj, 'Constraint', item );
            catch ex
                throw( ex )
            end
        end
    end
    methods ( Access = { ?SLSlicerAPI.SLSlicerOptions } )
        function applySliceCriterion( obj, sc )

            obj.modelH = sc.modelSlicer.modelH;
            obj.Name = sc.name;
            obj.Description = sc.description;
            switch lower( sc.direction )
                case 'back'
                    obj.SignalPropagation = 'upstream';
                case 'forward'
                    obj.SignalPropagation = 'downstream';
                otherwise
                    obj.SignalPropagation = 'bidirectional';
            end
            obj.Color = sc.colorValue;

            topModelName = get_param( sc.modelSlicer.modelH, 'Name' );
            nMainModelName = numel( topModelName );

            obj.start = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'StartingPoint', sc.getUserStarts );
            obj.exclude = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'ExclusionPoint', sc.getUserExclusions );

            if sc.constraints.Count > 0


                csrntMap = createStrippedMap( sc.constraints );
                obj.cnstrnt = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'Constraint', csrntMap );
            end
            if sc.covConstraints.Count > 0


                csrntMap = createStrippedMap( sc.covConstraints );
                covcnstrnt = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'Constraint', csrntMap );

                obj.cnstrnt = [ obj.cnstrnt, covcnstrnt ];
            end
            if ~isempty( sc.sliceSubSystemH )


                fullSubSysSID = Simulink.ID.getSID( sc.sliceSubSystemH );
                if strncmp( fullSubSysSID, topModelName, nMainModelName )
                    subSysSID = fullSubSysSID( nMainModelName + 1:end  );
                end
                obj.slicesys = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'SliceSubSystem', subSysSID );
            end
            obj.UseTimeWindow = sc.useCvd;
            obj.CoverageFile = sc.cvFileName;
            obj.UseDeadLogic = sc.useDeadLogic;
            obj.DeadLogicFile = sc.sldvFileName;
            sc.dirty = false;
            obj.internalSC = sc;

            function stripMap = createStrippedMap( origMap )
                cSIDs = origMap.keys;
                vals = origMap.values;
                newcSIDs = cell( size( cSIDs ) );
                for n = 1:length( cSIDs )
                    if strncmp( cSIDs{ n }, topModelName, nMainModelName )
                        newcSIDs{ n } = cSIDs{ n }( nMainModelName + 1:end  );
                    else
                        newcSIDs{ n } = cSIDs{ n };
                    end
                end
                stripMap = containers.Map( newcSIDs, vals );
            end
        end
    end
    methods ( Access = protected )
        function propgrp = getPropertyGroups( obj )

            if ~isscalar( obj )
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay( obj );
            else
                if obj.needSync && obj.internalSC.useCvd && isa( obj.internalSC.cvd, 'Coverage.CovData' )
                    propList = { 'Name', 'Description', 'Color', 'SignalPropagation',  ...
                        'StartingPoint', 'ExclusionPoint', 'Constraint', 'SliceComponent', 'UseTimeWindow',  ...
                        'CoverageFile', 'StartTime', 'StopTime' };
                else
                    propList = { 'Name', 'Description', 'Color', 'SignalPropagation',  ...
                        'StartingPoint', 'ExclusionPoint', 'Constraint', 'SliceComponent', 'UseTimeWindow',  ...
                        'CoverageFile', 'UseDeadLogic', 'DeadLogicFile' };
                end
                propgrp = matlab.mixin.util.PropertyGroup( propList );
            end
        end
    end

    methods ( Access = private )
        function updateSliceCriterion( obj, model )
            obj.internalSC = SLSlicerAPI.SLSlicerConfig.SLSlicerConfig2SliceCriteria( model, obj );
        end
        function yesno = needSync( obj )
            yesno = ~isempty( obj.modelH );
        end
        function out = scAddStartingPoint( obj, s, busElementPath )




            out = [  ];
            mex = {  };
            [ blkH, lineH ] = loc_filterSeeds( s );
            [ ~, msg ] = obj.internalSC.addStart( blkH );

            bidex1 = ismember( msg, { 'InvalidVirtualBlock', 'InactiveHandle' } );
            bidex2 = ismember( msg, { 'StartAddedAlready' } );
            bidex3 = ismember( msg, 'ExclusionCannotBeAddedAsStart' );
            if any( bidex1 )
                bH = blkH( bidex1 );
                for index = 1:length( sum( bidex1 ) )
                    mex{ end  + 1 } = slslicer.internal.DiagnosticsGenerator.getErrorForStartingPoint( bH );
                end
            end
            if any( bidex3 )
                bH = blkH( bidex3 );
                for index = 1:length( sum( bidex3 ) )
                    mex{ end  + 1 } = slslicer.internal.DiagnosticsGenerator.getErrorForStartingAndExclusionPoint( bH );
                end
            end

            out = [ out, blkH( ~bidex1 & ~bidex2 & ~bidex3 ) ];

            [ ~, msg ] = obj.internalSC.addStart( lineH, busElementPath );

            lidex1 = ismember( msg, { 'InvalidVirtualLine',  ...
                'ExclusionCannotBeAddedAsStart', 'InactiveHandle' } );
            lidex2 = ismember( msg, { 'StartAddedAlready' } );
            lidex3 = ismember( msg, 'ExclusionCannotBeAddedAsStart' );
            if any( lidex1 )
                lH = lineH( lidex1 );
                for index = 1:length( sum( lidex1 ) )
                    p = get( lH( index ), 'SrcPortHandle' );
                    mex{ end  + 1 } = slslicer.internal.DiagnosticsGenerator.getErrorForStartingPoint( p );
                end
            end
            if any( lidex3 )
                lH = lineH( lidex3 );
                for index = 1:length( sum( lidex3 ) )
                    p = get( lH( index ), 'SrcPortHandle' );
                    mex{ end  + 1 } = slslicer.internal.DiagnosticsGenerator.getErrorForStartingAndExclusionPoint( p );
                end
            end

            out = [ out, lineH( ~lidex1 & ~lidex2 & ~lidex3 ) ];

            if ~isempty( mex )
                for index = 1:length( mex )
                    modelslicerprivate( 'MessageHandler', 'warning',  ...
                        mex{ index }, getfullname( obj.modelH ) );
                end
            end

            obj.internalSC.dirty = true;
        end
        function out = scAddExclusionPoint( obj, s )
            out = [  ];
            ms = obj.internalSC.modelSlicer;
            blkH = loc_filterSeeds( s );

            allstarts = [ obj.StartingPoint.Handle ];
            idx = ismember( blkH, allstarts );
            if any( idx )
                error( 'ModelSlicer:API:ConflictStartsAndExclusions', getString( message( 'Sldv:ModelSlicer:Analysis:ConflictStartsAndExclusions' ) ) )
            end
            mex = {  };
            for i = 1:length( blkH )
                if ~obj.isCompiled || ms.isBlockValidTarget( blkH( i ) )
                    if obj.internalSC.addExclusion( blkH( i ) )
                        out( end  + 1 ) = blkH( i );%#ok<AGROW>
                    end
                else
                    mex{ end  + 1 } = slslicer.internal.DiagnosticsGenerator.getErrorForExclusionPoint( blkH );%#ok<AGROW>
                end
            end
            if ~isempty( mex )
                for i = 1:length( mex )
                    modelslicerprivate( 'MessageHandler', 'warning', mex{ i }, getfullname( obj.modelH ) );
                end
            end
            obj.internalSC.dirty = true;
        end
        function out = scAddConstraint( obj, s, p )
            out = [  ];
            blkH = loc_filterSeeds( s );

            for i = 1:length( blkH )
                blockType = get( blkH( i ), 'BlockType' );
                if any( strcmp( blockType, { 'Switch', 'MultiPortSwitch' } ) )
                    if obj.internalSC.addConstraint( blkH( i ), p{ i } )
                        out( end  + 1 ) = blkH( i );%#ok<AGROW>
                    end
                else
                    warning( 'ModelSlicer:API:InvalidConstraint',  ...
                        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidConstraintBlock', getfullname( blkH( i ) ) ) ) );
                end
            end
            obj.internalSC.dirty = true;
        end

        function [ out, constrStruct ] = scAddCovConstraint( obj, modelObjs )
            out = {  };
            constrStruct = {  };
            if isempty( modelObjs )
                return ;
            end
            obj.checkCoverage(  );
            sc = obj.sc;
            if isempty( sc.cvd )
                error( 'ModelSlicer:NoCoverage',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:NoCoverageDataFile' ) ) );
            end
            for i = 1:length( modelObjs )
                sfObj = modelObjs( i );
                [ yesno, sfObj ] = isSfObj( sfObj );
                Mex = obj.sc.validateStateflowConstraint( sfObj );
                if ~isempty( Mex )
                    modelslicerprivate( 'MessageHandler', 'warning', Mex, getfullname( obj.modelH ) );
                end
                if yesno
                    sid = Simulink.ID.getSID( sfObj );
                    valid = sc.addCovConstraint( sfObj );
                    if valid
                        if isempty( out )
                            out = { sid };
                            constrStruct = { sc.covConstraints( sid ) };
                        else
                            out{ end  + 1 } = sid;%#ok<AGROW>
                            constrStruct{ end  + 1 } = sc.covConstraints( sid );%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function scSetName( obj, n )
            obj.internalSC.name = n;
        end
        function scSetDescription( obj, d )
            obj.internalSC.description = d;
        end
        function scSetDirection( obj, d )
            switch lower( d )
                case 'upstream'
                    obj.internalSC.direction = 'Back';
                case 'downstream'
                    obj.internalSC.direction = 'Forward';
                otherwise
                    obj.internalSC.direction = 'Either';
            end
            obj.internalSC.dirty = true;
        end
        function scSetColor( obj, c )
            if isa( obj.internalSC, 'SliceCriterion' )
                obj.internalSC.setColor( '', c );
                obj.internalSC.updateColor(  );
                scfg = obj.internalCfg;
                if ~isempty( scfg.session )
                    if length( scfg.allDisplayed ) > 1
                        scfg.session.remove_overlap_rules(  );
                    end
                    scfg.addOverlapRules(  );
                end
            else
                obj.internalSC.colorValue = c;
            end
            obj.internalSC.dirty = true;
        end
        function scSetUseCvd( obj, u )
            obj.internalSC.useCvd = u;
            obj.internalSC.dirty = true;
        end
        function scCvFileName( obj, c )
            obj.internalSC.cvFileName = c;
            obj.internalSC.dirty = true;
        end
        function scDvFileName( obj, d )
            obj.internalSC.sldvFileName = d;
            obj.internalSC.dirty = true;
        end
        function scSetUseDeadLogic( obj, u )
            obj.internalSC.useDeadLogic = u;
            obj.internalSC.dirty = true;
        end
        function scSetSliceSubSystem( obj, s )
            sliceSubSystemH = get_param( s, 'Handle' );
            Transform.SubsystemSliceUtils.checkCompatibility( sliceSubSystemH );
            obj.internalSC.addSliceSubsystem( sliceSubSystemH );
        end
        function applySLMSStruct( obj, sc )
            obj.Name = sc.Name;
            obj.Description = sc.Description;
            switch lower( sc.Direction )
                case 'back'
                    obj.SignalPropagation = 'upstream';
                case 'forward'
                    obj.SignalPropagation = 'downstream';
                otherwise
                    obj.SignalPropagation = 'bidirectional';
            end
            obj.UseTimeWindow = sc.UseCvd;
            obj.CoverageFile = sc.CvFileName;
            obj.Color = sc.ColorValue;
            obj.start = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'StartingPoint', sc.Elements );
            obj.exclude = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'ExclusionPoint', sc.Exclusions );
            if ~isempty( sc.ConstraintKeys )
                constraints = containers.Map( sc.ConstraintKeys, sc.ConstraintValues );
                obj.cnstrnt = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'Constraint', constraints );
            end
            if ~isempty( sc.CovConstraintKeys )
                constraints = containers.Map( sc.CovConstraintKeys, sc.CovConstraintValues );
                covcnstrnt = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'Constraint', constraints );

                obj.cnstrnt = [ obj.cnstrnt, covcnstrnt ];
            end
            obj.slicesys = SLSlicerAPI.SLSlicerItem.SliceCriterionElem2SLSlicerItem( 'SliceSubSystem', sc.SliceSubsystem );
        end

        function yesno = isCompiled( obj )
            yesno = slslicer.internal.checkDesiredSimulationStatus( obj.modelH,  ...
                'isSimStatusPausedOrCompiled' );
        end

        function checkCoverage( obj )
            if obj.UseTimeWindow
                ms = obj.internalCfg.modelSlicer;
                origActiveVal = get_param( obj.modelH, 'ModelSlicerActive' );
                if ~origActiveVal
                    ms.setModelSlicerActive( ModelSlicer.UsingCovTool );
                    cleanupObj = onCleanup( @(  )ms.setModelSlicerActive( origActiveVal ) );
                end
                if ~isempty( obj.sc.cvd ) && isempty( obj.CoverageFile )


                    scfg = obj.internalCfg;
                    Coverage.saveCoverage( scfg );
                elseif isempty( obj.sc.cvd ) && isempty( obj.CoverageFile )
                    error( 'ModelSlicer:API:TimeWindowTrueButNoCovFile',  ...
                        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:TimeWindowTrueButNoCovFile' ) ) );
                elseif isempty( obj.sc.cvd )

                    obj.sc.cvd = Coverage.loadCoverage( obj.sc.cvFileName, obj.sc.modelSlicer.model );
                    obj.sc.modelSlicer.cvd = obj.sc.cvd;

                    if ~obj.sc.modelSlicer.hasValidCoverageData
                        error( 'ModelSlicer:StaleCoverage', getString( message( 'Sldv:ModelSlicer:gui:StaleCoverage' ) ) );
                    end
                    constraintStructs = obj.sc.covConstraints.values;
                    for i = 1:length( constraintStructs )
                        obj.sc.cvd.addConstraint( constraintStructs{ i } );
                    end
                elseif obj.sc.reloadForStaleCpyRefMdl(  )






                    obj.sc.cvd.refreshCvData( obj.sc.cvFileName, obj.sc.modelSlicer.model );
                    obj.sc.modelSlicer.cvd = obj.sc.cvd;
                end
            end
            if obj.UseDeadLogic
                if ~isempty( obj.DeadLogicFile ) && isempty( obj.sc.deadLogicData )
                    obj.sc.sldvFileName = obj.DeadLogicFile;
                end
                try
                    obj.sc.modelSlicer.deadLogicData = obj.sc.getDeadLogicData(  );
                catch mex
                    error( mex.identifier, mex.message );
                end
            end
        end
        function removeItem( obj, seedType, x, varargin )



            if nargin > 3
                busElementPath = varargin{ 1 };
            else
                busElementPath = {  };
            end

            if isempty( x )
                error( 'ModelSlicer:API:InvalidRemoval',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemoval', [ 'remove', seedType ] ) ) );
            end

            thisSeed = obj.( seedType );
            nSeeds = numel( thisSeed );
            if nSeeds == 0
                error( 'ModelSlicer:API:NoSeedAvailable',  ...
                    getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:NoSeedAvailable', seedType ) ) );
            end

            item = parseInput( seedType, x, [  ] );

            delIdx = [  ];
            for p = 1:length( item )
                in = item{ p };
                if isnumeric( in )
                    if mod( in, 1 ) == 0 && in > 0 && in <= nSeeds

                        delIdx( end  + 1 ) = in;%#ok<AGROW>
                        if strcmp( seedType, 'StartingPoint' )
                            busElementPath = obj.start( in ).BusElementPath;
                        end
                    elseif in <= 0

                        error( 'ModelSlicer:API:InvalidIndex',  ...
                            getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidIdx' ) ) );
                    else
                        delIdx = [ delIdx, getExistingItemIdx( in ) ];%#ok<AGROW>
                    end
                elseif isa( in, 'Stateflow.Object' )
                    delIdx( end  + 1 ) = getExistingItemIdx( in );%#ok<AGROW>
                elseif ischar( in )
                    if strcmp( in, 'all' )
                        switch seedType
                            case 'StartingPoint'
                                obj.start = SLSlicerAPI.SLSlicerItem.empty(  );
                            case 'ExclusionPoint'
                                obj.exclude = SLSlicerAPI.SLSlicerItem.empty(  );
                            case 'Constraint'
                                obj.cnstrnt = SLSlicerAPI.SLSlicerItem.empty(  );
                        end
                        if obj.needSync
                            switch seedType
                                case 'StartingPoint'
                                    obj.sc.clearAllStartingPoints(  );
                                case 'ExclusionPoint'
                                    obj.sc.clearAllExclutionPoints(  );
                                case 'Constraint'
                                    obj.sc.clearAllConstraints(  );
                                    obj.sc.clearAllCovConstraints(  );
                            end
                        end
                        return ;
                    else

                        delIdx( end  + 1 ) = getExistingItemIdx( in );%#ok<AGROW>
                    end
                elseif isstruct( in ) && isfield( in, 'SID' )

                    delIdx( end  + 1 ) = getExistingItemIdx( in.SID );%#ok<AGROW>
                else
                    error( 'ModelSlicer:API:InvalidRemoval',  ...
                        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemoval', [ 'remove', seedType ] ) ) );
                end
            end

            if obj.needSync
                switch seedType
                    case 'StartingPoint'
                        obj.sc.deleteStart( delIdx );
                    case 'ExclusionPoint'
                        obj.sc.deleteExclusion( delIdx );
                    case 'Constraint'
                        for idx = delIdx
                            bh = Simulink.ID.getHandle( thisSeed( idx ).SID );


                            obj.sc.removeConstraint( bh );
                            obj.sc.removeCovConstraint( bh );
                        end
                end
            end
            switch seedType
                case 'StartingPoint'
                    obj.start( delIdx ) = [  ];
                case 'ExclusionPoint'
                    obj.exclude( delIdx ) = [  ];
                case 'Constraint'
                    obj.cnstrnt( delIdx ) = [  ];
            end
            function [ id, mexIfAttemptFails ] = attemptGetIdx( in )
                id = [  ];
                mexIfAttemptFails = MException( 'ModelSlicer:InvalidInput',  ...
                    getString(  ...
                    message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemoval',  ...
                    [ 'remove', seedType ] ) ) );

                portNumber = [  ];
                if isempty( Simulink.ID.checkSyntax( in ) )
                    thisSID = in;
                else
                    try
                        if isa( in, 'Stateflow.Object' )
                            thisSID = Simulink.ID.getSID( in );
                            stateFlowI8n = getString(  ...
                                message( 'Sldv:ModelSlicer:SLSlicerAPI:Stateflow' ) );
                            mexIfAttemptFails =  ...
                                MException( 'ModelSlicer:InvalidStateFlowInput',  ...
                                getString( message(  ...
                                'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemovalTargetted',  ...
                                stateFlowI8n, string( thisSID ), seedType ) ) );
                        elseif strcmp( get_param( in, 'type' ), 'block' )
                            thisSID = Simulink.ID.getSID( in );
                            blockI8n = getString(  ...
                                message( 'Sldv:ModelSlicer:SLSlicerAPI:Block' ) );
                            mexIfAttemptFails =  ...
                                MException( 'ModelSlicer:InvalidBlockInput',  ...
                                getString( message(  ...
                                'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemovalTargetted',  ...
                                blockI8n, string( in ), seedType ) ) );
                        elseif strcmp( get_param( in, 'type' ), 'line' )
                            portH = get_param( in, 'SrcPortHandle' );
                            thisSID = Simulink.ID.getSID( get( portH, 'ParentHandle' ) );
                            portNumber = get( portH, 'PortNumber' );
                            lineI8n = getString(  ...
                                message( 'Sldv:ModelSlicer:SLSlicerAPI:Line' ) );
                            mexIfAttemptFails =  ...
                                MException( 'ModelSlicer:InvalidLineInput',  ...
                                getString( message(  ...
                                'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemovalTargetted',  ...
                                lineI8n, string( in ), seedType ) ) );
                        elseif strcmp( get_param( in, 'type' ), 'port' )
                            thisSID = Simulink.ID.getSID( get( in, 'ParentHandle' ) );
                            portNumber = get( in, 'PortNumber' );
                            if isempty( busElementPath )
                                portI8n = getString(  ...
                                    message( 'Sldv:ModelSlicer:SLSlicerAPI:Port' ) );
                                mexIfAttemptFails =  ...
                                    MException( 'ModelSlicer:InvalidPortInput',  ...
                                    getString( message(  ...
                                    'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemovalTargetted',  ...
                                    portI8n, string( in ), seedType ) ) );
                            else
                                busElementI8n = getString(  ...
                                    message( 'Sldv:ModelSlicer:SLSlicerAPI:BusElement' ) );
                                mexIfAttemptFails =  ...
                                    MException( 'ModelSlicer:InvalidBusElementInput',  ...
                                    getString( message(  ...
                                    'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemovalTargetted',  ...
                                    busElementI8n, strcat( string( in ), ":", busElementPath ),  ...
                                    seedType ) ) );
                            end
                        else
                            thisSID = Simulink.ID.getSID( in );
                        end
                    catch mx
                        if ischar( in )

                            sfObj = getSfObjFromPath( in );
                            thisSID = Simulink.ID.getSID( sfObj );
                            stateFlowI8n = getString(  ...
                                message( 'Sldv:ModelSlicer:SLSlicerAPI:Stateflow' ) );
                            mexIfAttemptFails =  ...
                                MException( 'ModelSlicer:InvalidStateFlowInput',  ...
                                getString( message(  ...
                                'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemovalTargetted',  ...
                                stateFlowI8n, string( in ), seedType ) ) );
                        else
                            rethrow( mx )
                        end
                    end
                end
                for m = 1:length( thisSeed )


                    if strcmp( thisSID, thisSeed( m ).SID )

                        if ~isfield( thisSeed( m ), 'Port' )
                            id = m;
                            break ;







                        elseif ~isempty( busElementPath )
                            if isfield( thisSeed( m ), 'BusElementPath' )
                                prefixToCheck = busElementPath + ".";
                                yesno = isequal( busElementPath,  ...
                                    thisSeed( m ).BusElementPath ) ||  ...
                                    startsWith( thisSeed( m ).BusElementPath,  ...
                                    prefixToCheck );
                                if yesno
                                    id = [ id, m ];
                                end
                            end



                        elseif ( isempty( portNumber ) ||  ...
                                thisSeed( m ).Port == portNumber ) &&  ...
                                ~isfield( thisSeed( m ), 'BusElementPath' )
                            id = m;
                            break ;
                        end
                    end
                end
            end

            function idx = getExistingItemIdx( in )
                idx = [  ];
                try
                    [ idx, mexIfAttemptFails ] = attemptGetIdx( in );
                catch mx %#ok<NASGU>
                    mexIfAttemptFails = MException( 'ModelSlicer:InvalidInput',  ...
                        getString(  ...
                        message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedRemoval',  ...
                        [ 'remove', seedType ] ) ) );
                    throwDiagnostics( mexIfAttemptFails );
                    return ;
                end

                if isempty( idx )
                    throwDiagnostics( mexIfAttemptFails );
                end

                function throwDiagnostics( mexIfAttemptFails )
                    if isnumeric( in ) && mod( in, 1 ) == 0

                        if in > nSeeds
                            mexIfAttemptFails = MException( 'ModelSlicer:API:InvalidIndex',  ...
                                getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidConfigIdx', nSeeds ) ) );
                        end
                    end
                    throw( mexIfAttemptFails );
                end
            end
        end
    end
    methods ( Access = { ?SLSlicerAPI.SLSlicerOptions } )
        function out = sc( obj )

            out = obj.internalSC;
        end
        function assignSliceCriterion( obj, sc, scfg )
            obj.modelH = scfg.modelH;
            obj.internalSC = sc;
            obj.internalCfg = scfg;
        end
        function validateSeeds( obj, modelName, msObj )
            for nCfg = 1:length( obj )

                invalidStart = validateSeeds( obj( nCfg ).start, modelName, msObj, obj( nCfg ).internalSC );
                if ~isempty( invalidStart )


                    obj( nCfg ).start( invalidStart ) = [  ];

                end
                invalidExclude = validateSeeds( obj( nCfg ).exclude, modelName, msObj );
                if ~isempty( invalidExclude )
                    obj( nCfg ).removeExclusionPoint( invalidExclude );
                end
                invalidConstr = validateSeeds( obj( nCfg ).cnstrnt, modelName, msObj );
                if ~isempty( invalidConstr )
                    obj( nCfg ).removeConstraint( invalidConstr );
                end
                invalidSubSys = validateSeeds( obj( nCfg ).slicesys, modelName, msObj );
                if ~isempty( invalidSubSys )
                    obj( nCfg ).removeSliceComponent( invalidSubSys );
                end
            end
        end
    end

    methods ( Static, Hidden )
        function slcfg = SliceCriteria2SLSlicerConfig( sc )
            slcfg = SLSlicerAPI.SLSlicerConfig(  );
            slcfg.applySliceCriterion( sc );
        end

        function sc = SLSlicerConfig2SliceCriteria( model, slcfg )
            for i = 1:length( slcfg )
                ms = slslicer.internal.createModelSlicer(  );
                ms.modelH = get_param( model, 'Handle' );
                sc = SliceCriterion( ms );
                cf = slcfg( i );
                sc.name = cf.Name;
                sc.description = cf.Description;
                switch lower( cf.SignalPropagation )
                    case 'upstream'
                        sc.direction = 'Back';
                    case 'downstream'
                        sc.direction = 'Forward';
                    otherwise
                        sc.direction = 'Either';
                end
                sc.colorValue = cf.Color;
                sc.useCvd = cf.UseTimeWindow;
                sc.cvFileName = cf.CoverageFile;

                sc.useDeadLogic = cf.UseDeadLogic;
                sc.sldvFileName = cf.DeadLogicFile;




                SLSlicerAPI.SLSlicerItem.SLSlicerItem2SliceCriterionElem( 'StartingPoint', cf.start, sc );
                SLSlicerAPI.SLSlicerItem.SLSlicerItem2SliceCriterionElem( 'ExclusionPoint', cf.exclude, sc );
                sc.constraints = SLSlicerAPI.SLSlicerItem.SLSlicerItem2SliceCriterionElem( 'Constraint', cf.cnstrnt );

                sc.covConstraints = SLSlicerAPI.SLSlicerItem.SLSlicerItem2SliceCriterionElem( 'CovConstraint', cf.cnstrnt );
                sc.sliceSubSystemH = SLSlicerAPI.SLSlicerItem.SLSlicerItem2SliceCriterionElem( 'SliceSubSystem', cf.slicesys );
            end
        end
    end
end


function out = loc_addItem( seedType, existingPoints,  ...
    s, dataPorts, busElementPath, varargin )
out = SLSlicerAPI.SLSlicerItem(  ).empty(  );

[ item, dp ] = parseInput( seedType, s, dataPorts );

if nargin > 5 && ~isempty( varargin{ 1 } )
    constrStruct = varargin{ 1 };
else
    constrStruct = cell( 1, numel( item ) );
end

for i = 1:length( item )
    stp = loc_addSingleItem( seedType, item{ i }, dp{ i },  ...
        busElementPath, constrStruct{ i } );
    if ~isempty( stp )
        if isempty( out )
            out = stp;
        else
            out( end  + 1 ) = stp;%#ok<AGROW>
        end
    end
end
if ~isempty( existingPoints )
    out = [ existingPoints, out ];
end

    function o = loc_addSingleItem( t, b, d, busElementPath, cstruct )
        o = SLSlicerAPI.SLSlicerItem(  );
        isBySID = false;
        if ischar( b ) && contains( b, ':' )
            o.SID = b;
            isBySID = true;
        else
            try
                if ischar( b )
                    get_param( b, 'type' );
                end
            catch Mx

                b = getSfObjFromPath( b );
            end
            if isa( b, 'Stateflow.Object' ) || strcmp( get_param( b, 'type' ), 'block' )
                o.SID = Simulink.ID.getSID( b );
            end
        end
        o.SeedType = t;
        o.DataPorts = d;
        try

            if strcmp( t, 'StartingPoint' ) ...
                    && ~isBySID
                if strcmp( get_param( b, 'type' ), 'line' )
                    portH = get_param( b, 'SrcPortHandle' );
                    o.SID = Simulink.ID.getSID( get( portH, 'ParentHandle' ) );
                    o.DataPorts = get( portH, 'PortNumber' );
                elseif strcmp( get_param( b, 'type' ), 'port' )
                    o.SID = Simulink.ID.getSID( get( b, 'ParentHandle' ) );
                    o.DataPorts = get( b, 'PortNumber' );
                    o.BusElementPath = busElementPath;
                end
            elseif ~isempty( cstruct )
                o.CovConstraintStruct = cstruct;
            end
        catch
            o = SLSlicerAPI.SLSlicerItem(  ).empty(  );
        end
        if isempty( o.SID )
            o = SLSlicerAPI.SLSlicerItem(  ).empty(  );
        end
    end
end

function [ item, dp ] = parseInput( seedType, s, dataPorts )
if ischar( s )
    item{ 1 } = s;
    dp{ 1 } = dataPorts;
elseif isnumeric( s )
    item = num2cell( s );
    if isempty( dataPorts )
        dp = cell( 1, numel( s ) );
    else
        dp = dataPorts;
    end
elseif iscell( s )
    item = s;
    if isempty( dataPorts )
        dp = cell( 1, numel( s ) );
    else
        dp = dataPorts;
    end
elseif isstruct( s )
    if isfield( s, 'SID' )
        item = { s.SID };
    else
        error( 'ModelSlicer:API:UnknownSLSlicerItem', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:UnknownTypeForAddItem', seedType ) ) );
    end
    if isfield( s, 'Port' )
        dp = { s.Port };
    else
        dp = cell( 1, numel( s ) );
    end
elseif isa( s, 'Stateflow.Object' )
    item = arrayfun( @( o ){ o }, s );
    dp = cell( 1, numel( s ) );
else
    error( 'ModelSlicer:API:UnknownSLSlicerItem', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:UnknownTypeForAddItem', seedType ) ) );
end

if strcmp( seedType, 'Constraint' )
    if numel( item ) ~= numel( dp ) || ~iscell( dp )
        error( 'ModelSlicer:API:InvalidDataPorts', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:DataPortsNeedsCellArrays' ) ) )
    end
elseif strcmp( seedType, 'SliceSubSystem' )
    if numel( item ) ~= 1
        error( 'ModelSlicer:API:InvalidSubsystem', getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:SliceSubSystemASingleSystem' ) ) )
    end
end
end
function [ blkH, lineH ] = loc_filterSeeds( s )
if ischar( s )
    seed = get_param( s, 'Handle' );
elseif iscell( s )
    seed = cellfun( @( x )get_param( x, 'Handle' ), s );
else
    seed = arrayfun( @( x )get_param( x, 'Handle' ), s );
end


seed = seed( seed > 0 );
filt = arrayfun( @( x )strcmp( get( x, 'Type' ), 'block' ), seed );
blkH = seed( filt );
if nargout == 2

    filt2 = arrayfun( @( x )strcmp( get( x, 'Type' ), 'line' ) ...
        || strcmp( get( x, 'Type' ), 'port' ), seed );
    lineH = seed( filt2 );
end
end
function bh = getBlockHandles( sc )

allelements = sc.getUserStarts(  );
blocks = arrayfun( @( x )strcmp( allelements( x ).Type, 'block' ),  ...
    1:numel( allelements ) );
bh = [ allelements( blocks ).Handle ];
bh = reshape( bh, numel( bh ), 1 );
end
function ph = getSignalHandles( sc )

allelements = sc.getUserStarts(  );
sigs = arrayfun( @( x )strcmp( allelements( x ).Type, 'signal' ),  ...
    1:numel( allelements ) );
bh = [ allelements( sigs ).Handle ];
ph = reshape( bh, numel( bh ), 1 );
end

function sfObj = getSfObjFromPath( spath )
str = strsplit( spath, '/' );
name = str{ end  };
path = strjoin( str( 1:end  - 1 ), '/' );
rt = sfroot;
sfObj = rt.find( '-isa', 'Stateflow.Object', 'Path', path,  ...
    'Name', name );
end

function [ sfObjs, remObjs, idx ] = filterSfObj( elemList )
sfObjs = [  ];
idx = false( length( elemList ), 1 );
for i = 1:length( elemList )
    e = elemList( i );
    if isSfObj( e )
        sfObjs{ end  + 1 } = e;%#ok<AGROW>
        idx( i ) = true;
    end
end
remObjs = elemList( ~idx );
end

function [ yesno, sfObj ] = isSfObj( sfObj )
yesno = false;
try
    if iscell( sfObj )
        sfObj = sfObj{ 1 };
    end
    if isnumeric( sfObj )
        try


            get_param( sfObj, 'type' );
            sfObj = [  ];
            return ;
        catch
        end
        sfObj = idToHandle( sfroot, sfObj );
    elseif ischar( sfObj )
        if contains( sfObj, ':' )

            sfObj = Simulink.ID.getHandle( sfObj );
        else

            sfObj = getSfObjFromPath( sfObj );
        end
    elseif isstruct( sfObj ) && isfield( sfObj, 'SID' )
        sfObj = Simulink.ID.getHandle( sfObj.SID );
    end
    if ~isa( sfObj, 'Stateflow.Object' )
        sfObj = [  ];
    else
        yesno = true;
    end
catch
    sfObj = [  ];
end
end

function yesno = isValidWindow( startTime, stopTime )
yesno = ( isnumeric( startTime ) && isfinite( startTime ) ) &&  ...
    ( isnumeric( stopTime ) && isfinite( stopTime ) ) &&  ...
    ( startTime <= stopTime );
end


function status = validateBusElement( item, busElementPath )
status = false;
item = get_param( item, 'Handle' );
try

    if ~strcmp( get( item, 'Type' ), 'port' )
        return ;
    end


    signalNames = strsplit( busElementPath, '.' );


    signalHierarchy = get( item, 'SignalHierarchy' );


    signalDepth = length( signalNames );



    currentSignalDepthCount = 1;

    while ( currentSignalDepthCount <= signalDepth )
        curSignalName = signalNames( currentSignalDepthCount );
        numChildren = length( signalHierarchy.Children );


        matchFound = false;
        for i = 1:numChildren
            childSignal = signalHierarchy.Children( i );
            if strcmp( curSignalName( 1 ), childSignal.SignalName )
                matchFound = true;
                signalHierarchy = childSignal;
                break ;
            end
        end


        if ~matchFound
            return ;
        end

        currentSignalDepthCount =  ...
            currentSignalDepthCount + 1;
    end


    status = true;
catch
end
end



function modelElements = filterValidModelElements(  ...
    allMdls, items, busElementPath )

arguments
    allMdls
    items
    busElementPath = [  ]
end

modelElements = [  ];

if ~isempty( busElementPath )
    status = validateBusElement( items, busElementPath );
    if ~status
        warning( 'ModelSlicer:API:InvalidInput',  ...
            getString( message(  ...
            'Sldv:ModelSlicer:SLSlicerAPI:InvalidInputIsSpecified' ) ) );
        return ;
    end
end



if isempty( allMdls )
    modelElements = items;
    return ;
end


if isempty( items )
    warning( 'ModelSlicer:API:InvalidEmptyInput',  ...
        getString( message( 'Sldv:ModelSlicer:SLSlicerAPI:InvalidInputIsSpecifiedEmpty' ) ) );
    return ;
end


if ischar( items )
    items = { items };
end

isCell = iscell( items );
numOfItems = length( items );

for itemIndex = 1:numOfItems

    if isCell
        seed = items{ itemIndex };
    else
        seed = items( itemIndex );
    end

    try

        [ isStateflow, sfObj ] = isSfObj( seed );


        if isStateflow
            sid = Simulink.ID.getSID( sfObj );
            splitNames = strsplit( sid, ':' );
        else
            fullName = getfullname( seed );
            splitNames = strsplit( fullName, '/' );
        end


        modelName = splitNames{ 1 };

    catch


        warnAboutInvalidInput(  );
        continue ;
    end


    if ~any( ismember( allMdls, modelName ) )
        warnAboutInvalidInput(  );
    else
        if numOfItems == 1
            modelElements = seed;
        elseif isCell
            modelElements{ end  + 1 } = seed;
        else
            modelElements( end  + 1 ) = seed;
        end
    end
end

    function warnAboutInvalidInput(  )
        if numOfItems == 1
            warning( 'ModelSlicer:API:InvalidInput',  ...
                getString( message(  ...
                'Sldv:ModelSlicer:SLSlicerAPI:InvalidInputIsSpecified' ) ) );
        else
            warning( 'ModelSlicer:API:InvalidInputIndexed',  ...
                getString( message(  ...
                'Sldv:ModelSlicer:SLSlicerAPI:InvalidInputIsSpecifiedIndexed',  ...
                num2str( itemIndex ) ) ) );
        end
    end
end
