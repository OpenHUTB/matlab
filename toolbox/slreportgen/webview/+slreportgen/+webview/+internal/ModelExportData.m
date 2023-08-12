classdef ModelExportData < handle






















properties ( SetAccess = private )
Model slreportgen.webview.internal.Model
end 





methods 
function this = ModelExportData( model )
this.Model = model;
end 

function write( this, writer )
R36
this %#ok
writer slreportgen.webview.JSONWriter %#ok
end 

end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1l6bmf.p.
% Please follow local copyright laws when handling this file.

