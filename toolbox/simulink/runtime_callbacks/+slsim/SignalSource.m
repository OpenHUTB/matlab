



classdef SignalSource

properties ( SetAccess = private, GetAccess = public )



BlockPath( 1, 1 )Simulink.SimulationData.BlockPath




UserData




BusElement( 1, : )char
end 

methods 
function obj = SignalSource( propArgs )
R36
propArgs.BlockPath
propArgs.UserData
propArgs.BusElement
end 

obj.BlockPath = propArgs.BlockPath;
obj.UserData = propArgs.UserData;
obj.BusElement = propArgs.BusElement;
end 

end 

methods ( Static, Hidden )
function validateBlockPath( blockPath )

mustBeText( blockPath );
end 

function validateUserData( userData )

end 

function validateBusElement( busElement )

mustBeTextScalar( busElement );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpmgXLbc.p.
% Please follow local copyright laws when handling this file.

