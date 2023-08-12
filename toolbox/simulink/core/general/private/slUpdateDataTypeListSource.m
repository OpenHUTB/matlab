

















function dataSource = slUpdateDataTypeListSource( varargin )

mlock;
persistent currentDataSource;



if nargin == 1
if strcmp( varargin{ 1 }, 'get' )

if isempty( currentDataSource )
dataSource = '';
else 
dataSource = currentDataSource;
end 

elseif strcmp( varargin{ 1 }, 'clear' )

assert( ~isempty( currentDataSource ),  ...
'Data source cache should be non-empty when it is being cleared.' );
dataSource = currentDataSource;
currentDataSource = '';
else 
assert( false, 'Invalid operation! It should be one of get, set and clear.' );
end 
else 
assert( nargin == 2, 'Invalid input arguments.' );
assert( strcmp( varargin{ 1 }, 'set' ),  ...
'Invalid operation! It should be one of get, set and clear.' );


if ~any( strcmp( methods( class( varargin{ 2 } ) ), 'hasSLDDAPISupport' ) )
assert( isa( varargin{ 2 }, 'Simulink.dd.Connection' ),  ...
'New value should be a Simulink.dd.Connection object.' );
end 
assert( isempty( currentDataSource ),  ...
'Data source cache should be empty before a valid value is set.' );


dataSource = currentDataSource;
currentDataSource = varargin{ 2 };
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3Lqzog.p.
% Please follow local copyright laws when handling this file.

