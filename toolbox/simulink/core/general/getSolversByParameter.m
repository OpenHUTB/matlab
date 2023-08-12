function solvers = getSolversByParameter( varargin )























if mod( nargin, 2 )
error( 'Please use pairs of param_name, param_value as input' )
end 


start_simulink;
assert( is_simulink_loaded );

solvers = slmex( 'getSolverInfo' );

for i = 1:2:length( varargin )
solvers = process( solvers, varargin{ i }, varargin{ i + 1 } );
end 



function solvers = process( solvers, param_name, param_value )
if strcmp( param_name, 'States' )
if strcmp( param_value, 'Discrete' ) || strcmp( param_value, 'Continuous' )
arr = 1:length( solvers );
idx = strfindidx( solvers, 'Discrete' );
if strcmp( param_value, 'Discrete' )
solvers = solvers( idx );
return ;
else 
arrxor = setxor( idx, arr );
solvers = solvers( arrxor );
return ;
end 
else 
solvers = {  };
end 
else 
idx = [  ];
j = 1;
for i = 1:length( solvers )
slvrs_struct = slmex( 'getSolverInfo', solvers{ i } );
if ~isempty( strmatch( param_name, fieldnames( slvrs_struct ) ) )
if strfind( slvrs_struct.( param_name ).Value, param_value )
idx( j ) = i;
j = j + 1;
end 
end 
end 
solvers = solvers( idx );
end 




function idx = strfindidx( cell, value )
ret = strfind( cell, 'Discrete' );
idx = [  ];
j = 1;
for i = 1:length( ret )
if ~isempty( ret{ i } )
idx( j ) = i;
j = j + 1;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8BL5vz.p.
% Please follow local copyright laws when handling this file.

