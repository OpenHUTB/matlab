classdef ( Abstract )DataAdapter


properties ( Access = protected )
dataWrapper
end 

properties ( Constant )
DEFAULT = string.empty;
end 

methods 
function obj = DataAdapter( dataSource )
R36
dataSource( 1, 1 )compiler.internal.deployScriptData.Data
end 
obj.dataWrapper = dataSource;
end 
end 

methods ( Abstract )
value = getOptionValue( obj, option )
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp_z0zMh.p.
% Please follow local copyright laws when handling this file.

