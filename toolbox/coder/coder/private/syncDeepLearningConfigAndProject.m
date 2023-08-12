function varargout = syncDeepLearningConfigAndProject( mode, project, config )





R36
mode( 1, 1 )string{ mustBeMember( mode, [ "toconfig", "toproject" ] ) }
project( 1, 1 ){ mustBeA( project, [ "com.mathworks.project.impl.model.Project", "com.mathworks.project.impl.model.Configuration" ] ) }
config = [  ]
end 

if isa( project, 'com.mathworks.project.impl.model.Project' )
javaConfig = project.getConfiguration(  );
else 
javaConfig = project;
end 
varargout = {  };
if ~com.mathworks.toolbox.coder.app.UnifiedTargetFactory.isUnifiedTarget( javaConfig.getTarget(  ) )
return ;
end 


TARGET_LIB_KEY = 'param.deeplearning.TargetLib';
DL_ENABLED_KEY = 'param.deeplearning.EnableDeepLearning';

TYPE_CONVERTERS = struct(  );
TYPE_CONVERTERS.ArmComputeVersion.toJava = @( x )sprintf( 'option.arm-compute.version.%s', strrep( x, '.', '_' ) );
TYPE_CONVERTERS.ArmComputeVersion.toMatlab = @( x )strrep( x, '_', '.' );


switch mode
case 'toconfig'
if ~isempty( config )
validateattributes( config, { 'coder.Config' }, { 'scalar' } );
end 
evalc( 'projectToConfig' );
varargout = { config };
case 'toproject'
validateattributes( config, { 'coder.Config', 'coder.DeepLearningConfigBase' }, { 'scalar' } );
evalc( 'configToProject' );
end 



function projectToConfig(  )
dlc = coder.DeepLearningConfigBase.empty(  );
if valueFromProject( DL_ENABLED_KEY )
libId = extractValueToken( valueFromProject( TARGET_LIB_KEY ) );
if ~strcmpi( libId, 'none' ) || supportsTargetLibNone( config )
dlc = applyProjectSettingsForConfig( coder.DeepLearningConfig( 'TargetLibrary', libId ) );
end 
end 
if isempty( config )
config = dlc;
end 
if ~isempty( config ) && isprop( config, 'DeepLearningConfig' )
config.DeepLearningConfig = dlc;
end 
end 

function dlc = applyProjectSettingsForConfig( dlc )
forEachConfigPropertyMapping( dlc, @applySingleProjectSetting );

function applySingleProjectSetting( dlcProp, paramKey )
if ( ( dlcProp == "DataPath" ) || ( dlcProp == "NumCalibrationBatches" ) ) && ( dlc.DataType == "fp32" )

return ;
end 
projValue = valueFromProject( paramKey );
if dlcProp == "ArmArchitecture" && projValue == "unspecified"
if isempty( dlc.( dlcProp ) )

return ;
end 
projValue = '';
elseif isfield( TYPE_CONVERTERS, dlcProp )
projValue = TYPE_CONVERTERS.( dlcProp ).toMatlab( projValue );
end 
if ~isequal( dlc.( dlcProp ), projValue )
try 
dlc.( dlcProp ) = projValue;
catch 
end 
end 
end 
end 

function value = valueFromProject( paramKey )
paramType = getParamType( paramKey );
value = javaConfig.getParamAsObject( paramKey );
if isempty( value ) && ismember( paramType, { 'string', 'dir', 'file', 'enum' } )
value = '';
end 
if isjava( value )
value = char( value.toString(  ) );
end 
if ischar( value ) && paramType == "enum"
value = extractValueToken( value );
end 
end 

function paramType = getParamType( paramKey )
paramType = lower( char( javaConfig.getTarget(  ).getParam( paramKey ).getType(  ) ) );
end 

function configToProject(  )
if isa( config, 'coder.Config' )
if isprop( config, 'DeepLearningConfig' )
dlc = config.DeepLearningConfig;
else 
dlc = [  ];
end 
else 
dlc = config;
end 
if ~isempty( dlc )
targetLibEnumToken = dlc.TargetLibrary;
else 
targetLibEnumToken = 'none';
end 
javaConfig.setParamAsString( TARGET_LIB_KEY, [ 'option.deeplearning.targetlibrary.', targetLibEnumToken ] );
javaConfig.setParamAsBoolean( DL_ENABLED_KEY, ~isempty( dlc ) );
forEachConfigPropertyMapping( dlc, @applySingleConfigSetting );

function applySingleConfigSetting( dlcProp, paramKey )
value = dlc.( dlcProp );
if dlcProp == "DataType"
value = sprintf( 'option.%s.datatype.%s', lower( dlc.TargetLibrary ), value );
elseif dlcProp == "ArmArchitecture"
if isempty( value )
value = "unspecified";
end 
value = sprintf( 'option.arm-compute.architecture.%s', value );
elseif isfield( TYPE_CONVERTERS, dlcProp )
value = TYPE_CONVERTERS.( dlcProp ).toJava( value );
end 
javaConfig.setParamAsObject( paramKey, value );
end 
end 
end 


function valueToken = extractValueToken( projectOptionValue )
valueToken = regexp( projectOptionValue, '^.+\.(.+)$', 'Tokens' );
if ~isempty( valueToken )
valueToken = valueToken{ 1 }{ 1 };
else 
valueToken = projectOptionValue;
end 
end 


function forEachConfigPropertyMapping( dlc, task )
allProps = properties( dlc );
allProps = allProps( allProps ~= "TargetLibrary" );


if dlcoderfeature( 'cuDNNFp16' )
allProps{ end  + 1 } = 'DataType';
end 

for i = 1:numel( allProps )
dlcProp = allProps{ i };
task( dlcProp, sprintf( 'param.%s.%s', dlc.TargetLibrary, dlcProp ) );
end 
end 





function supported = supportsTargetLibNone( cfg )
if isempty( cfg )
supported = true;
return 
end 
supported = isprop( cfg, 'DeepLearningConfig' ) &&  ...
( ~isprop( cfg, 'GpuConfig' ) || isempty( cfg.GpuConfig ) || ~cfg.GpuConfig.Enabled );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp8bK2_G.p.
% Please follow local copyright laws when handling this file.

