function [ x, lambda, how ] = simlp( f, A, B, vlb, vub, x, neqcstr, verbosity )



































if nargin < 8, verbosity = 0;
if nargin < 7, neqcstr = 0;
if nargin < 6, x = [  ];
if nargin < 5, vub = [  ];
if nargin < 4, vlb = [  ];
end 
end 
end 
end 
end 
[ ncstr, nvars ] = size( A );
nvars = max( [ length( f ), nvars ] );

if isempty( x ), x = zeros( nvars, 1 );end 


if isempty( A ), A = zeros( 0, nvars );end 
if isempty( B ), B = zeros( 0, 1 );end 

caller = 'lp';
negdef = 0;normalize = 1;
[ x, lambda, how ] = qpsub( [  ], f( : ), A, B( : ), vlb, vub,  ...
x( : ), neqcstr, verbosity, caller, ncstr, nvars, negdef, normalize );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvtRO9C.p.
% Please follow local copyright laws when handling this file.

