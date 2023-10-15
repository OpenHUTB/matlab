classdef StateflowAnalyzer < dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties ( Constant )
        StateflowStateType = 'StateflowState'
        StateflowTransitionType = 'StateflowTransition'
    end

    properties ( Constant, Access = private )
        StateflowProduct = dependencies.internal.graph.Nodes.createProductNode( "SF" )
        SimulinkTestProduct = dependencies.internal.graph.Nodes.createProductNode( "SZ" )
        StateLabelPattern = i_createStateLabelPattern(  )
    end

    methods

        function this = StateflowAnalyzer(  )
            import dependencies.internal.analysis.simulink.queries.StateflowChartQuery.*
            import dependencies.internal.analysis.simulink.queries.StateflowQuery.*

            queries.malCharts = createChartQuery( actionLanguage = "2" );
            queries.states = createStateQuery( "labelString" );
            queries.transitions = createTransitionQuery( "labelString" );

            queries.allCharts = createChartQuery(  );
            queries.emlCharts = createChartQuery( type = "EML_CHART" );
            queries.testTables = createTableQuery( tableType = "REACTIVE_TESTING_TABLE_TYPE" );

            this.addQueries( queries );
        end

        function deps = analyzeMatches( this, handler, node, matches )
            import dependencies.internal.graph.Dependency.createToolbox;

            deps = dependencies.internal.graph.Dependency.empty( 1, 0 );

            malCharts = string( [ matches.malCharts.ChartID ] );
            isMALState = ismember( string( [ matches.states.ChartID ] ), malCharts );
            isMALTransition = ismember( string( [ matches.transitions.ChartID ] ), malCharts );


            for match = matches.states( isMALState )
                code = this.preprocessStateLabel( match.Value );
                component = match.createComponent(  );
                factory = dependencies.internal.analysis.DependencyFactory( handler, component, this.StateflowStateType );
                workspace = this.getWorkspace( handler, match.ID );
                deps = [ deps, handler.Analyzers.MATLAB.analyze( code, factory, workspace ) ];%#ok<AGROW>
            end

            for match = matches.transitions( isMALTransition )
                code = this.preprocessTransitionLabel( match.Value );
                component = match.createComponent(  );
                factory = dependencies.internal.analysis.DependencyFactory( handler, component, this.StateflowTransitionType );
                workspace = this.getWorkspace( handler, match.ParentID );
                deps = [ deps, handler.Analyzers.MATLAB.analyze( code, factory, workspace ) ];%#ok<AGROW>
            end


            deps = [  ...
                deps ...
                , i_analyzeCActionLanguage( matches.states( ~isMALState ), this.StateflowStateType ) ...
                , i_analyzeCActionLanguage( matches.transitions( ~isMALTransition ), this.StateflowTransitionType ) ...
                ];


            emlChartIDs = string( [ matches.emlCharts.ChartID ] );
            testChartIDs = string( [ matches.testTables.ChartID ] );
            sfChartIDs = setdiff( [ matches.allCharts.ChartID ], [ emlChartIDs, testChartIDs ] );

            for n = 1:numel( sfChartIDs )
                chartPath = handler.getStateflowChartName( sfChartIDs{ n } );
                deps( end  + 1 ) = createToolbox(  ...
                    node, chartPath,  ...
                    this.StateflowProduct, 'SFunction' );%#ok<AGROW>
            end

            for n = 1:length( testChartIDs )
                chartPath = handler.getStateflowChartName( testChartIDs{ n } );
                deps( end  + 1 ) = createToolbox(  ...
                    node, chartPath,  ...
                    this.SimulinkTestProduct, 'SFunction' );%#ok<AGROW>
            end
        end
    end

    methods ( Access = private )
        function workspace = getWorkspace( ~, handler, id )
            stateWorkspace = handler.getStateflowWorkspace( id );
            workspace = dependencies.internal.analysis.matlab.Workspace.createChildWorkspace( stateWorkspace, "" );
        end
    end

    methods ( Static, Hidden )
        function code = preprocessStateLabel( label )
            arguments
                label( 1, 1 )string
            end

            code = erase( label, dependencies.internal.analysis.simulink.StateflowAnalyzer.StateLabelPattern );
        end

        function code = preprocessTransitionLabel( label )
            arguments
                label( 1, : )char
            end

            code = "";
            start = 0;
            depth = 0;
            comment = false;

            for n = 1:length( label )
                switch label( n )
                    case '%'
                        comment = true;
                    case newline
                        comment = false;
                    case { '{', '[' }
                        if ~comment
                            depth = depth + 1;
                            if depth == 1
                                start = n;
                            end
                        end
                    case { '}', ']' }
                        if ~comment
                            depth = depth - 1;
                            if depth == 0
                                code = code + label( start + 1:n - 1 ) + ";";
                            end
                        end
                end
            end
        end
    end

end


function deps = i_analyzeCActionLanguage( matches, type )










labels = string( [ matches.Value ] );
tokens = regexp( labels, '\<ml\.(\w+)', 'tokens' );

deps = dependencies.internal.graph.Dependency.empty( 1, 0 );
for i = 1:numel( tokens )
    for j = 1:numel( tokens{ i } )
        target = dependencies.internal.analysis.findSymbol( tokens{ i }{ j } );
        depType = dependencies.internal.graph.Type( type + ",FunctionCall" );
        deps( end  + 1 ) = dependencies.internal.graph.Dependency.createSource(  ...
            matches( i ).createComponent(  ), target, depType );%#ok<AGROW>
    end
end

end


function pattern = i_createStateLabelPattern(  )
stateNamePattern = namedPattern( textBoundary( "start" ) + wildcardPattern + ( "/" | lineBoundary( "end" ) ), "stateName" );

actionPattern = "entry" | "en" | "exit" | "ex" | "during" | "du" | "bind" | "on" + wildcardPattern;
spacePattern = namedPattern( whitespacePattern( 0, Inf ), "space" );
labelPattern = namedPattern( spacePattern + actionPattern + spacePattern, "label" );
actionLabelPattern = namedPattern( lineBoundary( "start" ) + labelPattern + asManyOfPattern( "," + labelPattern ) + ":", "actionLabel" );

pattern = stateNamePattern | actionLabelPattern;
end
