function resetCoderInterface( mdlName )





cm_internal = Simulink.CodeMapping.getCurrentMapping( mdlName );
if isa( cm_internal, 'Simulink.CoderDictionary.ModelMapping' )
cm_internal.updatePlatform( true );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBdvyr3.p.
% Please follow local copyright laws when handling this file.

