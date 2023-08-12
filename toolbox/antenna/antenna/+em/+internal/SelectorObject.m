classdef SelectorObject < handle



properties 
MainObject = dipole;
end 

methods 
function obj = SelectorObject(  )


end 

function rtn = getPropertyTable( obj, MainObject )


R36
obj %#ok<INUSA> 
MainObject = obj.MainObject;
end 

propertyTable = em.internal.apps.getPropertyTable( MainObject );





rtn = propertyTable;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpDNJ7iP.p.
% Please follow local copyright laws when handling this file.

