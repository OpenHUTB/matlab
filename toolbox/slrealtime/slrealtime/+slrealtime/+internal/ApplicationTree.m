classdef ApplicationTree < handle






































    methods ( Access = public, Static )
        function val = isTreeNodeParameter( node )


            assert( numel( node ) == 1 );

            val = false;

            if isfield( node.NodeData, 'BlockParameterName' )
                val = true;
            end
        end

        function val = isTreeNodeSignal( node )


            assert( numel( node ) == 1 );

            val = false;

            if isfield( node.NodeData, 'SignalLabel' )
                val = true;
            end
        end







        function populate( tree, source, options )
            arguments
                tree( 1, 1 )matlab.ui.container.Tree{ mustBeNonempty }
                source{ mustBeModelOrSLApp( source ) }
                options.Signals{ mustBeNumericOrLogical } = true
                options.Parameters{ mustBeNumericOrLogical } = true
                options.Search{ mustBeTextScalar } = ''
            end
            slrealtime.internal.ApplicationTree( tree, source, options );
        end










        function parameters = getParametersFromModel( modelName )
            wsParams = Simulink.findVars( modelName, 'SearchMethod', 'cached' );
            parameters = arrayfun( @( x )struct( 'BlockPath', '', 'BlockParameterName', x.Name ), wsParams );

            paramintrf = Simulink.HMI.ParamInterface( modelName );
            blks = find_system( modelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'type', 'Block' );
            for i = 1:numel( blks )
                params = paramintrf.getBindableParams( blks{ i } );
                for j = 1:numel( params )
                    if isempty( params( j ).VarName )
                        p = struct( 'BlockPath', blks{ i }, 'BlockParameterName', params( j ).ParamName );
                        parameters = [ parameters;p ];%#ok
                    end
                end
            end

            modelblks = find_system( modelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'type', 'Block', 'BlockType', 'ModelReference' );
            for i = 1:numel( modelblks )
                instParams = get_param( modelblks{ i }, 'InstanceParameters' );
                for j = 1:numel( instParams )
                    parameters = [ parameters;struct(  ...
                        'BlockPath', { [ modelblks{ i };instParams( j ).Path.convertToCell ] },  ...
                        'BlockParameterName', { instParams( j ).Name } ) ];%#ok
                end
            end
        end











        function signals = getSignalsFromModel( modelName )
            function signals = getSignalsFromModelWork( modelName, modelRefPath )
                function path = createBlockPath( blockPath, modelRefPath )
                    if isempty( modelRefPath )
                        path = blockPath;
                    else
                        path = [ modelRefPath, blockPath ];
                    end
                end

                signals = [  ];


                ports = get( find_system( modelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FindAll', 'on', 'Type', 'port', 'PortType', 'outport' ), 'Object' );
                if ~iscell( ports )
                    ports = { ports };
                end
                signals = [ signals;struct(  ...
                    'BlockPath', cellfun( @( x )createBlockPath( x.Parent, modelRefPath ), ports, 'UniformOutput', false ),  ...
                    'PortIndex', cellfun( @( x )x.PortNumber, ports, 'UniformOutput', false ),  ...
                    'SignalLabel', cellfun( @( x )x.SignalNameFromLabel, ports, 'UniformOutput', false ) ) ];


                modelblks = find_system( modelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'type', 'Block', 'BlockType', 'ModelReference' );
                if isempty( modelblks ), return ;end

                submodels = get_param( modelblks, 'ModelName' );
                for i = 1:numel( submodels )
                    try
                        find_system( submodels{ i } );
                    catch
                        load_system( submodels{ i } );
                        cleanup = onCleanup( @(  )close_system( submodels{ i }, false ) );
                    end
                    signals = [ signals;getSignalsFromModelWork( submodels{ i }, [ modelRefPath, modelblks{ i } ] ) ];%#ok
                end
            end

            signals = getSignalsFromModelWork( modelName, {  } );
        end
    end





    properties ( Access = private )
        Tree
        Parameters
        Signals
    end

    properties ( Constant, Hidden )
        ModelIcon = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'model_16.png' );
        VariableIcon = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'variable_16.png' );
        ParameterIcon = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'parameter_16.png' );
        SubsystemIcon = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'subsystem_16.png' );
        ModelrefIcon = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'modelref_16.png' );
        SignalIcon = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'signal_16.png' );
        SignalGroupIcon = fullfile( matlabroot, 'toolbox', 'slrealtime', 'slrealtime', '+slrealtime', '+icons', 'groupSignals_16.png' );

        Loading_msg = message( 'slrealtime:appdesigner:Loading' ).getString(  );
        Workspace_msg = message( 'slrealtime:appdesigner:Workspace' ).getString(  );
        NamedSignals_msg = message( 'slrealtime:appdesigner:NamedSignals' ).getString(  );
    end

    methods ( Access = private )



        function this = ApplicationTree( tree, source, options )

            this.Tree = tree;
            delete( this.Tree.Children );

            try

                if isa( source, 'slrealtime.Application' )



                    app = source;
                    modelName = app.ModelName;
                else
                    app = [  ];

                    if ishandle( source )



                        modelName = get( source, 'Name' );
                    else
                        [ ~, modelName ] = fileparts( source );
                        try
                            find_system( modelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices );
                        catch



                            load_system( source );
                            cleanup = onCleanup( @(  )close_system( modelName, false ) );
                        end
                    end
                end

                if options.Parameters
                    if ~isempty( app )



                        this.Parameters = app.getParameters(  );
                    else



                        this.Parameters = slrealtime.internal.ApplicationTree.getParametersFromModel( modelName );
                    end

                    if ~isempty( this.Parameters )
                        for i = 1:length( this.Parameters )
                            this.Parameters( i ).DisplayBlockPath = blockPathToDisplay( this.Parameters( i ).BlockPath );
                        end


                        if ~isempty( options.Search )
                            idxs = arrayfun( @( x )~isempty( regexp( lower( [ x.DisplayBlockPath, x.BlockParameterName ] ), lower( options.Search ), 'once' ) ), this.Parameters );
                            this.Parameters = this.Parameters( idxs );
                        end


                        T = struct2table( this.Parameters );
                        sortedT = sortrows( T, 'DisplayBlockPath' );
                        this.Parameters = table2struct( sortedT );



                        if any( cellfun( @( x )isempty( x ), { this.Parameters.BlockPath } ) )
                            n = uitreenode( this.Tree,  ...
                                'Tag', lower( this.Workspace_msg ),  ...
                                'Text', this.Workspace_msg,  ...
                                'Icon', this.VariableIcon,  ...
                                'NodeData', struct( 'processed', false, 'path', this.Workspace_msg ) );
                            uitreenode( n, 'Text', this.Loading_msg );
                        end
                    end
                end

                if options.Signals
                    if ~isempty( app )



                        this.Signals = app.getSignals(  );
                    else



                        this.Signals = slrealtime.internal.ApplicationTree.getSignalsFromModel( modelName );
                    end

                    if ~isempty( this.Signals )
                        for i = 1:length( this.Signals )
                            this.Signals( i ).DisplayBlockPath = blockPathToDisplay( this.Signals( i ).BlockPath );
                            this.Signals( i ).NameToSort = [ this.Signals( i ).DisplayBlockPath, ':', num2str( this.Signals( i ).PortIndex ) ];
                        end


                        if ~isempty( options.Search )
                            idxs = arrayfun( @( x )~isempty( regexp( lower( [ x.DisplayBlockPath, x.SignalLabel ] ), lower( options.Search ), 'once' ) ), this.Signals );
                            this.Signals = this.Signals( idxs );
                        end


                        if numel( this.Signals ) == 1
                            T = struct2table( this.Signals, 'AsArray', true );
                        else
                            T = struct2table( this.Signals );
                        end
                        sortedT = sortrows( T, 'NameToSort' );
                        this.Signals = rmfield( table2struct( sortedT ), 'NameToSort' );



                        if any( cellfun( @( x )~isempty( x ), { this.Signals.SignalLabel } ) )
                            n = uitreenode( this.Tree,  ...
                                'Tag', lower( this.NamedSignals_msg ),  ...
                                'Text', this.NamedSignals_msg,  ...
                                'Icon', this.SignalGroupIcon,  ...
                                'NodeData', struct( 'processed', false, 'path', this.NamedSignals_msg ) );
                            uitreenode( n, 'Text', this.Loading_msg );
                        end
                    end
                end



                n = uitreenode( this.Tree,  ...
                    'Tag', lower( modelName ),  ...
                    'Text', modelName,  ...
                    'Icon', this.ModelIcon,  ...
                    'NodeData', struct( 'processed', false, 'path', modelName ) );
                uitreenode( n, 'Text', this.Loading_msg );



                this.Tree.NodeExpandedFcn = @( o, e )this.populateTreeNode( e.Node );
            catch ME
                delete( this.Tree.Children );
                slrealtime.internal.throw.ErrorWithCause( 'slrealtime:appdesigner:CannotPopulateTree', ME );
            end
        end








        function addSystemNodeIfNeeded( this, sigOrParam, currNode, newNodeStr )

            newNode = currNode.findobj( 'Text', newNodeStr );
            if ~isempty( newNode ), return ;end


            icon = this.SubsystemIcon;


            path = [ currNode.NodeData.path, '/', newNodeStr ];


            if iscell( sigOrParam.BlockPath ) && numel( sigOrParam.BlockPath ) > 1
                for i = 1:numel( sigOrParam.BlockPath )
                    if strcmp( blockPathToDisplay( sigOrParam.BlockPath( 1:i ) ), path )
                        icon = this.ModelrefIcon;
                        break ;
                    end
                end
            end


            n = uitreenode( currNode,  ...
                'Tag', lower( newNodeStr ),  ...
                'Text', newNodeStr,  ...
                'Icon', icon,  ...
                'NodeData', struct( 'processed', false, 'path', path ) );
            uitreenode( n, 'Text', this.Loading_msg );
        end





        function populateTreeNode( this, systemNode )
            if systemNode.NodeData.processed
                return ;
            end
            systemNode.NodeData.processed = true;

            for nLoop = 1:2
























                systemNodesOnly = ( nLoop == 1 );

                if ~isempty( this.Parameters )
                    if strcmp( systemNode.NodeData.path, this.Workspace_msg )




                        if systemNodesOnly, continue ;end


                        idxs = cellfun( @( x )isempty( x ), { this.Parameters.BlockPath } );
                        params = this.Parameters( idxs );


                        for nParam = 1:numel( params )
                            uitreenode( systemNode,  ...
                                'Tag', lower( params( nParam ).BlockParameterName ),  ...
                                'Text', params( nParam ).BlockParameterName,  ...
                                'Icon', this.ParameterIcon,  ...
                                'NodeData', params( nParam ) );
                        end
                    else






                        idxs = cellfun( @( x )startsWith( x, [ systemNode.NodeData.path, '/' ] ), { this.Parameters.DisplayBlockPath } );
                        params = this.Parameters( idxs );

                        for nParam = 1:numel( params )


                            blockpathStr = extractAfter(  ...
                                params( nParam ).DisplayBlockPath,  ...
                                length( systemNode.NodeData.path ) + 1 );

                            indices = slrealtime.internal.parseBlockPath( blockpathStr );
                            if isempty( indices )




                                if systemNodesOnly, continue ;end

                                uitreenode( systemNode,  ...
                                    'Tag', lower( strcat( blockpathStr, ':', params( nParam ).BlockParameterName ) ),  ...
                                    'Text', strcat( blockpathStr, ':', params( nParam ).BlockParameterName ),  ...
                                    'Icon', this.ParameterIcon,  ...
                                    'NodeData', params( nParam ) );
                            else



                                newSystemNodeName = extractBefore( blockpathStr, indices( 1 ) );
                                this.addSystemNodeIfNeeded( params( nParam ), systemNode, newSystemNodeName );
                            end
                        end
                    end
                end

                if ~isempty( this.Signals )
                    if strcmp( systemNode.NodeData.path, this.NamedSignals_msg )




                        if systemNodesOnly, continue ;end


                        namedSignals = this.Signals( cellfun( @( x )~isempty( x ), { this.Signals.SignalLabel } ) );
                        [ ~, I ] = sort( { namedSignals.SignalLabel } );
                        namedSignals = namedSignals( I );


                        for nSignal = 1:numel( namedSignals )
                            uitreenode( systemNode,  ...
                                'Tag', lower( namedSignals( nSignal ).SignalLabel ),  ...
                                'Text', namedSignals( nSignal ).SignalLabel,  ...
                                'Icon', this.SignalIcon,  ...
                                'NodeData', namedSignals( nSignal ) );
                        end
                    else





                        idxs = cellfun( @( x )startsWith( x, [ systemNode.NodeData.path, '/' ] ), { this.Signals.DisplayBlockPath } );
                        signals = this.Signals( idxs );

                        for nSignal = 1:numel( signals )


                            blockpathStr = extractAfter(  ...
                                signals( nSignal ).DisplayBlockPath,  ...
                                length( systemNode.NodeData.path ) + 1 );

                            indices = slrealtime.internal.parseBlockPath( blockpathStr );
                            if isempty( indices )




                                if systemNodesOnly, continue ;end

                                if ~isempty( signals( nSignal ).SignalLabel )
                                    text = signals( nSignal ).SignalLabel;
                                else
                                    text = strcat( blockpathStr, ':', num2str( signals( nSignal ).PortIndex ) );
                                end

                                uitreenode( systemNode,  ...
                                    'Tag', lower( text ),  ...
                                    'Text', text,  ...
                                    'Icon', this.SignalIcon,  ...
                                    'NodeData', signals( nSignal ) );
                            else



                                newSystemNodeName = extractBefore( blockpathStr, indices( 1 ) );
                                this.addSystemNodeIfNeeded( signals( nSignal ), systemNode, newSystemNodeName );
                            end
                        end
                    end
                end
            end


            delete( systemNode.Children( 1 ) );
        end
    end
end

function blockPathStr = blockPathToDisplay( blockpath )










if iscell( blockpath )
    blockPathStr = blockpath{ 1 };
    for i = 2:length( blockpath )
        blockPathStr = strcat( blockPathStr, '/', extractAfter( blockpath{ i }, '/' ) );
    end
else
    blockPathStr = blockpath;
end
end

function mustBeModelOrSLApp( a )






valid = true;
if isempty( a )
    valid = false;
else
    try

        mustBeTextScalar( a );
        fileExists = exist( a );%#ok
        if fileExists ~= 4
            [ ~, ~, ext ] = fileparts( a );
            if fileExists ~= 2 || ~( strcmp( ext, '.slx' ) || strcmp( ext, '.mdl' ) )
                error( 'Not a model name' );
            end
        end
    catch
        try
            if ~isscalar( a )
                valid = false;
            else

                modelH = ishandle( a ) && strcmp( get( a, 'Type' ), 'block_diagram' );
                if ~modelH
                    mustBeA( a, 'slrealtime.Application' );
                end
            end
        catch
            valid = false;
        end
    end
end
if ~valid
    slrealtime.internal.throw.Error( 'slrealtime:appdesigner:SLRTAppOrModel' );
end
end


