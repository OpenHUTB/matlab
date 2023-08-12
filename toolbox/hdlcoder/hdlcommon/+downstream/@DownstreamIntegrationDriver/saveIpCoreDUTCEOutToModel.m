function saveIpCoreDUTCEOutToModel( obj, modelName, DUTCEOutPort )


if ( DUTCEOutPort )
exposeDUTCEOutPort = 'on';
else 
exposeDUTCEOutPort = 'off';
end 

if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'ExposeDUTCEOutPort' ), exposeDUTCEOutPort )
hdlset_param( modelName, 'ExposeDUTCEOutPort', exposeDUTCEOutPort );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpU7l3cG.p.
% Please follow local copyright laws when handling this file.

