classdef VariableTuner < simulink.internal.SLComponent




    properties ( Access = protected )
        tgEventsTriggeringUpdateGUI =  ...
            {  ...
            'Connected',  ...
            'Disconnected',  ...
            'Loaded',  ...
            'Started',  ...
            'Stopped' ...
            }
    end

    properties ( Access = public, SetObservable )
        Enable matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.on
        DisplayVariables cell
        FontColor{ validateattributes( FontColor, { 'double' }, { '<=', 1, '>=', 0, 'size', [ 1, 3 ] } ) } = [ 0, 0, 0 ]

        EnableLiveTuning matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.on;
    end

    properties ( Access = private, Transient, NonCopyable )
        Grid matlab.ui.container.GridLayout
        PrmsGL matlab.ui.container.GridLayout

        StatusLabel matlab.ui.control.Label

        TabGroup

        Model
        TunableVariables

        OldDisplayVariables

        DisplayBeingUpdated = false
        UserChangedDisplayVars = false

        RuntimeUpdatedVariables( 1, : )Simulink.Simulation.Variable
    end

    methods ( Access = protected )

        function setup( obj )

            obj.Grid = uigridlayout( obj, [ 1, 1 ],  ...
                'ColumnWidth', { '1x' },  ...
                'RowHeight', { '1x' },  ...
                'ColumnSpacing', 0,  ...
                'RowSpacing', 5,  ...
                'Padding', 0,  ...
                'BackgroundColor', 'white' );

            obj.buildContent(  );
            obj.BackgroundColor = [ 1, 1, 1 ];
            obj.Position = [ 25, 50, 505, 250 ];

            addlistener( obj, 'DisplayVariables', 'PostSet', @( src, event )obj.handleVarsUpdated(  ) );
        end

        function update( obj )
            if obj.firstUpdate


                if isempty( obj.GetTargetNameFcnH )
                    obj.initTarget( [  ] );
                end
            end

            obj.updateGUI( [  ] );
        end

    end

    methods ( Access = public, Hidden )
        function disableControlForInvalidTarget( obj )
            delete( obj.StatusLabel );
            obj.StatusLabel = obj.getLabelFor( message( 'simulinkcompiler:simulink_components:InvalidTargetTooltip',  ...
                obj.GetTargetNameFcnH(  ) ).getString(  ) );
            obj.Grid.RowHeight = { '1x' };
            obj.StatusLabel.Layout.Row = 1;
            obj.StatusLabel.Layout.Column = 1;
        end

        function enableControlForValidTarget( obj )
            obj.TabGroup.Tooltip = message( 'simulinkcompiler:simulink_components:VariableTunerTooltip' ).getString(  );
        end

        function updateGUI( obj, ~ )

            obj.enableDisable(  );
            obj.updateTheme(  );

            if obj.DisplayBeingUpdated
                return ;
            end

            if ~obj.isDesignTime(  )
                obj.verifyTargetIsInitialised(  );
            end

            tg = obj.tgGetTargetObject(  );
            if tg.isTargetEmpty(  ), return ;end

            if isempty( tg.SimulationInput )
                return ;
            end

            if isempty( obj.Model )
                obj.Model = tg.ModelName;
            end

            obj.DisplayBeingUpdated = true;

            if obj.firstUpdate
                addlistener( tg, 'Resuming', @( ~, ~ )obj.ResumeButtonPressed(  ) );
            end
            if obj.firstUpdate ||  ...
                    ~isempty( setdiff( obj.DisplayVariables, obj.OldDisplayVariables ) )

                try
                    obj.TabGroup.Tooltip = message( 'simulinkcompiler:simulink_components:VariableTunerTooltip' ).getString(  );
                    varNames = [  ];
                    loading1 = showLoadingIndicatorAtGridPosition( obj.Grid, 1, 1 );
                    drawnow limitrate;


                    try
                        tunableVars = obj.getTunableVariablesForModel(  );
                        if isempty( tunableVars )
                            varNames = [  ];
                        else
                            varNames = [ tunableVars.Name ];
                        end
                    catch
                    end

                    for idx = 1:numel( varNames )
                        updateVariable( obj, varNames( idx ), tunableVars( idx ).Value, tunableVars( idx ).Workspace );
                    end

                    delete( loading1 );

                    obj.buildContent(  );

                    if isempty( varNames )
                        delete( obj.StatusLabel );
                        obj.StatusLabel = obj.getLabelFor( message( 'simulinkcompiler:simulink_components:NoTunableVariables' ).getString(  ) );
                        obj.Grid.RowHeight = { '1x' };
                        obj.StatusLabel.Layout.Row = 1;
                        obj.StatusLabel.Layout.Column = 1;
                        drawnow limitrate;
                        obj.DisplayBeingUpdated = false;
                        return ;
                    end

                    obj.setupPrmsGL(  );

                    drawnow limitrate;

                catch ME

                end
                obj.firstUpdate = false;
            end

            obj.DisplayBeingUpdated = false;
        end
    end

    methods ( Access = private )

        function enableDisable( obj )
            choices = { 'on', 'off' };

            if obj.Enable
                choices = sort( choices );
            end

            enablableComps = findobj( obj.TabGroup, 'Enable', choices{ 1 } );
            enable = choices{ 2 };

            for child = enablableComps'
                child.Enable = enable;
            end
        end

        function updateTheme( obj )

            tabs = obj.TabGroup.Children;
            for tab = tabs'
                tabChildren = findobj( tab, '-function', 'BackgroundColor', @( x )~isempty( x ) );
                set( tabChildren, 'BackgroundColor', obj.BackgroundColor );
            end


            tabs = obj.TabGroup.Children;
            for tab = tabs'
                tabChildren = findobj( tab, '-function', 'FontColor', @( x )~isempty( x ) );
                set( tabChildren, 'FontColor', obj.FontColor );
            end

            tables = findobj( tab, 'Type', 'uitable' );
            style = uistyle;
            style.FontColor = obj.FontColor;
            style.BackgroundColor = obj.BackgroundColor;
            for table = tables'
                addStyle( table, style );
            end

            drawnow limitrate;
        end

        function buildContent( obj )

            obj.TabGroup = uitabgroup( obj.Grid );

            obj.TabGroup.Layout.Row = 1;
            obj.TabGroup.Layout.Column = 1;

            paramsTab = uitab( obj.TabGroup, Title = "Variables", Tag = "_vars_tab_" );

            prmsWrapperGL = uigridlayout( paramsTab, [ 2, 1 ],  ...
                'ColumnWidth', { '1x' },  ...
                'RowHeight', { 25, '1x' },  ...
                'ColumnSpacing', 2,  ...
                'RowSpacing', 2,  ...
                'Padding', 0,  ...
                'BackgroundColor', 'white' );

            prmsHeaderWrapperGL = uigridlayout( prmsWrapperGL, [ 1, 3 ],  ...
                'ColumnWidth', { '0.3x', '2x', '0.3x' },  ...
                'RowHeight', { '1x' },  ...
                'ColumnSpacing', 0,  ...
                'RowSpacing', 0,  ...
                'Padding', 0,  ...
                'BackgroundColor', [ 0.8, 0.8, 0.8 ] );

            prmsHeaderWrapperGL.Layout.Row = 1;
            prmsHeaderWrapperGL.Layout.Column = 1;

            prmsHeaderGL = uigridlayout( prmsHeaderWrapperGL, [ 1, 2 ],  ...
                'ColumnWidth', { '1x', '1x' },  ...
                'RowHeight', { '1x' },  ...
                'ColumnSpacing', 0,  ...
                'RowSpacing', 0,  ...
                'Padding', 0,  ...
                'BackgroundColor', [ 0.8, 0.8, 0.8 ] );

            prmsHeaderGL.Layout.Row = 1;
            prmsHeaderGL.Layout.Column = 2;


            prmsInnerWrapperGL = uigridlayout( prmsWrapperGL, [ 1, 3 ],  ...
                'ColumnWidth', { '0.3x', '2x', '0.3x' },  ...
                'RowHeight', { 'fit' },  ...
                'ColumnSpacing', 0,  ...
                'RowSpacing', 0,  ...
                'Padding', [ 0, 10, 0, 10 ],  ...
                'BackgroundColor', 'white',  ...
                'Scrollable', 'on' );

            prmsInnerWrapperGL.Layout.Row = 2;
            prmsInnerWrapperGL.Layout.Column = 1;

            obj.PrmsGL = uigridlayout( prmsInnerWrapperGL, [ 1, 2 ],  ...
                'ColumnWidth', { '1x', '1x' },  ...
                'RowHeight', { 'fit' },  ...
                'ColumnSpacing', 0,  ...
                'RowSpacing', 10,  ...
                'Padding', 0,  ...
                'BackgroundColor', 'white' );

            obj.PrmsGL.Layout.Row = 1;
            obj.PrmsGL.Layout.Column = 2;


            lbl = uilabel( prmsHeaderGL );
            lbl.HorizontalAlignment = 'left';
            lbl.Text = message( 'simulinkcompiler:simulink_components:Variable' ).getString;

            lbl.Layout.Row = 1;
            lbl.Layout.Column = 1;

            lbl = uilabel( prmsHeaderGL );
            lbl.HorizontalAlignment = 'left';
            lbl.Text = message( 'simulinkcompiler:simulink_components:Value' ).getString;

            lbl.Layout.Row = 1;
            lbl.Layout.Column = 2;
        end

        function handleVarsUpdated( obj )
            obj.UserChangedDisplayVars = true;
            obj.updateGUI( [  ] );
        end

        function tunableVars = getTunableVariablesForModel( obj )
            tunableVars = [  ];

            tg = obj.tgGetTargetObject(  );
            if tg.isTargetEmpty(  ), return ;end

            if isempty( obj.Model )
                obj.Model = tg.ModelName;
            end

            if isempty( obj.TunableVariables )
                variables = simulink.compiler.getTunableVariables( obj.Model );

                allTunableVars = struct( 'QualifiedName', {  }, 'Value', {  }, 'Workspace', {  } );

                for idx = 1:numel( variables )
                    allTunableVars( idx ).QualifiedName = variables( idx ).QualifiedName;
                    allTunableVars( idx ).Value = variables( idx ).Value;
                    allTunableVars( idx ).Workspace = char( obj.Model );
                end
                obj.TunableVariables = allTunableVars;
            end

            tunableVars = struct( 'QualifiedName', {  }, 'Value', {  }, 'Workspace', {  } );

            if ~obj.UserChangedDisplayVars
                tunableVars = obj.TunableVariables;
                vars = tv2slsv( tunableVars );
                obj.DisplayVariables = cellstr( [ vars.Name ] );
            else
                tunableVars = obj.getVisibleTunableVars( tunableVars );
                obj.OldDisplayVariables = obj.DisplayVariables;
            end

            tunableVars = tv2slsv( tunableVars );
        end

        function updateVariable( obj, varName, newValue, workspace )
            tg = obj.tgGetTargetObject(  );
            if tg.isTargetEmpty(  ), return ;end

            simIn = tg.SimulationInput;
            simIn = simIn.setVariable( char( varName ), newValue, 'Workspace', workspace );
            tg.SimulationInput = simIn;
        end

        function tunableVars = getVisibleTunableVars( obj, tunableVars )
            for var = obj.TunableVariables
                topVar = extractTopVarName( var.QualifiedName );
                [ isaMember, idx ] = ismember( cellstr( topVar ), obj.DisplayVariables );
                if isaMember
                    tunableVars( idx ) = var;
                end
            end
        end

        function label = getLabelFor( obj, text )
            label = uilabel( obj.Grid,  ...
                'Text', [ '<p style="padding:20px">', text, '</p>' ],  ...
                'VerticalAlignment', 'center',  ...
                'HorizontalAlignment', 'center',  ...
                'BackgroundColor', [ 0.9, 0.9, 0.9 ],  ...
                'Interpreter', 'html',  ...
                'WordWrap', 'on' );
        end

        function createNoVariableSelectedLabel( obj )
            obj.StatusLabel = obj.getLabelFor( 'Use the Parameters pane to tune scalars or drill into nonscalars to tune them here.' );
            obj.StatusLabel.Layout.Row = 1;
            obj.StatusLabel.Layout.Column = 2;
        end

        function cleanUpStatusLabel( obj )
            if ~isempty( obj.StatusLabel ) && isvalid( obj.StatusLabel )
                delete( obj.StatusLabel );
            end
        end

        function fillVariableEditTab( obj, varName, var, mode )













            import matlab.internal.datatoolsservices.getWorkspaceDisplay;

            tabGroup = obj.TabGroup;

            if isequal( mode, 'Create' ) && foundAndActivatedTab( tabGroup, varName )
                return ;
            end

            if isequal( mode, 'Update' ) && ~obj.varHasTab( varName )
                return ;
            end

            subVar = evalSubVarValue( varName, var );
            varTable = obj.getVarTable( mode, varName );

            varData.mode = 'Create';
            varData.var = var;
            varData.varName = varName;
            varData.subVar = subVar;
            varData.varTable = varTable;
            varData.view = 'FieldValue';
            varData.fieldNames = {  };
            varData.fieldValues = {  };

            varDisplaydata = getWorkspaceDisplay( { subVar } );

            if varDisplaydata.IsSummary
                obj.createDrillInVarView( varData );
            else
                obj.createEditVarView( varData );
            end
        end



        function TF = varHasTab( obj, varName )
            tab = findobj( obj.TabGroup, "Title", varName );
            TF = ~isempty( tab );
        end

        function createDrillInVarView( obj, varData )
            if isstruct( varData.subVar )
                obj.processStructVar( varData );

            elseif iscell( varData.subVar )
                obj.processCellVar( varData );

            elseif ismatrix( varData.subVar )
                obj.processMatrixVar( varData );
            end
        end



        function processStructVar( obj, varData )
            import matlab.internal.datatoolsservices.getWorkspaceDisplay;
            varData.view = 'FieldValue';

            if isscalar( varData.subVar )
                [ varData.fieldNames, varData.fieldValues ] =  ...
                    exctractStructVars( varData.subVar );
            else
                for idx = 1:numel( varData.subVar )
                    [ structArrElmNames, structArrElmValues ] =  ...
                        exctractStructVars( varData.subVar );
                    varData.fieldNames = [ varData.fieldNames;structArrElmNames ];
                    varData.fieldValues = [ varData.fieldValues;structArrElmValues ];
                end
            end

            varData = setStructVarData( varData );
            varData.varTable.SelectionChangedFcn = @( table, event )obj.btnDnCbk(  ...
                event, varData );
        end



        function processCellVar( obj, varData )

            import matlab.internal.datatoolsservices.getWorkspaceDisplay;

            varData.view = 'Cell';
            cellIdx = numel( varData.subVar );
            cellValues( cellIdx ) = "";

            while cellIdx > 0
                elem = varData.subVar( cellIdx );
                elemDisplaydata = getWorkspaceDisplay( elem );
                cellValues( cellIdx ) = elemDisplaydata.Value;
                cellIdx = cellIdx - 1;
            end

            varData.varTable.Data = reshape( cellValues, size( varData.var ) );
            varData.varTable.ColumnEditable = true( 1, size( varData.subVar, 2 ) );

            varData.varTable.SelectionChangedFcn = @( table, event )obj.btnDnCbk(  ...
                event, varData );
        end



        function processMatrixVar( obj, varData )
            varData.view = 'Edit';

            varData.varTable.Data = varData.subVar;
            varData.varTable.ColumnEditable = true( 1, size( varData.subVar, 2 ) );
            varData.varTable.CellEditCallback = @( table, event )obj.varValueChanged(  ...
                table, event );

            varData.varTable.SelectionChangedFcn = @( table, event )obj.btnDnCbk(  ...
                event, varData );
        end



        function createEditVarView( obj, varData )
            varData.view = 'Edit';

            if ischar( varData.subVar )
                varData.subVar = string( varData.subVar );
            end

            varData.varTable.Data = varData.subVar;
            varData.varTable.ColumnEditable = true( 1, numel( varData.subVar ) );
            varData.varTable.CellEditCallback = @( table, event )obj.varValueChanged(  ...
                table, event );

            varData.varTable.SelectionChangedFcn = @( table, event )obj.btnDnCbk(  ...
                event, varData );
        end



        function varTable = createNewTabWithTable( obj, tabGroup, varName )
            newTab = uitab( tabGroup, "Title", varName, "Scrollable", "on" );
            fig = ancestor( obj.Grid, 'figure' );
            newTab.ContextMenu = uicontextmenu( fig );
            newTab.Tooltip = varName;
            tabGroup.SelectedTab = newTab;
            obj.addCloseMenuToTab( newTab );

            grid = uigridlayout( newTab,  ...
                "ColumnWidth", { '1x' },  ...
                "RowHeight", { '1x' },  ...
                "Padding", [ 0, 0, 0, 0 ] );

            varTable = uitable( grid );
        end



        function btnDnCbk( obj, event, varData )
            varData.varTable.Selection = [  ];
            if isDoubleClick(  ) && ~isequal( varData.view, 'Edit' )
                obj.drillInTriggered( event, varData );
                obj.updateTheme(  );
            end
        end



        function drillInTriggered( obj, event, varData )
            switch ( varData.view )
                case 'FieldValue'
                    obj.spawnFieldValueView( event, varData );

                case 'Field'
                    obj.spawnFieldView( event, varData );

                case 'Cell'
                    obj.spawnCellView( event, varData );
            end
        end



        function spawnFieldValueView( obj, event, varData )
            row = event.Selection( 1 );
            col = event.Selection( 2 );

            if isequal( event.SelectionType, 'cell' ) && col == 2
                vName = varData.varTable.Data( row, 1 );
            else
                vName = varData.varTable.Data( row, col );
            end

            obj.fillVariableEditTab( varData.varName + "." + vName,  ...
                varData.var, varData.mode );
        end



        function spawnFieldView( obj, event, varData )
            import matlab.internal.datatoolsservices.getWorkspaceDisplay;

            row = event.Selection( 1 );
            qualifiedSubVarName = varData.subVar( row ).( varData.fieldNames( 1 ) );
            subVarDisplayData = getWorkspaceDisplay( { qualifiedSubVarName } );
            varData.varTable.ColumnEditable = ~subVarDisplayData.IsSummary;

            if subVarDisplayData.IsSummary
                varData.varTable.CellEditCallback = [  ];
                arrayIndex = "(" + row + ")";
                newTabVarName = varData.varName + arrayIndex + "." +  ...
                    varData.fieldNames( 1 );
                obj.fillVariableEditTab( newTabVarName, varData.var,  ...
                    varData.mode );
            else
                varData.varTable.CellEditCallback =  ...
                    @( table, event )obj.varValueChanged( table, event );
            end
        end



        function spawnCellView( obj, event, varData )
            row = event.Selection( 1 );
            col = event.Selection( 2 );
            varData.varTable.CellEditCallback = [  ];
            cellIndex = "{" + row + ", " + col + "}";
            obj.fillVariableEditTab( varData.varName + cellIndex,  ...
                varData.var, varData.mode );
        end

        function simIn = updateSimInVarsFromTunableVars( obj )
            tg = obj.tgGetTargetObject(  );
            if tg.isTargetEmpty(  ), return ;end

            simIn = tg.SimulationInput;
            simIn.Variables = tv2slsv( obj.TunableVariables );
            tg.SimulationInput = simIn;
        end



        function varValueChanged( obj, table, event )
            if isequal( event.PreviousData, event.NewData )
                return ;
            end

            vName = table.Parent.Parent.Title;
            newValue = table.Data;

            search = [ obj.TunableVariables.QualifiedName ] == vName;
            obj.TunableVariables( search ).Value = newValue;

            obj.modifyTunableVariable( obj.TunableVariables( search ) );

            topVarName = extractTopVarName( vName );

            simIn = obj.updateSimInVarsFromTunableVars(  );

            simInVarNames = [ simIn.Variables.Name ];
            topVar = simIn.Variables( simInVarNames == topVarName ).Value;
            obj.fillVariableEditTab( topVarName, topVar, 'Update' );



        end



        function varTable = getVarTable( obj, mode, varName )
            tabGroup = obj.TabGroup;
            if isequal( mode, 'Create' )
                varTable = obj.createNewTabWithTable( tabGroup, varName );
            else
                tab = findobj( tabGroup, "Title", varName );
                varTable = findobj( tab, "Type", 'uitable' );
            end
        end



        function setupPrmsGL( obj )








            import matlab.internal.datatoolsservices.getWorkspaceDisplay;

            delete( obj.PrmsGL.Children );

            tunableVars = obj.getTunableVariablesForModel(  );

            simVars = tv2slsv( tunableVars );
            nTV = length( simVars );
            obj.PrmsGL.RowHeight = repmat( { 'fit' }, 1, nTV );

            for iTV = 1:nTV
                paramName = simVars( iTV ).Name;
                lbl = uilabel( obj.PrmsGL );
                lbl.Layout.Row = iTV;
                lbl.Layout.Column = 1;
                lbl.HorizontalAlignment = 'left';
                paramValue = simVars( iTV ).Value;
                lbl.Text = paramName;

                if ~isscalar( paramValue ) || isstruct( paramValue )
                    displayData = getWorkspaceDisplay( { paramValue } );

                    wgt = uipanel( obj.PrmsGL, 'BorderType', 'none' );
                    wgtGL = uigridlayout( wgt, 'BackgroundColor', 'white' );
                    wgtGL.ColumnWidth = { '1x', 'fit' };
                    wgtGL.RowHeight = { '1x' };
                    wgtGL.Padding = [ 0, 0, 0, 0 ];

                    chWgt1 = uilabel( wgtGL );
                    chWgt1.Text = displayData.Size + " " + displayData.Class;
                    chWgt1.Layout.Column = 1;

                    chWgt2 = uibutton( wgtGL );
                    chWgt2.Text = '';
                    chWgt2.Icon = 'penCursor.svg';
                    chWgt2.Layout.Column = 2;
                    chWgt2.ButtonPushedFcn = @( o, e )obj.varEditBtnPushedFcn( iTV );
                else
                    paramValType = class( paramValue );
                    switch paramValType
                        case { 'single', 'double', 'int32' }

                            wgt = uieditfield( obj.PrmsGL, "numeric" );
                            wgt.Value = double( paramValue );

                        case { 'uint8', 'logical', 'matlab.lang.OnOffSwitchState' }

                            wgt = uigridlayout( obj.PrmsGL, [ 1, 2 ],  ...
                                'ColumnWidth', { '1x', 'fit' },  ...
                                'RowHeight', { '1x' },  ...
                                'ColumnSpacing', 0,  ...
                                'RowSpacing', 0,  ...
                                'Padding', 0,  ...
                                'BackgroundColor', 'white' );
                            cbx = uicheckbox( wgt, Text = '' );
                            cbx.Value = logical( paramValue );
                            cbx.Layout.Row = 1;
                            cbx.Layout.Column = 2;

                        case 'string'

                            wgt = uieditfield( obj.PrmsGL );
                            wgt.Value = paramValue;
                        otherwise
                            wgt = uilabel( obj.PrmsGL );
                            msgId = "simulinkcompiler:genapp:VariableTypeNotHandled";
                            wgt.Text = message( msgId, paramValType ).getString;
                            wgt.HorizontalAlignment = 'left';
                    end
                end
                wgt.Layout.Row = iTV;
                wgt.Layout.Column = 2;

                wgtToCreateCBFor = wgt;
                wgtCheckbox = findobj( wgt, 'Type', 'uicheckbox' );
                if ~isempty( wgtCheckbox )
                    wgtToCreateCBFor = wgtCheckbox;
                end

                if isprop( wgtToCreateCBFor, 'ValueChangedFcn' )
                    wgtToCreateCBFor.ValueChangedFcn =  ...
                        @( src, ev )obj.prmValueChangedFcn( ev );
                end

            end
            obj.PrmsGL.ColumnWidth = { '1x', '1x' };
        end

        function prmValueChangedFcn( obj, event )



            if isa( event.Source, 'matlab.ui.control.CheckBox' )
                tunableVarIdx = 2 * event.Source.Parent.Layout.Row;
            else
                tunableVarIdx = 2 * event.Source.Layout.Row;
            end

            varName = obj.PrmsGL.Children( tunableVarIdx - 1 ).Text;
            search = string( { obj.TunableVariables.QualifiedName } ) == varName;
            obj.TunableVariables( search ).Value = event.Value;

            obj.modifyTunableVariable( obj.TunableVariables( search ) );

            obj.updateSimInVarsFromTunableVars(  );
        end

        function varEditBtnPushedFcn( obj, varIndex )
            simVars = tv2slsv( obj.TunableVariables );
            paramName = simVars( varIndex ).Name;
            paramValue = simVars( varIndex ).Value;
            obj.fillVariableEditTab( paramName, paramValue, 'Create' );
            obj.cleanUpStatusLabel(  );
            drawnow;
            obj.updateTheme(  );
        end

        function addCloseMenuToTab( obj, newTab )
            close = uimenu( newTab.ContextMenu, 'Text', 'Close' );
            close.MenuSelectedFcn = @( src, event )obj.deleteTab( newTab );
            closeAll = uimenu( newTab.ContextMenu, 'Text', 'Close All' );
            closeAll.MenuSelectedFcn = @( src, event )obj.deleteTabs(  );
        end

        function deleteTab( obj, tab )
            numTabsBeforeDelete = numel( obj.TabGroup.Children );
            delete( tab );
            if numTabsBeforeDelete == 1
                obj.createNoVariableSelectedLabel(  );
                obj.activateParameterListView(  );
            end
        end

        function deleteTabs( obj )
            tabs = obj.TabGroup.Children';
            for tab = tabs
                if isequal( tab.Tag, "_vars_tab_" )
                    continue ;
                end
                obj.deleteTab( tab );
            end
        end
    end

    methods ( Access = private )
        function ResumeButtonPressed( obj )
            if isempty( obj.RuntimeUpdatedVariables )
                return ;
            end
            updatedVars = tv2slsv( obj.RuntimeUpdatedVariables );
            simulink.compiler.modifyParameters( obj.Model, updatedVars );
            obj.RuntimeUpdatedVariables = Simulink.Simulation.Variable.empty;
        end

        function modifyTunableVariable( obj, tunedVariable )

            tg = obj.tgGetTargetObject(  );
            if tg.isTargetEmpty(  ), return ;end

            updatedVar = tv2slsv( tunedVariable );


            if obj.EnableLiveTuning && tg.isSimulationRunning(  )
                simulink.compiler.modifyParameters( obj.Model, updatedVar );
            end




            if tg.isSimulationPaused(  )
                obj.RuntimeUpdatedVariables( end  + 1 ) = updatedVar;
            end

            obj.setTunedVariablesOnSimulationInput( updatedVar );
        end



        function setTunedVariablesOnSimulationInput( obj, varList )
            tg = obj.tgGetTargetObject(  );
            if tg.isTargetEmpty(  ), return ;end

            simIn = tg.SimulationInput;
            if isempty( simIn )
                return ;
            end

            for idx = 1:numel( varList )
                simIn = simIn.setVariable( varList( idx ).Name, varList( idx ).Value, 'Workspace', varList( idx ).Workspace );
            end
            tg.SimulationInput = simIn;
        end
    end
end



function subVar = evalSubVarValue( varName, var )%#ok<INUSL>
topVarName = extractTopVarName( varName );
subVar = eval( "var" + extractAfter( varName, topVarName ) );
end



function loadingIndicator = showLoadingIndicatorAtGridPosition( grid, row, col )
loadingIndicator = uigridlayout( grid,  ...
    BackgroundColor = 'white',  ...
    ColumnWidth = { '1x', '1x', '1x' },  ...
    RowHeight = { '1x', '1x', '1x' } );
loadingIndicator.Layout.Row = row;
loadingIndicator.Layout.Column = col;

img = uiimage( loadingIndicator,  ...
    ImageSource = 'loading.gif',  ...
    BackgroundColor = 'white',  ...
    ScaleMethod = 'scaledown' );

img.Layout.Row = 2;
img.Layout.Column = 2;

drawnow limitrate;
end



function topVarName = extractTopVarName( varName )
arguments
    varName( 1, 1 )string
end

topVarName = varName;

if contains( topVarName, '{' )
    topVarName = extractBefore( topVarName, '{' );
end

if contains( topVarName, '(' )
    topVarName = extractBefore( topVarName, '(' );
end

if contains( topVarName, '.' )
    parts = split( topVarName, '.' );
    topVarName = parts( 1 );
end
end



function TF = isDoubleClick(  )
persistent chk;TF = false;

if isempty( chk )
    chk = 1;
    pause( 0.5 );
    if chk == 1
        chk = [  ];TF = false;
    end
else
    chk = [  ];TF = true;
end
end



function TF = foundAndActivatedTab( tabGroup, varName )
TF = false;
tab = findobj( tabGroup, "Title", varName );

if ~isempty( tab )
    tabGroup.SelectedTab = tab;
    TF = true;
end
end



function varData = setStructVarData( varData )
isStructArrayField = numel( varData.fieldValues ) > 1 &&  ...
    numel( unique( varData.fieldNames ) ) == 1;

if isStructArrayField
    varData = setStructArrayFieldVarData( varData );
else
    varData = setStructFieldVarData( varData );
end
end



function varData = setStructArrayFieldVarData( varData )
varData.view = 'Field';
varData.varTable.ColumnName = varData.fieldNames( 1 );
varData.varTable.Data = varData.fieldValues;
end



function varData = setStructFieldVarData( varData )
varData.varTable.Data = [ varData.fieldNames, varData.fieldValues ];
field = message( 'simulinkcompiler:simulink_components:Field' ).getString(  );
value = message( 'simulinkcompiler:simulink_components:Value' ).getString(  );
varData.varTable.ColumnName = [ field, value ];
end



function [ fieldNames, fieldValues ] = exctractStructVars( topStruct )
import matlab.internal.datatoolsservices.getWorkspaceDisplay;

structFields = fields( topStruct );
varsCount = numel( structFields );
fieldNames = cell( varsCount, 1 );
fieldValues = cell( varsCount, 1 );

for idx = 1:varsCount
    field = structFields{ idx };
    childVar = topStruct.( field );
    varDisplaydata = getWorkspaceDisplay( { childVar } );
    fieldNames{ idx } = field;
    fieldValues{ idx } = char( varDisplaydata.Value );
end
end



function varList = tv2slsv( tv2slsv_Inp )
if isempty( tv2slsv_Inp )
    varList = [  ];
    return ;
end

if isa( tv2slsv_Inp, 'Simulink.Simulation.Variable' )
    varList = tv2slsv_Inp;
    return ;
end

for tv2slsv_Idx = 1:numel( tv2slsv_Inp )
    eval( tv2slsv_Inp( tv2slsv_Idx ).QualifiedName ...
        + "= tv2slsv_Inp(tv2slsv_Idx).Value;" );
end

topVarList = getTopVariableList( tv2slsv_Inp );

for tv2slsv_Idx = 1:numel( topVarList )
    eval( "tv2slsv_VarValue = " + topVarList( tv2slsv_Idx ) + ";" );
    varList( tv2slsv_Idx ) =  ...
        Simulink.Simulation.Variable(  ...
        topVarList( tv2slsv_Idx ),  ...
        tv2slsv_VarValue,  ...
        'Workspace', tv2slsv_Inp( tv2slsv_Idx ).Workspace );%#ok<AGROW>
end
end



function varList = getTopVariableList( structVariables )
varList = string( numel( structVariables ) );
for idx = 1:numel( structVariables )
    varList( idx ) = extractTopVarName( structVariables( idx ).QualifiedName );
end
varList = unique( varList, 'stable' );
end

