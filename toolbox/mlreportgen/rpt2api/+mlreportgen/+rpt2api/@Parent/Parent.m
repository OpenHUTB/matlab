classdef Parent < mlreportgen.rpt2api.ComponentConverter




















methods 

function obj = Parent( component, rptFileConverter )
init( obj, component, rptFileConverter );
end 

end 

methods ( Access = protected )

function convertComponentChildren( obj )



import mlreportgen.rpt2api.*

children = getComponentChildren( obj );
n = numel( children );
for i = 1:n
cmpn = children{ i };
c = getConverter( obj.RptFileConverter.ConverterFactory,  ...
cmpn, obj.RptFileConverter );
convert( c );
end 

end 

function name = getVariableName( ~ )
name = [  ];
end 

end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpTeNDMQ.p.
% Please follow local copyright laws when handling this file.

