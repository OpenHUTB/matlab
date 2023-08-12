function result = isStiffSystem( Jm, model )





condThreshold = 100;
isStiff = false;

Jm = full( Jm );


[ ~, D, s ] = condeigNoBalance( Jm );
D = diag( D );










n1 = ( s < condThreshold );
maxCondNum = max( s( n1 ) );

if ( ~isempty( maxCondNum ) )
condThreshold = max( condThreshold, 10 * maxCondNum );
end 



n2 = ( s < condThreshold ) & ( abs( real( D ) ) > sqrt( eps( 1 ) ) );
D = D( n2 );


if isempty( D )
stiffness =  - 1;


result.isStiff = false;
result.stiffness = stiffness;

return ;
end 


eigenValue_realpart = real( D );

eigenValue_realpart_negative = eigenValue_realpart( eigenValue_realpart < 0 );

if ( isempty( eigenValue_realpart_negative ) )

stiffness = 0;
elseif ( length( eigenValue_realpart_negative ) == 1 )





sDiscTs = Inf;
sampleTimes = get_param( model, 'SampleTimes' );
for i = 1:length( sampleTimes )
if ~isempty( sampleTimes( i ).Value )
discTs = sampleTimes( i ).Value( 1 );
if ( discTs > 0 ) && ( discTs < sDiscTs )
sDiscTs = discTs;
end 
end 
end 







compMaxStepSize = str2double( get_param( model, 'CompiledStepSize' ) );

ratio = abs( 1.0 / eigenValue_realpart_negative ) / min( sDiscTs, compMaxStepSize );

chokeThreshold = 10;
if ( ratio >= chokeThreshold )
stiffness =  - 1;
else 
stiffness = abs( eigenValue_realpart_negative );
end 
else 
absVal = abs( eigenValue_realpart_negative );
maxVal = max( absVal );
minVal = min( absVal );








minEvalThreshold = 1e9;
if ( minVal >= minEvalThreshold )
stiffness = minVal;
else 
stiffness = maxVal / minVal;
end 

end 

threshold = get_param( model, 'StiffnessThreshold' );

if ( stiffness > threshold )
isStiff = true;
end 

result.isStiff = isStiff;
result.stiffness = stiffness;
end 

function [ X, D, s ] = condeigNoBalance( A )



try 
[ X, D, Y ] = eig( A, 'nobalance' );
catch ME
if ( strcmp( ME.identifier, 'MATLAB:eig:matrixWithNaNInf' ) )


msgId = 'Simulink:Engine:JacobianMatrixWithNanInf';
MSLException( [  ], message( msgId ) ).throw;
end 
end 

n = size( A, 1 );
s = zeros( n, 1, class( A ) );
for i = 1:n
s( i ) = norm( Y( :, i ) ) * norm( X( :, i ) ) / abs( Y( :, i )' * X( :, i ) );
end 

if nargout < 2
X = s;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXRGhpX.p.
% Please follow local copyright laws when handling this file.

