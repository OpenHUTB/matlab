function [ status, prev, curr ] = vmsims( varargin )

curr.level = [  ];
curr.mdlRefLevel = [  ];
curr.verbose = [  ];
curr.rateGrouping = [  ];

prev = curr;

prev.verbose = get_param( 0, 'GlobalAccelVerboseBuild' );
prev.rateGrouping = slfeature( 'RateGroupingForAccelModes' );

defaultOnLevel = 1;
defaultOffLevel = 0;
defaultOnMdlRefLevel = 0;
defaultOffMdlRefLevel = 0;

idx = 1;
if nargin > 0
if isstruct( varargin{ 1 } )
curr = varargin{ 1 };
idx = idx + 1;
elseif strcmpi( varargin{ 1 }, 'on' )
curr.level = defaultOnLevel;
curr.mdlRefLevel = defaultOnMdlRefLevel;
idx = idx + 1;
elseif strcmpi( varargin{ 1 }, 'off' )
curr.level = defaultOffLevel;
curr.mdlRefLevel = defaultOffMdlRefLevel;
idx = idx + 1;
end 
end 

curr.prettyPrint = [  ];
curr.clear = [  ];
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

case { 'mdlreflevel', 'mdlrefvalue',  ...
'modelreflevel', 'modelrefvalue' }
if ~isempty( curr.mdlRefLevel )
error( 'invalid usage' );
end 
idx = idx + 1;
if ( idx > numOptions )
error( 'invalid usage' );
end 
curr.mdlRefLevel = numericValue( options{ idx }, true );

case { 'verbose' }
if ~isempty( curr.verbose )
error( 'invalid usage' );
end 
if ( idx + 1 <= numOptions )
value = options{ idx + 1 };
if strcmpi( value, 'on' )
curr.verbose = 'on';
idx = idx + 1;
elseif strcmpi( value, 'off' )
curr.verbose = 'off';
idx = idx + 1;
else 
value = numericValue( value, false );
if ~isnan( value )
if value == 0
curr.verbose = 'off';
else 
curr.verbose = 'on';
end 
idx = idx + 1;
else 
curr.verbose = 'on';
end 
end 
else 
curr.verbose = 'on';
end 

case { 'pp', 'prettyprint' }
if ~isempty( curr.prettyPrint )
error( 'invalid usage' );
end 
if ( idx + 1 <= numOptions )
value = numericValue( options{ idx + 1 }, false );
if ~isnan( value )
curr.prettyPrint = value;
idx = idx + 1;
else 
curr.prettyPrint = 1;
end 
else 
curr.prettyPrint = 1;
end 

case { 'rg', 'rategrouping' }
if ~isempty( curr.rateGrouping )
error( 'invalid usage' );
end 
if ( idx + 1 <= numOptions )
value = numericValue( options{ idx + 1 }, false );
if ~isnan( value )
curr.rateGrouping = value;
idx = idx + 1;
else 
curr.rateGrouping = 1;
end 
else 
curr.rateGrouping = 1;
end 

case { 'clear' }
if ~isempty( curr.clear )
error( 'invalid usage' );
end 
if ( idx + 1 <= numOptions )
value = options{ idx + 1 };
if strcmpi( value, 'Memory' )
curr.clear = 'Memory';
idx = idx + 1;
elseif strcmpi( value, 'All' )
curr.clear = 'All';
idx = idx + 1;
else 
value = numericValue( value, false );
if ~isnan( value )
if value == 1
curr.clear = 'Memory';
elseif value > 1
curr.clear = 'All';
end 
idx = idx + 1;
else 
curr.clear = 'All';
end 
end 
else 
curr.clear = 'All';
end 

otherwise 
error( 'invalid usage' );
end 
idx = idx + 1;
end 
if ~isempty( curr.level )
prev.level = slfeature( 'VMSimulations', curr.level );
status = curr.level > defaultOffLevel;
else 
prev.level = slfeature( 'VMSimulations' );
status = prev.level > defaultOffLevel;
end 
if ~isempty( curr.mdlRefLevel )
prev.mdlRefLevel = slfeature( 'ModelRefVMSimulations', curr.mdlRefLevel );
else 
prev.mdlRefLevel = slfeature( 'ModelRefVMSimulations' );
end 
if ~isempty( curr.verbose )
set_param( 0, 'GlobalAccelVerboseBuild', curr.verbose );
end 
if ~isempty( curr.prettyPrint )
switch curr.prettyPrint
case 0
set_param( 0, 'AcceleratorUseTrueIdentifier', 'off' );
slsvTestingHook( 'EnableCGIRPrettyPrinting', 0 );
slfeature( 'rtwcgir', 1 );
case 1
set_param( 0, 'AcceleratorUseTrueIdentifier', 'on' );
slsvTestingHook( 'EnableCGIRPrettyPrinting', 1 );
slfeature( 'rtwcgir', 6 );
otherwise 
set_param( 0, 'AcceleratorUseTrueIdentifier', 'on' );
slsvTestingHook( 'EnableCGIRPrettyPrinting', 1 );
slfeature( 'rtwcgir', 7 );
end 
end 
if ~isempty( curr.rateGrouping )
slfeature( 'RateGroupingForAccelModes', curr.rateGrouping );
end 
if ~isempty( curr.clear )
set_param( 0, 'GlobalClearAccelCache', curr.clear );
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmp_Leucy.p.
% Please follow local copyright laws when handling this file.

