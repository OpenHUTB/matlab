function savetargetDeviceSettingToModel( obj, modelName, workflow, targetPlatform, synthesisTool, synthesisToolChipFamily, synthesisToolDeviceName, synthesisToolPackageName, synthesisToolSpeedValue )


if ( ~obj.isMLHDLC )
if ~obj.getloadingFromModel
paramValPairs = { modelName };

if ~strcmp( hdlget_param( modelName, 'Workflow' ), workflow )
paramValPairs = [ paramValPairs, { 'Workflow', workflow } ];
end 
if ~strcmp( hdlget_param( modelName, 'TargetPlatform' ), targetPlatform )
paramValPairs = [ paramValPairs, { 'TargetPlatform', targetPlatform } ];
end 
if ~strcmp( hdlget_param( modelName, 'SynthesisTool' ), synthesisTool )
paramValPairs = [ paramValPairs, { 'SynthesisTool', synthesisTool } ];
end 
if ~strcmp( hdlget_param( modelName, 'SynthesisToolChipFamily' ), synthesisToolChipFamily )
paramValPairs = [ paramValPairs, { 'SynthesisToolChipFamily', synthesisToolChipFamily } ];
end 
if ~strcmp( hdlget_param( modelName, 'SynthesisToolDeviceName' ), synthesisToolDeviceName )
paramValPairs = [ paramValPairs, { 'SynthesisToolDeviceName', synthesisToolDeviceName } ];
end 
familyName = hdlget_param( modelName, 'SynthesisToolChipFamily' );
if ( ~isempty( familyName ) && ( strcmpi( familyName, 'kintexu' ) || strcmpi( familyName, 'virtexu' ) || contains( familyName, 'UltraScale' ) ) )
paramValPairs = [ paramValPairs, { 'SynthesisToolPackageName', '' } ];
paramValPairs = [ paramValPairs, { 'SynthesisToolSpeedValue', '' } ];
else 
if ~strcmp( hdlget_param( modelName, 'SynthesisToolPackageName' ), synthesisToolPackageName )
paramValPairs = [ paramValPairs, { 'SynthesisToolPackageName', synthesisToolPackageName } ];
end 
if ~strcmp( hdlget_param( modelName, 'SynthesisToolSpeedValue' ), synthesisToolSpeedValue )
paramValPairs = [ paramValPairs, { 'SynthesisToolSpeedValue', synthesisToolSpeedValue } ];
end 
end 




if length( paramValPairs ) > 1
hdlset_param( paramValPairs{ : } );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyBnzps.p.
% Please follow local copyright laws when handling this file.

