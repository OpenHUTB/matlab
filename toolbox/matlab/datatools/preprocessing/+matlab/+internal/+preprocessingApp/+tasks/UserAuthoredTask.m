classdef UserAuthoredTask < handle


    properties ( Constant )
        VARNAME_TAG = "variableName"
        TABLEVARNAME_TAG = "tableVariableName"
        TABLEVARIABLE_TAG = "tableVariable"
        VARIABLECOLUMN_TAG = "variableColumn"
    end

    events
        StateChanged
    end

    properties
        UIFigure matlab.ui.Figure = matlab.ui.Figure.empty
        Workspace = "base"
        GridLayout

        Name( 1, 1 )string = ""
        Description( 1, 1 )string = ""
        Code string = string.empty
        PlotCode string = string.empty
        Summary_private( 1, 1 )string = ""
        HasTableVariable( 1, 1 )logical = false
        DocFunctions
    end

    properties ( Dependent )
        VariableName( 1, 1 )string
        TableVariableName( 1, 1 )string
        State
        Summary
    end
    methods
        function varName = get.VariableName( obj )
            state = obj.State;
            varName = "";
            if isfield( state, obj.VARNAME_TAG )
                varName = state.( obj.VARNAME_TAG );
            end
        end

        function tableVarName = get.TableVariableName( obj )
            state = obj.State;
            tableVarName = "";
            if isfield( state, obj.TABLEVARNAME_TAG )
                tableVarName = state.( obj.TABLEVARNAME_TAG );
            end
        end

        function summary = get.Summary( obj )
            summary = obj.constructCode( obj.Summary_private );
        end

        function state = get.State( obj )
            state = struct(  );


            tagNames = obj.getStateTags;
            if ~isempty( tagNames )
                for i = 1:length( tagNames )
                    tagName = tagNames( i );
                    if ~strcmp( tagName, obj.TABLEVARIABLE_TAG )
                        uielement = findobj( obj.UIFigure, 'Tag', tagName );
                        if ~isempty( uielement )
                            state.( tagName ) = uielement.Value;
                        end
                    else
                        varNameDD = findobj( obj.UIFigure, 'Tag', obj.VARNAME_TAG );
                        tableVarNameDD = findobj( obj.UIFigure, 'Tag', obj.TABLEVARNAME_TAG );
                        state.( obj.VARNAME_TAG ) = varNameDD.Value;
                        state.( obj.TABLEVARNAME_TAG ) = tableVarNameDD.Value;
                        state.( tagName ) = string( varNameDD.Value ) + string( tableVarNameDD.Value );
                    end
                end
            end
        end

        function set.State( obj, state )
            setTaskState( obj, state );
        end
    end

    methods
        function obj = UserAuthoredTask( figToPlotTo, workspace, nvpairs )
            arguments
                figToPlotTo = uifigure
                workspace = "base"
                nvpairs.Name( 1, 1 )string
                nvpairs.Description( 1, 1 )string = ""
                nvpairs.Code string
                nvpairs.PlotCode string = string.empty
                nvpairs.State( 1, 1 )struct = struct
                nvpairs.Summary( 1, 1 )string = ""
                nvpairs.VariableName( 1, 1 )string = ""
                nvpairs.TableVariableName( 1, 1 )string = ""
                nvpairs.HasTableVariable( 1, 1 )logical = false
                nvpairs.DocFunctions
            end

            obj.UIFigure = figToPlotTo;
            obj.Workspace = workspace;
            obj.Name = nvpairs.Name;
            obj.Description = nvpairs.Description;
            obj.Code = nvpairs.Code;
            obj.PlotCode = nvpairs.PlotCode;
            obj.Summary_private = nvpairs.Summary;
            obj.HasTableVariable = nvpairs.HasTableVariable;
            obj.DocFunctions = "";

            obj.createUI;


            state = nvpairs.State;
            if isempty( state )
                state = struct;
            end
            if strlength( nvpairs.VariableName ) > 0
                state.( obj.VARNAME_TAG ) = nvpairs.VariableName;
            end
            if strlength( nvpairs.TableVariableName ) > 0
                state.( obj.TABLEVARNAME_TAG ) = nvpairs.TableVariableName;
            end
            obj.State = state;
        end

        function [ script, varNames ] = generateScript( obj )
            varNames = { obj.VariableName };
            [ script, ~ ] = obj.constructCode( obj.Code );
            script = strcat( script, ';' );
            script = strjoin( script, newline );
        end

        function vizScript = generateVisualizationScript( obj )
            vizScript = obj.constructCode( obj.PlotCode );
            vizScript = strjoin( vizScript, newline );
        end

        function setTaskState( obj, state, propName )
            arguments
                obj
                state
                propName string = string.empty
            end
            tagNames = obj.getStateTags;
            if ~isempty( tagNames )
                for i = 1:length( tagNames )
                    tagName = tagNames( i );
                    uielement = findobj( obj.UIFigure, 'Tag', tagName );
                    if ~isempty( uielement ) && isfield( state, tagName )
                        try
                            val = state.( tagName );
                            uielement.Value = val;
                        catch

                            if isnumeric( val )
                                val = num2str( val );
                            end
                            uielement.Value = val;
                        end
                    elseif strcmp( tagName, obj.TABLEVARIABLE_TAG )
                        varNameDD = findobj( obj.UIFigure, 'Tag', obj.VARNAME_TAG );
                        tableVarNameDD = findobj( obj.UIFigure, 'Tag', obj.TABLEVARNAME_TAG );
                        if isfield( state, obj.VARNAME_TAG )
                            varNameDD.Value = state.( obj.VARNAME_TAG );
                        elseif isfield( state, obj.TABLEVARIABLE_TAG )
                            s = strsplit( state.( obj.TABLEVARIABLE_TAG ) );
                            varNameDD.Value = s( 1 );
                        end
                        obj.updateTableVariableNamesDropDown( varNameDD, tableVarNameDD );
                        if isfield( state, obj.TABLEVARNAME_TAG )
                            tableVarNameDD.Value = state.( obj.TABLEVARNAME_TAG );
                        elseif isfield( state, obj.TABLEVARIABLE_TAG )
                            s = strsplit( state.( obj.TABLEVARIABLE_TAG ) );
                            varNameDD.Value = s( 2 );
                        end
                    end
                end
            end

            notify( obj, 'StateChanged' );
        end

        function initialize( obj, NVPairs )
            arguments
                obj( 1, 1 )matlab.internal.preprocessingApp.tasks.UserAuthoredTask
                NVPairs.Inputs = string.empty
                NVPairs.TableVariableNames = string.empty
            end
            state = struct(  );
            if ~isempty( NVPairs.Inputs )
                state.( obj.VARNAME_TAG ) = NVPairs.Inputs;
            end
            if ~isempty( NVPairs.TableVariableNames )
                if ~startsWith( NVPairs.TableVariableNames, "." )
                    state.( obj.TABLEVARNAME_TAG ) = "." + NVPairs.TableVariableNames;
                else
                    state.( obj.TABLEVARNAME_TAG ) = NVPairs.TableVariableNames;
                end
            end

            obj.State = state;
        end

        function reset( obj )
            obj.State = struct;
        end

        function task = getTask( obj )
            task = struct(  );
            task.Name = obj.Name;
            task.Description = obj.Description;
            task.Group = getString( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_USER' ) );
            task.Path = obj.getPath;
            task.Icon = matlab.ui.internal.toolstrip.Icon.TOOLS_24;
            task.InputProperty = obj.VARNAME_TAG;
            if obj.HasTableVariable
                task.TableVariableProperty = obj.TABLEVARNAME_TAG;
            else
                task.TableVariableProperty = "";
            end
            task.TableVariableNamesProperty = "";
            task.TableVariableVisibleProperty = "";
            task.HasVisualization = ~isempty( obj.PlotCode ) && any( strlength( obj.PlotCode ) ) > 0;
            task.ReshapeOutputVariable = "";
            task.IsTimetableProperty = "";
            task.HasRowLabelsProperty = "";
            task.NumberOfTableVariablesProperty = "";
            task.DocFunctions = [  ];
        end

        function addTaskToFactory( obj )
            atf = matlab.internal.preprocessingApp.tasks.AppTaskFactory.getInstance;
            task = obj.getTask;
            atf.addTask(  ...
                'Name', task.Name ...
                , 'Description', task.Description ...
                , 'Group', task.Group ...
                , 'Path', task.Path ...
                , 'Icon', task.Icon ...
                , 'HasVisualization', task.HasVisualization ...
                , 'ReshapeOutputVariable', task.ReshapeOutputVariable ...
                , 'InputProperty', task.InputProperty ...
                , 'TableVariableProperty', task.TableVariableProperty ...
                );
        end

        function removeTaskFromFactory( obj )
            atf = matlab.internal.preprocessingApp.tasks.AppTaskFactory.getInstance;
            atf.removeTask( obj.Name, getString( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_USER' ) ) );
        end

        function propTable = getPropertyInformation( obj )






















            variableGroupName = string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_PP_DIALOG_SELECT_DATA_GROUP' ) );
            if obj.HasTableVariable
                inputPropNames = [ obj.VARNAME_TAG;obj.TABLEVARNAME_TAG ];
                displayNames = [ string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_PP_DIALOG_VARIABLENAME' ) ); ...
                    string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_PP_DIALOG_TABLEVARNAME' ) ) ];
            else
                inputPropNames = [ obj.VARNAME_TAG ];
                displayNames = [ string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_PP_DIALOG_VARIABLENAME' ) ) ];
            end
            stateNames = inputPropNames;

            inputArgsGroupName = string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_PP_DIALOG_INPUT_ARGS_GROUP' ) );
            [ tagNames ] = obj.getStateTags(  )';
            tagNames = tagNames( ~ismember( tagNames, [ obj.VARNAME_TAG, obj.TABLEVARNAME_TAG, obj.TABLEVARIABLE_TAG, obj.VARIABLECOLUMN_TAG ] ) );

            propNames = [ inputPropNames;tagNames ];
            displayNames = [ displayNames;tagNames ];
            stateNames = [ stateNames;tagNames ];

            groupNames = [ repmat( variableGroupName, length( inputPropNames ), 1 );repmat( inputArgsGroupName, length( tagNames ), 1 ); ];

            types = [ "matlab.ui.control.internal.model.WorkspaceDropDown" ];
            if obj.HasTableVariable
                types = [ types;"matlab.ui.control.DropDown"; ];
            end
            types = [ types;repmat( "", length( tagNames ), 1 ) ];

            tooltips = repmat( "", length( propNames ), 1 );
            items = repmat( { char.empty }, length( propNames ), 1 );
            itemsData = repmat( { char.empty }, length( propNames ), 1 );
            visible = true( length( propNames ), 1 );
            enable = true( length( propNames ), 1 );
            initializeFlag = zeros( length( propNames ), 1 );
            inSubgroup = false( length( propNames ), 1 );
            groupExpanded = true( length( propNames ), 1 );


            initializeFlag( 1 ) = 1;
            varNameDD = findobj( obj.UIFigure, 'Tag', obj.VARNAME_TAG );
            items{ 1 } = varNameDD.Items;
            itemsData{ 1 } = varNameDD.ItemsData;

            if obj.HasTableVariable
                initializeFlag( 2 ) = 2;
                tableVarNameDD = findobj( obj.UIFigure, 'Tag', obj.TABLEVARNAME_TAG );
                if isempty( tableVarNameDD.Items )
                    items{ 2 } = { string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:USER_AUTHORED_TASKS_SELECT_A_VARIABLE' ) ) };
                    itemsData{ 2 } = { string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:USER_AUTHORED_TASKS_SELECT_A_VARIABLE' ) ) };
                else
                    items{ 2 } = tableVarNameDD.Items;
                    itemsData{ 2 } = tableVarNameDD.ItemsData;
                end
            end

            propTable = table( propNames, groupNames, displayNames, stateNames, types, tooltips, items, itemsData, visible, enable, initializeFlag, inSubgroup, groupExpanded,  ...
                'VariableNames', { 'Name', 'Group', 'DisplayName', 'StateName', 'Type', 'Tooltip', 'Items', 'ItemsData', 'Visible', 'Enable', 'InitializeFlag', 'InSubgroup', 'GroupExpanded' } );
        end
    end

    methods ( Access = { ?matlab.internal.preprocessingApp.tasks.UserAuthoredTask, ?matlab.unittest.TestCase } )
        function createUI( obj )
            obj.GridLayout = uigridlayout( obj.UIFigure, 'BackgroundColor', 'white' );
            obj.GridLayout.ColumnSpacing = 5;
            obj.GridLayout.RowSpacing = 5;
            obj.GridLayout.Padding = [ 1, 1, 1, 1 ];
            obj.GridLayout.Scrollable = 'on';

            variableLabel = uilabel( obj.GridLayout );
            variableLabel.HorizontalAlignment = 'right';
            variableLabel.Layout.Row = 1;
            variableLabel.Layout.Column = 1;
            variableLabel.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_PP_DIALOG_VARIABLENAME' ) );

            wsdd = matlab.ui.control.internal.model.WorkspaceDropDown( 'Parent', obj.GridLayout, 'Workspace', obj.Workspace );
            wsdd.Tag = obj.VARNAME_TAG;
            wsdd.Layout.Row = 1;
            wsdd.Layout.Column = 2;
            rowCounter = 1;

            if obj.HasTableVariable
                rowCounter = 2;
                tableVariableLabel = uilabel( obj.GridLayout );
                tableVariableLabel.HorizontalAlignment = 'right';
                tableVariableLabel.Layout.Row = 2;
                tableVariableLabel.Layout.Column = 1;
                tableVariableLabel.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_PP_DIALOG_TABLEVARNAME' ) );

                tableNamesDD = uidropdown( obj.GridLayout );
                tableNamesDD.Layout.Row = 2;
                tableNamesDD.Layout.Column = 2;
                tableNamesDD.Tag = obj.TABLEVARNAME_TAG;

                obj.updateTableVariableNamesDropDown( wsdd, tableNamesDD );
                wsdd.ValueChangedFcn = @( e, d )obj.updateTableVariableNamesDropDown( wsdd, tableNamesDD );
            end


            tagNames = obj.getStateTags(  );
            for i = 1:length( tagNames )
                tagName = tagNames( i );
                if ~ismember( tagName, [ obj.VARNAME_TAG, obj.TABLEVARNAME_TAG, obj.TABLEVARIABLE_TAG ] )
                    rowCounter = rowCounter + 1;

                    userFieldLabel = uilabel( obj.GridLayout );
                    userFieldLabel.HorizontalAlignment = 'right';
                    userFieldLabel.Layout.Row = rowCounter;
                    userFieldLabel.Layout.Column = 1;
                    userFieldLabel.Text = tagName.replace( "_", " " );

                    tableNamesDD = obj.createComponentForArgument( tagName, obj.GridLayout, rowCounter );
                end
            end

            obj.GridLayout.RowHeight = repmat( 25, 1, rowCounter );
            obj.GridLayout.ColumnWidth = [ 200, 200 ];
        end

        function comp = createComponentForArgument( ~, argName, layout, row )
            comp = uieditfield( layout );
            comp.Layout.Row = row;
            comp.Layout.Column = 2;
            comp.Tag = argName;
        end

        function updateTableVariableNamesDropDown( obj, wsdd, tableNamesDD )
            tableNamesDD.Items = {  };
            try
                varName = wsdd.Value;
                if ~isempty( varName ) && strlength( varName ) > 0
                    varValue = evalin( obj.Workspace, varName );
                    selectData = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:USER_AUTHORED_TASKS_SELECT_A_VARIABLE' ) );
                    if istimetable( varValue )
                        tableNamesDD.Items = [ selectData, ( "." + varValue.Properties.DimensionNames{ 1 } ), ( "." + varValue.Properties.VariableNames ) ];
                    elseif istable( varValue )
                        tableNamesDD.Items = [ selectData, ( "." + varValue.Properties.VariableNames ) ];
                    elseif isnumeric( varValue )
                        tableNamesDD.Items = [ selectData, ( "." + string( 1:size( varValue, 2 ) ) ) ];
                    end
                end
            catch
            end
        end

        function [ varNames, tagNames ] = getVariableNamesInCode( ~, code )
            varNames = string.empty;
            tagNames = string.empty;
            if ~isstring( code )
                code = string( code );
            end
            if ~isempty( code )
                varNames = regexp( code, "(?<tag>{\$.*?})", "match" );
                if length( code ) > 1
                    varNames = unique( string( [ varNames{ : } ] ), 'stable' );
                else
                    varNames = unique( varNames, 'stable' );
                end
                if ~isempty( varNames )
                    tagNames = varNames.replace( "{$", "" ).replace( "}", "" ).replace( " ", "_" );
                end
            end
        end

        function tagNames = getStateTags( obj )
            tagNames = string.empty;
            [ ~, codeTagNames ] = obj.getVariableNamesInCode( obj.Code );
            [ ~, plotTagNames ] = obj.getVariableNamesInCode( obj.PlotCode );
            allTags = [ codeTagNames, plotTagNames ];
            if ~isempty( allTags )
                tagNames = unique( allTags, 'stable' );
            end
        end

        function [ outCode, tagNames ] = constructCode( obj, inCode )
            outCode = inCode;
            tagNames = {  };
            if strcmp( obj.VariableName, 'select variable' ) ||  ...
                    ( obj.HasTableVariable &&  ...
                    strcmp( obj.TableVariableName, getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:USER_AUTHORED_TASKS_SELECT_A_VARIABLE' ) ) ) )
                outCode = "";
                return ;
            end


            tableVariable = string( obj.VariableName ) + string( obj.TableVariableName );
            variableColumn = obj.VariableName + "(" + obj.TableVariableName + ")";
            outCode = replace( outCode, "{$" + obj.TABLEVARIABLE_TAG + "}", tableVariable );
            outCode = replace( outCode, "{$" + obj.VARNAME_TAG + "}", obj.VariableName );
            outCode = replace( outCode, "{$" + obj.TABLEVARNAME_TAG + "}", replace( obj.TableVariableName, ".", "" ) );
            outCode = replace( outCode, "{$" + obj.VARIABLECOLUMN_TAG + "}", variableColumn );



            [ varNames, tagNames ] = obj.getVariableNamesInCode( outCode );
            state = obj.State;
            if ~isempty( varNames )
                for i = 1:length( tagNames )
                    tagName = tagNames( i );
                    if isfield( state, tagName ) && ~isempty( state.( tagName ) )
                        outCode = outCode.replace( varNames( i ), string( state.( tagName ) ) );
                    else


                        outCode = "";
                    end
                end
            end
        end

        function path = getPath( ~ )
            path = mfilename( 'class' );
        end
    end
end

