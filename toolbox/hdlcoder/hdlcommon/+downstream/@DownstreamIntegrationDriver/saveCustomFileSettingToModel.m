function saveCustomFileSettingToModel( obj, modelName, customFiles )


if ( ~obj.isMLHDLC )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'SynthesisProjectAdditionalFiles' ), customFiles )
hdlset_param( modelName, 'SynthesisProjectAdditionalFiles', customFiles );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDhRtYx.p.
% Please follow local copyright laws when handling this file.

