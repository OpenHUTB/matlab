function saveGenerateHDLSettingToModel( obj, modelName, generateHDLCode, generateTestbench, generateValidationModel )


if ~obj.isMLHDLC && ~obj.getloadingFromModel

if generateHDLCode
generateCodeSetting = 'on';
else 
generateCodeSetting = 'off';
end 
hdlset_param( modelName, 'GenerateHDLCode', generateCodeSetting );




if generateTestbench
generateTBSetting = 'on';

else 
generateTBSetting = 'off';

end 
obj.transientCLIMaps( 'GenerateTB' ) = generateTBSetting;


if generateValidationModel
generateModelSetting = 'on';
else 
generateModelSetting = 'off';
end 
hdlset_param( modelName, 'GenerateValidationModel', generateModelSetting );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRQMzyW.p.
% Please follow local copyright laws when handling this file.

