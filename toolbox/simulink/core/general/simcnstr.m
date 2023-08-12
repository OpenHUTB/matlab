function [ x, OPTIONS, lambda, HESS ] = simcnstr( caller, FUN, x, OPTIONS,  ...
VLB, VUB, GRADFUN, varargin )








if nargin < 2, DAStudio.error( 'Simulink:util:InsufficientInputArguments', 'SIMCNSTR', num2str( 2 ) );end 
if nargin < 3, OPTIONS = [  ];end 
if nargin < 4, VLB = [  ];end 
if nargin < 5, VUB = [  ];end 
if nargin < 6, GRADFUN = [  ];end 

lenVarIn = length( varargin );


[ funfcn, msg ] = prefcnchk( FUN, caller, lenVarIn );
if ~isempty( msg )
error( msg );
end 

if ~isempty( GRADFUN )
[ gradfcn, msg ] = prefcnchk( GRADFUN, caller, lenVarIn );
if ~isempty( msg )
error( msg );
end 
else 
gradfcn = [  ];
end 

[ x, OPTIONS, lambda, HESS ] = nlconst( funfcn, x, OPTIONS, VLB, VUB, gradfcn, varargin{ : } );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpzcOT0W.p.
% Please follow local copyright laws when handling this file.

