classdef DebugService < SldvDebugger.DebugService

    properties
        commonBackwardCriteria = [  ];

        analysisMode = 'Generic';
        slicerRefreshPortLabelListener = [  ];
        slicerCloseListener = [  ];
    end

    methods
        function obj = DebugService( model, sldvData )


            obj@SldvDebugger.DebugService( model, sldvData );
        end

        function addSlicerRefreshPortLabelListener( obj )
            if ~isempty( obj.slicerRefreshPortLabelListener )
                return ;
            end
            slicerConfig = SlicerConfiguration.getConfiguration( obj.model );
            obj.slicerRefreshPortLabelListener = addlistener( slicerConfig, 'eventSlicerRefreshPortValueLabel',  ...
                @( ~, ~ )obj.togglePortValueLabelsForOverlapHighlight( slicerConfig ) );
        end

        function removeSlicerRefreshPortLabelListener( obj )
            delete( obj.slicerRefreshPortLabelListener );
            obj.slicerRefreshPortLabelListener = [  ];
        end

        function addSlicerCloseListener( obj )
            if ~isempty( obj.slicerCloseListener )
                return ;
            end
            slicerConfig = SlicerConfiguration.getConfiguration( obj.model );
            obj.slicerCloseListener = addlistener( slicerConfig.modelSlicer, 'eventModelSlicerDialogClosed',  ...
                @( ~, ~ )obj.removeAllSlicerListeners );
        end

        function removeSlicerCloseListener( obj )
            delete( obj.slicerCloseListener );
            obj.slicerCloseListener = [  ];
        end

        function removeAllSlicerListeners( obj )
            obj.removeSlicerCloseListener(  );
            obj.removeSlicerRefreshPortLabelListener(  );
        end

        function detectionPointHandles = getObjectDetectionSites( obj, objectiveId )


            detectionPointHandles = [  ];
            if ~isfield( obj.sldvData.Objectives( objectiveId ), 'detectionSites' )
                return ;
            end
            DetectionPointObjects = obj.sldvData.Objectives( objectiveId ).detectionSites;
            for i = 1:length( DetectionPointObjects )
                detectionPointSID = string( DetectionPointObjects( i ).modelObj );
                updatedSID = obj.updateSIDForExtractionReplacementWorkflow( detectionPointSID );
                portHandles = get_param( updatedSID, 'PortHandles' );
                detectionPointHandles = [ detectionPointHandles, portHandles.Outport( DetectionPointObjects( i ).port ) ];
            end
        end

        function status = isObjectiveDebuggable( obj, objectiveId )


            objective = obj.sldvData.Objectives( objectiveId );
            status = isfield( objective, 'testCaseIdx' ) && ~isempty( objective.testCaseIdx );
        end

        function testCase = getTestCase( obj, idx )


            testCase = obj.sldvData.TestCases( idx );
        end

        function simInputValues = getSimInputValues( obj, idx )

            sldvDataSLDataSet = Sldv.DataUtils.convertTestCasesToSLDataSet( obj.sldvData );
            simInputValues = sldvDataSLDataSet.TestCases( idx );
        end

        function mapKey = getCriteriaMapKey( obj, objectiveNum )
            arguments
                obj( 1, 1 )SldvDebugger.TestGeneration.DebugService
                objectiveNum( 1, 1 )double = obj.DebugCtx.curObjId
            end

            mapKey = strcat( string( objectiveNum ), obj.analysisMode );
        end

        function simButtonEnableMessage = getSimButtonEnableMessage( ~ )

            simButtonEnableMessage = getString( message( 'Sldv:DebugUsingSlicer:SimulationButtonEnabledMessageForInspect' ) );
        end

        function messageTag = getProgressIndicatorToLoadTestCase( ~ )

            messageTag = 'Sldv:DebugUsingSlicer:ProgressIndicatorLoadTestCase';
        end

        function messageTag = getProgressIndicatorStepToTime( ~ )

            messageTag = 'Sldv:DebugUsingSlicer:ProgressIndicatorStepToObservationTime';
        end

        function messageTag = getCriteriaDescription( obj )

            if strcmp( obj.analysisMode, 'Generic' )
                messageTag = 'Sldv:DebugUsingSlicer:CriteriaDescriptionForTestGenValidation';
            elseif strcmp( obj.analysisMode, 'EnhancedMCDC' )
                messageTag = 'Sldv:DebugUsingSlicer:CriteriaDescriptionForValidation';
            end
        end

        function togglePortValueLabelsForOverlapHighlight( ~, slicerConfig )


            import SldvDebugger.TestGeneration.DebugService.*;
            if ~isempty( slicerConfig.allDisplayed )
                turnOffPortValueLabels( slicerConfig );
                turnOnPortValueLabelsToInspectEMCDC( slicerConfig );
            end
        end

        function disableCriteriaPanel( obj, dlg )



            dlgSrc = dlg.getDialogSource;

            dlgSrc.sigListPanel.lockedForInspect = 1;
            dlgSrc.criteriaListPanel.lockedForInspect = 1;
            dlg.refresh(  );
            obj.disableCriteriaPanel@SlicerApplication.DebugService( dlg );
        end

        function setupSlicer( obj, SID, objectiveId )



            obj.setupSlicer@SldvDebugger.DebugService( SID, objectiveId );
            if ~exist( obj.model )%#ok<EXIST>

                return ;
            end
            slicerConfig = SlicerConfiguration.getConfiguration( obj.model );
            obj.togglePortValueLabelsForOverlapHighlight( slicerConfig );

            obj.setupBackWardCriterionCoverageData( slicerConfig );
        end

        function setupSlicerConfiguration( obj, dlgSrc, objectiveId, ~ )



            import SldvDebugger.TestGeneration.DebugService.*;
            obj.commonBackwardCriteria = [  ];
            slicerConfig = dlgSrc.Model;


            obj.criteriaColor = 'Green';
            obj.analysisMode = 'Generic';


            obj.addSlicerRefreshPortLabelListener(  );
            obj.addSlicerCloseListener(  );

            slicerConfig.externalPVDManagement = true;


            obj.setupSlicerConfiguration@SldvDebugger.DebugService( dlgSrc, objectiveId );

            multiCriteriaRowIndex = { slicerConfig.allDisplayed };


            objectDetectionHandles = obj.getObjectDetectionSites( objectiveId );
            if ~isempty( objectDetectionHandles )




                slicerConfig.unhighlightCriteria(  );

                obj.analysisMode = 'EnhancedMCDC';




                startingPointH = obj.getSlicerSeed;


                turnOffPortValueLabels( slicerConfig );

                newCriteria = obj.setupExtraSlicerCriteriaForInspection(  );
                removeUncommonOverlays( slicerConfig, newCriteria );


                obj.setupSlicerConfiguration@SldvDebugger.DebugService( dlgSrc, objectiveId );




                slicerConfig.CurrentCriteria.direction = 'Forward';

                for n = 1:length( objectDetectionHandles )
                    newCriteria.addStart( objectDetectionHandles( n ) );
                    slicerConfig.CurrentCriteria.addExclusion( objectDetectionHandles( n ) );
                end
                newCriteria.addExclusion( startingPointH );

                slicerConfig.CurrentCriteria.showCtrlDep = true;
                newCriteria.showCtrlDep = true;


                criteriaIndex = slicerConfig.getCriteriaIndexInSlicerConfiguration( newCriteria );
                slicerConfig.allDisplayed = unique( [ criteriaIndex, slicerConfig.selectedIdx ] );

                for i = 1:length( slicerConfig.allDisplayed )
                    idx = slicerConfig.allDisplayed( i );
                    slicerConfig.sliceCriteria( idx ).refresh;
                end
                slicerConfig.addOverlapRules( true );





                obj.commonBackwardCriteria = multiCriteriaRowIndex{ 1 };


                multiCriteriaRowIndex = [ slicerConfig.allDisplayed, multiCriteriaRowIndex ];
            end


            dlgSrc.criteriaListPanel.multiCriteriaRowIndex = multiCriteriaRowIndex;

            dlgSrc.criteriaListPanel.rowToInspect = 0;
            slicerConfig.modelSlicer.dlg.refresh;
        end

        function setupBackWardCriterionCoverageData( obj, slicerConfig )


            if ~isempty( obj.commonBackwardCriteria )
                criteria = slicerConfig.sliceCriteria( obj.commonBackwardCriteria );
                criteria.cvd = slicerConfig.CurrentCriteria.cvd;
                criteria.useCvd = true;
            end
        end
    end

    methods ( Static )
        function turnOnPortValueLabelsToInspectEMCDC( slicerConfig )


            selectedCriteria = slicerConfig.sliceCriteria( slicerConfig.selectedIdx );
            if ~selectedCriteria.showLabels
                return ;
            end
            activeBlocksIntersect = slicerConfig.sliceCriteria( slicerConfig.allDisplayed( 1 ) ).activeBlocks;
            for idx = 2:length( slicerConfig.allDisplayed )
                activeBlocksIntersect = intersect( activeBlocksIntersect, slicerConfig.sliceCriteria( slicerConfig.allDisplayed( idx ) ).activeBlocks );
            end




            activeBlocksIntersect = slicerConfig.filterRedundantParents( activeBlocksIntersect );
            SlicerConfiguration.togglePortValueLabel( activeBlocksIntersect, 'on' );
            SldvDebugger.TestGeneration.DebugService.toggleInportLabels( activeBlocksIntersect, 'on' );
        end

        function turnOffPortValueLabels( slicerConfig )


            activeBlocksUnion = [  ];
            for idx = 1:length( slicerConfig.allDisplayed )
                activeBlocksUnion = union( activeBlocksUnion, slicerConfig.sliceCriteria( slicerConfig.allDisplayed( idx ) ).activeBlocks );
            end
            SlicerConfiguration.togglePortValueLabel( activeBlocksUnion, 'off' );
            SldvDebugger.TestGeneration.DebugService.toggleInportLabels( activeBlocksUnion, 'off' );
        end

        function toggleInportLabels( blocks, value )
            for i = 1:length( blocks )
                portHandles = get_param( blocks( i ), 'PortHandles' );
                for j = 1:length( portHandles.Inport )
                    inport = portHandles.Inport( j );
                    lineH = get( inport, 'Line' );
                    if ishandle( lineH )
                        srcPortHandle = get( lineH, 'SrcPortHandle' );
                        if ishandle( srcPortHandle )
                            set_param( srcPortHandle, 'ShowValueLabel', value );
                        end
                    end
                end
            end
        end

        function removeUncommonOverlays( slicerConfig, commonCriteria )

            commonCriteriaIndex = slicerConfig.getCriteriaIndexInSlicerConfiguration( commonCriteria );
            for i = 1:length( slicerConfig.allDisplayed )
                if slicerConfig.allDisplayed( i ) ~= commonCriteriaIndex &&  ...
                        ~isempty( slicerConfig.sliceCriteria( slicerConfig.allDisplayed( i ) ).overlay )
                    slicerConfig.sliceCriteria( slicerConfig.allDisplayed( i ) ).overlay.removeFromEditor(  );
                end
            end
        end
    end
end

