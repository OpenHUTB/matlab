function [ list, valueStr, valueInt ] = pmsl_resolvedialogunit( default, given, paramLabel )













default = l_pre_pmu_sanitize( default );
given = l_pre_pmu_sanitize( given );

if nargin ~= 3
paramLabel = '''''';
end 

paramLabel = pm.sli.internal.resolveMessageString( paramLabel );


if ~l_validate_unit( default )
pm_error( 'physmod:pm_sli:pmsl_resolvedialogunit:InvalidDefaultUnit',  ...
default );
else 
default = pm_canonicalunit( default );
end 


if ~l_validate_unit( given )


disp( [ 'Warning: ', pm_message( 'physmod:pm_sli:pmsl_resolvedialogunit:InvalidUnit',  ...
given, paramLabel, default, paramLabel ) ] );
list = pm_suggestunits( default );
unit = default;
else 

if ~pm_commensurate( given, default )


disp( [ 'Warning: ', pm_message( 'physmod:pm_sli:pmsl_resolvedialogunit:UnitsNotCommensurate',  ...
given, paramLabel, default, default, paramLabel ) ] );
list = pm_suggestunits( default );
unit = default;
elseif ~pm_directlyconvertible( given, default )
list = pm_suggestunits( default );
if ~any( strcmp( given, list ) )
list = unique( [ given;list ] );
end 
unit = given;
else 
unit = pm_canonicalunit( given );
list = pm_suggestunits( unit );
if ~ismember( default, list )
list = [ default;list ];
end 
end 
end 


valueStr = unit;


list = l_post_pmu_sanitize( valueStr, list );
list = { list{ : } };


idxs = find( strcmp( valueStr, list ) );
valueInt = idxs( 1 );

end 



function isValid = l_validate_unit( unit )



isValid = true;
try 
pm_canonicalunit( unit );
catch %#ok<CTCH>
isValid = false;
end 

end 



function retUnit = l_pre_pmu_sanitize( unit )











unit = strrep( unit, '-', '*' );
unit = strrep( unit, char( 178 ), '^2' );

retUnit = unit;
end 



function list = l_post_pmu_sanitize( unit, list )




persistent ENERGY_UNITS
persistent TORQUE_UNITS

if isempty( ENERGY_UNITS )




ENERGY_UNITS = pm_getallunits;
ENERGY_UNITS = ENERGY_UNITS( pm_commensurate( ENERGY_UNITS, 'J' ) );
end 

if isempty( TORQUE_UNITS )




allUnits = pm_getallunits;
forceUnits = allUnits( pm_commensurate( allUnits, 'N' ) );
lengthUnits = allUnits( pm_commensurate( allUnits, 'm' ) );
torqueUnits = {  };
for i = 1:length( forceUnits )
torqueUnits = cat( 1, torqueUnits, strcat( forceUnits{ i }, '*', lengthUnits ) );
end 
TORQUE_UNITS = l_canonicize( torqueUnits );
end 

if any( strcmp( TORQUE_UNITS, unit ) )



list = setdiff( list, ENERGY_UNITS );
elseif any( strcmp( ENERGY_UNITS, unit ) )



list = setdiff( list, TORQUE_UNITS );
end 

end 


function retList = l_canonicize( list )


retList = cellfun( @pm_canonicalunit, list, 'UniformOutput', false );

end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpK1c8pe.p.
% Please follow local copyright laws when handling this file.

