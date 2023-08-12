classdef FluidProperties < simscape.schema.internal.DerivedProperties




methods ( Static )
function params = requiredParams(  )
params = [ "SelFluid", "SysTemp" ];
end 
function res = derivedProperties( paramData )
R36
paramData( 1, : )struct
end 
import simscape.schema.internal.SchemaProperty


density = nan;
viscosity = nan;
bulkModulous = nan;



try %#ok<TRYNC> 
p = sh_stockfluidproperties;
d = struct2cell( p );
f = d{ paramData.SelFluid };
[ v, density, bulkModulous ] = f.prop( paramData.SysTemp.value( '1' ) );
viscosity = v * pm_unit( 'm^2/s', 'cSt', 'linear' );
end 


precision = 6;
lToStr = @( n )num2str( n, precision );
t = [ SchemaProperty( Label = "Density (kg/m^3)", Value = lToStr( density ) ),  ...
SchemaProperty( Label = "Viscosity (cSt)", Value = lToStr( viscosity ) ),  ...
SchemaProperty( Label = "Bulk modulus (Pa)", Value = lToStr( bulkModulous ),  ...
Tooltip = "Bulk modulus (Pa) at atm. pressure and no gass" ) ];

res = SchemaProperty( Label = "Fluid Properties", Children = t );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFxu7hI.p.
% Please follow local copyright laws when handling this file.

