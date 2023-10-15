classdef Control < simscape.internal.variablescaling.Base

    properties
        Model simscape.internal.variablescaling.Model
        View simscape.internal.variablescaling.View
    end

    properties ( Access = private )
        ListenerHandles = event.listener.empty;
        ProcessedData = struct.empty;
        ScalarizedStateData( :, 3 );
        OriginalPath;
        PathCleaner = onCleanup.empty;
        SelectedRows;
        HighlightedCells;
        LastUIOpenPath = '';
    end

    properties ( Access = private, Constant )
        ThresholdTimePercentage = 50;
        ThresholdMaxValue = 5;
        ThresholdLargeState = 1e4;
    end

    methods
        function obj = Control( model, view )
            arguments
                model( 1, 1 )simscape.internal.variablescaling.Model
                view( 1, 1 )simscape.internal.variablescaling.View
            end

            import simscape.internal.variablescaling.ModelStatus;
            obj.Model = model;
            obj.View = view;
            if obj.Model.Status ~= ModelStatus.Ready ...
                    && obj.Model.Status ~= ModelStatus.Running
                obj.View.StatusLabel.Text = obj.getStandardCatalogMessage( 'NoModelAttached' );
                if isempty( Simulink.allBlockDiagrams( 'model' ) )
                    obj.View.MessageArea.Value = obj.getStandardCatalogMessage( 'ClickOpenModel' );
                else
                    obj.View.MessageArea.Value = obj.getStandardCatalogMessage( 'ClickOpenOrAttachModel' );
                end
            else
                obj.View.StatusLabel.Text = obj.getStandardCatalogMessage( 'AttachedTo', obj.Model.Name );
                obj.View.MessageArea.Value = obj.getStandardCatalogMessage( 'ClickRun' );
            end
            obj.View.WarningArea.Value = obj.getStandardCatalogMessage( 'NoWarnings' );
            obj.updateButtonEnabling(  );
            obj.ListenerHandles( end  + 1 ) = listener( obj.Model, 'StatusChanged', @obj.modelStatusChanged );
            obj.ListenerHandles( end  + 1 ) = listener( obj.Model, 'ValueChanged', @obj.modelValueChanged );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.OpenModelButton, 'ButtonPushed', @( source, event )obj.openModelButtonPushed );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.AttachModelButton, 'ButtonPushed', @( source, event )obj.attachModelButtonPushed );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.RunButton, 'ButtonPushed', @( source, event )obj.runModel );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.PlotButton, 'ButtonPushed', @( source, event )obj.plotState );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.TabulatedData, 'CellSelection', @( source, event )obj.selectCells( source, event ) );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View, 'StateChanged', @( source, event )obj.viewStatusChanged );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.SettingsButton, 'ButtonPushed', @( source, event )obj.openModelSettings );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.NomValsButton, 'ButtonPushed', @( source, event )obj.openNominalValues );
            obj.ListenerHandles( end  + 1 ) = listener( obj.View.PIButton, 'ButtonPushed', @( source, event )obj.openPropertyInspector );
        end

        function runModel( obj )
            obj.Model.run;
            obj.updateButtonEnabling(  );
        end

        function result = getStateInfo( obj, scalarizedIndex )

            if isempty( scalarizedIndex ) || scalarizedIndex < 1 || scalarizedIndex > size( obj.ScalarizedStateData, 1 )
                result = [  ];
                return ;
            end
            data_index = obj.ScalarizedStateData( scalarizedIndex, 1 );



            start = obj.ScalarizedStateData( scalarizedIndex, 2 );
            stop = obj.ScalarizedStateData( scalarizedIndex, 3 );


            time = obj.Model.Data{ data_index }.Values.Time;
            data = obj.Model.Data{ data_index }.Values.Data( start:stop );


            unit = obj.Model.getNominalUnitForState( obj.Model.Data{ data_index }.Name );


            result = timeseries( data, time, 'Name', obj.ProcessedData.StateName( scalarizedIndex ) );


            result.DataInfo.Units = unit;



            result.Name = regexprep( result.Name, [ '^', obj.Model.Name, '\.' ], '' );
        end

        function delete( obj )
            delete( obj.PathCleaner );
            delete( obj.ListenerHandles );
            delete( obj.Model );
            delete( obj.View );
        end
    end

    methods ( Access = private )
        function viewStatusChanged( obj, ~, ~ )
            if obj.View.State == matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                delete( obj.PathCleaner );
                delete( obj.ListenerHandles );
                delete( obj.Model );
            end
        end

        function modelStatusChanged( obj, ~, ~ )
            import simscape.internal.variablescaling.ModelStatus;
            switch obj.Model.Status
                case { ModelStatus.Uninitialized, ModelStatus.Closed }
                    obj.View.TabulatedData.Data = table.empty;
                    obj.SelectedRows = [  ];
                    obj.HighlightedCells = [  ];
                    clf( obj.View.FigureVisual );
                    if isempty( Simulink.allBlockDiagrams( 'model' ) )
                        obj.View.MessageArea.Value = obj.getStandardCatalogMessage( 'ReopenModel' );
                    else
                        obj.View.MessageArea.Value = obj.getStandardCatalogMessage( 'ReopenOrAttachModel' );
                    end
                    obj.View.StatusLabel.Text = obj.getStandardCatalogMessage( 'NoModelAttached' );
                    obj.View.WarningArea.Value = obj.getStandardCatalogMessage( 'NoWarnings' );
                case ModelStatus.Ready
                    obj.View.StatusLabel.Text = obj.getStandardCatalogMessage( 'AttachedTo', obj.Model.Name );
                    obj.View.MessageArea.Value = obj.getStandardCatalogMessage( 'ClickRun' );
                case ModelStatus.Running
                    obj.View.StatusLabel.Text = obj.getStandardCatalogMessage( 'Running' );
                    obj.View.WarningArea.Value = "";
                    obj.View.MessageArea.Value = "";
                    clf( obj.View.FigureVisual );
                    obj.View.TabulatedData.Data = table.empty;
                case ModelStatus.Opening
                    obj.View.TabulatedData.Data = table.empty;
                    clf( obj.View.FigureVisual );
                    obj.View.StatusLabel.Text = obj.getStandardCatalogMessage( 'Opening' );
                    obj.View.WarningArea.Value = obj.getStandardCatalogMessage( 'NoWarnings' );
                    obj.ScalarizedStateData = zeros( 0, 3 );
                otherwise
                    pm_error( 'physmod:simscape:simscape:variablescaling:UnrecognizedModelStatus' );
            end
            obj.updateButtonEnabling(  );
        end

        function modelValueChanged( obj, ~, ~ )
            if isempty( obj.Model.ErrorMessage ) && ~isempty( obj.Model.Data )
                obj.extractData;
            end
            obj.updateAnalysisMessages;
        end

        function updateAnalysisMessages( obj )
            w = string.empty;
            if ~isempty( obj.Model.ErrorMessage )
                w( end  + 1 ) = obj.getStandardCatalogMessage( 'SolverError' );
                w( end  + 1 ) = string( obj.Model.ErrorMessage );
                w( end  + 1 ) = "";
                w( end  + 1 ) = obj.getStandardCatalogMessage( 'DiagnosticsReference' );
            else
                if ~isempty( obj.Model.WarningMessage )
                    w( end  + 1 ) = obj.getStandardCatalogMessage( 'SolverWarning' );
                    w( end  + 1 ) = string( obj.Model.WarningMessage );
                    w( end  + 1 ) = "";
                    w( end  + 1 ) = obj.getStandardCatalogMessage( 'DiagnosticsReference' );
                else
                    w( end  + 1 ) = obj.getStandardCatalogMessage( 'NoWarnings' );
                end
            end
            obj.View.WarningArea.Value = w;

            s = string.empty;
            if ~isempty( obj.Model.ErrorMessage )
                s( end  + 1 ) = obj.getStandardCatalogMessage( 'FixErrors' );
            else
                if isempty( obj.View.TabulatedData.Data )
                    s( end  + 1 ) = obj.getStandardCatalogMessage( 'NoContinuousStates' );
                else
                    if ~isempty( obj.HighlightedCells )
                        s( end  + 1 ) = obj.getStandardCatalogMessage( 'Suggestions' );
                        suggestionIndex = 1;
                        if ~obj.Model.isEnabledNominalValues
                            s( end  + 1 ) = string( suggestionIndex ) + ") " + obj.getStandardCatalogMessage( 'SuggestionTurnOnNominalValues' );
                            suggestionIndex = suggestionIndex + 1;
                        end
                        if obj.Model.isAutoScaleAbsTol
                            if any( string( obj.View.TabulatedData.Data.Properties.VariableNames( obj.HighlightedCells( :, 2 ) ) ) == "PercentTimeBelowAbsTol" )



                                s( end  + 1 ) = string( suggestionIndex ) + ") " + obj.getStandardCatalogMessage( 'SuggestionPercentTimeAutoAbsTol' );
                                suggestionIndex = suggestionIndex + 1;
                            end
                        else
                            if any( string( obj.View.TabulatedData.Data.Properties.VariableNames( obj.HighlightedCells( :, 2 ) ) ) == "PercentTimeBelowAbsTol" )


                                s( end  + 1 ) = string( suggestionIndex ) + ") " + obj.getStandardCatalogMessage( 'SuggestionPercentTime' );
                                suggestionIndex = suggestionIndex + 1;
                            end
                        end
                        if any( string( obj.View.TabulatedData.Data.Properties.VariableNames( obj.HighlightedCells( :, 2 ) ) ) == "LogMaxAbsData" )


                            s( end  + 1 ) = string( suggestionIndex ) + ") " + obj.getStandardCatalogMessage( 'SuggestionMaxValue' );
                            suggestionIndex = suggestionIndex + 1;
                        end
                        if any( string( obj.View.TabulatedData.Data.Properties.VariableNames( obj.HighlightedCells( :, 2 ) ) ) == "MinData" ) ...
                                || any( string( obj.View.TabulatedData.Data.Properties.VariableNames( obj.HighlightedCells( :, 2 ) ) ) == "MaxData" )


                            s( end  + 1 ) = string( suggestionIndex ) + ") " + obj.getStandardCatalogMessage( 'SuggestionMinMax' );
                            suggestionIndex = suggestionIndex + 1;
                        end
                        if any( string( obj.View.TabulatedData.Data.Properties.VariableNames( obj.HighlightedCells( :, 2 ) ) ) == "MeanAbsData" )


                            s( end  + 1 ) = string( suggestionIndex ) + ") " + obj.getStandardCatalogMessage( 'SuggestionLargeState' );
                            suggestionIndex = suggestionIndex + 1;
                        end
                        if any( string( obj.View.TabulatedData.Data.Properties.VariableNames ) == "NominalUnits" )
                            all_units = obj.extractUnits( obj.View.TabulatedData.Data.NominalUnits );



                            rows = unique( obj.HighlightedCells( :, 1 ) );
                            flagged_units = obj.extractUnits( obj.View.TabulatedData.Data.NominalUnits( rows ) );
                            while ~isempty( flagged_units )
                                thisUnit = flagged_units( 1 );
                                flagged_units = flagged_units( 2:end  );
                                isCommensurate = pm_commensurate( thisUnit, flagged_units );
                                numFlagged = sum( isCommensurate ) + 1;
                                numTotal = sum( pm_commensurate( all_units, thisUnit ) );
                                if numFlagged > 0.75 * numTotal
                                    s( end  + 1 ) = string( suggestionIndex ) + ") " + obj.getStandardCatalogMessage( 'SuggestionGlobalNominalValue',  ...
                                        "'" + thisUnit + "'" );%#ok<AGROW>
                                    suggestionIndex = suggestionIndex + 1;
                                end
                                flagged_units = flagged_units( ~isCommensurate );
                            end
                        end
                        s( end  + 1 ) = "";
                        s( end  + 1 ) = obj.getStandardCatalogMessage( 'SuggestionStandard' );
                        s( end  + 1 ) = "";
                        s( end  + 1 ) = obj.getStandardCatalogMessage( 'SuggestionUpdate' );
                    else
                        s( end  + 1 ) = obj.getStandardCatalogMessage( 'NoProblems' );
                    end
                end
            end
            obj.View.MessageArea.Value = s;
        end

        function selectCells( obj, ~, event )
            obj.SelectedRows = unique( event.Indices( :, 1 ) );
            obj.updateButtonEnabling(  );
        end

        function plotState( obj )
            indices = obj.View.TabulatedData.Data.Index( obj.SelectedRows );
            clf( obj.View.FigureVisual );
            ax = axes( obj.View.FigureVisual );
            hold( ax, 'on' );
            cleaner = onCleanup( @(  )( hold( ax, 'off' ) ) );
            for ii = 1:length( indices )
                ts = obj.getStateInfo( indices( ii ) );
                plot( ax, ts.Time, squeeze( ts.Data ), 'DisplayName', ts.Name );
            end
            xlabel( ax, obj.getStandardCatalogMessage( 'Time' ) );
            ylabel( ax, obj.getStandardCatalogMessage( 'StateValue' ) );
            if obj.Model.isAutoScaleAbsTol
                title( ax, obj.getStandardCatalogMessage( 'AutoAbsTol' ) );
            else
                xlim = ax.XLim;
                ylim = ax.YLim;
                atol = obj.Model.absTol;
                if any( ylim >  - atol ) && any( ylim < atol )
                    if ylim( 1 ) <  - atol
                        bottomBdry =  - atol;
                    else
                        bottomBdry = ylim( 1 );
                    end
                    if ylim( 2 ) > atol
                        topBdry = atol;
                    else
                        topBdry = ylim( 2 );
                    end
                    h = fill( ax, [ xlim( 1 ), xlim( 2 ), xlim( 2 ), xlim( 1 ) ],  ...
                        [ bottomBdry, bottomBdry, topBdry, topBdry ], [ 0.1, 0.1, 0.1 ], 'HandleVisibility', 'on',  ...
                        'DisplayName', obj.getStandardCatalogMessage( 'UnderAbsTol' ) );
                    h.FaceAlpha = 0.1;
                end
                title( ax, obj.getStandardCatalogMessage( 'AbsoluteTolerance', string( atol ) ) );
            end
            legend( ax, 'Interpreter', 'none' );
            box( ax, 'on' );
        end

        function extractData( obj )
            [ stateNames, stateIndices ] = obj.getFilteredStateNames;
            numScalarizedVariables = 0;
            for ii = 1:length( stateNames )
                if obj.Model.Data{ stateIndices( ii ) }.Label == Simulink.SimulationData.StateType.CSTATE
                    numEntries = length( obj.Model.Data{ stateIndices( ii ) }.Values.Data( : ) ) / length( obj.Model.Data{ stateIndices( ii ) }.Values.Time );
                    if floor( numEntries ) ~= numEntries
                        pm_error( 'physmod:simscape:simscape:variablescaling:ErrorMatrixSize' );
                    end
                    numScalarizedVariables = numScalarizedVariables + numEntries;
                end
            end

            tBelowAbsTolRaw = NaN( numScalarizedVariables, 1 );
            stateNameRaw = strings( numScalarizedVariables, 1 );
            minRaw = NaN( numScalarizedVariables, 1 );
            meanRaw = NaN( numScalarizedVariables, 1 );
            logMaxAbsRaw = NaN( numScalarizedVariables, 1 );
            maxRaw = NaN( numScalarizedVariables, 1 );
            stdRaw = NaN( numScalarizedVariables, 1 );
            currentScalarState = 1;
            for ii = 1:length( stateNames )
                if obj.Model.Data{ stateIndices( ii ) }.Label == Simulink.SimulationData.StateType.CSTATE
                    currentIndex = 1;
                    for jj = 1:obj.Model.Data{ stateIndices( ii ) }.Values.TimeInfo.Length:numel( obj.Model.Data{ stateIndices( ii ) }.Values.Data )
                        endPt = jj + obj.Model.Data{ stateIndices( ii ) }.Values.TimeInfo.Length - 1;
                        loc_idx = ( jj:endPt ).';
                        obj.ScalarizedStateData( currentScalarState, : ) = [ stateIndices( ii ), jj, endPt ];
                        ts = timeseries( obj.Model.Data{ stateIndices( ii ) }.Values.Data( loc_idx ),  ...
                            obj.Model.Data{ stateIndices( ii ) }.Values.Time );
                        if obj.Model.isAutoScaleAbsTol
                            absTol = obj.Model.autoAbsTolValues( obj.Model.Data{ stateIndices( ii ) }.Values.Data( loc_idx ) );
                        else
                            absTol = obj.Model.absTol;
                        end
                        ats = timeseries( abs( ts.Data ), ts.Time );
                        dflag = ats.Data < absTol;
                        tBelowAbsTolRaw( currentScalarState ) = trapz( ats.Time, dflag );
                        if obj.Model.Data{ stateIndices( ii ) }.Values.TimeInfo.Length == numel( obj.Model.Data{ stateIndices( ii ) }.Values.Data )
                            stateNameRaw( currentScalarState ) = stateNames( ii );
                        else
                            stateNameRaw( currentScalarState ) = stateNames( ii ) + "(" + currentIndex + ")";
                            currentIndex = currentIndex + 1;
                        end
                        minRaw( currentScalarState ) = min( ts );
                        meanRaw( currentScalarState ) = mean( ats, 'Weighting', 'time' );
                        logMaxAbsRaw( currentScalarState ) = log10( max( ats ) );
                        maxRaw( currentScalarState ) = max( ts );
                        stdRaw( currentScalarState ) = std( ts, 'Weighting', 'time' );
                        currentScalarState = currentScalarState + 1;
                    end
                end
            end
            nominalUnits = strings( size( stateNameRaw ) );
            for ii = 1:length( nominalUnits )
                nominalUnits( ii ) = obj.Model.getNominalUnitForState( obj.Model.Data{ obj.ScalarizedStateData( ii, 1 ) }.Name );
            end
            obj.ProcessedData = struct( 'StateName', stateNameRaw,  ...
                'NominalUnits', nominalUnits,  ...
                'PercentTimeBelowAbsTol', tBelowAbsTolRaw ./ ( obj.Model.stopTime - obj.Model.startTime ) * 100,  ...
                'MinData', minRaw,  ...
                'MaxData', maxRaw,  ...
                'MeanAbsData', meanRaw,  ...
                'LogMaxAbsData', logMaxAbsRaw,  ...
                'StdDevData', stdRaw );
            sortcol = 8;
            fnames = fieldnames( obj.ProcessedData );
            if ~isempty( fnames )
                Index = ( 1:length( obj.ProcessedData.( fnames{ 1 } ) ) )';
                outputTable = table( Index );
                for ii = 1:length( fnames )
                    outputTable = addvars( outputTable, obj.ProcessedData.( fnames{ ii } )( Index ), 'NewVariableNames', fnames{ ii } );
                end
            end
            obj.View.TabulatedData.Data = sortrows( outputTable, sortcol, 'descend' );


            s = obj.View.HighlightStyle;
            removeStyle( obj.View.TabulatedData );


            rows = find( obj.View.TabulatedData.Data.PercentTimeBelowAbsTol > obj.ThresholdTimePercentage );
            col = find( string( obj.View.TabulatedData.Data.Properties.VariableNames ) == "PercentTimeBelowAbsTol" );
            obj.HighlightedCells = [ rows( : ), col * ones( length( rows ), 1 ) ];


            rows = find( obj.View.TabulatedData.Data.MeanAbsData > obj.ThresholdLargeState * median( obj.View.TabulatedData.Data.MeanAbsData ) );
            col = find( string( obj.View.TabulatedData.Data.Properties.VariableNames ) == "MeanAbsData" );
            obj.HighlightedCells = [ obj.HighlightedCells;rows, col * ones( length( rows ), 1 ) ];


            rows = find( obj.View.TabulatedData.Data.LogMaxAbsData > log10( obj.ThresholdLargeState * obj.View.TabulatedData.Data.MeanAbsData ) );
            col = find( string( obj.View.TabulatedData.Data.Properties.VariableNames ) == "LogMaxAbsData" );
            obj.HighlightedCells = [ obj.HighlightedCells;rows, col * ones( length( rows ), 1 ) ];



            if ~obj.Model.isAutoScaleAbsTol
                rows = find( abs( obj.View.TabulatedData.Data.MinData ) < obj.ThresholdMaxValue * obj.Model.absTol ...
                    & abs( obj.View.TabulatedData.Data.MaxData ) < obj.ThresholdMaxValue * obj.Model.absTol ...
                    & obj.View.TabulatedData.Data.PercentTimeBelowAbsTol <= obj.ThresholdTimePercentage );
                col = find( string( obj.View.TabulatedData.Data.Properties.VariableNames ) == "MinData" ...
                    | string( obj.View.TabulatedData.Data.Properties.VariableNames ) == "MaxData" );
                if length( col ) ~= 2
                    pm_error( 'physmod:simscape:simscape:variablescaling:ErrorColumnHeadings' );
                end
                obj.HighlightedCells = [ obj.HighlightedCells;rows( : ), col( 1 ) * ones( length( rows ), 1 ) ];
                obj.HighlightedCells = [ obj.HighlightedCells;rows( : ), col( 2 ) * ones( length( rows ), 1 ) ];
            end

            addStyle( obj.View.TabulatedData, s, 'cell', obj.HighlightedCells );
        end

        function openModelButtonPushed( obj )

            delete( obj.PathCleaner );
            obj.OriginalPath = path;
            [ fname, pathname, filter ] = uigetfile( { '*.mdl;*.slx', 'Models' }, obj.getStandardCatalogMessage( 'PickModel' ), obj.LastUIOpenPath );
            if filter > 0
                obj.LastUIOpenPath = pathname;
                path( pathname, obj.OriginalPath );
                obj.PathCleaner = onCleanup( @(  )path( obj.OriginalPath ) );
                [ ~, rootname, ~ ] = fileparts( fname );
                if ~simscape.internal.variablescaling.Base.isValidSimulinkModel( rootname )
                    delete( obj.PathCleaner );
                    h = errordlg( obj.getStandardCatalogMessage( 'ErrorInvalidModel', rootname ) );
                    uiwait( h );
                else
                    obj.Model.open( rootname );
                    obj.View.bringToFront;
                end
            end
        end

        function attachModelButtonPushed( obj )

            import simscape.internal.variablescaling.ModelStatus;
            openModels = Simulink.allBlockDiagrams( 'model' );
            if isempty( openModels )
                h = errordlg( obj.getStandardCatalogMessage( 'CannotAttach' ) );
                uiwait( h );
            else
                if length( openModels ) == 1
                    modelName = get( openModels, 'Name' );
                    if ~( ( obj.Model.Status == ModelStatus.Ready ...
                            || obj.Model.Status == ModelStatus.Running ) ...
                            && strcmp( obj.Model.Name, modelName ) )
                        delete( obj.PathCleaner );
                        obj.OriginalPath = path;
                        obj.Model.open( modelName );
                        obj.View.bringToFront;
                    end
                else
                    modelNames = arrayfun( @( x )( get( x, 'Name' ) ), openModels, 'UniformOutput', false );
                    [ idx, tf ] = listdlg( 'Name', obj.getStandardCatalogMessage( 'PickOpenModel' ),  ...
                        'ListString', modelNames, 'SelectionMode', 'single',  ...
                        'PromptString', strsplit( matlab.internal.display.printWrapped( obj.getStandardCatalogMessage( 'AttachList' ), 32 ), '\n' ),  ...
                        'ListSize', [ 300, 300 ] );
                    if tf
                        if ~( ( obj.Model.Status == ModelStatus.Ready ...
                                || obj.Model.Status == ModelStatus.Running ) ...
                                && strcmp( obj.Model.Name, modelNames{ idx } ) )
                            delete( obj.PathCleaner );
                            obj.OriginalPath = path;
                            obj.Model.open( modelNames{ idx } );
                            obj.View.bringToFront;
                        end
                    end
                end
            end
        end

        function openModelSettings( obj )
            import simscape.internal.variablescaling.ModelStatus;
            if obj.Model.Status == ModelStatus.Ready
                slCfgPrmDlg( obj.Model.Name, 'Open', 'Solver' );
            end
        end

        function openNominalValues( obj )
            import simscape.internal.variablescaling.ModelStatus;
            if obj.Model.Status == ModelStatus.Ready
                simscape.nominal.internal.getSimscapeNominalValues( obj.Model.Name );
            end
        end

        function openPropertyInspector( obj )
            import simscape.internal.variablescaling.ModelStatus;
            if obj.Model.Status == ModelStatus.Ready
                scalarized_index = obj.View.TabulatedData.Data.Index( obj.SelectedRows );
                data_index = obj.ScalarizedStateData( scalarized_index, 1 );
                blk = obj.Model.getBlockNameForState( obj.Model.Data{ data_index }.Name );


                p = get_param( blk, 'Parent' );
                open_system( p, 'force' );
                h_blk = get_param( blk, 'Handle' );


                e = GLUE2.Util.findAllEditors( p );
                s = e.getStudio;



                selectedDiagramElements = e.getSelection;
                for ii = 1:selectedDiagramElements.size
                    e.deselect( selectedDiagramElements.at( ii ) );
                end
                diagramElement = SLM3I.SLDomain.handle2DiagramElement( h_blk );
                e.select( diagramElement );

                pi = s.getComponent( 'GLUE2:PropertyInspector', 'Property Inspector' );
                pi.updateSource( pi.getName, get_param( blk, 'Object' ) );
                s.showComponent( pi );
                pi.show;
                pi.restore;
            end
        end

        function [ stateNames, indices ] = getFilteredStateNames( obj )
            stateNames = getElementNames( obj.Model.Data );
            idx = cellfun( @( x )( ~isempty( x ) & ~strcmpi( x, 'Discrete' ) ), stateNames );
            for ii = 1:length( idx )
                if idx( ii ) && strcmp( obj.Model.getBlockNameForState( stateNames( ii ) ),  ...
                        obj.getStandardCatalogMessage( 'Unknown' ) )
                    idx( ii ) = false;
                end
            end
            stateNames = stateNames( idx );
            indices = find( idx );
        end

        function updateButtonEnabling( obj )
            import simscape.internal.variablescaling.ModelStatus;

            if isempty( obj.SelectedRows )
                obj.View.PlotButton.Enabled = false;
            else
                obj.View.PlotButton.Enabled = true;
            end
            if length( obj.SelectedRows ) == 1
                obj.View.PIButton.Enabled = true;
            else
                obj.View.PIButton.Enabled = false;
            end
            if obj.Model.Status == ModelStatus.Ready
                obj.View.RunButton.Enabled = true;
                obj.View.SettingsButton.Enabled = true;
                obj.View.NomValsButton.Enabled = true;
            else
                obj.View.RunButton.Enabled = false;
                obj.View.SettingsButton.Enabled = false;
                obj.View.NomValsButton.Enabled = false;
            end
        end
    end

    methods ( Static, Access = private )
        function result = extractUnits( input_units )
            result = extractBetween( input_units, ', ''', '''}' );
        end
    end
end


