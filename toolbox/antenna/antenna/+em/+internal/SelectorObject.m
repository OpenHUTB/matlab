classdef SelectorObject < handle



properties 
MainObject = dipole;
end 

methods 
function obj = SelectorObject(  )


end 

function rtn = getPropertyTable( obj, MainObject )


arguments
obj %#ok<INUSA> 
MainObject = obj.MainObject;
end 

propertyTable = em.internal.apps.getPropertyTable( MainObject );

rtn = propertyTable;
end 
end 
end 




