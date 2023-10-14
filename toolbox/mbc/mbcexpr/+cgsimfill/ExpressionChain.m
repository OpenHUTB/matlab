classdef ExpressionChain < handle

































    properties

        Pointers = mbcpointer( 1, 0 );

        Values = cell( 1, 100 );
        derivativeValues = cell( 1, 100 );

        Inputs = cell( 1, 100 );

        Location = 0;

        Inports = [  ];

        Output

        HasLoop = false;


        HasDynamics

        KeepLastOnly = false;

        SimFillTables cgsimfill.PointerInterface



        LastUse
        Simulator
    end

    properties ( Dependent, SetAccess = private )

        ExpressionArray
    end

    properties ( Access = private )

        pExpressionArray = {  }
    end


    properties ( Dependent, SetAccess = private )

        Tables

        InputNames

        HasState
    end


    methods

        function ES = ExpressionChain( expression, removeFeatures, loopInputs )

            arguments
                expression = [  ];
                removeFeatures = true;
                loopInputs = mbcpointer( 0 );
            end
            if nargin
                if isa( expression, 'xregpointer' )
                    expression = info( expression );
                end
                if nargin < 2
                    removeFeatures = true;
                end

                build( ES, expression, removeFeatures, loopInputs );

                len = length( ES.Pointers );
                ES.Values = ES.Values( 1:len );
                ES.Inputs = ES.Inputs( 1:len );
                ES.Output = len;

                for i = 1:len

                    if any( ES.Inputs{ i } == 0 )

                        ES.HasLoop = true;
                        pInputs = ES.Pointers( i ).getinputs;
                        for j = 1:length( pInputs )
                            if removeFeatures && pInputs( j ).isfeature

                                pInputs( j ) = pInputs( j ).getinputs;
                            end
                        end
                        [ ~, ES.Inputs{ i } ] = ismember( pInputs, ES.Pointers );
                    end
                end
                ES.HasDynamics = false( 1, len );
                if ES.HasLoop

                    reorderLoops( ES, removeFeatures );
                end



                ES.LastUse = zeros( 1, len );
                inps = ES.Inputs;
                for i = 1:len

                    ind = len;
                    while ind > i
                        if any( i == inps{ ind } )
                            break
                        end
                        ind = ind - 1;
                    end
                    if ind > i
                        ES.LastUse( i ) = ind;
                    end
                end

            end

        end


        function e = get.ExpressionArray( ES )

            if isempty( ES.pExpressionArray )
                e = infoarray( ES.Pointers );
                if ~isempty( ES.SimFillTables )


                    [ OK, loc ] = ismember( ES.Pointers, [ ES.SimFillTables.Pointer ] );
                    e( OK ) = num2cell( ES.SimFillTables( loc( OK ) ) );
                end
            else
                e = ES.pExpressionArray;
            end

        end

        function set.ExpressionArray( ES, array )

            ES.pExpressionArray = array;
        end

        function pTables = get.Tables( ES )

            isTable = cellfun( @istable, ES.ExpressionArray );
            pTables = ES.Pointers( isTable );
        end

        function inpNames = get.InputNames( ES )
            inpNames = cellfun( @getname, ES.ExpressionArray( ES.Inports ), 'UniformOutput', false );
        end

        function ok = get.HasState( ES )

            ok = any( cellfun( @hasState, ES.ExpressionArray ) );
        end


        function setInitialConditions( ES, icTable, data )

            if ES.HasState && ~isempty( icTable )
                isState = cellfun( @hasState, ES.ExpressionArray );
                states = ES.ExpressionArray( isState );
                for i = 1:length( states )
                    if strcmp( icTable{ i, 3 }, '<none>' )

                        ic = icTable{ i, 2 };
                    else

                        ic = data.( icTable{ i, 3 } );
                        if strcmp( icTable{ i, 1 }, "StepSize" )

                            ic = ic( 2 ) - ic( 1 );
                        else
                            ic = ic( 1 );
                        end
                    end
                    states{ i } = setInitialConditions( states{ i }, ic );
                end
                ES.ExpressionArray( isState ) = states;
            end

        end

        function snapshot( ES )


            ES.ExpressionArray = infoarray( ES.Pointers );

            if ~isempty( ES.SimFillTables )

                [ OK, loc ] = ismember( ES.Pointers, [ ES.SimFillTables.Pointer ] );
                ES.ExpressionArray( OK ) = num2cell( ES.SimFillTables( loc( OK ) ) );
                snapshot( ES.SimFillTables )
            end
        end

        function clearSnapshot( ES )

            ES.ExpressionArray = {  };
            if ~isempty( ES.SimFillTables )
                clearSnapshot( ES.SimFillTables )
            end
        end

        function addExpression( ES, E, removeFeatures )



            if nargin < 3
                removeFeatures = true;
            end

            if isa( E, 'xregpointer' )
                E = info( E );
            end
            if removeFeatures && isfeature( E )
                E = info( getinputs( E ) );
            end
            build( ES, E, removeFeatures );

            [ ~, ES.Output( end  + 1 ) ] = ismember( address( E ), ES.Pointers );
        end

        function [ y, dy ] = evaluate( ES, X, ClearResults, dExpr )









            if nargin < 3
                ClearResults = true;
            end
            if nargin < 4
                dExpr = mbcpointer( 0 );
            end


            expressionArray = ES.ExpressionArray;

            doDerivatives = nargout == 2;
            len = length( expressionArray );
            inputs = ES.Inputs;
            nd = length( dExpr );
            dValues = cell( nd, len );

            reuseValues = ~isempty( ES.Values ) && all( ~cellfun( @isempty, ES.Values ) );
            if reuseValues
                values = ES.Values;
            else

                values = cell( 1, len );
                if nargin > 1 && ~isempty( X )
                    if istable( X )
                        testData = X;
                        inpNames = ES.InputNames;
                        X = cell( 1, length( inpNames ) );
                        for i = 1:length( inpNames )
                            X{ i } = testData.( inpNames{ i } );
                        end

                    elseif ~iscell( X )

                        X = num2cell( X, 1 );
                    end
                    values( ES.Inports ) = X;
                    if doDerivatives
                        pInputs = ES.Pointers( ES.Inports );
                        [ OK, loc ] = ismember( pInputs, dExpr );
                        nx = size( X{ 1 }, 1 );
                        for i = 1:length( OK )
                            if OK( i )

                                pos = pInputs( i ) == ES.Pointers;
                                dValues{ loc( i ), pos } = speye( nx );
                            end
                        end
                    end
                end

                source = cellfun( @isempty, inputs );
                source( ES.Inports ) = false;

                values( source ) = cellfun( @evalAtInputs, expressionArray( source ), 'UniformOutput', false );
                if doDerivatives && any( ismember( ES.Pointers( source ), dExpr ) )

                    [ ok, loc ] = ismember( ES.Pointers( source ), dExpr );
                    dConst = dExpr( loc( ok ) );
                    [ ok, loc ] = ismember( dConst, dExpr );
                    indConst = loc( ok );
                    for i = indConst
                        dValues{ i, ismember( ES.Pointers, dExpr( i ) ) } = 1;
                    end

                end

            end


            isDiff = false( nd, len );
            for i = 1:nd
                isDiff( i, : ) = dExpr( i ) == ES.Pointers;
            end
            for i = 1:len
                if ~ES.HasDynamics( i )

                    inputValues = values( inputs{ i } );

                    if isempty( values{ i } )

                        values{ i } = evalAtInputs( expressionArray{ i }, inputValues );


                        if doDerivatives

                            dInputs = dValues( :, inputs{ i } );
                            dy = differentiate( expressionArray{ i }, isDiff( :, i ), inputValues, dInputs );
                            dValues( :, i ) = dy;
                        end
                    end
                    remove = find( i == ES.LastUse );
                    if ClearResults && ~isempty( remove )

                        values( remove ) = { [  ] };
                        dValues( :, remove ) = { [  ] };
                    end
                end

            end
            if any( ES.HasDynamics )

                if doDerivatives

                    [ values, dValues ] = evaluateTransient( ES, dExpr, values, inputs, dValues );
                else

                    values = evaluateTransient( ES, dExpr, values, inputs );
                end
            end

            ES.Values = values;

            y = matrixResults( ES );
            if doDerivatives

                dy = dValues( :, ES.Output );
                for i = 1:length( dy )
                    di = dy{ i };
                    if ~isempty( di ) && ~issparse( di ) && nnz( di ) / numel( di ) < 0.1
                        dy{ i } = sparse( di );
                    end
                end
            end

            if ES.KeepLastOnly

                y = y( end , : );
                if doDerivatives
                    for i = 1:length( dy )
                        di = dy{ i };
                        if ~isempty( di )
                            dy{ i } = di( end , : );
                        end
                    end
                end
            end

            if ~isreal( y )

                y( abs( imag( y ) ) > 1e-8 ) = NaN;
                y = real( y );
            end
            if ClearResults


                ES.Values = cell( size( values ) );
                ES.derivativeValues = [  ];

            else
                ES.derivativeValues = dValues;
            end
        end

        function [ f, isTransient ] = evaluators( ES, dExpr, derivativeLevel )


            doDerivative = nargin > 1;


            e = ES.ExpressionArray;
            n = length( e );
            if doDerivative
                numDerivatives = length( dExpr );
                dExpr = dExpr( : );
            else
                numDerivatives = 0;
            end
            isTransient = false( size( e ) );

            f = cell( 1, n );
            for i = 1:n
                f{ i } = evaluateTransient2( e{ i }, numDerivatives );
                isTransient( i ) = hasState( e{ i } );
            end
            for i = 1:n

                fi = f{ i };
                fi.Expression = e{ i };
                inputs = f( ES.Inputs{ i } );
                fi.Inputs = inputs;
                if doDerivative
                    fi.IsCurrent = dExpr == address( e{ i } );
                    if any( fi.IsCurrent ) || any( cellfun( @( f )f.Derivative > 0, inputs ) ) || ES.HasDynamics( i )
                        fi.Derivative = derivativeLevel;
                    else


                        fi.Derivative = 0;
                    end
                    fi.HasDerivative = false( numDerivatives, 1 );
                    fi.HasInputDerivatives = false( numDerivatives, length( fi.Inputs ) );
                end
            end


        end

        function n = numOutputs( ES )


            n = length( ES.Output );
        end

        function names = getOutputNames( ES )


            names = cellfun( @getname, ES.ExpressionArray, 'UniformOutput', false );
        end

        function clearResults( ES )

            ES.Values = cell( size( ES.Values ) );
        end

        function [ y, ceq, vloop ] = evalLoop( ES, Loop, NumIter )





            for i = 1:size( Loop, 2 )
                E = info( Loop( 2, i ) );
                if isfeature( E )
                    Loop( 2, i ) = getinputs( E );
                end
            end

            [ ~, LoopExpr ] = ismember( Loop( 2, : ), ES.Pointers );

            OldOutputs = ES.Output;

            ES.Output = LoopExpr;

            V0 = evaluate( ES );

            if nargin < 3
                NumIter = 5;
            end
            for i = 1:NumIter



                for j = 1:size( Loop, 2 )
                    Loop( 1, j ).info = setvalue( Loop( 1, j ).info, V0( :, j ) );
                end

                vloop = evaluate( ES );

                ceq = sqrt( sum( ( V0 - vloop ) .^ 2, 1 ) / size( V0, 1 ) );
                V0 = vloop;
            end
            for j = 1:size( Loop, 2 )

                Loop( 1, j ).info = setvalue( Loop( 1, j ).info, V0( :, j ) );
            end

            ES.Output = OldOutputs;
            y = evaluate( ES );

        end

        function [ J, Ind ] = JacobPattern( ES, pTab, RemoveNull )





            pos = pTab == ES.Pointers;

            InputPos = fliplr( ES.Inputs{ pos } );
            ndim = length( InputPos );
            TabInputs = cell( 1, ndim );
            for i = 1:ndim

                TabInputs{ i } = ES.Inputs{ InputPos( i ) };
            end
            X = matrixResults( ES, [ TabInputs{ : } ] );

            LT = pTab.info;
            J = JacobPattern( LT, X );


            vlocks = get( LT, 'vlocks' );
            if nargin < 3 || RemoveNull
                Ind = ~all( J == 0, 1 )' & ~vlocks( : );
            else
                Ind = ~vlocks( : );
            end
            mask = getExtrapolationMask( LT );
            if ~isempty( mask ) && any( mask( : ) )

                Ind = Ind & mask( : );
            end
            J = J( :, Ind );
        end

    end

    methods ( Access = protected )
        function build( ES, expression, removeFeatures, loopInputs )



            arguments
                ES cgsimfill.ExpressionChain
                expression
                removeFeatures = true;
                loopInputs = mbcpointer( 0 );
            end
            if removeFeatures && isfeature( expression )

                expression = info( getinputs( expression ) );
            end
            pExpr = address( expression );


            allReadyDone = any( pExpr == ES.Pointers ) || any( pExpr == loopInputs );
            if ~allReadyDone


                if isinport( expression )

                    ES.Inports = [ ES.Inports, ES.Location + 1 ];
                    InputLocs = [  ];
                else
                    pInputs = getinputs( expression );
                    inputs = infoarray( pInputs );
                    toDo = ~ismember( pInputs, loopInputs );
                    loopInputs = [ loopInputs;pExpr ];
                    for i = 1:length( inputs )
                        if toDo( i )

                            if removeFeatures && isfeature( inputs{ i } )



                                pInputs( i ) = getinputs( inputs{ i } );
                            end
                            if pInputs

                                build( ES, inputs{ i }, removeFeatures, loopInputs );
                            end
                        end
                    end


                    [ ~, InputLocs ] = ismember( pInputs, ES.Pointers );
                end


                ES.Location = ES.Location + 1;


                ES.Inputs{ ES.Location } = InputLocs;
                ES.Pointers = [ ES.Pointers, pExpr ];
                if ES.Location > length( ES.Values )


                    ES.Values = [ ES.Values, cell( 1, 100 ) ];
                    ES.Inputs = [ ES.Inputs, cell( 1, 100 ) ];
                end
            end
        end



































        function [ values, dValues ] = evaluateTransient( ES, dExpr, values, inputs, dValues )



            doDerivatives = nargout > 1;
            lenExpressions = length( values );

            expressionArray = ES.ExpressionArray;

            isLoop = ES.HasDynamics;
            hasState = cellfun( @hasState, expressionArray );

            indexState = ( find( isLoop & hasState ) );
            indexDynamics = find( ES.HasDynamics );

            tfinal = max( cellfun( @numel, values ) );

            numDerivatives = length( dExpr );
            if ~ES.KeepLastOnly

                outputValues = zeros( tfinal, 1 );
                outputDerivatives = cell( numDerivatives, 1 );
            end


            required = ES.HasDynamics;
            for exprIndex = find( required )
                required( inputs{ exprIndex } ) = true;
            end

            isVector = ~cellfun( @isscalar, values );
            inputList = find( required & ~ES.HasDynamics & isVector );
            AllValues = values;
            values = zeros( 1, lenExpressions );
            values( ~isVector ) = [ AllValues{ ~isVector } ];

            if doDerivatives
                dValues( :, ~required ) = { [  ] };
                hasDiffAll = ~cellfun( 'isempty', dValues );


                dValues( :, isVector ) = cellfun( @( J )full( J )', dValues( :, isVector ), 'UniformOutput', false );

                dV = cell( 1, lenExpressions );

                for i = 1:lenExpressions

                    dV{ i } = dValues( :, i );
                end
                dValues = dV;
                dValuesAll = dV;

            else

                dValues = {  };
            end
            keepLastOnly = ES.KeepLastOnly;

            isDiff = false( numDerivatives, lenExpressions );
            for exprIndex = 1:numDerivatives

                isDiff( exprIndex, : ) = dExpr( exprIndex ) == ES.Pointers;
            end
            dv0 = cell( numDerivatives, 1 );


            fEval = struct( 'evaluate', cell( 1, length( expressionArray ) ),  ...
                'differentiate', [  ],  ...
                'updateStates', [  ],  ...
                'updateStateDerivatives', [  ] );
            for i = indexDynamics


                fEval( i ) = evaluateTransient( expressionArray{ i }, numDerivatives, isDiff( :, i ) );
            end

            for t = 1:tfinal


                for i = inputList


                    values( i ) = AllValues{ i }( t );
                    if doDerivatives && any( hasDiffAll( :, i ) )
                        dvAll = dValuesAll{ i };
                        dv = dv0;
                        for j = 1:numDerivatives
                            if hasDiffAll( j, i )




                                dv{ j } = dvAll{ j }( :, t )';
                            end
                        end
                        dValues{ i } = dv;
                    end
                end

                for exprIndex = indexDynamics




                    inputIndices = inputs{ exprIndex };

                    inputValues = values( inputIndices );


                    values( exprIndex ) = fEval( exprIndex ).evaluate( inputValues );

                    if doDerivatives






                        if isscalar( inputIndices )
                            dInputs = dValues{ inputIndices };
                        else
                            dInputs = [ dValues{ inputIndices } ];
                        end
                        hasD = hasDiffAll( :, inputIndices );

                        [ dValues{ exprIndex }, hasDy ] = fEval( exprIndex ).differentiate( inputValues, dInputs, hasD );
                        hasDiffAll( :, exprIndex ) = hasDy;
                    end
                end


                if ~keepLastOnly

                    outputValues( t ) = values( ES.Output );
                    if doDerivatives
                        outputDerivatives = storeDerivatives( outputDerivatives, dValues{ ES.Output }, t, tfinal );
                    end
                end


                for exprIndex = indexState



                    inputIndices = inputs{ exprIndex };
                    inputValues = values( inputIndices );

                    if doDerivatives



                        if isscalar( inputIndices )
                            dInputs = dValues{ inputIndices };
                        else
                            dInputs = [ dValues{ inputIndices } ];
                        end
                        hasD = hasDiffAll( :, inputIndices );



                        fEval( exprIndex ).updateStateDerivatives( inputValues, dInputs, hasD );

                    end

                    fEval( exprIndex ).updateStates( inputValues );
                end

            end

            values = num2cell( values );
            if ~keepLastOnly
                values{ ES.Output } = outputValues;
            end
            if doDerivatives
                if ~ES.KeepLastOnly && tfinal > 0

                    dValues{ ES.Output } = cellfun( @( J )cat( 1, J{ : } ), outputDerivatives, 'UniformOutput', false );
                end
                dV = cell( numDerivatives, lenExpressions );
                dV( :, ES.Output ) = dValues{ ES.Output };
                dValues = dV;
            end
        end

        function y = recursiveEval( ES, E, X )




            pExpr = address( E );
            [ OK, loc ] = ismember( pExpr, ES.Pointers );
            if ~OK

                if isinport( E )

                    ES.Inports = [ ES.Inports, ES.Location + 1 ];
                    y = X{ length( ES.Inports ) };
                    InputLocs = [  ];
                else
                    pInputs = getinputs( E );
                    inputs = infoarray( pInputs );
                    for i = 1:length( inputs )


                        recursiveEval( ES, inputs{ i }, X );
                    end
                    [ ~, InputLocs ] = ismember( pInputs, ES.Pointers );

                    y = evalAtInputs( E, ES.Values( InputLocs ) );
                end
                ES.Location = ES.Location + 1;
                ES.Inputs{ ES.Location } = InputLocs;
                ES.Pointers = [ ES.Pointers, pExpr ];
                if ES.Location > length( ES.Values )
                    ES.Values = [ ES.Values, cell( 1, 100 ) ];
                    ES.Inputs = [ ES.Inputs, cell( 1, 100 ) ];
                end

                ES.Values{ ES.Location } = y;
            else

                y = ES.Values{ loc };
            end
        end

        function y = matrixResults( ES, indices )


            if nargin < 2
                indices = ES.Output;
            end
            X = ES.Values( indices );
            ndim = length( X );
            y = zeros( max( cellfun( 'size', X, 1 ) ), ndim );
            for i = 1:ndim
                y( :, i ) = X{ i };
            end

        end

        function reorderLoops( ES, removeFeatures )







            hasState = parrayeval( ES.Pointers, @hasState, {  }, @false );
            hasDF = parrayeval( ES.Pointers, @hasDirectFeedthrough, {  }, @false );

            for i = 1:length( ES.HasDynamics )
                if any( ES.Inputs{ i } >= i )

                    ES.HasDynamics = findDependencies( i, ES.Inputs, ES.HasDynamics );
                end
            end




            originalPonterOrder = ES.Pointers;

            pDF = ES.Pointers( ES.HasDynamics & hasDF );
            swapped = true;
            count = 0;
            while swapped


                swapped = false;
                for i = 1:length( pDF )
                    pInputs = pDF( i ).getinputs;
                    [ ~, inp ] = ismember( pInputs, pDF );
                    mi = max( inp );
                    if mi > i

                        pDF( i:mi ) = [ pDF( i + 1:mi ), pDF( i ) ];
                        swapped = true;
                    end
                end



                count = count + 1;
                if swapped && count > length( pDF )
                    error( 'Cannot sort loop: possible algebraic loop' );
                end
            end


            hasState = hasState & ES.HasDynamics;
            newPointerOrder = [ ES.Pointers( ~ES.HasDynamics ), ES.Pointers( hasState & ~hasDF ), pDF ];
            if ~all( newPointerOrder == originalPonterOrder )


                oldOutput = ES.Pointers( ES.Output );
                ES.Pointers = newPointerOrder;


                hasDynamics = false( size( ES.HasDynamics ) );
                hasDynamics( nnz( ~ES.HasDynamics ) + 1:end  ) = true;
                ES.HasDynamics = hasDynamics;

                ES.Output = find( ES.Pointers == oldOutput );
                for i = 1:length( ES.Pointers )

                    pInputs = ES.Pointers( i ).getinputs;
                    for j = 1:length( pInputs )
                        if removeFeatures && pInputs( j ).isfeature

                            pInputs( j ) = pInputs( j ).getinputs;
                        end
                    end
                    [ ~, ES.Inputs{ i } ] = ismember( pInputs, ES.Pointers );
                end

                ES.Inports = find( cellfun( @isinport, ES.ExpressionArray ) );
            end
        end


    end


    methods ( Static )
        function [ y, ES ] = fastEvaluate( E, X )



            if isa( E, 'xregpointer' )
                E = info( E );
            end
            ES = cgsimfill.ExpressionChain;
            y = recursiveEval( ES, E, X );
            len = length( ES.Pointers );
            ES.Values = ES.Values( 1:len );
            ES.Inputs = ES.Inputs( 1:len );
            ES.Output = len;
            ES.clearResults;
        end

        function ch = htmlchar( E, doFull, ES )



            arguments
                E %#ok<INUSA> expression
                doFull = false;
                ES = cgsimfill.ExpressionChain( info( E ), doFull );
            end

            values = cell( 1, length( ES.Pointers ) );
            exprArray = infoarray( ES.Pointers );
            LoopNum = 1;
            Loop = [  ];
            for i = 1:length( values )
                inputValues = values( ES.Inputs{ i } );
                if any( ES.Inputs{ i } > i )

                    isloop = ES.Inputs{ i } > i;
                    for j = find( isloop )
                        if doFull || ~isfeature( exprArray{ ES.Inputs{ i }( j ) } )
                            inputValues{ j } = sprintf( '<b><it>Loop#%d</b></it>', LoopNum );
                            Loop = [ Loop, ES.Inputs{ i }( j ) ];%#ok<AGROW>
                            LoopNum = LoopNum + 1;
                        end
                    end
                end
                ch = htmlchar( exprArray{ i }, doFull, inputValues );
                if any( i == Loop )

                    ref = find( i == Loop );
                    loopString = sprintf( 'Loop#%d', ref );
                    if any( cellfun( @( ch )contains( ch, loopString ), values( 1:i - 1 ) ) )


                        ch = sprintf( '<b><it>Loop#%d</b></it>:%s', ref, ch );
                    end
                end
                values{ i } = ch;

            end
            ch = values{ ES.Output };

        end

    end

end


function dependencies = findDependencies( index, inputs, dependencies )



dependencies( index ) = true;

currentDependencies = cellfun( @( x )any( index == x ), inputs ) & ~dependencies;
for j = find( currentDependencies )

    dependencies = dependencies | findDependencies( j, inputs, dependencies );
end
end

function dValues = storeDerivatives( dValues, dy, t, N )




for i = 1:length( dy )
    dyi = dy{ i };
    if ~isempty( dyi )
        if isempty( dValues{ i } )



            dv = cell( 1, N );
            if t > 1

                dv( 1:t - 1 ) = { zeros( size( dyi ) ) };
            end
            dv{ t } = dyi;
            dValues{ i } = dv;
        else

            dValues{ i }{ t } = dyi;
        end

    end
end
end
