function [ C, Xidx, numBins, binEdges ] = binData( X, binningOptions, evalOptions )

arguments

    X( :, 1 )double


    binningOptions.minMaxNumBins;
    binningOptions.numBins;
    binningOptions.binEdges( 1, : )double


    evalOptions.criterion = 'DaviesBouldin';
end


C = [  ];
Xidx = [  ];
numBins = [  ];
binEdges = [  ];
returnBinEdges = ( nargout > 3 );




binningMethod = fieldnames( binningOptions );
switch ( binningMethod{ 1 } )
    case 'minMaxNumBins'
        [ C, Xidx, numBins ] = binDataAndFindK( X, binningOptions.minMaxNumBins, evalOptions.criterion );
    case 'numBins'
        numBins = binningOptions.numBins;
        [ C, Xidx ] = binDataInKBins( X, numBins );
    case 'binEdges'
        binEdges = binningOptions.binEdges;
        [ C, Xidx, numBins ] = binDataUsingBinEdges( X, binEdges );
end


if returnBinEdges && isempty( binEdges )
    binEdges = computeBinEdges( X, Xidx, numel( C ) );
end
end


function [ C, Xidx, numBins ] = binDataUsingBinEdges( X, binEdges )


if binEdges( 1 ) ==  - inf
    frontPadding = [  ];
else
    frontPadding =  - inf;
end
if binEdges( end  ) == inf
    backPadding = [  ];
else
    backPadding = inf;
end

binEdges = [ frontPadding, binEdges, backPadding ];

[ ~, ~, Xidx ] = histcounts( X, binEdges );





numBins = numel( binEdges ) - 1;
C = accumarray( Xidx, X, [ numBins, 1 ], @mean, nan );
end


function [ C, Xidx ] = binDataInKBins( X, numBins )

[ C, ~, Xidx ] = unique( X );

numUniqueTimepoints = numel( C );
if numUniqueTimepoints < numBins
    warning( message( 'SimBiology:Plotting:NUM_BINS_GREATER_THAN_UNIQUE_VALUES', numBins ) );
    numBinsToUse = numUniqueTimepoints;
else
    numBinsToUse = numBins;
    [ C, Xidx ] = callKMeans( X, numBins );
end

[ C, Xidx ] = sortBins( C, Xidx, numBinsToUse );
end


function [ C, Xidx, numBins ] = binDataAndFindK( X, minMaxNumBins, criterion )

minValue = minMaxNumBins( 1 );
maxValue = min( minMaxNumBins( 2 ), numel( unique( X ) ) );
kVals = minValue:maxValue;

for kIdx = numel( kVals ): - 1:1
    [ allC{ kIdx }, allXidx( :, kIdx ) ] = callKMeans( X, kVals( kIdx ) );
end

evaluationObject = evalclusters( X, allXidx, criterion );


numBins = evaluationObject.OptimalK;
kOptIdx = ( kVals == numBins );

Xidx = allXidx( :, kOptIdx );
C = allC{ kOptIdx };

[ C, Xidx ] = sortBins( C, Xidx, numBins );
end


function [ C, Xidx ] = callKMeans( X, numBins )
[ Xidx, C ] = kmeans( X, numBins, 'Replicates', 5,  ...
    'Options', statset( 'Streams', RandStream( 'mt19937ar', 'Seed', 22 ) ) );
end


function [ sortedC, sortedXidx ] = sortBins( unsortedC, unsortedXidx, numBins )
[ sortedC, sortedBinIdx ] = sort( unsortedC );

oldToNewIdxMap( sortedBinIdx, 1 ) = 1:numBins;


sortedXidx = oldToNewIdxMap( unsortedXidx );
end


function binEdges = computeBinEdges( X, Xidx, numBins )
binMinVals = accumarray( Xidx, X, [  ], @min );
binMaxVals = accumarray( Xidx, X, [  ], @max );

binEdges( 1 ) = floor( binMinVals( 1 ) );
binEdges( numBins + 1 ) = ceil( binMaxVals( end  ) );

for i = 2:numBins
    lowVal = binMaxVals( i - 1 );
    highVal = binMinVals( i );
    binEdges( i ) = ( lowVal + highVal ) / 2;

    orderOfMagnitude = round( log10( highVal ) );
    maxRoundingDigit = 4;
    for r =  - orderOfMagnitude:maxRoundingDigit
        roundedBinEdge = round( binEdges( i ), r );
        if ( lowVal < roundedBinEdge && highVal > roundedBinEdge )
            binEdges( i ) = roundedBinEdge;
            break ;
        end
    end
end
end
