classdef AppProxy < handle

    properties ( Access = private )
        AppHandle

        ProblemType

        AppArguments

        SessionFilePath

        AppContainerHandle
    end

    properties ( SetAccess = private )
        AppTag
    end

    methods ( Static )
        function app = openApp( problemType, varargin )
            appArguments = [  ];
            sessionFilePath = [  ];


            if nargin > 1
                [ varargin{ : } ] = convertStringsToChars( varargin{ : } );

                if nargin == 2
                    firstOptionalArgument = varargin{ 1 };
                    if ~ischar( firstOptionalArgument )
                        error( 'stats:mlearnapp:AppArgumentsNumberError', iMessageString( 'stats:mlearnapp:AppArgumentsNumberErrorMessage' ) );
                    elseif iFileExists( firstOptionalArgument )
                        error( 'stats:mlearnapp:InputFileNotFound', iMessageString( 'stats:mlearnapp:MLearnAppSessionFileNotFoundErrorMessage', firstOptionalArgument ) );
                    end
                    sessionFilePath = firstOptionalArgument;
                else
                    if mod( nargin - 1, 2 ) ~= 0
                        error( 'stats:mlearnapp:AppArgumentsNumberError', iMessageString( 'stats:mlearnapp:AppArgumentsNumberErrorMessage' ) );
                    end

                    varargin = [ varargin( : )', { inputname( 2 ) }, { inputname( 3 ) }, { problemType } ];


                    appArguments = mlearnapp.internal.tools.AppArguments( varargin );
                end
            end

            hApp = mlearnapp.internal.adapterlayer.AppProxy.initializeApp( problemType );
            appReadyListener = addlistener( hApp, 'WindowReady',  ...
                @( ~, ~ )mlearnapp.internal.adapterlayer.AppProxy.processStepsFollowingInitialization( hApp, appArguments, sessionFilePath ) );

            if hApp.isReady(  )
                delete( appReadyListener );
                mlearnapp.internal.adapterlayer.AppProxy.processStepsFollowingInitialization( hApp, appArguments, sessionFilePath );
            end


            app = mlearnapp.internal.adapterlayer.AppProxy( problemType );
            app.AppArguments = appArguments;
            app.SessionFilePath = sessionFilePath;
        end

        function setTrainingMode( tf )


            appConfiguration = mlearnapp.internal.config.AppConfiguration.getInstance(  );
            appConfiguration.setTrainingMode( tf );
        end
    end

    methods ( Static, Access = private )
        function hApp = initializeApp( problemType )
            switch problemType
                case 'classification'
                    hApp = iGetCLearnerAppHandle(  );
                    if isempty( hApp ) || ~isvalid( hApp )
                        classificationLearner(  );
                        hApp = iGetCLearnerAppHandle(  );
                    end
                case 'regression'
                    hApp = iGetRLearnerAppHandle(  );
                    if isempty( hApp ) || ~isvalid( hApp )
                        regressionLearner(  );
                        hApp = iGetRLearnerAppHandle(  );
                    end
                otherwise
                    error( 'stats:mlearnapp:InvalidValue', 'Problem type can only be ''classification'' or ''regression''' );
            end
        end

        function processStepsFollowingInitialization( hApp, appArguments, sessionFilePath )


            appGraphicsRoot = mlearnapp.internal.tools.MLearnAppGraphicsRoot.getInstance(  );
            hBtn = appGraphicsRoot.findForTesting( 'MLearnAppMainToolstripUseParallelButton' );
            if ~isempty( hBtn ) && hBtn.Value
                hBtn.ValueChangedFcn(  );
            end



            hCheckBox = appGraphicsRoot.findForTesting( 'MLearnAppMainToolstripUseBackgroundTrainingCheckbox' );
            if ~isempty( hCheckBox ) && hCheckBox.Value
                hCheckBox.ValueChangedFcn(  );
            end

            if ~isempty( appArguments )
                mlearnapp.internal.adapterlayer.AppProxy.openNewSessionDialogWithArgs( hApp, appArguments );
            end

            if ~isempty( sessionFilePath )
                hApp.Session.SessionSaveLoadController.openSessionFromFilePathArgs( sessionFilePath );
            end
        end

        function openNewSessionDialogWithArgs( hApp, appArguments )
            if ~isempty( appArguments )
                hApp.ToolGroup.setAppBusyState( true );
                cleaner1 = onCleanup( @(  )hApp.ToolGroup.setAppBusyState( false ) );

                iSuppressNewSessionDialog( true );
                cleaner2 = onCleanup( @(  )iSuppressNewSessionDialog( false ) );

                hApp.NewSessionCreator.newSessionFromArgsForceReplaceSession( appArguments );
                startBtn = findall( groot, 'Tag', 'MLearnAppSessionSetupDialogStartButton' );
                if startBtn.Enable
                    startBtn.ButtonPushedFcn(  );
                else
                    hFigure = findall( groot, 'Tag', 'MLearnAppSessionSetupDialogWindow' );
                    hFigure.Visible = true;
                end
            end
        end






    end

    methods
        function this = AppProxy( problemType )
            this.initializeAppProxyInstance( problemType );
        end

        function closeAppByForce( this )
            delete( this.AppHandle );
        end

        function closeAppWithConfirmation( this )
            if isvalid( this.AppContainerHandle )
                this.AppContainerHandle.close(  );
            else
                error( 'stats:mlearnapp:NoAValidWindow', 'App window is not valid' );
            end
        end

        function resetApp( this )
            if ~iIsEmptyDataset( this.AppHandle.Session.TrainingDataset )
                this.AppHandle.Session.initializeSessionWithProblem( this.AppHandle.Session.SupervisedProblem )
            end
        end


        function data = getNewSessionDialogData( this )%#ok<MANU>
            hWindow = findall( groot, 'tag', 'MLearnAppSessionSetupDialogWindow' );
            if ~isempty( hWindow )
                selectedWSVariable = strsplit( iGetSessionSetupDialogDataSetDropDown( hWindow ).Value, ' ' );
                data.DataSetVariableName = selectedWSVariable{ 1 };
                responseVariableName = strsplit( iGetResponseCombobox( hWindow ).Value, ' ' );
                data.ResponseVariableName = responseVariableName{ 1 };
                data.ResponseVariableOrigin = iGetResponseOriginFromDialog( hWindow );
                data.PredictorsTable = iGetSummaryTableData( hWindow );
                if iGetCrossValidationStatus( hWindow )
                    data.ValidationMethod = 'CrossVal';
                    data.ValidationValue = iGetCrossValidationValue( hWindow );
                elseif iGetHoldoutValidationStatus( hWindow )
                    data.ValidationMethod = 'HoldOut';
                    data.ValidationValue = iGetHoldOutValidationValue( hWindow );
                else
                    data.ValidationMethod = 'Resubstitution';
                    data.ValidationValue = [  ];
                end
                data.TestDataValue = iGetTestDataPercentValue( hWindow );
            else
                error( 'stats:mlearnapp:DialogNotOpen', 'New Session dialog is not open' );
            end
        end

        function data = getSessionData( this )
            trainingDataset = this.AppHandle.Session.TrainingDataset;
            testDataset = this.AppHandle.Session.TestDataset;

            if ~isa( trainingDataset, 'mlearnapp.internal.model.EmptyDataset' )
                data.TrainingDataSetVariableName = trainingDataset.Title;
                data.TrainingPredictorsTable = trainingDataset.PredictorTable;
                data.TrainingResponseVariableName = trainingDataset.ResponseName{ 1 };
                data.TrainingResponseVector = trainingDataset.ResponseVector.OriginalData;

                data.TestDataSetVariableName = testDataset.Title;
                data.TestPredictorsTable = testDataset.PredictorTable;
                data.TestResponseVector = testDataset.ResponseVector.OriginalData;

                if ~isa( testDataset, 'mlearnapp.internal.model.EmptyDataset' )
                    data.TestResponseVariableName = testDataset.ResponseName{ 1 };
                else
                    data.TestResponseVariableName = testDataset.ResponseName;
                end

                data.ResponseVariableOrigin = iGetResponseOrigin( this.AppHandle.Session.IsResponseFromWorkspace );

                validationSpec = this.AppHandle.Session.SupervisedProblem.ValidationSpecification;
                if isa( validationSpec, 'mlearnapp.internal.model.validators.CrossValidationSpecification' )
                    data.ValidationMethod = 'CrossVal';
                    data.ValidationValue = validationSpec.KFolds;
                elseif isa( validationSpec, 'mlearnapp.internal.model.validators.HoldoutValidationSpecification' )
                    data.ValidationMethod = 'HoldOut';
                    data.ValidationValue = validationSpec.HoldoutPercentage;
                else
                    data.ValidationMethod = 'Resubstitution';
                    data.ValidationValue = [  ];
                end
            else
                error( 'stats:mlearnapp:EmptySession', 'Session not initialized' );
            end
        end

        function updateNewSessionDialogStartButtonEnablement( this, isEnabled )%#ok<INUSD>
            hBtn = findall( groot, 'tag', 'MLearnAppSessionSetupDialogStartButton' );
            hBtn.Enable = isEnabled;
        end


        function metrics = getCurrentModelMetrics( this )
            model = this.getCurrentSelectedModel(  );
            metrics = this.extractModelMetrics( model );
        end

        function metrics = getCurrentModelTestDataMetrics( this )
            model = this.getCurrentSelectedModel(  );
            metrics = this.extractModelTestDataMetrics( model );
        end

        function metrics = getModelMetrics( this, modelIndex )
            model = this.getModel( modelIndex );
            metrics = this.extractModelMetrics( model );
        end

        function metrics = getModelTestDataMetrics( this, modelIndex )
            model = this.getModel( modelIndex );
            metrics = this.extractModelTestDataMetrics( model );
        end

        function allModelMetrics = getAllModelMetrics( this )
            models = this.getAllModels(  );
            allModelMetrics = cellfun( @( x )this.extractModelMetrics( x ), models );
        end

        function allModelTestDataMetrics = getAllModelTestDataMetrics( this )
            models = this.getAllModels(  );
            allModelTestDataMetrics = cellfun( @( x )this.extractModelTestDataMetrics( x ), models );
        end


        function spec = getCurrentModelFeatureSelectionSpecification( this )
            model = this.getCurrentSelectedModel(  );
            spec = this.createSpecStructFromSpec( model.FeatureSelectionSpecification );
            spec.ModelNumber = model.ModelNumber;
        end

        function spec = getCurrentModelPCASpecification( this )
            model = this.getCurrentSelectedModel(  );
            spec = this.createSpecStructFromSpec( model.PCASpecification );
            spec.ModelNumber = model.ModelNumber;
        end

        function spec = getCurrentModelCostSpecification( this )
            model = this.getCurrentSelectedModel(  );
            spec.CostMatrix = model.CostSpecification.CostMatrix;
            spec.ModelNumber = model.ModelNumber;
        end

        function spec = getCurrentModelAdvancedModelSpecification( this )
            model = this.getCurrentSelectedModel(  );
            if length( model.ModelSpecification.ModelSpecificationsToTrain ) == 1
                spec = this.createSpecStructFromSpec( model.ModelSpecification );
            else
                spec = model.PresetID;
            end
            spec.ModelNumber = model.ModelNumber;
        end

        function spec = getCurrentModelOptimizerSpecification( this )
            model = this.getCurrentSelectedModel(  );
            spec = this.createSpecStructFromSpec( model.OptimizerSpecification );
            spec.ModelNumber = model.ModelNumber;
        end






        function statusChar = getModelStatus( this, modelIndex )
            hModel = this.getModel( modelIndex );
            statusChar = char( hModel.Status );
        end

        function statusChar = getCurrentModelStatus( this )
            hModel = this.getCurrentSelectedModel(  );
            statusChar = char( hModel.Status );
        end

        function mdoelNumberChar = getCurrentModelNumber( this )
            hModel = this.getCurrentSelectedModel(  );
            mdoelNumberChar = hModel.ModelNumber;
        end

        function tf = isCurrentModelDraft( this )
            hModel = this.getCurrentSelectedModel(  );
            tf = hModel.Status == mlearnapp.internal.enums.ModelStatus.Draft;
        end

        function tf = isCurrentModelTrained( this )
            hModel = this.getCurrentSelectedModel(  );
            tf = hModel.Status == mlearnapp.internal.enums.ModelStatus.Trained;
        end

        function tf = isCurrentModelTested( this )
            hModel = this.getCurrentSelectedModel(  );
            tf = hModel.Status == mlearnapp.internal.enums.ModelStatus.Tested;
        end

        function tf = isCurrentModelFailed( this )
            hModel = this.getCurrentSelectedModel(  );
            tf = hModel.Status == mlearnapp.internal.enums.ModelStatus.Failed;
        end

        function tf = isCurrentModelCanceled( this )
            hModel = this.getCurrentSelectedModel(  );
            tf = hModel.Status == mlearnapp.internal.enums.ModelStatus.Interrupted;
        end

        function tf = isCurrentModelOptimized( this )
            hModel = this.getCurrentSelectedModel(  );
            tf = startsWith( hModel.ModelSpecification.PresetID, 'Optimize' );
        end


        function text = getCurrentActiveFigureName( this )
            text = '';
            figureDocument = this.getCurrentActiveFigureDocument(  );
            if ~isempty( figureDocument )
                text = figureDocument.Title;
            end
        end

        function hFigure = getCurrentActiveFigure( this )
            figureDocument = this.getCurrentActiveFigureDocument(  );
            if ~isempty( figureDocument )
                hFigure = figureDocument.Figure;
            else
                error( 'stats:mlearnapp:EmptyPlot', 'No active plot in the app' );
            end
        end

        function plotData = getScatterPlotData( this )
            plotData = [  ];
            if strcmp( this.getCurrentActiveFigureName(  ),  ...
                    iMessageString( 'stats:mlearnapp:ScatterPlotFigureTitle' ) )

                hFigure = this.getCurrentActiveFigure(  );
                scatterAxes = iGetScatterAxes( hFigure );

                if ~isempty( scatterAxes ) && isvalid( scatterAxes )
                    plotData.Title = scatterAxes.Title.String;
                    plotData.XLabel = scatterAxes.XLabel.String;
                    plotData.YLabel = scatterAxes.YLabel.String;
                    plotData.IsPredictionsModeSelected = iGetPredictionsModeRadioButton( hFigure ).Value;
                    plotData.ResponseClassTable = iGetClassesTable( hFigure ).Data;
                end
            end
        end

        function plotData = getValidationConfusionMatrixPlotData( this )
            plotData = [  ];
            if strcmp( this.getCurrentActiveFigureName(  ),  ...
                    iMessageString( 'stats:mlearnapp:ConfusionMatrixFigureTitleJS' ) )

                hFigure = this.getCurrentActiveFigure(  );
                confusionChart = iGetConfusionMatrixAxes( hFigure );

                if ~isempty( confusionChart ) && isvalid( confusionChart )
                    plotData.Title = confusionChart.Title;
                    plotData.XLabel = confusionChart.XLabel;
                    plotData.YLabel = confusionChart.YLabel;
                    plotData.ClassLabels = confusionChart.ClassLabels;
                    switch iConfusionMatrixPlotMode( hFigure ).Tag
                        case 'ConfusionMatrixSummaryModeOffRadioButton'
                            plotData.PlotMode = 'Off';
                        case 'ConfusionMatrixSummaryModePerTrueClassLabel'
                            plotData.PlotMode = 'RowSummary';
                        case 'ConfusionMatrixSummaryModePerPredictedClassRadioButton'
                            plotData.PlotMode = 'ColumnSummary';
                    end
                    plotData.NormalizedValues = confusionChart.NormalizedValues;
                end
            end
        end


        function createModelType( this, modelType )
            hGallery = this.getToolstripButton( 'MLearnAppMainToolstripGallery' );
            if hGallery.Enabled
                itemID = mlearnapp.internal.enums.GalleryModels.getTag( modelType );
                hBtn = this.getToolstripButton( [ 'MLearnAppMainToolstripGalleryItem', itemID ] );
                if hBtn.Enabled
                    hBtn.ItemPushedFcn(  );
                else
                    error( 'stats:mlearnapp:ModelTypeDisabled', 'Model type button is disabled.' );
                end
            else
                error( 'stats:mlearnapp:GalleryDisabled', 'Model gallery is disabled.' );
            end
        end

        function selectModelByIndex( this, modelIndexInList )
            model = this.getModel( modelIndexInList );
            this.AppHandle.Session.DisplayedModel = model;

            this.AppHandle.ToolGroup.setActivePlotGroup( model.ModelNumber );
        end

        function selectModelByNumber( this, modelNumber )
            model = this.getModelByModelNumber( modelNumber );
            this.AppHandle.Session.DisplayedModel = model;

            this.AppHandle.ToolGroup.setActivePlotGroup( model.ModelNumber );
        end

        function deleteModelByNumber( this, modelNumber )
            model = this.getModelByModelNumber( modelNumber );
            deleteModelController = mlearnapp.internal.ui.modellist.DeleteModelController(  ...
                this.AppHandle.Session, this.AppHandle.ToolGroup, [  ], this.AppHandle.Session.MainThreadBusyTracker );
            deleteModelController.deleteModelWithoutConfirmation( model );
        end

        function trainCurrentModel( this )
            this.clickTrainToolstripButton(  );
        end

        function clickNewSessionFromWorkspaceToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripNewSessionFromWorkspaceListItem' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'New Session from Workspace button disabled' );
            end
        end

        function clickNewSessionFromFileToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripNewSessionFromFileListItem' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'New Session from File button disabled' );
            end
        end

        function clickFeatureSelectionToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripAutomaticFeatureSelectionButton' );
            if hBtn.Enabled
                hBtn.ButtonPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Feature Selection button disabled' );
            end
        end

        function clickPCAToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripPCAButton' );
            if hBtn.Enabled
                hBtn.ButtonPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'PCA button disabled' );
            end
        end

        function clickCostsToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripCostOptionsButton' );
            if hBtn.Enabled
                hBtn.ButtonPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Misclassification Costs button disabled' );
            end
        end

        function clickOptimizerOptionsToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOptimizerOptionsButton' );
            if hBtn.Enabled
                hBtn.ButtonPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Optimizer options button disabled' );
            end
        end

        function clickTrainToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripTrainButton' );
            if hBtn.Enabled
                hBtn.ButtonPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Train button disabled' );
            end
        end

        function clickGenerateCodeToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripGenerateCodeButton' );
            if hBtn.Enabled
                hBtn.ButtonPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Generate Code button disabled.' );
            end
        end

        function clickExportPlotToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripExportPlotButton' );
            if hBtn.Enabled
                hBtn.ButtonPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Export Plot button is disabled.' );
            end
        end

        function clickExportModelToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripExportModelSplitButton' );
            if hBtn.Enabled
                hBtn = this.getToolstripButton( 'MLearnAppMainToolstripExportTrainedModelListItem' );
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Export Model button is disabled.' );
            end
        end

        function openScatterPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenScatterPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Scatter plot button disabled.' );
            end
        end

        function openValidationConfusionMatrixPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenValidationConfusionMatrixPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Validation Confusion Matrix Plot button disabled.' );
            end
        end

        function openTestConfusionMatrixPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenTestConfusionMatrixPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Test Confusion Matrix Plot button disabled.' );
            end
        end

        function openValidationROCCurvePlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenValidationROCCurvePlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Validation ROC Curve Plot button disabled.' );
            end
        end

        function openTestROCCurvePlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenTestROCCurvePlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Test ROC Curve Plot button disabled.' );
            end
        end

        function openParallelCoordinatesPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenParallelCoordinatesPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Parallel Coordinates Plot button disabled.' );
            end
        end

        function openMinClassificationErrorPlot( this )
            if strcmp( this.AppTag, 'ClassificationLearner' )
                hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenObjectivePlotButton' );
                if hBtn.Enabled
                    hBtn.ItemPushedFcn(  );
                else
                    error( 'stats:mlearnapp:ButtonDisabled', 'Min. Classification Error Plot button disabled.' );
                end
            else
                error( 'stats:mlearnapp:ButtonMissing', 'Toolstrip button is not available in the app.' )
            end
        end

        function openResponsePlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenTracePlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Response Plot button disabled.' );
            end
        end

        function openValidationPredictedVsActualPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenValidationPredictedVsActualPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Validation Predicted Vs. Actual Plot button disabled.' );
            end
        end

        function openTestPredictedVsActualPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenTestPredictedVsActualPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Test Predicted Vs. Actual Plot button disabled.' );
            end
        end

        function openValidationResidualsPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenValidationResidualsPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Validation Residuals Plot button disabled.' );
            end
        end

        function openTestResidualsPlot( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenTestResidualsPlotPlotButton' );
            if hBtn.Enabled
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Test Residuals Plot button disabled.' );
            end
        end

        function openMinMSEPlot( this )
            if strcmp( this.AppTag, 'RegressionLearner' )
                hBtn = this.getToolstripButton( 'MLearnAppMainToolstripOpenObjectivePlotButton' );
                if hBtn.Enabled
                    hBtn.ItemPushedFcn(  );
                else
                    error( 'stats:mlearnapp:ButtonDisabled', 'Min. MSE Plot button disabled.' );
                end
            else
                error( 'stats:mlearnapp:ButtonMissing', 'Toolstrip button is not available in the app.' )
            end
        end

        function clickImportTestDataFromWorkspaceToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripImportTestDataSplitButton' );
            if hBtn.Enabled
                hBtn = this.getToolstripButton( 'MLearnAppMainToolstripImportTestDataFromWorkspaceListItem' );
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Import Test Data from Workspace button not disabled.' );
            end
        end

        function clickImportTestDataFromFileToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripImportTestDataSplitButton' );
            if hBtn.Enabled
                hBtn = this.getToolstripButton( 'MLearnAppMainToolstripImportTestDataFromFileListItem' );
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Import Test Data from File button not disabled.' );
            end
        end

        function clickTestSelectedModelToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripTestModelButton' );
            if hBtn.Enabled
                hBtn = this.getToolstripButton( 'MLearnAppMainToolstripTestSelectedModelListItem' );
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Test Selected Model button is disabled.' );
            end
        end

        function clickTestAllModelsToolstripButton( this )
            hBtn = this.getToolstripButton( 'MLearnAppMainToolstripTestModelButton' );
            if hBtn.Enabled
                hBtn = this.getToolstripButton( 'MLearnAppMainToolstripTestAllModelsListItem' );
                hBtn.ItemPushedFcn(  );
            else
                error( 'stats:mlearnapp:ButtonDisabled', 'Test All Models button is disabled.' );
            end
        end


        function saveSessionToFile( this, sessionFilePath )
            iValidateSessionFileName( char( sessionFilePath ) );
            if ~this.AppHandle.Session.SessionIsEmpty
                this.AppHandle.Session.SessionSaveLoadController.saveSessionToFile( sessionFilePath );
            else
                error( 'stats:mlearnapp:SessionEmpty', 'App session is not initialized.' );
            end
        end

        function openSessionFromFile( this, sessionFilePath )
            iValidateSessionFileName( char( sessionFilePath ) );
            if iFileExists( sessionFilePath )
                error( 'stats:mlearnapp:InputFileNotFound', iMessageString( 'stats:mlearnapp:MLearnAppSessionFileNotFoundErrorMessage', sessionFilePath ) );
            else
                this.AppHandle.Session.SessionSaveLoadController.openSessionFromFilePathArgs( sessionFilePath );
            end
        end
    end

    methods ( Access = private )
        function initializeAppProxyInstance( this, problemType )
            switch problemType
                case 'classification'
                    this.AppHandle = iGetCLearnerAppHandle(  );
                case 'regression'
                    this.AppHandle = iGetRLearnerAppHandle(  );
                otherwise
                    error( 'stats:mlearnapp:InvalidValue', 'Input must be ''classification'' or ''regression''' );
            end

            if ~isempty( this.AppHandle )
                this.AppContainerHandle = this.AppHandle.ToolGroup.PrivateToolGroup;
                this.AppTag = this.AppHandle.ToolGroup.Tag;
                this.ProblemType = problemType;
            else
                error( 'stats:mlearnapp:AppNotOpen', 'App is not currently open' );
            end
        end

        function hToolstripBtn = getToolstripButton( this, buttonTag )%#ok<INUSL>
            appGraphicsRoot = mlearnapp.internal.tools.MLearnAppGraphicsRoot.getInstance(  );
            hToolstripBtn = appGraphicsRoot.findForTesting( buttonTag );
            if isempty( hToolstripBtn )
                error( 'stats:mlearnapp:ButtonMissing', 'Toolstrip button is not available in the app.' )
            end
        end

        function hModel = getCurrentSelectedModel( this )
            hModel = this.AppHandle.Session.DisplayedModel;
        end

        function figureDocument = getCurrentActiveFigureDocument( this )
            figureDocument = [  ];
            lastSelectedDocument = this.AppContainerHandle.LastSelectedDocument;
            if ~isempty( lastSelectedDocument )
                figureTag = lastSelectedDocument.tag;
                figureGroupTag = lastSelectedDocument.documentGroupTag;
                figureDocument = this.AppContainerHandle.getDocument( figureGroupTag, figureTag );
            end
        end

        function model = getModel( this, modelIndexInList )
            if ( modelIndexInList <= this.AppHandle.Session.ModelList.NumberOfModels )
                model = this.AppHandle.Session.ModelList.getModelByIndex( modelIndexInList );
            else
                error( 'stats:mlearnapp:InvalidIndex', 'Model index is not valid.' );
            end
        end

        function model = getModelByModelNumber( this, modelID )
            model = this.AppHandle.Session.ModelList.getModelByModelNumber( modelID );
            if isempty( model )
                error( 'stats:mlearnapp:InvalidModelNumber', 'Model number is not valid.' );
            end
        end

        function models = getAllModels( this )
            numModels = this.AppHandle.Session.ModelList.NumberOfModels;
            models = cell( numModels, 1 );
            for i = 1:numModels
                models{ i } = this.AppHandle.Session.ModelList.getModelByIndex( i );
            end
        end

        function metrics = extractModelMetrics( this, model )%#ok<INUSL>
            metrics = structfun( @( x )x.Value, model.DerivedMetrics, 'UniformOutput', false );
            metrics.ModelName = model.ModelSpecification.PresetID;
            metrics.ModelNumber = model.ModelNumber;
        end

        function metrics = extractModelTestDataMetrics( this, model )%#ok<INUSL>
            metrics = structfun( @( x )x.Value, model.DerivedTestDataMetrics, 'UniformOutput', false );
            metrics.ModelName = model.ModelSpecification.PresetID;
            metrics.ModelNumber = model.ModelNumber;
        end

        function specStruct = createSpecStructFromSpec( this, specObj )%#ok<INUSL>
            specStruct = struct(  );
            publicProperties = properties( specObj );
            for i = 1:length( publicProperties )
                propertyName = publicProperties{ i };
                if ~ismember( propertyName, { 'IsLastSpecChangeByUser',  ...
                        'ModelSpecificationsToTrain', 'TypeShortNameMessage',  ...
                        'TypeLongNameMessage', 'PresetNameMessage' } )
                    specStruct.( propertyName ) = specObj.( propertyName );
                end
            end
        end
    end
end

function iSuppressNewSessionDialog( shouldSuppress )
appConfiguration = mlearnapp.internal.config.AppConfiguration.getInstance(  );
appConfiguration.setShouldDisplayNewSessionDialog( ~shouldSuppress );
end

function string = iMessageString( ID, varargin )
string = mlearnapp.internal.adapterlayer.Message( ID, varargin{ : } ).getString(  );
end

function tf = iIsEmptyDataset( dataset )
tf = isa( dataset, 'mlearnapp.internal.model.EmptyDataset' );
end

function hApp = iGetCLearnerAppHandle( ~ )
hApp = getappdata( groot, 'ClassificationLearnerAppHandle' );
end

function hApp = iGetRLearnerAppHandle( ~ )
hApp = getappdata( groot, 'RegressionLearnerAppHandle' );
end

function str = iGetResponseOrigin( isResponseFromWorkspace )
if isResponseFromWorkspace
    str = 'FromWorkspace';
else
    str = 'FromBaseData';
end
end

function datasetDropdown = iGetSessionSetupDialogDataSetDropDown( hWindow )
datasetDropdown = findall( hWindow, 'tag', 'MLearnAppDataSessionSetupDialogWorkspaceVariablesComboBox' );
end

function responseDropdown = iGetResponseCombobox( hWindow )
responseDropdown = findall( hWindow, 'tag', 'MLearnAppDataSessionSetupDialogResponseComboBox' );
end

function data = iGetSummaryTableData( hWindow )
summaryTable = findall( hWindow, 'tag', 'MLearnAppSessionSetupDialogPredictorTable' );
data = summaryTable.Data;
end

function value = iGetCrossValidationStatus( hWindow )
crossValRadioButton = findall( hWindow, 'tag', 'MLearnAppValidationMethodDropDown' );
value = crossValRadioButton.Value;
end

function value = iGetCrossValidationValue( hWindow )
crossValSpinner = findall( hWindow, 'tag', 'MLearnAppDataSessionSetupDialogCrossValidationSpinner' );
value = crossValSpinner.Value;
end

function value = iGetHoldOutValidationValue( hWindow )
holdoutValidationSpinner = findall( hWindow, 'tag', 'MLearnAppDataSessionSetupDialogHoldoutValidationSpinner' );
value = holdoutValidationSpinner.Value;
end

function value = iGetHoldoutValidationStatus( hWindow )
holdoutRadioButtion = findall( hWindow, 'tag', 'MLearnAppDataSessionSetupDialogHoldoutRadioButton' );
value = holdoutRadioButtion.Value;
end






function value = iGetTestDataPercentValue( hWindow )
testDataSpinner = findall( hWindow, 'tag', 'MLearnAppSessionSetupDialogTestPercentSpinner' );
value = testDataSpinner.Value;
end

function str = iGetResponseOriginFromDialog( hWindow )
baseDataRadioButton = findall( hWindow, 'tag', 'MLearnAppDataSessionSetupDialogFromBaseDataRadioButton' );
if baseDataRadioButton.Value
    str = 'FromBaseData';
else
    str = 'FromWorkspace';
end
end

function hAxes = iGetScatterAxes( hFigure )
hAxes = findall( hFigure, 'Tag', 'MLearnAppScatterviewAxes' );
end

function radioButton = iGetPredictionsModeRadioButton( hFigure )
radioButton = findall( hFigure, 'Tag', 'MLearnAppScatterPlotPredictionsModeRadioButton' );
end

function hTable = iGetClassesTable( hFigure )
hTable = findall( hFigure, 'Tag', 'MLearnAppScatterPlotClassesTable' );
end

function hAxes = iGetConfusionMatrixAxes( hFigure )
hAxes = findall( hFigure, 'Description', 'MLearnAppConfusionMatrixAxes' );
end

function radioButton = iConfusionMatrixPlotMode( hFigure )
radioButtonGroup = findall( hFigure, 'Tag', 'ConfusionMatrixSummaryModeRadioButtonGroup' );
radioButton = radioButtonGroup.SelectedObject;
end





function tf = iFileExists( filePath )
tf = exist( filePath, 'file' ) ~= 2;
end

function iValidateSessionFileName( sessionFilePath )
arguments
    sessionFilePath{ mustBeNonempty, mustBeTextScalar }
end

[ filePath, fileName, ext ] = fileparts( sessionFilePath );
if isempty( ext ) || ~strcmpi( ext, '.mat' )
    error( 'stats:mlearnapp:NotAValidFileName', '"%s" is not a MAT file.', sessionFilePath );
end
if ( ~isempty( filePath ) && ~isfolder( filePath ) ) || isempty( fileName )
    error( 'stats:mlearnapp:NotAValidFilePath', '"%s" is not on a valid file path. Please check the file path.', sessionFilePath );
end
end

