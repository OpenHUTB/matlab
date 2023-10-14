classdef InspectorAppTask < handle



    properties ( SetAccess = private )
        TaskPanel
        Task( 1, 1 )struct
        TaskUI
        TaskUIFigure
        Code string = string.empty
        FunctionCode_I string = string.empty
        PreviousState
        Selection
        VizScript

        RunButton
        PreviewButton
        SuccessButton
        StopButton
        ApplyBanner
        AutoRunCB
        AutoRunLabel
        AutoRunOn = false
    end

    properties ( Constant )
        INSPECTOR_PANEL_ROWHEIGHTS = { '1x', 20, 20, 25 };

        BANNER_BACKGROUNDCOLOR = '#E6F6FE';
        BANNER_ROWHEIGHT = 20;
        BUTTONS_ROWHEIGHT = 25;

        BANNER_ROWNUM = 3;
        AUTORUN_ROWNUM = 2;
        BUTTONS_ROWNUM = 4;

        APPLY_BANNER_TEXT = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:APPLY_BANNER' ) );
        UPDATE_BANNER_TEXT = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:UPDATE_BANNER' ) );
    end

    properties ( Access = private )
        TaskPanelDeletionListener
        InspectorChangedListener
    end

    properties
        TaskInspector
        TaskProxyView
        CurrentWorkspace
    end

    properties ( Dependent )
        PreviewPanel;
    end
    methods
        function set.PreviewPanel( obj, val )
            obj.TaskPanel = val;
        end
        function val = get.PreviewPanel( obj )
            val = obj.TaskPanel;
        end
    end

    properties
        TaskCompletedFcn
        TaskStartedFcn
        App
    end

    properties ( Dependent )
        State
        Data
        VariableName
        TableVariableName
        Summary
        FunctionCode
    end
    methods
        function state = get.State( obj )
            try
                state = obj.TaskUI.State;
            catch e
                state = struct(  );
            end
        end

        function set.State( obj, state )
            if ~isempty( state ) && ~isempty( fieldnames( state ) )
                obj.TaskUI.State = state;
            end
        end

        function data = get.Data( obj )
            workspace = obj.CurrentWorkspace;
            data = workspace.( obj.VariableName );
        end

        function varName = get.VariableName( obj )
            try
                varName = '';
                state = obj.State;
                if ~isempty( obj.Task.InputProperty )
                    varName = state.( obj.Task.InputProperty );
                    if iscell( varName )
                        varName = varName{ 1 };
                    end
                end
            catch
            end
        end

        function tableVarName = get.TableVariableName( obj )
            tableVarName = '';
            try
                state = obj.State;
                if isfield( state, "InputDataTableVarDropDownValues" ) &&  ...
                        ~isempty( state.( "InputDataTableVarDropDownValues" ) )
                    tableVarName = state.( "InputDataTableVarDropDownValues" );
                elseif ~isempty( obj.Task.TableVariableProperty )
                    tableVarName = state.( obj.Task.TableVariableProperty );
                end
            catch
            end
        end

        function set.VariableName( obj, varName )
            state = obj.State;
            if ~isempty( obj.Task.InputProperty ) && ~isempty( varName )
                state.( obj.Task.InputProperty ) = char( varName );
                obj.updateTaskDocument( true );
            end
        end

        function set.TableVariableName( obj, tableVarName )
            state = obj.State;
            if ~isempty( obj.Task.TableVariableProperty ) && ~isempty( tableVarName )
                state.( obj.Task.TableVariableProperty ) = char( tableVarName );
                obj.updateTaskDocument( true );
            end
        end

        function val = get.Summary( obj )
            val = obj.TaskUI.Summary;
        end

        function val = get.FunctionCode( obj )
            val = obj.FunctionCode_I;
            val = strrep( val, obj.VariableName, 'inputTable' );
        end
    end

    methods
        function obj = InspectorAppTask( PVPairs )
            arguments
                PVPairs.Task( 1, 1 )struct
                PVPairs.VariableName string = string.empty
                PVPairs.TableVariableName string = string.empty
                PVPairs.State( 1, 1 )struct = struct(  )
                PVPairs.TaskPanel
                PVPairs.TaskInspector
                PVPairs.TaskDocument
                PVPairs.CurrentWorkspace
                PVPairs.TaskCompletedFcn = function_handle.empty
                PVPairs.App
            end
            if ~isempty( PVPairs.State ) && isfield( PVPairs.State, 'Task' )
                obj.Task = PVPairs.State.Task;
            else
                obj.Task = PVPairs.Task;
            end
            obj.App = PVPairs.App;
            obj.AutoRunOn = obj.App.AutoRunOn;
            obj.TaskPanel = PVPairs.TaskPanel;
            obj.TaskInspector = PVPairs.TaskInspector;
            obj.CurrentWorkspace = PVPairs.CurrentWorkspace;
            obj.Selection = matlab.internal.preprocessingApp.selection.Selection.getInstance(  );
            PVPairs.PanelOptions.HasVisualization = obj.Task.HasVisualization;

            obj.TaskUI = obj.createTaskUI( obj.Task, PVPairs.VariableName, PVPairs.TableVariableName, PVPairs.State );
            obj.TaskCompletedFcn = PVPairs.TaskCompletedFcn;


            obj.TaskPanel.startup(  );

            if ~isempty( fieldnames( PVPairs.State ) )
                obj.setTaskPanelNoUnsavedChanged(  );
            else
                obj.updateTaskDocument( obj.AutoRunOn );
            end

            obj.TaskPanelDeletionListener = addlistener( obj.TaskPanel, 'ObjectBeingDestroyed', @( e, d )obj.delete );
        end

        function updateRunButton( obj )
            obj.App.LastChangeSource = obj;

            obj.setTaskPanelHasUnsavedChanges(  );
            if obj.AutoRunOn
                obj.updateTaskDocument( true );
            end
        end

        function delete( obj )
            if ~isempty( obj.TaskPanelDeletionListener )
                obj.TaskPanelDeletionListener.delete;
            end

            if ~isempty( obj.TaskUI ) && isvalid( obj.TaskUI )
                delete( obj.TaskUI );
            end
        end

        function startup( obj )
            obj.TaskInspector.inspect( obj.TaskProxyView );
        end
    end

    methods
        function taskUI = createTaskUI( obj, task, variable, tableVariable, oldState )
            import matlab.ui.internal.toolstrip.*;

            workspace = obj.CurrentWorkspace;
            taskUI = [  ];
            try


                if ~isempty( fieldnames( task ) )
                    taskCommand = task.Path;
                else
                    taskCommand = oldState.Path;
                end

                if isempty( obj.TaskUIFigure )
                    obj.TaskUIFigure = uifigure( 'Visible', false, 'HandleVisibility', 'off' );
                end

                if contains( taskCommand, "(" )
                    taskCommand = split( taskCommand, "(" );
                    taskCommand = taskCommand( 1 ) + "(obj.TaskUIFigure, workspace, " + taskCommand( 2 ) + ";";
                else
                    taskCommand = taskCommand + "(obj.TaskUIFigure, workspace);";
                end

                taskUI = eval( taskCommand );


                if ismethod( taskUI, 'initialize' )
                    inputArgs = { "Inputs", variable };
                    if ~isempty( tableVariable )
                        inputArgs{ end  + 1 } = "TableVariableNames";
                        inputArgs{ end  + 1 } = tableVariable;
                    end
                    taskUI.initialize( inputArgs{ : } );
                end

                obj.TaskPanel.Figure.Children.Visible = 'on';

                obj.createTaskControls(  );

                obj.TaskProxyView = matlab.internal.preprocessingApp.tasks.LiveTaskProxyView( taskUI );

                if ~isempty( fieldnames( oldState ) )
                    obj.TaskUI = taskUI;
                    obj.State = oldState;
                end



                obj.InspectorChangedListener = addlistener( obj.TaskProxyView, 'DataChange', @( e, d )obj.updateRunButton );
            catch e
                disp( e );
            end
        end

        function createTaskControls( obj )
            obj.ApplyBanner = uilabel( obj.TaskInspector.Parent );
            obj.ApplyBanner.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:APPLY_BANNER' ) );
            obj.ApplyBanner.Layout.Row = obj.BANNER_ROWNUM;
            obj.ApplyBanner.Layout.Column = [ 1, 5 ];
            obj.ApplyBanner.Parent.RowHeight{ obj.BANNER_ROWNUM } = obj.BANNER_ROWHEIGHT;
            obj.ApplyBanner.BackgroundColor = obj.BANNER_BACKGROUNDCOLOR;

            obj.AutoRunCB = uicheckbox( obj.TaskInspector.Parent );
            obj.AutoRunCB.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:AUTORUN' ) );
            obj.AutoRunCB.Tooltip = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:AUTORUN_TOOLTIP' ) );
            obj.AutoRunCB.Layout.Row = obj.AUTORUN_ROWNUM;
            obj.AutoRunCB.Layout.Column = [ 1, 4 ];
            obj.AutoRunCB.Value = obj.AutoRunOn;
            obj.AutoRunCB.ValueChangedFcn = @( e, d )obj.updateAutoRunState(  );

            obj.PreviewButton = uibutton( obj.TaskInspector.Parent );
            obj.PreviewButton.Text = '';
            obj.PreviewButton.Icon = fullfile( matlabroot,  ...
                'toolbox', 'matlab', 'datatools', 'preprocessing',  ...
                '+matlab', '+internal', '+preprocessingApp', '+images', 'run_16.png' );
            obj.PreviewButton.Layout.Row = obj.AUTORUN_ROWNUM;
            obj.PreviewButton.Layout.Column = 5;
            obj.PreviewButton.ButtonPushedFcn = @( e, d )obj.previewButtonClicked(  );

            obj.RunButton = uibutton( obj.TaskInspector.Parent );
            obj.RunButton.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:APPLY_BUTTON' ) );
            obj.RunButton.BackgroundColor = [ 1, 1, 1 ];
            obj.RunButton.Layout.Row = obj.BUTTONS_ROWNUM;
            obj.RunButton.Layout.Column = 3;
            obj.RunButton.ButtonPushedFcn = @( e, d )obj.applyButtonClicked( false );

            obj.SuccessButton = uibutton( obj.TaskInspector.Parent );
            obj.SuccessButton.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CLOSE_BUTTON' ) );
            obj.SuccessButton.BackgroundColor = [ 1, 1, 1 ];
            obj.SuccessButton.Layout.Row = obj.BUTTONS_ROWNUM;
            obj.SuccessButton.Layout.Column = [ 4, 5 ];
            obj.SuccessButton.ButtonPushedFcn = @( e, d )obj.clearInspector( e, d, true );

            if ~obj.AutoRunOn
                obj.PreviewButton.Visible = true;
            else
                obj.PreviewButton.Visible = false;
            end

            obj.App.VariableBrowserPanel.showDisableLabel(  );
        end

        function setTaskPanelNoUnsavedChanged( obj )
            obj.ApplyBanner.Parent.RowHeight{ obj.BANNER_ROWNUM } = 0;
            obj.RunButton.Enable = false;
            obj.App.VariableBrowserPanel.hideDisableLabel(  );
        end

        function setTaskPanelHasUnsavedChanges( obj )
            if isempty( obj.App.CurrentStepIDString )
                obj.ApplyBanner.Text = obj.APPLY_BANNER_TEXT;
            else
                obj.ApplyBanner.Text = obj.UPDATE_BANNER_TEXT;
            end
            obj.ApplyBanner.Parent.RowHeight{ obj.BANNER_ROWNUM } = obj.BANNER_ROWHEIGHT;
            obj.App.VariableBrowserPanel.showDisableLabel(  );
            obj.RunButton.Enable = true;
        end

        function updateAutoRunState( obj )

            if obj.AutoRunCB.Value
                obj.PreviewButton.Visible = false;
                obj.AutoRunOn = true;
                if obj.RunButton.Enable

                    obj.updateTaskDocument( true );
                end
            else

                obj.AutoRunOn = false;
                obj.PreviewButton.Visible = true;
            end
        end


        function enableView( this )
            this.TaskProxyView.updateEditableState( true );
            this.enableControlButtons(  );
        end


        function disableView( this )
            this.TaskProxyView.updateEditableState( false );
            this.disableControlButtonsWhenNoInput(  );
        end

        function applyButtonClicked( obj, notify )
            obj.RunButton.Enable = false;
            obj.TaskInspector.Parent.RowHeight{ obj.BANNER_ROWNUM } = 0;


            if ~obj.AutoRunOn
                obj.updateTaskDocument( true );
            end


            obj.callTaskCompletedFcn( true, [  ] );
            obj.clearInspector( [  ], [  ], true );
        end

        function previewButtonClicked( obj )
            obj.updateTaskDocument( true );
        end

        function clearInspector( obj, ~, ~, updateData )
            obj.RunButton.Enable = false;
            obj.SuccessButton.Enable = false;
            obj.cleanUpTask(  );

            obj.App.resetToDefault( updateData );
        end

        function cleanUpTask( obj )
            delete( obj.TaskProxyView );
            delete( obj.TaskUI );
            delete( obj.TaskUIFigure );
            obj.TaskPanel.Figure.Children.Visible = 'off';


            delete( obj.RunButton );
            delete( obj.SuccessButton );
            delete( obj.ApplyBanner );
            delete( obj.AutoRunCB );
            delete( obj.AutoRunLabel );
            delete( obj.PreviewButton );
        end

        function [ dataScript, varNames ] = getScriptCode( obj, isForExport )





            try
                overwriteVar = isForExport;
                [ dataScript, varNames ] = obj.TaskUI.generateScript( isForExport, overwriteVar );
            catch
                dataScript = "";
                varNames = {  };
            end
        end

        function plotCodeMap = getVisualizationScript( obj )
            plotCodeMap = obj.TaskUI.getPlotCode( '' );
        end

        function pushCode( obj, code, clearCode )
            arguments
                obj
                code string
                clearCode( 1, 1 )logical = false
            end

            if clearCode
                obj.Code = string.empty;
            end

            obj.Code = [ obj.Code;code ];
        end

        function pushFunctionCode( obj, code, clearCode )
            arguments
                obj
                code string
                clearCode( 1, 1 )logical = false
            end

            if clearCode
                obj.FunctionCode_I = string.empty;
            end

            obj.FunctionCode_I = [ obj.FunctionCode_I;code ];
        end

        function updateTaskDocument( obj, notify )
            errorMsg = string.empty;
            obj.TaskPanel.disableUpdateInteractions;
            obj.callTaskStartedFcn(  );
            try
                if isvalid( obj )
                    [ dataScript, varNames ] = obj.getScriptCode( false );
                    dataScriptForCodeGen = obj.getScriptCode( true );

                    cloneWS = obj.CurrentWorkspace.clone(  );
                    cleanupCode = string.empty;

                    if ~isempty( dataScript ) && strlength( dataScript ) > 0

                        obj.pushCode( dataScriptForCodeGen, true );
                        obj.pushFunctionCode( dataScriptForCodeGen, true );

                        evalin( cloneWS, dataScript + ";" );

                        visScriptMap = [  ];
                        if obj.Task.HasVisualization
                            visScriptMap = obj.getVisualizationScript(  );





                            for var = keys( visScriptMap )
                                if isempty( visScriptMap( var{ 1 } ) )
                                    remove( visScriptMap, var{ 1 } );
                                end
                            end
                        end
                        obj.VizScript = struct(  );
                        obj.VizScript.Code = visScriptMap;
                        obj.VizScript.Workspace = cloneWS;
                        data = cloneWS.( varNames{ 1 } );
                        allTableVars = data.Properties.VariableNames;
                        if istimetable( data )
                            allTableVars = [ data.Properties.DimensionNames{ 1 },  ...
                                allTableVars ];
                        end
                    else



                        obj.VizScript = [  ];
                        allTableVars = [  ];
                    end

                    obj.updateSelection( false, allTableVars );

                    obj.PreviousState = obj.State;
                end
            catch e


                obj.SuccessButton.Enable = true;
                if ~isempty( obj.PreviousState )
                    obj.TaskUI.setTaskState( obj.PreviousState );
                    obj.enableControlButtons(  );
                    obj.TaskPanel.enableUpdateInteractions;
                else
                    obj.RunButton.Enable = false;
                end
                obj.TaskProxyView.updateDynamicProperties(  );
                errorTitle = getString( message( 'MATLAB:datatools:preprocessing:app:USR_ACTION_ERROR_TITLE' ) );
                if ~isempty( e.cause ) && ~isempty( e.cause{ 1 } ) && ~isempty( e.cause{ 1 }.message )
                    errorMsg = e.cause{ 1 }.message;
                elseif ~isempty( e.message )
                    errorMsg = e.message;
                else
                    errorMsg = sprintf( 'History Error: %s \nReverting user action', e.message );
                end

                uialert( obj.App.AppContainer, errorMsg, errorTitle );
                return ;
            end
            obj.TaskPanel.enableUpdateInteractions;
            if notify
                if ~isempty( varNames ) && ~isempty( obj.VizScript )
                    varNames = varNames{ 1 };
                    obj.enableControlButtons(  );
                else
                    obj.disableControlButtonsWhenNoInput(  );
                end
                obj.TaskProxyView.updateEditableState( true );
                obj.App.updateWithTaskPreview( varNames, obj.VizScript, cloneWS );
            end
        end

        function disableControlButtonsWhenNoInput( obj )
            obj.RunButton.Enable = false;
            obj.PreviewButton.Enable = false;
            obj.ApplyBanner.Enable = false;
        end

        function enableControlButtons( obj )
            obj.RunButton.Enable = true;
            obj.PreviewButton.Enable = true;
            obj.ApplyBanner.Enable = true;
        end

        function updateSelection( obj, notify, allTableVars )


            if ~isfield( obj.State, "InputDataTableVarNames" )


                tableVars = allTableVars;
            elseif ~isempty( obj.TableVariableName ) &&  ...
                    any( contains( obj.State.( "InputDataTableVarNames" ),  ...
                    obj.TableVariableName ) )


                tableVars = cellfun( @( x )regexprep( x, '^\.', '' ),  ...
                    obj.TableVariableName, 'UniformOutput', false );
            else


                tableVars = [  ];
            end

            selObj = struct;
            selObj.SelectedVariable = obj.VariableName;
            selObj.SelectedTableVariables = tableVars;
            selObj.LastChangedSrc = obj.TaskPanel;
            obj.Selection.setSelection( selObj, notify );
        end

        function callTaskStartedFcn( obj )
            if ~isempty( obj.TaskStartedFcn )
                try
                    obj.TaskStartedFcn(  );
                catch e
                    disp( e );
                end
            end
        end

        function callTaskCompletedFcn( obj, isSuccess, errorMsg )
            arguments
                obj
                isSuccess( 1, 1 )logical = true
                errorMsg string = string.empty
            end

            if ~isempty( obj.TaskCompletedFcn )
                eventData = struct(  );
                eventData.Source = obj;
                eventData.IsSuccess = isSuccess;
                eventData.ErrorMessage = errorMsg;
                eventData.Code = obj.Code;
                eventData.Summary = obj.Summary;
                eventData.Data = obj.Data;
                eventData.State = obj.State;
                eventData.addNewCodeLine = false;
                try
                    obj.TaskCompletedFcn( eventData );
                catch e
                    disp( e );
                end
            end
        end
    end
end

function noop( varargin )

end

