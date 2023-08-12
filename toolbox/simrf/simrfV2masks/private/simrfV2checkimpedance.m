function outval = simrfV2checkimpedance( inval, realval, paramname,  ...
canbezero, infinity )

















narginchk( 2, 5 );

if nargin < 3
paramname = 'Impedance';
end 

validateattributes( inval, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'nonnan' }, '', paramname );

if nargin < 4
canbezero = 1;
end 

if realval
validateattributes( inval, { 'numeric' }, { 'real', 'positive' }, '', paramname );
else 
realparm = [ 'real part of ', paramname ];
if ( canbezero )
validateattributes( real( inval ), { 'numeric' }, { 'nonnegative' },  ...
'', realparm );
else 
validateattributes( real( inval ), { 'numeric' }, { 'positive' },  ...
'', realparm );
end 

end 

if nargin < 5
infinity = 0;
end 

if ~infinity
validateattributes( inval, { 'numeric' }, { 'finite' }, '', paramname );
end 

outval = inval;

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpHWNaAe.p.
% Please follow local copyright laws when handling this file.

