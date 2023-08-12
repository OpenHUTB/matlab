function saveTestPointSettingToModel( obj, modelName, enableTestPoints )


if ~obj.isMLHDLC && ~obj.getloadingFromModel

if enableTestPoints
enableTestPointsSetting = 'on';
else 
enableTestPointsSetting = 'off';
end 
hdlset_param( modelName, 'EnableTestpoints', enableTestPointsSetting );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIiE30H.p.
% Please follow local copyright laws when handling this file.

