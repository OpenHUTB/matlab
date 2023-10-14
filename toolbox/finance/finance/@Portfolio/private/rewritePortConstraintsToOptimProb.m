function [ prob, flags ] = rewritePortConstraintsToOptimProb( obj )

arguments
    obj( 1, 1 ){ mustBeA( obj, "Portfolio" ) }
end


prob = optimproblem;


auxVar = false;
if ( ~isempty( obj.BuyCost ) || ~isempty( obj.SellCost ) ||  ...
        ~isempty( obj.Turnover ) || ~isempty( obj.BuyTurnover ) ||  ...
        ~isempty( obj.SellTurnover ) )
    auxVar = true;
end


binaryVar = false;
if hasIntegerConstraints( obj )
    binaryVar = true;
end



nAssets = obj.NumAssets;
if isempty( nAssets )
    error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:UndefinedNumAssets' ) )
end


lowerBound = obj.LowerBound;

if binaryVar && ~isempty( obj.BoundType )
    cond = obj.BoundType == obj.BoundTypeCategory( 2 );

    if isempty( lowerBound )
        lowerBound =  - Inf( nAssets, 1 );
    end
    lowerBound( cond ) = 0;
end

x = optimvar( 'x', nAssets, 1, 'Type', 'continuous', 'LowerBound', lowerBound,  ...
    'UpperBound', obj.UpperBound );
prob.Objective = sum( x );





if auxVar
    y = optimvar( 'y', nAssets, 1, 'Type', 'continuous', 'LowerBound', 0 );

    initPort = obj.InitPort;
    if isempty( initPort )
        initPort = zeros( nAssets, 1 );
    end

    prob.Constraints.AuxVarLowerBound = y >= x - initPort;
end




if ~isempty( obj.AInequality ) && ~isempty( obj.bInequality )

    if any( ~isfinite( obj.AInequality ), 'all' )
        error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidAInequalityMatrix' ) );
    end
    idx = isfinite( obj.bInequality );

    if any( ~idx & ( obj.bInequality ~= Inf ) )
        error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidLinearInequality' ) );
    end
    prob.Constraints.LinearInequalities =  ...
        obj.AInequality( idx, : ) * x <= obj.bInequality( idx );
end



if ~isempty( obj.AEquality ) && ~isempty( obj.bEquality )
    if any( ~isfinite( obj.AEquality ), 'all' )
        error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidAEqualityMatrix' ) );
    end

    if any( ~isfinite( obj.bEquality ) )
        error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidLinearEquality' ) );
    end
    prob.Constraints.LinearEqualities =  ...
        obj.AEquality * x == obj.bEquality;
end


consTol = obj.solverOptionsNL.ConstraintTolerance;
if ~isempty( obj.LowerBudget ) && ~isempty( obj.UpperBudget ) &&  ...
        abs( obj.UpperBudget - obj.LowerBudget ) <= consTol

    prob.Constraints.Budget = sum( x ) == obj.LowerBudget;
else


    if ~isempty( obj.LowerBudget )

        if ( obj.LowerBudget == Inf ) || isnan( obj.LowerBudget )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidLowerBudget' ) );
        end
        if isfinite( obj.LowerBudget )
            prob.Constraints.LowerBudget = sum( x ) >= obj.LowerBudget;
        end
    end


    if ~isempty( obj.UpperBudget )

        if ( obj.UpperBudget ==  - Inf ) || isnan( obj.UpperBudget )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidUpperBudget' ) );
        end
        if isfinite( obj.UpperBudget )
            prob.Constraints.UpperBudget = sum( x ) <= obj.UpperBudget;
        end
    end
end



if ~isempty( obj.GroupMatrix )
    if any( ~isfinite( obj.GroupMatrix ), 'all' )
        error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidGroupMatrix' ) );
    end

    if ~isempty( obj.UpperGroup )
        idx = isfinite( obj.UpperGroup );

        if any( ~idx & ( obj.UpperGroup ~= Inf ) )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidUpperGroup' ) );
        end
        prob.Constraints.UpperGroup =  ...
            obj.GroupMatrix( idx, : ) * x <= obj.UpperGroup( idx );
    end

    if ~isempty( obj.LowerGroup )
        idx = isfinite( obj.LowerGroup );

        if any( ~idx & ( obj.LowerGroup ~=  - Inf ) )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidLowerGroup' ) );
        end
        prob.Constraints.LowerGroup =  ...
            obj.GroupMatrix( idx, : ) * x >= obj.LowerGroup( idx );
    end
end



if ~isempty( obj.GroupA ) && ~isempty( obj.GroupB )
    if any( ~isfinite( obj.GroupA ), 'all' ) || any( ~isfinite( obj.GroupB ), 'all' )
        error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidGroupRatioMatrix' ) );
    end

    if ~isempty( obj.UpperRatio )
        idx = isfinite( obj.UpperRatio );

        if any( ~idx & ( obj.UpperRatio ~= Inf ) )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidUpperRatio' ) );
        end
        prob.Constraints.UpperGroupRatio = obj.GroupA( idx, : ) * x <=  ...
            obj.UpperRatio( idx ) .* ( obj.GroupB( idx, : ) * x );
    end

    if ~isempty( obj.LowerRatio )
        idx = isfinite( obj.LowerRatio );

        if any( ~idx & ( obj.LowerRatio ~=  - Inf ) )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidLowerRatio' ) );
        end
        prob.Constraints.LowerGroupRatio = obj.GroupA( idx, : ) * x >=  ...
            obj.LowerRatio( idx ) .* ( obj.GroupB( idx, : ) * x );
    end
end


if auxVar



    if ~isempty( obj.Turnover )

        if ( obj.Turnover ==  - Inf ) || isnan( obj.Turnover )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidTurnover' ) );
        end
        if isfinite( obj.Turnover )
            prob.Constraints.Turnover = sum( 2 * y - x + initPort ) <= 2 * ( obj.Turnover );
        end
    end




    if ~isempty( obj.BuyTurnover )

        if ( obj.BuyTurnover ==  - Inf ) || isnan( obj.BuyTurnover )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidBuyTurnover' ) );
        end
        if isfinite( obj.BuyTurnover )
            prob.Constraints.BuyTurnover = sum( y ) <= obj.BuyTurnover;
        end
    end




    if ~isempty( obj.SellTurnover )

        if ( obj.SellTurnover ==  - Inf ) || isnan( obj.SellTurnover )
            error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidSellTurnover' ) );
        end
        if isfinite( obj.SellTurnover )
            prob.Constraints.SellTurnover = sum( y - x + initPort ) <= obj.SellTurnover;
        end
    end
end



teFlag = false;
if ~isempty( obj.TrackingError )

    if ( obj.TrackingError ==  - Inf ) || isnan( obj.TrackingError )
        error( message( 'finance:Portfolio:rewritePortConstraintsToOptimProb:InvalidTrackingError' ) );
    end
    if isfinite( obj.TrackingError )
        teFlag = true;

        trackingPort = obj.TrackingPort;
        if isempty( trackingPort )
            trackingPort = zeros( nAssets, 1 );
        end

        prob.Constraints.TrackingError = ( x - trackingPort )' * obj.AssetCovar *  ...
            ( x - trackingPort ) <= obj.TrackingError ^ 2;
    end
end


flags.auxVar = auxVar;
flags.binary = binaryVar;
flags.te = teFlag;


