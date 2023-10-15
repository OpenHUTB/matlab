function [ fit, errdb, err, stats ] = fitter( freq, data, optTol, args )

arguments
    freq( 1, : )double{ mustBeNonempty, mustBeReal, mustBeFinite, mustBeNonNan, mustBeNonnegative }
    data double{ mustBeNonempty, mustBeFinite, mustBeNonNan }
    optTol( 1, 1 )double{ mustBeNonempty, mustBeReal, mustBeFinite, mustBeNonNan, mustBeNonpositive } =  - 40
    args.Tolerance( 1, 1 )double{ mustBeNonempty, mustBeReal, mustBeFinite, mustBeNonNan, mustBeNonpositive }
    args.TendsToZero( 1, 1 )logical{ mustBeNonempty, mustBeReal, mustBeFinite, mustBeNonNan } = true
    args.MaxPoles( 1, 1 )double{ mustBeReal, mustBeFinite, mustBeNonNan, mustBeNonnegative }
    args.NumPoles( 1, 1 )double{ mustBeReal, mustBeFinite, mustBeNonNan, mustBeNonnegative }
    args.Causal( 1, 1 )logical{ mustBeNonempty, mustBeReal, mustBeFinite, mustBeNonNan } = true
    args.QLimit( 1, 1 )double{ mustBeNonempty, mustBeReal, mustBeNonNan, mustBeNonnegative } = 1000
    args.Display( 1, 1 )string{ mustBeTextScalar } = 'off'
    args.ColumnReduce( 1, 1 )logical{ mustBeNonempty, mustBeReal, mustBeFinite, mustBeNonNan } = true
    args.ErrorMetric( 1, 1 )string{ mustBeTextScalar } = 'default'
    args.NoiseFloor( 1, 1 )double{ mustBeReal, mustBeNonNan, mustBeNonpositive } =  - Inf
end
narginchk( 2, Inf )
nfreq = numel( freq );
if ~isfield( args, 'Tolerance' )
    args.Tolerance = optTol;
end
args.Display = validatestring( args.Display, { 'on', 'off', 'plot', 'both' } );
args.ErrorMetric = validatestring( args.ErrorMetric, { 'default', 'relative' } );

maxPolesDefined = isfield( args, 'MaxPoles' );
numPolesDefined = isfield( args, 'NumPoles' );
if maxPolesDefined && numPolesDefined
    error( 'Both MaxPoles and NumPoles specified' )
elseif numPolesDefined

    if args.NumPoles == 0
        args.MaxPoles = 0;
    else
        args.MaxPoles = max( 10, args.NumPoles );
    end
elseif maxPolesDefined
    args.NumPoles = [  ];
else
    args.MaxPoles = 1000;
    args.NumPoles = [  ];
end


if ndims( data ) > 3
    error( message( 'rf:rational:Not2Dor3D' ) )
elseif ndims( data ) == 3 || nfreq == 1
    datasize = size( data );
    if nfreq > 1 && datasize( 3 ) ~= nfreq
        error( message( 'rf:rational:Bad3dSize' ) )
    end
    outsize = datasize( 1:2 );
    cols = prod( outsize );
    data = reshape( data, cols, nfreq ).';
else
    if isrow( data )
        data = data( : );
    end
    datasize = size( data );
    if datasize( 1 ) == nfreq
        outsize = [ 1, datasize( 2 ) ];
        cols = datasize( 2 );
    elseif datasize( 2 ) == nfreq
        error( message( 'rf:rational:DataMustBeColumns' ) )
    else
        error( message( 'rf:rational:WrongFreqOrDataInput' ) )
    end
end

[ fitA, fitC, fitD, errdb, err, stats ] = rf.internal.rational.fitterImpl( freq, data, cols, args );

temp = rfmodel.rational;
fit = temp( ones( outsize ) );
assert( numel( fit ) == cols )
for k = 1:numel( fit )
    fit( k ) = rfmodel.rational( 'a', fitA{ k }, 'c', fitC{ k }, 'd', fitD( k ), 'delay', 0 );
end

end


