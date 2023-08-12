classdef LegacyProjectData < compiler.internal.deployScriptData.Data


methods 
function obj = LegacyProjectData( prjPath )
R36
prjPath{ mustBeTextScalar, mustBeFile }
end 
prjData = compiler.internal.readPRJStruct( prjPath );
obj = obj@compiler.internal.deployScriptData.Data( prjData );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpi_18lQ.p.
% Please follow local copyright laws when handling this file.

