function saveIpCoreDUTClockEnableToModel( obj, modelName, DUTClockEnPort )


if ( DUTClockEnPort )
exposeDUTClockEnPort = 'on';
else 
exposeDUTClockEnPort = 'off';
end 

if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'ExposeDUTClockEnablePort' ), exposeDUTClockEnPort )
hdlset_param( modelName, 'ExposeDUTClockEnablePort', exposeDUTClockEnPort );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5X7gXk.p.
% Please follow local copyright laws when handling this file.

