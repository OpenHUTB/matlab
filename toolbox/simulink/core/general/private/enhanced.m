function [ status, prev, curr ] = enhanced( varargin )

curr.level = [  ];
curr.blockLimit = [  ];
curr.optimization = [  ];

prev = curr;

prev.blockLimit = get_param( 0, 'AutoAccelerationStepsPerBlockLimit' );
prev.optimization = get_param( 0, 'GlobalNormalModeOptimization' );

defaultOnLevel = 1;
defaultOffLevel = 0;

idx = 1;
if nargin > 0
if isstruct( varargin{ 1 } )
curr = varargin{ 1 };
idx = idx + 1;
elseif strcmpi( varargin{ 1 }, 'on' )
curr.level = defaultOnLevel;
idx = idx + 1;
elseif strcmpi( varargin{ 1 }, 'off' )
curr.level = defaultOffLevel;
idx = idx + 1;
end 
end 

options = {  };
if ( idx <= nargin )
options = varargin( idx:nargin );
end 
numOptions = nargin + 1 - idx;
idx = 1;
while idx <= numOptions
name = lower( options{ idx } );
switch name
case { 'level', 'value' }
if ~isempty( curr.level )
error( 'invalid usage' );
end 
idx = idx + 1;
if ( idx > numOptions )
error( 'invalid usage' );
end 
curr.level = numericValue( options{ idx }, true );

case { 'blocklimit' }
if ~isempty( curr.blockLimit )
error( 'invalid usage' );
end 
idx = idx + 1;
if ( idx > numOptions )
error( 'invalid usage' );
end 
curr.blockLimit = numericValue( options{ idx }, true );

case { 'optimization' }
if ~isempty( curr.optimization )
error( 'invalid usage' );
end 
idx = idx + 1;
if ( idx > numOptions )
error( 'invalid usage' );
end 
curr.optimization = options{ idx };
otherwise 
error( 'invalid usage' );
end 
idx = idx + 1;
end 

if ~isempty( curr.level )
prev.level = slfeature( 'EnhancedNormalMode', curr.level );
status = curr.level > defaultOffLevel;
else 
prev.level = slfeature( 'EnhancedNormalMode' );
status = prev.level > defaultOffLevel;
end 
if ~isempty( curr.blockLimit )
set_param( 0, 'AutoAccelerationStepsPerBlockLimit', curr.blockLimit );
end 
if ~isempty( curr.optimization )
set_param( 0, 'GlobalNormalModeOptimization', curr.optimization );
end 
end 

function oVal = numericValue( iVal, reportError )
if isnumeric( iVal )
oVal = iVal;
else 
oVal = str2double( iVal );
if reportError && isnan( oVal )
error( 'invalid usage' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp65FlEG.p.
% Please follow local copyright laws when handling this file.

