classdef AppTask < handle

    properties ( SetAccess = private )
        PreviewPanel
        TaskDocument
        Task( 1, 1 )struct
        TaskUI
        Workspace
        Code string = string.empty
        FunctionCode_I string = string.empty
        CurrentWorkspace
        PreviousState

        SubsetStart_I( 1, 1 )double{ mustBePositive, mustBeInteger } = 1
        SubsetEnd_I( 1, 1 )double{ mustBeNonnegative, mustBeInteger } = 0
        SubsetStep_I( 1, 1 )double{ mustBePositive, mustBeInteger } = 1
    end

    properties ( Access = private )
        TaskDocumentDeletionListener
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

        SubsetStart( 1, 1 )double{ mustBePositive, mustBeInteger }
        SubsetEnd( 1, 1 )double{ mustBeNonnegative, mustBeInteger }
        SubsetStep( 1, 1 )double{ mustBePositive, mustBeInteger }
    end
    methods
        function state = get.State( obj )
            try
                sstate = obj.TaskUI.State;
            catch e
                state = struct(  );
            end
        end

        function set.State( obj, state )
            if ~isempty( state ) && ~isempty( fieldnames( state ) )
                obj.TaskUI.State = state;
                obj.updatePreviewPanel(  );
            end
        end

        function data = get.Data( obj )
            if ~isempty( obj.PreviewPanel.PreprocessedTableView )
                data = obj.PreviewPanel.PreprocessedTableView.Data;
            elseif ~isempty( obj.CurrentWorkspace )
                data = obj.CurrentWorkspace.( obj.VariableName );
            else
                data = obj.Workspace.( obj.VariableName );
            end
        end

        function varName = get.VariableName( obj )
            try
                varName = '';
                state = obj.State;
                if ~isempty( obj.Task.InputProperty )
                    varName = state.( obj.Task.InputProperty );
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
                obj.updatePreviewPanel;
            end
        end

        function set.TableVariableName( obj, tableVarName )
            state = obj.State;
            if ~isempty( obj.Task.TableVariableProperty ) && ~isempty( tableVarName )
                state.( obj.Task.TableVariableProperty ) = char( tableVarName );
                obj.updatePreviewPanel;
            end
        end

        function val = get.Summary( obj )
            val = obj.TaskUI.Summary;
        end

        function val = get.SubsetStart( obj )
            val = obj.SubsetStart_I;
        end

        function set.SubsetStart( obj, val )
            obj.SubsetStart_I = val;
            obj.updatePreviewPanel(  );
        end

        function val = get.SubsetEnd( obj )
            val = obj.SubsetEnd_I;
        end

        function set.SubsetEnd( obj, val )
            obj.SubsetEnd_I = val;
            obj.updatePreviewPanel(  );
        end

        function val = get.SubsetStep( obj )
            val = obj.SubsetStep_I;
        end

        function set.SubsetStep( obj, val )
            obj.SubsetStep_I = val;
            obj.updatePreviewPanel(  );
        end

        function val = get.FunctionCode( obj )
            val = obj.FunctionCode_I;
            val = strrep( val, obj.VariableName, 'inputTable' );
        end
    end

    methods
        function obj = AppTask( PVPairs )
            arguments
                PVPairs.Task( 1, 1 )struct
                PVPairs.Workspace( 1, 1 )matlab.internal.datatoolsservices.AppWorkspace
                PVPairs.VariableName string = string.empty
                PVPairs.TableVariableName string = string.empty
                PVPairs.State( 1, 1 )struct = struct(  )
                PVPairs.TaskDocument
                PVPairs.PreviewPanel
                PVPairs.TaskCompletedFcn = @noop;
                PVPairs.SubsetStart( 1, 1 )double{ mustBePositive, mustBeInteger } = 1
                PVPairs.SubsetEnd( 1, 1 )double{ mustBeNonnegative, mustBeInteger } = 0
                PVPairs.SubsetStep( 1, 1 )double{ mustBePositive, mustBeInteger } = 1
                PVPairs.App = [  ]
            end
            if ~isempty( PVPairs.State ) && isfield( PVPairs.State, 'Task' )
                obj.Task = PVPairs.State.Task;
            else
                obj.Task = PVPairs.Task;
            end
            obj.App = PVPairs.App;
            obj.SubsetStart_I = PVPairs.SubsetStart;
            obj.SubsetEnd_I = PVPairs.SubsetEnd;
            obj.SubsetStep_I = PVPairs.SubsetStep;
            obj.TaskDocument = PVPairs.TaskDocument;
            obj.TaskDocument.TaskChangedFcn = @obj.updatePreviewPanel;

            obj.PreviewPanel = PVPairs.PreviewPanel;
            obj.updateWorkspaces( PVPairs.Workspace );
            obj.PreviewPanel.HasVisualization = obj.Task.HasVisualization;

            obj.PreviewPanel.setOriginalTableWorkspace( obj.Workspace );

            obj.TaskUI = obj.createTaskUI( obj.Task, PVPairs.VariableName, PVPairs.TableVariableName, PVPairs.Workspace, obj.TaskDocument, PVPairs.State );
            obj.TaskCompletedFcn = PVPairs.TaskCompletedFcn;


            obj.TaskDocument.startup( obj.TaskUI );

            if ~isempty( fieldnames( PVPairs.State ) )
                obj.State = PVPairs.State;
            end
            obj.TaskDocumentDeletionListener = addlistener( obj.TaskDocument, 'ObjectBeingDestroyed', @( e, d )obj.delete );


            obj.setSubset( PVPairs.SubsetStart, PVPairs.SubsetEnd, PVPairs.SubsetStep );
        end

        function delete( obj )
            if ~isempty( obj.TaskDocumentDeletionListener )
                obj.TaskDocumentDeletionListener.delete;
            end

            if ~isempty( obj.TaskDocument ) && isvalid( obj.TaskDocument )
                delete( obj.TaskDocument );
            end

            if ~isempty( obj.TaskUI ) && isvalid( obj.TaskUI )
                delete( obj.TaskUI );
            end
        end

        function setSubset( obj, subsetStart, subsetEnd, subsetStep )
            arguments
                obj
                subsetStart( 1, 1 )double{ mustBePositive, mustBeInteger } = 1
                subsetEnd( 1, 1 )double{ mustBeNonnegative, mustBeInteger } = 0
                subsetStep( 1, 1 )double{ mustBePositive, mustBeInteger } = 1
            end
            obj.SubsetStart_I = subsetStart;
            obj.SubsetEnd_I = subsetEnd;
            obj.SubsetStep_I = subsetStep;
            obj.updatePreviewPanel(  );
        end
    end

    methods ( Access = { ?AppTask, ?matlab.unittest.TestCase } )
        function updateWorkspaces( obj, workspace )
            if ~isempty( obj.PreviewPanel.OriginalTableView ) &&  ...
                    ~isempty( obj.PreviewPanel.OriginalTableView{ 1 }.Workspace )


                obj.PreviewPanel.OriginalTableView{ 1 }.Workspace = workspace.clone( obj.PreviewPanel.OriginalTableView{ 1 }.Workspace,  ...
                    'SubsetStart', obj.SubsetStart,  ...
                    'SubsetEnd', obj.SubsetEnd,  ...
                    'SubsetStep', obj.SubsetStep );
                obj.Workspace = obj.PreviewPanel.OriginalTableView{ 1 }.Workspace;
            else
                obj.Workspace = workspace;
            end

            if ~isempty( obj.PreviewPanel.PreprocessedTableView ) &&  ...
                    ~isempty( obj.PreviewPanel.PreprocessedTableView.Workspace )


                obj.PreviewPanel.PreprocessedTableView.Workspace =  ...
                    workspace.clone( obj.PreviewPanel.PreprocessedTableView.Workspace,  ...
                    'SubsetStart', obj.SubsetStart,  ...
                    'SubsetEnd', obj.SubsetEnd,  ...
                    'SubsetStep', obj.SubsetStep );
                obj.CurrentWorkspace = obj.PreviewPanel.PreprocessedTableView.Workspace;
            else


                obj.CurrentWorkspace = obj.Workspace.clone( 'SubsetStart', obj.SubsetStart,  ...
                    'SubsetEnd', obj.SubsetEnd,  ...
                    'SubsetStep', obj.SubsetStep );
            end
        end

        function TaskDocument = createTaskDocument( ~, docOptions )
            TaskDocument = matlab.internal.preprocessingApp.tasks.TaskDocument( docOptions );
        end

        function doc = createTaskPreviewPanel( ~, panelOptions )
            doc = matlab.internal.preprocessingApp.tasks.TaskPanel( panelOptions );
        end

        function taskUI = createTaskUI( obj, task, variable, tableVariable, workspace, taskDocument, oldState )
            taskUI = [  ];
            try


                if ~isempty( fieldnames( task ) )
                    taskCommand = task.Path;
                else
                    taskCommand = oldState.Path;
                end

                if contains( taskCommand, "(" )
                    taskCommand = split( taskCommand, "(" );
                    taskCommand = taskCommand( 1 ) + "(taskDocument.Figure, workspace, " + taskCommand( 2 ) + ";";
                else
                    taskCommand = taskCommand + "(taskDocument.Figure, workspace);";
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

                if ~isempty( fieldnames( oldState ) )
                    obj.TaskUI = taskUI;
                    obj.State = oldState;
                    return ;
                end
            catch e
                disp( e );
            end
        end

        function [ dataScript, varNames, codeGenScript ] = getScriptCode( obj )
            try
                [ dataScript, varNames ] = obj.TaskUI.generateScript(  );
                [ codeGenScript, ~ ] = obj.TaskUI.generateScript( true );
            catch
                dataScript = "";
                varNames = {  };
            end
        end

        function visScript = getVisualizationScript( obj )
            visScript = obj.TaskUI.generateVisualizationScript(  );
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

        function updatePreviewPanel( obj )
            obj.App.AppContainer.Busy = true;
            errorMsg = string.empty;
            obj.TaskDocument.disableUpdateInteractions;

            obj.callTaskStartedFcn(  );
            try
                if isvalid( obj ) && isvalid( obj.PreviewPanel )
                    [ dataScript, varNames ] = obj.getScriptCode(  );




                    if isempty( obj.CurrentWorkspace )
                        cloneWS = obj.Workspace.clone( 'SubsetStart', obj.SubsetStart, 'SubsetEnd', obj.SubsetEnd, 'SubsetStep', obj.SubsetStep );
                    else
                        cloneWS = obj.Workspace.clone( obj.CurrentWorkspace, 'SubsetStart', obj.SubsetStart, 'SubsetEnd', obj.SubsetEnd, 'SubsetStep', obj.SubsetStep );
                    end
                    obj.PreviewPanel.setPreprocessedTableWorkspace( cloneWS );
                    cleanupCode = string.empty;

                    if ~isempty( dataScript ) && strlength( dataScript ) > 0

                        dataScript = strrep( dataScript, '`', '' );
                        obj.pushCode( dataScript, true );
                        obj.pushFunctionCode( dataScript, true );

                        evalin( cloneWS, dataScript + ";" );
                        if obj.Task.HasVisualization
                            visScript = obj.getVisualizationScript(  );

                            if ~isempty( visScript ) && strlength( visScript ) > 0
                                if ~isempty( visScript )
                                    loadingScript = "yLimits=get(gca,'ylim');xLimits=get(gca,'xlim');" ...
                                        + "patch([xLimits(1), xLimits(1), xLimits(2), xLimits(2)], [yLimits(1), yLimits(2), yLimits(2), yLimits(1)], [0,0,0], 'FaceAlpha', 0.5);" ...
                                        + "text(xLimits(2)/2,yLimits(2)/2,'...','FontSize', 20, 'BackgroundColor', 'w');drawnow;clear yLimits xLimits";
                                    obj.PreviewPanel.updateVisualization( loadingScript, cloneWS );
                                end




                                cleanupCode = obj.generateTempVarCleanupCode( cloneWS );

                                obj.PreviewPanel.updateVisualization( visScript, cloneWS );
                            else

                                obj.PreviewPanel.updateVisualization( "cla", obj.Workspace );
                            end
                        end


                        if ~isempty( varNames )
                            varName = varNames{ 1 };
                            obj.updateTableView( cloneWS, varName, varNames );
                        end


                        obj.cleanupTempVars( cloneWS, cleanupCode );
                    else
                        obj.pushCode( string.empty, true );
                        obj.pushFunctionCode( string.empty, true );
                        if obj.Task.HasVisualization

                            obj.PreviewPanel.updateVisualization( "cla", obj.Workspace );
                        end
                        obj.updateTableView( obj.CurrentWorkspace );
                    end


                    obj.CurrentWorkspace = cloneWS;

                    obj.PreviousState = obj.State;
                end
            catch e
                errorMsg = e.message;
                if ~isempty( obj.TaskUI.UIFigure )
                    uialert( obj.TaskUI.UIFigure, errorMsg, 'Error' );
                end
                obj.Code = [  ];
            end
            obj.TaskDocument.enableUpdateInteractions;

            obj.callTaskCompletedFcn( isempty( errorMsg ), errorMsg );
            obj.App.AppContainer.Busy = false;
        end

        function updateTableView( obj, workspace, cleanVarName, outputVariables )
            arguments
                obj
                workspace
                cleanVarName = ""
                outputVariables = {  }
            end


            state = obj.State;
            if isempty( cleanVarName ) || strlength( cleanVarName ) == 0
                if ~isempty( obj.Task.InputProperty )
                    cleanVarName = state.( obj.Task.InputProperty );
                end
            end

            tableValue = table(  );
            tableName = [  ];
            if ~isempty( obj.Task.InputProperty ) && isfield( state, obj.Task.InputProperty )
                tableName = string( state.( obj.Task.InputProperty ) );
                obj.PreviewPanel.InputTableNames = tableName;
                try
                    tableValue = evalin( workspace, tableName );
                catch
                    tableValue = table(  );
                end
            end
            origTableValue = { tableValue };
            if ~isempty( obj.Task.SecondInputProperty ) && isfield( state, obj.Task.SecondInputProperty )
                secondInput = string( state.( obj.Task.SecondInputProperty ) );

                if ~strcmp( secondInput, 'select variable' )
                    obj.PreviewPanel.InputTableNames( end  + 1 ) = secondInput;
                    origTableValue{ end  + 1 } = evalin( workspace, secondInput );
                end
            end

            tableVariable = "";
            try
                varValue = evalin( workspace, cleanVarName );
            catch
                varValue = table(  );
            end

            if ~isa( varValue, 'tabular' ) && isa( tableValue, 'tabular' )
                isReshape = false;



                if ~isempty( obj.Task.InputProperty )
                    if ~isempty( tableName )



                        if ~isempty( obj.Task.ReshapeOutputVariable ) ...
                                && length( outputVariables ) >= obj.Task.ReshapeOutputVariable
                            isReshape = true;



                            indexVarName = outputVariables{ obj.Task.ReshapeOutputVariable };
                            indicies = evalin( workspace, indexVarName );
                            tableValue( indicies, : ) = [  ];


                            reshapeCode = sprintf( "%s(%s,:) = [];", tableName, indexVarName );
                            evalin( workspace, reshapeCode );
                            obj.pushCode( reshapeCode );
                            obj.pushFunctionCode( reshapeCode );
                        end



                        tableVariable = state.( obj.Task.TableVariableProperty );
                        tableVariable = replace( tableVariable, ".", "" );
                        tableValue.( tableVariable ) = varValue;


                        assigmentCode = sprintf( "%s.('%s') = %s;", tableName, tableVariable, cleanVarName );
                        evalin( workspace, assigmentCode );
                        obj.pushCode( assigmentCode );
                        obj.pushFunctionCode( assigmentCode );
                    end
                    varValue = tableValue;
                end
            else

                if ~strcmp( tableName, cleanVarName )
                    assigmentCode = sprintf( "%s = %s;", tableName, cleanVarName );
                    evalin( workspace, assigmentCode );
                    obj.pushCode( assigmentCode );
                    obj.pushFunctionCode( assigmentCode );
                end
            end

            if ~isempty( varValue ) && ~isempty( tableName )
                obj.PreviewPanel.setTableData( varValue, tableName, origTableValue );
            end
        end

        function clearCode = generateTempVarCleanupCode( obj, cloneWS )
            origVars = obj.Workspace.getVariables;
            cloneVariables = cloneWS.getVariables;
            origVarnames = string( fieldnames( origVars ) );
            cloneVarnames = string( fieldnames( cloneVariables ) );
            tempVars = ~ismember( cloneVarnames, origVarnames );
            tempVars = cloneVarnames( tempVars );
            if ~isempty( tempVars )
                clearCode = sprintf( "clear %s;", strjoin( tempVars, " " ) );
            else
                clearCode = string.empty;
            end
        end

        function cleanupTempVars( obj, cloneWS, clearCode )

            if isempty( clearCode ) || clearCode == ""
                clearCode = obj.generateTempVarCleanupCode( cloneWS );
            end

            if isempty( clearCode )


                return ;
            end

            obj.pushCode( "% Clean up temporary variables" );
            obj.pushCode( clearCode );


            evalin( cloneWS, clearCode );
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
                eventData.CurrentWorkspace = obj.CurrentWorkspace;
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

