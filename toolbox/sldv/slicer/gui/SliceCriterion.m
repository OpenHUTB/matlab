





classdef SliceCriterion < handle
    properties


        name = 'untitled';
        description = '';
        direction = 'Back';



        constraints


        covConstraints

        useCvd = false;
        cvd = [  ]
        cvFileName = ''
        cvFileNameOld = ''


        useDeadLogic = false;
        deadLogicData = [  ]
        sldvFileName = ''

        modelSlicer
        session

        colorName = 'Cyan';
        colorValue = [ 0, 1, 1 ];
        visible = true;
        dirty = false;


        sliceSubSystemH = [  ];


        isInEditableHighlight = false;



        openConstraintDialog = [  ];

        startingPoints = [  ];
        dependencies = [  ];
        exclusionPoints = [  ];
        stateConstraints = [  ];
        stateflowElems = struct( 'activeIds', [  ], 'subChartStruct', [  ] );

        hiliteElems = containers.Map( 'keytype', 'char', 'valuetype', 'any' );



        activeBlocks = [  ];
        allActiveBlocks = [  ];
        allNonVirtualBlocks = [  ];
        allLineHandles = [  ];
        overlay = [  ];

        showLabels = true;
        showCtrlDep = false;
        portsToLabel = [  ];
        currentPortsLabelled = [  ];
        seedHandler
    end


    properties ( SetAccess = private, GetAccess = public, Hidden = true )

        sdiViewObj = [  ];
        sdiLoggingPointsAdded = [  ];
        sdiLoggingPointsAll = [  ];



        tag = 'UserGenerated';
    end


    methods ( Access = public )





        function [ elements, invalidHandle ] = getUserStarts( this )
            [ elements, invalidHandle ] = this.seedHandler.getUserStarts(  );
        end



        function [ elements, invalidHandle ] = getUserExclusions( this )
            [ elements, invalidHandle ] = this.seedHandler.getUserExclusions(  );
        end


        function bh = getVirtualStarts( this )
            bh = this.seedHandler.getVirtualStarts( this );
        end



        function rgb = start_color( this )
            hlHsv = rgb2hsv( this.colorValue );
            rgb = hsv2rgb( [ hlHsv( 1 ), 0.5, 0.9 ] );
        end


        function rgb = exclusion_color( this )
            hlHsv = rgb2hsv( this.colorValue );

            hue = hlHsv( 1 ) + 0.5;
            if hue > 1.0
                hue = hue - 1.0;
            end
            rgb = hsv2rgb( [ hue, 0.5, 0.9 ] );
        end
    end



    methods ( Access = public )


        function out = getExclusionBlks( this )
            out = this.seedHandler.getExclusionBlks;
        end


        function out = getExclusionSigs( this )%#ok<MANU>

            out = [  ];
        end


        function out = getConstraintBlks( this )
            out = this.constraints.keys;
        end


        function [ status, mex ] = updateUserStartsFromStruct( this, elements )
            [ status, mex ] = this.seedHandler.updateUserStartsFromStruct( elements, this );
        end


        function [ validelements, invalidelements ] = updateUserExclusionsFromStruct( this, exelements )
            [ validelements, invalidelements ] = this.seedHandler.updateUserExclusionsFromStruct( exelements, this );
        end



        function this = SliceCriterion( ms, varargin )
            this.constraints = containers.Map( 'KeyType', 'char',  ...
                'ValueType', 'any' );
            this.covConstraints = containers.Map( 'KeyType', 'char',  ...
                'ValueType', 'any' );
            this.useCvd = false;
            this.cvd = [  ];
            this.modelSlicer = ms;

            if ~isempty( varargin )
                this.tag = varargin{ 1 };
            end

            this.seedHandler = slslicer.internal.SeedHandler(  );
        end


        function that = clone( this )
            that = SliceCriterion( this.modelSlicer, this.tag );

            that.seedHandler = this.seedHandler.clone(  );

            if this.constraints.length == 0
                that.constraints = containers.Map( 'KeyType', 'char',  ...
                    'ValueType', 'any' );
            else
                that.constraints = containers.Map( this.constraints.keys,  ...
                    this.constraints.values );
            end

            if this.covConstraints.length == 0
                that.covConstraints = containers.Map( 'KeyType', 'char',  ...
                    'ValueType', 'any' );
            else
                that.covConstraints = containers.Map( this.covConstraints.keys,  ...
                    this.covConstraints.values );
            end

            that.description = this.description;
            that.direction = this.direction;

            that.useCvd = this.useCvd;
            if ~isempty( this.cvd ) && isa( this.cvd, 'Coverage.CovData' )
                that.cvd = copy( this.cvd );
            end
            that.cvFileName = this.cvFileName;
            that.name = this.name;

            that.colorName = this.colorName;
            that.colorValue = this.colorValue;
            that.visible = this.visible;
        end




        function refresh( this )
            sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok<NASGU>

            dlg = this.modelSlicer.dlg;
            scfg = SlicerConfiguration.getConfiguration( this.modelSlicer.modelH );
            if ~isempty( this.getUserStarts(  ) )
                try
                    this.modelSlicer.checkOutLicense(  );
                catch Mex


                    this.handleLicenseCheckOutFailure(  );


                    modelslicerprivate( 'MessageHandler',  ...
                        'single_error',  ...
                        Mex, this.modelSlicer.model, this.hasDialog );

                    return ;
                end
            end


            this.modelSlicer.hasError = false;
            scfg.forceManualRefresh = false;

            if ~this.useCvd
                this.clearAllCovConstraints(  );
            end

            if ~this.dirty && ~isempty( this.overlay )

                try
                    this.restoreHighlightCompileTimeCache(  );
                    this.modelSlicer.refreshSdiView(  );
                    return ;
                catch err %#ok<NASGU>

                end
            end

            this.modelSlicer.enableSdiSlicerController( false );
            if this.hasDialog

                dlgSrc = dlg.getSource;
                dlgSrc.Busy = true;
                dlg.refresh;
            end

            this.computeDependencies(  );

            if isempty( this.overlay )
                this.highlightInEditor(  );
            else
                this.modelSlicer.session.remove_atomicChart_overlap(  );
                this.overlay.updateDisplayItems( this );
                this.overlay.addToEditor( ~scfg.usingMultiCriteriaCommonOverlap );
                this.modelSlicer.session.add_atomicChart_overlap(  );
            end

            this.dirty = false;

            this.revertToDefaultSlicerDialog( scfg );


            if ~isempty( this.modelSlicer.session.notifier )
                this.modelSlicer.session.notifier.update(  );
            end

            scfg.refreshPortValueLabels(  );
            this.modelSlicer.refreshSdiView(  );
            this.modelSlicer.enableSdiSlicerController( ~isempty( this.cvd ) );
        end


        function [ invalidblock, invalidline ] = validateStarts( this )
            [ invalidblock, invalidline ] = this.seedHandler.validateStarts( this );
        end


        function computeDependencies( this )
            dlg = this.modelSlicer.dlg;


            slslicer.internal.DependencyHandler.resetDependencies( this );

            try


                this.modelSlicer.configureAnalysisDirection( this );





                [ invalidStartBH, invalidStartLH ] = this.validateStarts(  );
                [ ~, invalidBH ] = this.getStartBlockHandles;

                [ hasValidStarts, invalidBlk, invalidSig ] = this.modelSlicer.configureAnalysisSeeds( this );

                if ~isempty( [ invalidBlk, invalidStartBH, invalidBH ] ) || ~isempty( [ invalidSig, invalidStartLH ] )

                    this.seedHandler.handleInvalidStartingPoints( this, [ invalidBlk, invalidStartBH, invalidBH ], [ invalidSig, invalidStartLH ] );
                    if ~this.seedHandler.hasValidStarts( this )
                        return ;
                    end
                end

                if this.hasDialog
                    dlg.setWidgetValue( 'DialogStatusText',  ...
                        getString( message( 'Sldv:ModelSlicer:ModelSlicer:ComputingElementsHighlight' ) ) )
                end

                if isequal( hasValidStarts, true )
                    if ~this.useCvd || ( isempty( this.cvFileName ) && isempty( this.cvd ) )
                        this.modelSlicer.configureDeadLogicData( this );
                    else
                        this.modelSlicer.configureCoverageData( this );
                        this.createSdiViewIfNeeded(  );
                        [ validCovData, loadCovMex ] = this.loadCoverageData(  );
                        if ~isempty( loadCovMex ) || ~validCovData
                            this.removeSdiView;
                        end
                    end

                    [ s, b ] = this.modelSlicer.analyse;
                    this.allActiveBlocks = b;
                else
                    s = [  ];
                    b = [  ];
                end


                if ~isempty( this.cvd )
                    simStatus = get_param( this.modelSlicer.modelH, 'SimulationStatus' );
                    modelStartTime = str2double( get_param( this.modelSlicer.modelH, 'StartTime' ) );
                    [ startTime, stopTime ] = this.cvd.getStartStopTime(  );
                    isFastRestartEnabled = strcmp( get_param( this.modelSlicer.modelH, 'FastRestart' ), 'on' );
                    this.modelSlicer.notify( 'eventModelSlicerTimeWindowSet',  ...
                        SlicerEvtData( [ modelStartTime, startTime,  ...
                        stopTime, { simStatus }, isFastRestartEnabled ] ) );
                end

                if ~isempty( this.modelSlicer.atomicGroups )
                    slslicer.internal.DependencyHandler.setActiveAndNVBlks( this, b );
                end


                this.partitionElements( s, b );

            catch ex



                if ~isempty( this.overlay )
                    this.overlay.removeFromEditor(  );
                end

                if this.modelSlicer.compiled
                    this.isInEditableHighlight = true;
                    this.modelSlicer.hasError = true;
                    this.modelSlicer.terminateModel;
                end
                if this.hasDialog


                    if strcmp( ex.identifier, 'ModelSlicer:Compatibility:Incompatible' )

                        Mex = ex;
                    else
                        Mex = MException( 'ModelSlicer:FailedHighlightMV',  ...
                            getString( message( 'Sldv:ModelSlicer:gui:FailedHighlightMV' ) ) );
                        Mex = Mex.addCause( ex );
                    end
                    modelslicerprivate( 'MessageHandler', 'error', Mex );
                    try
                        scfg.storeConfiguration(  );
                    catch exx %#ok<NASGU>

                    end
                    dlg.setWidgetValue( 'DialogStatusText',  ...
                        getString( message( 'Sldv:ModelSlicer:gui:FailedHighlight' ) ) );
                    dlg.refresh;
                    modelslicerprivate( 'MessageHandler', 'close' )
                else

                    throw( ex )
                end
            end
        end


        function removeSdiView( this )
            delete( this.sdiViewObj );
            this.sdiViewObj = [  ];
        end


        function [ validCovData, loadCovMex ] = loadCoverageData( this )
            loadCovMex = [  ];
            if isempty( this.cvd )
                try
                    this.cvd = Coverage.loadCoverage( this.cvFileName, this.modelSlicer.model );
                    this.sdiViewObj.extractSessionFromSlicexFile(  );
                    constraintStructs = this.covConstraints.values;
                    for i = 1:length( constraintStructs )
                        this.cvd.addConstraint( constraintStructs{ i } );
                    end
                catch loadCovMex
                end
            elseif this.reloadForStaleCpyRefMdl(  )




                try
                    this.cvd.refreshCvData( this.cvFileName, this.modelSlicer.model );
                catch loadCovMex
                end
            end
            validCovData = this.modelSlicer.hasValidCoverageData;



            if ~isempty( loadCovMex ) || ~validCovData
                modelslicerprivate( 'MessageHandler', 'open', this.modelSlicer.model )
                Mex = MException( 'ModelSlicer:FailedToApplyTimeWindow', getString( message( 'Sldv:ModelSlicer:gui:FailedToApplyTimeWindow' ) ) );
                if ~isempty( loadCovMex )
                    Mex = Mex.addCause( loadCovMex );
                end
                modelslicerprivate( 'MessageHandler', 'warning', Mex, this.modelSlicer.model )
                this.useCvd = false;
                this.cvd = [  ];
                this.modelSlicer.cvd = [  ];
                this.cvFileName = '';
            end
        end




        function [ status, msg ] = addStart( this, varargin )
            if nargin == 2
                [ status, msg ] = this.seedHandler.addStart( this,  ...
                    varargin{ 1 }, [  ] );
            else
                [ status, msg ] = this.seedHandler.addStart( this,  ...
                    varargin{ 1 }, varargin{ 2 } );
            end
        end


        function yesno = addExclusion( this, blockHandle )
            yesno = this.seedHandler.addExclusion( blockHandle, this );
        end


        function yesno = addConstraint( this, blockHandle, portNumbers )
            yesno = this.seedHandler.addConstraint( blockHandle, portNumbers, this );
        end


        function changed = removeStart( this, objH )
            changed = this.seedHandler.removeStart( objH, this );
        end


        function removeAllBusElementStarts( this, objH )
            this.seedHandler.removeAllBusElementStarts( objH, this );
        end


        function changed = removeExclusion( this, objH )
            changed = this.seedHandler.removeExclusion( objH, this );
        end


        function changed = removeConstraint( this, blockHandle )
            changed = this.seedHandler.removeConstraint( blockHandle, this );
        end


        function clearAllCovConstraints( this )
            this.covConstraints.remove( this.covConstraints.keys );
            if ~isempty( this.cvd )
                this.cvd.clearAllConstraints;
            end
            this.dirty = true;
        end


        function changed = removeCovConstraint( this, modelObj )
            changed = false;
            sid = Simulink.ID.getSID( modelObj );
            if isKey( this.covConstraints, sid ) && ~isempty( this.cvd )
                covConstraintStruct = this.covConstraints( sid );
                this.covConstraints.remove( sid );
                this.cvd.removeConstraint( covConstraintStruct )
                changed = true;
                this.dirty = true;
            end
        end


        function Mex = validateStateflowConstraint( this, modelObj )
            Mex = [  ];
            sid = Simulink.ID.getSID( modelObj );
            if isempty( this.cvd )
                Mex = MException( 'ModelSlicer:NoCoverage',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:NoCoverageDataFile' ) ) );
            elseif ~( isa( modelObj, 'Stateflow.State' ) ||  ...
                    isa( modelObj, 'Stateflow.AtomicSubchart' ) ||  ...
                    isa( modelObj, 'Stateflow.Transition' ) )

                Mex = MException( 'ModelSlicer:UnsupCov',  ...
                    getString( message( 'Sldv:ModelSlicer:Coverage:NonSFCovConstraint' ) ) );
            elseif isKey( this.covConstraints, sid )

                Mex = MException( 'ModelSlicer:AlreadyHasConstraint',  ...
                    getString( message( 'Sldv:ModelSlicer:Coverage:AlreadyHasConstraint' ) ) );
            end
        end

        function valid = addCovConstraint( this, modelObj )
            valid = false;
            sid = Simulink.ID.getSID( modelObj );
            Mex = this.validateStateflowConstraint( modelObj );
            if ~isempty( Mex )
                modelslicerprivate( 'MessageHandler',  ...
                    'single_warning',  ...
                    Mex, this.modelSlicer.model, this.hasDialog );
                return ;
            end

            import slslicer.internal.*
            covConstraintStruct = timeWindowConstraintUtils.getConstraintStruct ...
                ( modelObj, this.cvd );
            if ~isempty( covConstraintStruct )
                this.covConstraints( sid ) = covConstraintStruct;
                isEmpty = this.cvd.addConstraint( covConstraintStruct );
                if isEmpty


                    Mex = MException( 'ModelSlicer:EmptyInterval',  ...
                        getString( message( 'Sldv:ModelSlicer:Coverage:EmptyDerivedInterval' ) ) );
                    modelslicerprivate( 'MessageHandler',  ...
                        'single_warning',  ...
                        Mex, this.modelSlicer.model, this.hasDialog );
                    this.cvd.removeConstraint( covConstraintStruct );
                    this.covConstraints.remove( sid );
                    return ;
                else
                    numIntervals = size( this.cvd.constraintTimeIntervals, 1 );
                    if this.hasDialog && numIntervals > 20
                        qStr = getString( message( 'Sldv:ModelSlicer:gui:ApplyTimeWindowConstrQuestStr',  ...
                            num2str( numIntervals ) ) );
                        qTitle = getString( message( 'Sldv:ModelSlicer:gui:ApplyTimeWindowConstrTitle' ) );

                        yesStr = getString( message( 'MATLAB:finishdlg:Yes' ) );
                        noStr = getString( message( 'MATLAB:finishdlg:No' ) );
                        answer = questdlg( qStr, qTitle, yesStr, noStr, yesStr );
                        if strcmp( answer, noStr )
                            this.cvd.removeConstraint( covConstraintStruct );
                            this.covConstraints.remove( sid );
                            return ;
                        end
                    end
                end
                this.dirty = true;
                valid = true;
            else
                Mex = MException( 'ModelSlicer:NoDecCovSF',  ...
                    getString( message( 'Sldv:ModelSlicer:Coverage:NoDecCovSF' ) ) );
                modelslicerprivate( 'MessageHandler',  ...
                    'single_warning',  ...
                    Mex, this.modelSlicer.model, this.hasDialog );
            end
        end


        function addSliceSubsystem( this, sliceSubSystemH )

            if strcmp( get_param( this.modelSlicer.modelH, 'IsHarness' ), 'on' )
                error( 'ModelSlicer:API:HarnessSliceIsNotSupported',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:HarnessSliceIsNotSupported' ) ) );
            end
            this.sliceSubSystemH = sliceSubSystemH;
            this.dirty = true;
        end


        function addDefaultStartingPoint( this, portType )
            seeds = find_system( this.modelSlicer.modelH, 'FindAll', 'on',  ...
                'SearchDepth', 1, 'CompiledIsActive', 'on', 'BlockType', portType );
            for i = 1:length( seeds )
                this.seedHandler.addStart( this, seeds( i ) );
            end
        end


        function clearAllStartingPoints( this )

            this.seedHandler.clearUserStarts( this );
            this.dirty = true;
        end


        function clearAllExclutionPoints( this )
            this.seedHandler.clearUserExclusions( this );
            this.dirty = true;
        end


        function clearAllConstraints( this )
            this.constraints = containers.Map( 'KeyType', 'char',  ...
                'ValueType', 'any' );
            this.dirty = true;
        end




        function s = toStruct( this )


            mdlName = this.modelSlicer.model;
            userelements = this.getUserStarts(  );
            sigs = rmfield( userelements, 'Handle' );
            terminals = this.getUserExclusions;
            excls = rmfield( terminals, 'Handle' );
            if isempty( this.sliceSubSystemH )
                tsys = '';
            else
                tsys = Simulink.ID.getSID( this.sliceSubSystemH );
            end
            for i = 1:length( sigs )
                sigs( i ).SID = delTopModelNameFromSID( sigs( i ).SID );
            end
            for i = 1:length( excls )
                excls( i ).SID = delTopModelNameFromSID( excls( i ).SID );
            end
            tsys = delTopModelNameFromSID( tsys );
            s = struct(  ...
                'Elements', sigs,  ...
                'Exclusions', excls,  ...
                'Name', this.name,  ...
                'Description', this.description,  ...
                'UseCvd', this.useCvd,  ...
                'CvFileName', this.cvFileName,  ...
                'UseDeadLogic', this.useDeadLogic,  ...
                'SldvFileName', this.sldvFileName,  ...
                'ColorName', this.colorName,  ...
                'ColorValue', this.colorValue,  ...
                'Direction', this.direction,  ...
                'Visible', this.visible,  ...
                'Tag', this.tag,  ...
                'SliceSubsystem', tsys );

            constraintsKeys = this.constraints.keys;
            for i = 1:length( constraintsKeys )
                constraintsKeys{ i } = delTopModelNameFromSID( constraintsKeys{ i } );
            end
            s.( 'ConstraintKeys' ) = constraintsKeys;
            s.( 'ConstraintValues' ) = this.constraints.values;
            covConstraintsKeys = this.covConstraints.keys;
            for i = 1:length( covConstraintsKeys )
                covConstraintsKeys{ i } = delTopModelNameFromSID( covConstraintsKeys{ i } );
            end
            s.( 'CovConstraintKeys' ) = covConstraintsKeys;
            s.( 'CovConstraintValues' ) = this.covConstraints.values;
            if ~isempty( this.deadLogicData )
                s.( 'DeadLogicSys' ) = this.deadLogicData.getAllRefinedSys(  );
            else
                s.( 'DeadLogicSys' ) = {  };
            end
            function outStr = delTopModelNameFromSID( inStr )


                pos = strfind( inStr, ':' );
                if ~isempty( pos ) && strcmp( inStr( 1:pos( 1 ) - 1 ), mdlName )%#ok<STREMP>


                    outStr = inStr( pos( 1 ):end  );
                else
                    outStr = inStr;
                end
            end
        end



        function fromStruct( this, s )

            assert( isfield( s, 'Elements' ) );
            mdl = this.modelSlicer.model;








            this.updateUserStartsFromStruct( s.Elements );
            this.updateUserExclusionsFromStruct( s.Exclusions );

            this.name = s.Name;
            this.description = s.Description;
            this.useCvd = s.UseCvd;
            this.cvFileName = s.CvFileName;
            if isfield( s, 'UseDeadLogic' )
                this.useDeadLogic = s.UseDeadLogic;
                this.sldvFileName = s.SldvFileName;
            end
            this.colorName = s.ColorName;
            this.colorValue = s.ColorValue;
            this.visible = s.Visible;
            if isfield( s, 'Direction' )
                this.direction = s.Direction;
            end
            if isfield( s, 'ConstraintKeys' ) &&  ...
                    isfield( s, 'ConstraintValues' )
                if ~isempty( s.ConstraintKeys ) && ~isempty( s.ConstraintValues )
                    ConstraintKeys = {  };
                    for i = 1:length( s.ConstraintKeys )
                        key = slslicer.internal.addTopModelNameInSID( s.ConstraintKeys{ i }, mdl );
                        if validSID( key )
                            ConstraintKeys{ end  + 1 } = key;%#ok<AGROW>
                        end
                    end
                    if ~isempty( ConstraintKeys )
                        this.constraints = containers.Map( ConstraintKeys,  ...
                            s.ConstraintValues );
                    end
                end
            end

            if isfield( s, 'CovConstraintKeys' ) &&  ...
                    isfield( s, 'CovConstraintValues' )
                if ~isempty( s.CovConstraintKeys ) && ~isempty( s.CovConstraintValues )
                    CovConstraintKeys = {  };
                    for i = 1:length( s.CovConstraintKeys )
                        key = slslicer.internal.addTopModelNameInSID( s.CovConstraintKeys{ i }, mdl );
                        if validSID( key )
                            CovConstraintKeys{ end  + 1 } = key;%#ok<AGROW>
                        end
                    end
                    if ~isempty( CovConstraintKeys )
                        this.covConstraints = containers.Map( CovConstraintKeys,  ...
                            s.CovConstraintValues );
                    end
                end
            end

            try
                if ~isempty( s.SliceSubsystem )
                    SliceSubsystemSID = slslicer.internal.addTopModelNameInSID( s.SliceSubsystem, mdl );
                    pos = strfind( SliceSubsystemSID, ':' );
                    load_system( SliceSubsystemSID( 1:pos( 1 ) - 1 ) );
                    this.sliceSubSystemH = Simulink.ID.getHandle( SliceSubsystemSID );
                else
                    this.sliceSubSystemH = [  ];
                end
            catch
                this.sliceSubSystemH = [  ];
            end

            function res = validSID( sid )
                try
                    Simulink.ID.getHandle( sid );
                    res = true;
                catch
                    res = false;
                end
            end
        end



        function deleteStart( this, i )
            this.seedHandler.deleteStart( i, this );
        end

        function deleteBusElementStart( this, portH, busElementPath )
            this.seedHandler.deleteBusElementStart( portH, busElementPath, this );
        end

        function deleteExclusion( this, i )
            this.seedHandler.deleteExclusion( i, this );
        end


        function deleteSliceSubsystem( this )
            this.sliceSubSystemH = [  ];
            this.dirty = true;
        end



        function suggestedName = getSuggestedSliceFileName( this )
            [ path, baseName, ext ] = fileparts( get_param( this.modelSlicer.modelH, 'FileName' ) );
            if isempty( baseName )
                baseName = get_param( this.modelSlicer.modelH, 'Name' );
            end
            if isempty( path )
                path = pwd;
            end
            if isempty( ext )
                ext = '.slx';
            end
            if ~isempty( baseName )
                suggestedName = Sldv.utils.uniqueFileNameUsingNumbers( path, [ baseName, '_slice' ], ext );
            else
                suggestedName = fullfile( pwd, 'tmpmdl.slx' );
            end
        end


        function mdlName = exportSlice( this )
            suggestedName = this.getSuggestedSliceFileName(  );
            [ filename, thePath ] = uiputfile( suggestedName );
            if filename ~= 0
                [ ~, mdlName ] = fileparts( filename );
                scfg = SlicerConfiguration.getConfiguration( this.modelSlicer.modelH );
                this.modelSlicer.options = scfg.options;
                barH = waitbar( 0, getString( message( 'Sldv:ModelSlicer:gui:StartingSlicing' ) ) );
                this.modelSlicer.barH = barH;
                this.exportSliceHandler( mdlName, thePath );
                this.modelSlicer.barH = [  ];
                if ~isempty( barH ) && ishandle( barH )
                    close( barH )
                end
            end
        end

        function setColor( this, name, rgb )
            stdColors = ColorUtil.Instance.cToI;
            if nargin <= 2
                this.colorName = name;
                idx = stdColors( name );
                this.colorValue = ColorUtil.Instance.values{ idx };
            else
                this.colorName = 'Custom';
                this.colorValue = rgb;
            end
        end

        function updateColor( this )
            if ~isempty( this.overlay )
                this.overlay.setStyleColor( this );
            end
        end

        function filename = setCoverage( this )


            if slavteng( 'feature', 'EnhancedCoverageSlicer' )
                extn = '*.slslicex';
            else
                extn = '*.cvt';
            end
            filename = browseForFile( extn, this.cvFileName, this.cvFileNameOld );

            if ~isempty( filename )
                this.cvFileName = filename;
                this.cvd = Coverage.loadCoverage( this.cvFileName, this.modelSlicer.model );
                this.modelSlicer.cvd = this.cvd;
                this.useCvd = true;
                this.createSdiViewIfNeeded(  );
                this.sdiViewObj.extractSessionFromSlicexFile(  );
                if ~this.modelSlicer.hasValidCoverageData
                    delete( this.sdiViewObj );
                    this.sdiViewObj = [  ];
                    error( 'ModelSlicer:StaleCoverage', getString( message( 'Sldv:ModelSlicer:gui:StaleCoverage' ) ) );
                end
                filename = this.cvFileName;
                this.cvFileNameOld = '';
                this.dirty = true;
            end
        end

        function filename = loadDeadLogicResults( this )
            extn = '*.slslicex';
            filename = browseForFile( extn, this.sldvFileName, this.sldvFileName );
            if filename
                this.sldvFileName = filename;
                try
                    dLData = Sldv.DeadLogicData.loadFromFile( this.sldvFileName );
                    this.modelSlicer.validateDeadLogicData( dLData );
                    this.deadLogicData = dLData;
                catch mex
                    this.sldvFileName = '';
                    rethrow( mex );
                end
                this.modelSlicer.deadLogicData = this.deadLogicData;
                this.useDeadLogic = true;
                this.dirty = true;
            end
        end

        function importSldvData( this, resultFile )
            extn = '*.mat';
            filename = browseForFile( extn, '', '' );
            if ~isempty( filename )
                try
                    this.deadLogicData =  ...
                        Sldv.DeadLogicData.importFromSldvData( filename, resultFile );
                catch mex
                    this.sldvFileName = '';
                    rethrow( mex );
                end
                this.sldvFileName = resultFile;
                this.modelSlicer.deadLogicData = this.deadLogicData;
                this.useDeadLogic = true;
                this.dirty = true;
            end
        end

        function changed = refineForDeadLogic( this, sysH, analysisTime, saveFileName )
            changed = false;
            [ sldvData, ~, incompatMsg ] = this.modelSlicer.refineForDeadLogic( sysH, analysisTime );
            if ~isempty( sldvData )
                changed = true;
            else
                Mex = MException( 'ModelSlicer:IncompatDL',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:IncompatDL',  ...
                    getfullname( sysH ) ) ) );

                if ~isempty( incompatMsg )
                    for i = 1:length( incompatMsg )
                        newMex = MException( incompatMsg( i ).msgid, incompatMsg( i ).msg );
                        Mex = Mex.addCause( newMex );
                    end
                end

                modelslicerprivate( 'MessageHandler',  ...
                    'single_error',  ...
                    Mex, this.modelSlicer.model, this.hasDialog );
                return ;
            end
            if isempty( this.deadLogicData )
                this.deadLogicData = Sldv.DeadLogicData( sldvData );
            else
                this.deadLogicData.add( sldvData );
            end
            this.useDeadLogic = true;
            if isempty( saveFileName )
                saveFileName = Sldv.utils.settingsFilename( '$ModelName$', 'on',  ...
                    '.slslicex', this.modelSlicer.modelH );
            end
            this.deadLogicData.saveToFile( saveFileName );
            this.sldvFileName = saveFileName;
            this.dirty = true;
        end

        function removeDeadLogic( this, idx )
            if ~isempty( this.deadLogicData )
                this.deadLogicData.removeByIdx( idx );
                if isempty( this.deadLogicData.getAllRefinedSys )
                    this.clearAllDeadLogic(  );
                else
                    this.dirty = true;
                end
            end
        end

        function clearAllDeadLogic( this )
            delete( this.deadLogicData );
            this.deadLogicData = [  ];
            this.sldvFileName = '';
            this.useDeadLogic = false;
            this.dirty = true;
        end


        function checkDeletedItems( this )
            this.seedHandler.checkDeletedItems( this );
        end



        function partitionElements( this, signalPaths, blocks )


            ms = this.modelSlicer;

            this.setStartingPoints(  );
            this.setExclusionPoints(  );

            mdls = ms.getRootModels;

            if ( isempty( signalPaths ) && isempty( blocks ) )
                this.setDependencies( [  ], [  ], [  ], this.colorValue, mdls );
            elseif ( isempty( signalPaths ) && ~isempty( blocks ) )
                this.setDependencies( [  ], [  ], blocks, this.colorValue, mdls );
            else
                assert( numel( signalPaths.src ) == numel( signalPaths.dst ) );
                this.setDependencies( signalPaths.src, signalPaths.dst, blocks, this.colorValue, mdls );
            end
        end


        function highlightInEditor( this )
            ms = this.modelSlicer;


            if isempty( this.overlay )
                ol = SliceStyle.Overlay( this );
                this.overlay = ol;
                scfg = SlicerConfiguration.getConfiguration( this.modelSlicer.modelH );
                this.overlay.addToEditor( ~scfg.usingMultiCriteriaCommonOverlap, this );
            end

            if ~isempty( ms.dlg )
                ms.dlg.setWidgetValue( 'DialogStatusText', '' )
            end

            this.dirty = false;
        end


        function restoreHighlightCompileTimeCache( this )


            dlg = this.modelSlicer.dlg;
            if this.hasDialog
                dlg.setWidgetValue( 'DialogStatusText',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:HighlightingFromCache' ) ) );
            end
            scfg = SlicerConfiguration.getConfiguration( this.modelSlicer.modelH );
            this.overlay.addToEditor( ~scfg.usingMultiCriteriaCommonOverlap, this );
            this.dirty = false;
            if this.hasDialog
                dlg.setWidgetValue( 'DialogStatusText',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:Ready' ) ) );
            end
        end


        function tf = hasDialog( this )
            dlg = this.modelSlicer.dlg;
            if isa( dlg, 'DAStudio.Dialog' ) ...
                    && isa( dlg.getSource, 'SEUdd.ModelSlicerDlg' )
                tf = true;
            else
                tf = false;
            end
        end


        function out = getSubsystemInUserStarts( this )
            allstarts = this.getUserStarts(  );
            subsysIndex =  ...
                arrayfun( @( x )or( isa( get( x, 'Object' ), 'Simulink.SubSystem' ), isa( get( x, 'Object' ), 'Simulink.ModelReference' ) ),  ...
                [ allstarts.Handle ] );

            out = [ allstarts( subsysIndex ).Handle ];
        end


        function dlg = getConstraintDialog( this, modelBlockH, scfg, varargin )



            dlgList = this.openConstraintDialog;

            if ~isempty( dlgList )
                filter = arrayfun( @( dlg )dlg.getSource.modelBlockH ==  ...
                    modelBlockH, dlgList );
                dlg = dlgList( filter );
                if ~isempty( dlg )
                    return ;
                end
            end


            constDlg = SEUdd.ConstraintDlg( this );
            constDlg.modelBlockH = modelBlockH;
            constDlg.slCfg = scfg;

            dlg = DAStudio.Dialog( constDlg );

            this.openConstraintDialog = [ this.openConstraintDialog, dlg ];
        end


        function closeConstraintDialog( this, modelBlockH )

            dlgList = this.openConstraintDialog;
            filter = arrayfun( @( dlg )dlg.getSource.modelBlockH ~=  ...
                modelBlockH, dlgList );
            dlgList = dlgList( filter );
            this.openConstraintDialog = dlgList;
        end


        function setDependencies( this, allSrcP, allDstP, allBlks, varargin )
            slslicer.internal.DependencyHandler.setDependencies( this, allSrcP, allDstP, allBlks );
        end


        function setStartingPoints( this )
            this.seedHandler.setStartingPoints( this );
        end


        function setExclusionPoints( this )
            this.seedHandler.setExclusionPoints( this );
        end


        function updateSeedColor( this )



            this.setStartingPoints(  );
            this.setExclusionPoints(  );
            if isempty( this.overlay )
                ol = SliceStyle.Overlay( this );
                this.overlay = ol;
                scfg = SlicerConfiguration.getConfiguration( this.modelSlicer.modelH );
                this.overlay.addToEditor( ~scfg.usingMultiCriteriaCommonOverlap, this );
            end
            this.overlay.startItemsStyleGroup.setItems( this.startingPoints );
            if isempty( this.overlay.startItemsStyleGroup.rule )
                this.overlay.startItemsStyleGroup.show(  );
            end
            this.overlay.exclusionsStyleGroup.setItems( this.exclusionPoints );
            if isempty( this.overlay.exclusionsStyleGroup.rule )
                this.overlay.exclusionsStyleGroup.show(  );
            end
        end


        function updateCriterionTag( this, tag )
            this.tag = tag;
        end


        function [ blkH, allBlks ] = getActiveBlockList( this, includeVirtual )
            arguments
                this
                includeVirtual logical = false;
            end

            if isequal( includeVirtual, true )
                blkH = this.allActiveBlocks;
            else
                blkH = this.activeBlocks;
            end
            allBlks = this.allNonVirtualBlocks;
        end


        function activeSysH = getActiveSystemHandles( this )




            import slslicer.internal.*
            activeSysH = [  ];
            if ~isempty( this.overlay.dependenciesStyleGroup )




                filt = arrayfun( @( x )isHighlightedSubsystem( x ),  ...
                    this.overlay.dependenciesStyleGroup.handleList );
                activeSysH = this.overlay.dependenciesStyleGroup.handleList( filt );
            end

            if isempty( this.sliceSubSystemH )
                activeSysH = [ this.modelSlicer.modelH;activeSysH ];
            else
                activeSysH = [ this.sliceSubSystemH;activeSysH ];
            end
            activeSysH = unique( activeSysH );


            activeSysH = SLGraphUtil.getAllSystems( activeSysH );

            function yesno = isHighlightedSubsystem( h )
                yesno = strcmp( get( h, 'type' ), 'block' ) ...
                    && ( strcmp( get( h, 'BlockType' ), 'SubSystem' ) ...
                    || strcmp( get( h, 'BlockType' ), 'ModelReference' ) );
            end
        end

        function setViewToCurrentRun( obj )
            logsName = get_param( obj.modelSlicer.modelH, 'SignalLoggingName' );
            yesno = ~isempty( obj.cvd.simData.find( logsName ) );
            viewObj = obj.sdiViewObj;
            if yesno
                runIDs = Simulink.sdi.getAllRunIDs(  );
                if ~isempty( runIDs )
                    runID = runIDs( end  );
                    run = Simulink.sdi.getRun( runID );
                    if strcmp( run.Model, obj.modelSlicer.model )
                        viewObj.setCurrentRun( runID, obj.modelSlicer.isThisUsingSdi(  ) );
                    end
                end
            end
        end

        function collectCoverage( obj, scfg, startTime, stopTime, simulationInput, mdlHandleOrSimHandler, varargin )
            scfg.modelSlicer.checkOutLicense(  );
            if slavteng( 'feature', 'EnhancedCoverageSlicer' )
                try
                    if ~strcmp( get_param( scfg.modelH, 'FastRestart' ), 'on' ) && scfg.initialized
                        scfg.modelSlicer.terminateModelForTimeWindowSimulation(  );
                    end
                    obj.cvd = Coverage.collectEnhancedCoverage( mdlHandleOrSimHandler, stopTime, simulationInput );
                catch ex


                    warning( 'ModelSlicer:EnhancedCovCollectionFailed',  ...
                        getString( message( 'Sldv:ModelSlicer:Coverage:EnhancedCovCollectionFailed' ) ) );
                    obj.cvd = Coverage.collectCoverage( scfg.modelH, startTime, stopTime, true );
                end
                obj.cvd.setStartStopTime( startTime, stopTime );
            else
                obj.cvd = Coverage.collectCoverage( scfg.modelH, startTime, stopTime, true );
            end
            if isempty( varargin )
                Coverage.saveCoverage( scfg );
            else
                Coverage.saveCoverage( scfg, varargin{ 1 } );
            end
        end

    end


    methods ( Access = { ?SLSlicerAPI.SLSlicerConfig } )



        function exportSliceHandler( this, mdlName, thePath )
            if this.useCvd && isempty( this.cvd )
                error( 'Sldv:ModelSlicer:gui:NoCoverageDataFile',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:NoCoverageDataFile' ) ) );
            end

            ms = this.modelSlicer;
            [ hasValidStarts, ~ ] = ms.setAnalysisSeeds( this );

            for i = 1:length( ms.transforms )
                ms.transforms( i ).reset;
            end

            if isequal( hasValidStarts, true )
                if ~this.useCvd

                    ms.configureDeadLogicData( this );
                    ms.exportStaticSlice( mdlName, thePath );
                else

                    ms.exportDynamicSlice( this.cvd, mdlName, thePath, this );
                end
                if ~ms.compiled



                    this.isInEditableHighlight = true;
                    this.dirty = true;
                end
            else
                error( 'SliceCriterion:EmptyModel',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:EmptyModelSlice' ) ) );
            end
        end
    end

    methods ( Access = private )


        function handleLicenseCheckOutFailure( this )






            dlg = this.modelSlicer.dlg;
            scfg = SlicerConfiguration.getConfiguration( this.modelSlicer.modelH );



            this.dirty = true;
            this.modelSlicer.hasError = true;
            scfg.forceManualRefresh = true;


            if ~isempty( this.overlay )
                this.overlay.removeFromEditor(  );
            end

            if this.hasDialog
                dlg.getSource.Busy = false;
                dlg.refresh(  );
            end
        end
    end
    methods ( Access = public, Hidden = true )

        function [ ph, invalidHandle ] = getStartSignalHandles( this )
            [ ph, invalidHandle ] = this.seedHandler.getStartSignalHandles( this );
        end


        function busElements = getStartBusElements( this )
            busElements = this.seedHandler.getStartBusElements( this );
        end


        function [ bh, invalidHandle ] = getStartBlockHandles( this )
            [ bh, invalidHandle ] = this.seedHandler.getStartBlockHandles( this );
        end


        function tag = getOverlayTag( this )

            if isempty( this.overlay )
                tag = [  ];
            else
                tag = this.overlay.tag;
            end
        end


        function revertToDefaultSlicerDialog( this, scfg )

            if this.hasDialog
                scfg.removeFastRestartNotification(  );
                dlg = this.modelSlicer.dlg;
                dlgSrc = dlg.getSource;
                if ~isempty( this.cvd )


                    [ startTime, stopTime ] = this.cvd.getStartStopTime(  );
                    dlg.setWidgetValue( 'SimTstartTime', num2str( startTime ) );
                    dlg.setWidgetValue( 'SimTstopTime', num2str( stopTime ) );
                    dlg.apply(  );
                end
                dlgSrc.Busy = false;
                dlg.setWidgetValue( 'DialogStatusText',  ...
                    getString( message( 'Sldv:ModelSlicer:gui:Ready' ) ) )
                dlg.refresh;
                dlg.expandTogglePanel( 'CovGroup', ~isempty( this.cvd ) );
                dlg.expandTogglePanel( 'DeadLogicGroup', ~isempty( this.deadLogicData ) );
            end
        end


        function Ids = getActiveSubchartIds( this )
            Ids = [  ];
            for i = 1:length( this.stateflowElems.subChartStruct )
                s = this.stateflowElems.subChartStruct;
                Ids = [ Ids, s.AtomicSubID ];
            end
        end


        function sdiViewObj = getSdiViewObj( obj )
            obj.createSdiViewIfNeeded(  )
            sdiViewObj = obj.sdiViewObj;
        end

        function createSdiViewIfNeeded( obj )
            if isempty( obj.sdiViewObj )
                obj.sdiViewObj = SlicerSDI.SdiView( obj );
            end
        end

        function addSdiLoggingPointsForSeeds( obj, force )
            obj.sdiLoggingPointsAdded = [  ];
            obj.sdiLoggingPointsAll = [  ];
            elements = getUserStarts( obj );
            if force
                obj.modelSlicer.terminateModelForTimeWindowSimulation( true );
            end
            for i = 1:length( elements )
                e = elements( i );
                if strcmpi( e.Type, 'block' )
                    ph = get_param( e.Handle, 'porthandles' );
                    outports = ph.Outport;
                    for k = 1:length( outports )
                        setLoggingForPort( outports( k ) );
                    end

                    inports = ph.Inport;
                    for k = 1:length( inports )
                        l = get_param( inports( k ), 'Line' );
                        if l > 0
                            srcPortH = get_param( l, 'SrcPortHandle' );
                            setLoggingForPort( srcPortH );
                        end
                    end
                elseif strcmpi( e.Type, 'signal' )
                    if strcmpi( get_param( e.Handle, 'PortType' ), 'Outport' )
                        setLoggingForPort( e.Handle );
                    end
                end
            end

            function setLoggingForPort( ph )
                obj.sdiLoggingPointsAll( end  + 1 ) = ph;
                if force && strcmpi( get_param( ph, 'DataLogging' ), 'off' )
                    obj.sdiLoggingPointsAdded( end  + 1 ) = ph;
                    Simulink.sdi.markSignalForStreaming( ph, 'on' );
                end
            end
        end

        function removeAddedSdiLoggingPointsForSeeds( obj )
            for i = 1:length( obj.sdiLoggingPointsAdded )
                ph = obj.sdiLoggingPointsAdded( i );
                Simulink.sdi.markSignalForStreaming( ph, 'off' );
            end



            if ~isempty( obj.sdiLoggingPointsAdded )
                dirtyMdls = unique( bdroot( obj.sdiLoggingPointsAdded ) );
                for i = 1:length( dirtyMdls )
                    set_param( dirtyMdls( i ), 'Dirty', 'off' );
                end
            end
        end

        function deadLogicData = getDeadLogicData( this )
            deadLogicData = [  ];
            if slavteng( 'feature', 'DeadlogicForSlice' )
                if ~isempty( this.deadLogicData )
                    deadLogicData = this.deadLogicData;
                else
                    if ~isempty( this.sldvFileName )
                        try
                            deadLogicData = Sldv.DeadLogicData.loadFromFile( this.sldvFileName );
                            this.modelSlicer.validateDeadLogicData( deadLogicData );
                            this.deadLogicData = deadLogicData;
                            this.useDeadLogic = true;
                        catch Mex
                            this.sldvFileName = [  ];
                            this.deadLogicData = [  ];
                            this.useDeadLogic = false;
                            modelslicerprivate( 'MessageHandler',  ...
                                'single_error',  ...
                                Mex, this.modelSlicer.model, this.hasDialog );
                        end
                    end
                end
            end
        end

        function artifactName = getSlicexArtifactName( this )
            hiddenOpt = SlicerConfiguration.getAllOpts;
            settings.OutputDir = hiddenOpt.ResultOptions.OutputDir;
            modelH = get_param( this.modelSlicer.model, 'handle' );
            artifactName = Sldv.utils.settingsFilename( '$ModelName$', 'on',  ...
                '.slslicex', modelH, false, false, settings, 'Model Slicer' );
        end

        function refreshPortLabelsIfStepping( this )
            mdl = this.modelSlicer.model;

            if ~isempty( this.cvd ) &&  ...
                    strcmpi( get_param( mdl, 'FastRestart' ), 'on' ) &&  ...
                    strcmpi( get_param( mdl, 'SimulationStatus' ), 'paused' )

                if this.showLabels


                    portsToTurnOff = setdiff( this.currentPortsLabelled,  ...
                        this.portsToLabel );
                    turnOffPVD( portsToTurnOff );
                    this.currentPortsLabelled = [  ];

                    for i = 1:length( this.portsToLabel )
                        srcP = this.portsToLabel( i );
                        if strcmpi( get_param( srcP, 'PortType' ), 'OutPort' )
                            set_param( srcP, 'ShowValueLabel', 'on' );
                            this.currentPortsLabelled( end  + 1 ) = srcP;
                        end
                    end
                else
                    turnOffPVD( this.currentPortsLabelled );
                    this.currentPortsLabelled = [  ];
                end
            else
                this.removePortsLabelled(  );
            end
            function turnOffPVD( portsToTurnOff )
                try
                    arrayfun( @( p )set_param( p, 'ShowValueLabel', 'off' ), portsToTurnOff );
                catch
                end
            end
        end

        function removePortsLabelled( this )
            try
                allMdls = this.modelSlicer.getAllMdls;
                for idx = 1:length( allMdls )
                    if ~Simulink.internal.isModelReferenceMultiInstanceNormalModeCopy( getfullname( allMdls( idx ) ) )
                        SLM3I.SLDomain.removeAllValueLabels( allMdls( idx ) );
                    end
                end
                this.currentPortsLabelled = [  ];
            catch
            end
        end

        function yesno = reloadForStaleCpyRefMdl( this )
            yesno = false;
            if ~isempty( this.cvd ) && ~isempty( this.modelSlicer.mdlRefCtxMgr )
                cpyMdlHs = this.modelSlicer.mdlRefCtxMgr.copyRefMdlHs;
                try
                    for i = 1:length( cpyMdlHs )
                        mdlH = cpyMdlHs( i );
                        [ ~, blockCvId ] = SlCov.CoverageAPI.getCvdata( this.cvd.data, getfullname( mdlH ) );
                        if ischar( blockCvId )
                            yesno = true;
                            return ;
                        end
                    end
                catch
                    yesno = true;
                    return ;
                end
            end
        end

        function yesno = handleMultiInstanceRefs( this )
            yesno = ~isempty( this.modelSlicer ) && ~isempty( this.modelSlicer.mdlRefCtxMgr ) ...
                && this.modelSlicer.mdlRefCtxMgr.hasMultiInstanceRefMdls;
        end
    end
end


function filename = browseForFile( extn, currentFileName, defFileName )
filename = '';
if ~exist( defFileName, 'var' )
    defFileName = '';
end
if ~exist( currentFileName, 'var' )
    currentFileName = '';
end
dirToOpen = '';
if ~isempty( currentFileName )
    dirToOpen = fileparts( currentFileName );
    if ~exist( dirToOpen, 'dir' )
        dirToOpen = '';
    end
end
if isempty( dirToOpen ) ...
        && exist( defFileName, 'file' )
    [ baseName, dirName ] = uigetfile( defFileName );
else
    [ baseName, dirName ] = uigetfile( fullfile( dirToOpen, extn ) );
end
if baseName ~= 0
    fullFileName = fullfile( dirName, baseName );
    dirName( end  ) = [  ];
    if strcmp( dirName, pwd )
        filename = baseName;
    elseif contains( dirName, pwd )


        filename = strrep( fullFileName, pwd, '.' );
    else

        filename = fullFileName;
    end
end
end


