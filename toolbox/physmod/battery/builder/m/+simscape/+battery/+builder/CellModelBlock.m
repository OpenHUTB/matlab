classdef CellModelBlock < matlab.mixin.CustomDisplay













properties ( Constant )

CellModelBlockPath string = "batt_lib/Cells/Battery" + newline + "(Table-Based)"
end 

properties ( Dependent )
BlockParameters
end 

properties ( SetAccess = private, Hidden )
BlockParametersInternal struct
end 

methods 
function obj = CellModelBlock( namedArgs )
R36


namedArgs.CellModelBlockPath( 1, 1 )string = "batt_lib/Cells/Battery" + newline + "(Table-Based)" %#ok<INUSA>
end 

if ~pmsl_checklicense( 'simscape_battery' )
error( message( 'physmod:battery:license:MissingLicense' ) );
end 

blockParamFields = [ "T_dependence", "thermal_port", "prm_age_OCV", "prm_age_capacity",  ...
"prm_age_resistance", "prm_age_modeling", "prm_dyn",  ...
"prm_dir", "prm_fade", "prm_leak" ];
blockParamValues = { simscape.enum.tablebattery.temperature_dependence.no, simscape.enum.thermaleffects.omit,  ...
simscape.enum.tablebattery.prm_age_OCV.OCV, simscape.enum.tablebattery.prm_age.disabled,  ...
simscape.enum.tablebattery.prm_age.disabled, simscape.enum.tablebattery.prm_age_modeling.equation,  ...
simscape.enum.tablebattery.prm_dyn.off, simscape.enum.tablebattery.prm_dir.noCurrentDirectionality,  ...
simscape.enum.tablebattery.prm_fade.disabled, simscape.enum.tablebattery.prm_leak.disabled };
for fieldnamesIdx = 1:length( blockParamFields )
[ BlockParameters.( blockParamFields{ fieldnamesIdx } ) ] = ( blockParamValues{ fieldnamesIdx } );
end 
obj.BlockParameters = BlockParameters;
end 

function value = get.BlockParameters( obj )
value = obj.BlockParametersInternal;
end 

function obj = set.BlockParameters( obj, value )


if isempty( obj.BlockParameters )
obj.BlockParametersInternal = value;
else 
if isequal( obj.BlockParameters, value )
else 

blockParamFieldnames = fieldnames( obj.BlockParameters );
valueParamFieldnames = fieldnames( value );
assert( isequal( blockParamFieldnames, valueParamFieldnames ),  ...
message( "physmod:battery:builder:batteryclasses:InvalidFieldName" ) );

for idx = 1:length( blockParamFieldnames )
if isequal( obj.BlockParameters.( blockParamFieldnames{ idx } ), value.( blockParamFieldnames{ idx } ) )
else 
blockParameters.( valueParamFieldnames{ idx } ) = value.( valueParamFieldnames{ idx } );
end 
end 
blockParametersCell = namedargs2cell( blockParameters );
obj = obj.updateBlockParameter( fieldnames( blockParameters ), blockParametersCell{ : } );
end 
end 
end 
end 

methods ( Access = private )

function obj = updateBlockParameter( obj, diffPropertyName, value )
R36
obj simscape.battery.builder.CellModelBlock
diffPropertyName
value.T_dependence( 1, 1 )simscape.enum.tablebattery.temperature_dependence = "no"
value.thermal_port( 1, 1 )simscape.enum.thermaleffects = "omit"
value.prm_age_OCV( 1, 1 )simscape.enum.tablebattery.prm_age_OCV = "OCV"
value.prm_age_capacity( 1, 1 )simscape.enum.tablebattery.prm_age = "disabled"
value.prm_age_resistance( 1, 1 )simscape.enum.tablebattery.prm_age = "disabled"
value.prm_age_modeling( 1, 1 )simscape.enum.tablebattery.prm_age_modeling = "equation"
value.prm_dyn( 1, 1 )simscape.enum.tablebattery.prm_dyn = "off"
value.prm_dir( 1, 1 )simscape.enum.tablebattery.prm_dir = "noCurrentDirectionality"
value.prm_fade( 1, 1 )simscape.enum.tablebattery.prm_fade = "disabled"
value.prm_leak( 1, 1 )simscape.enum.tablebattery.prm_leak = "disabled"
end 

for diffPropertyNameIdx = 1:length( diffPropertyName )
obj.BlockParametersInternal.( diffPropertyName{ diffPropertyNameIdx } ) = value.( diffPropertyName{ diffPropertyNameIdx } );
end 
end 
end 

methods ( Access = protected )

function propgrp = getPropertyGroups( ~ )
propList = [ "CellModelBlockPath", "BlockParameters" ];
propgrp = matlab.mixin.util.PropertyGroup( propList );
end 

function footer = getFooter( obj )


objectName = inputname( 1 );



if isscalar( obj ) && ~isempty( objectName )
linkStr = sprintf(  ...
[ 'matlab: if exist( ''%s'', ''var''), ',  ...
'simscape.battery.builder.CellModelBlock.fullDisplay( %s ), ',  ...
'end' ], objectName, objectName );
linkStr =  ...
sprintf( '<a href="%s">all properties</a>', linkStr );
footer = sprintf( 'Show %s\n', linkStr );
else 
footer = '';
end 
end 
end 

methods ( Static, Hidden )
function fullDisplay( o )
details( o )
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7Dlg3_.p.
% Please follow local copyright laws when handling this file.

