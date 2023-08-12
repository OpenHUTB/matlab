


classdef LoadedArtifact < matlab.mixin.SetGet




properties ( Hidden )
InputArg_ArtifactUuid string
end 

properties 
ArtifactUuid string
CloseFcn function_handle
end 

methods 

function h = LoadedArtifact( artifactUuid, closeFcn )

R36
artifactUuid{ mustBeTextScalar }
closeFcn{ mustBeA( closeFcn, "function_handle" ) } = @(  )do_nothing;
end 

h.InputArg_ArtifactUuid = artifactUuid;
h.CloseFcn = closeFcn;
end 

end 

methods ( Hidden )

function proxy_close( h )

if functions( h.CloseFcn ).function ~= "@()[]"
h.CloseFcn(  );
end 
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgh5Ruj.p.
% Please follow local copyright laws when handling this file.

