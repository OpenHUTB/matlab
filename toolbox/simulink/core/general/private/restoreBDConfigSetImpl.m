function [ isRestored, restoredModels ] = restoreBDConfigSetImpl( mdl )


















if nargin > 0
mdl = convertStringsToChars( mdl );
end 

isRestored = false;%#ok
restoredModels = [  ];

loadFlag = false;

if isa( mdl, 'char' )
if bdIsLoaded( mdl )
loadFlag = true;
else 
load_system( mdl );
end 
elseif isa( mdl, 'Simulink.BlockDiagram' )
loadFlag = true;
mdl = mdl.Name;
else 
DAStudio.error( 'configset:util:IncorrectArgument' );
end 

h = configset.util.Propagation( mdl, 'nogui' );
if ~h.IsPropagated
if ~loadFlag
close_system( mdl, 1 );
end 
DAStudio.error( 'configset:util:NoBackupFile' );
end 

h.restore(  );
h.save(  );

vs = h.Map.values;
for i = 1:length( vs )
v = vs{ i };
if strcmp( v.Status, 'Restored' )
restoredModels{ end  + 1 } = v.Name;%#ok
end 
end 
isRestored = ~isempty( restoredModels );

delete( h );

if ~loadFlag
close_system( mdl, 0 );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmphneWyU.p.
% Please follow local copyright laws when handling this file.

