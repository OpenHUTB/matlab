classdef BlockPathToSignalMap < handle



properties ( Access = private )
BlockPathAndPortIndexMap
BlockPathAndNameMap
end 

methods ( Access = public )
function obj = BlockPathToSignalMap( run )


R36
run Simulink.sdi.Run;
end 

obj.BlockPathAndPortIndexMap = containers.Map;
obj.BlockPathAndNameMap = containers.Map;

if isempty( run )


return ;
end 


dsr = Simulink.sdi.DatasetRef( run.ID );
sigIDs = dsr.getSortedSignalIDs(  );















for kElem = 1:numel( sigIDs )
sig = Simulink.sdi.getSignal( sigIDs( kElem ) );
blockPath = sig.FullBlockPath;
portIndex = sig.PortIndex;
sigName = sig.Name;

fullPathWithPort = obj.getFullPathWithPort( blockPath, portIndex );
obj.BlockPathAndPortIndexMap( fullPathWithPort ) = sigIDs( kElem );

fullPathWithName = obj.getFullPathWithName( blockPath, sigName );
obj.BlockPathAndNameMap( fullPathWithName ) = sigIDs( kElem );
end 
end 

function sigID = getSigIDFromBlockPathAndPortIndex( obj, blockPath, portIndex )

fullPathWithPort = obj.getFullPathWithPort( blockPath, portIndex );
if obj.BlockPathAndPortIndexMap.isKey( fullPathWithPort )
sigID = obj.BlockPathAndPortIndexMap( fullPathWithPort );
else 
sigID = [  ];
end 
end 

function sigID = getSigIDFromBlockPathAndName( obj, blockPath, sigName )

fullPathWithName = obj.getFullPathWithName( blockPath, sigName );
if obj.BlockPathAndNameMap.isKey( fullPathWithName )
sigID = obj.BlockPathAndNameMap( fullPathWithName );
else 
sigID = [  ];
end 
end 
end 

methods ( Static, Access = private )
function fullPathWithPort = getFullPathWithPort( blockPath, portIndex )

fullPathWithPort = sprintf( '%s:%d', blockPath, portIndex );
end 

function fullPathWithName = getFullPathWithName( blockPath, sigName )

fullPathWithName = sprintf( '%s:#%s', blockPath, sigName );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzfyrp2.p.
% Please follow local copyright laws when handling this file.

