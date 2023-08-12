function paramsAndValues = upgradeModelForToolchainCompliance( in )





[ config, ~ ] = coder.make.internal.getConfigObject( in );
if isa( config, 'Simulink.ConfigSetRef' )
config = config.getRefConfigSet;
end 
output = coder.internal.checkModelToolchainCompliance( config );

paramsAndValues = [  ];
for i = 1:numel( output.Params )
paramStruct = output.Params( i );
param = paramStruct.Parameter;

if ~paramStruct.IsCompliant && strcmpi( paramStruct.UpgradeMode, 'upgradable' )
set_param( config, param, paramStruct.DefaultValue );
paramsAndValues = horzcat( paramsAndValues, { param, paramStruct.ActualValue, paramStruct.DefaultValue } );%#ok<*AGROW>
if ~isempty( paramStruct.OtherUpgrades )
for idx = 1:2:numel( paramStruct.OtherUpgrades )
oldValue = get_param( config, paramStruct.OtherUpgrades{ idx } );
set_param( config, paramStruct.OtherUpgrades{ idx }, paramStruct.OtherUpgrades{ idx + 1 } );
paramsAndValues = horzcat( paramsAndValues, { paramStruct.OtherUpgrades{ idx }, oldValue, paramStruct.OtherUpgrades{ idx + 1 } } );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfL7OhE.p.
% Please follow local copyright laws when handling this file.

