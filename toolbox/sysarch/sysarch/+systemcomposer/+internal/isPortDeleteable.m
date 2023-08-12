function tf = isPortDeleteable( cbinfo )





target = SLStudio.Utils.getOneMenuTarget( cbinfo );
archPort = systemcomposer.internal.getArchitecturePortFromCbinfo( cbinfo );
portHandle = archPort.SimulinkHandle;
parentHandle = get_param( get_param( portHandle, 'Parent' ), 'Handle' );

if isa( target, 'SLM3I.Port' )
tf = SLM3I.Util.isPortDeleteable( target );
elseif isa( target, 'SLM3I.Block' )
tf = ~systemcomposer.internal.isArchitectureLocked( parentHandle );
else 
tf = false;
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpvNRBYc.p.
% Please follow local copyright laws when handling this file.

