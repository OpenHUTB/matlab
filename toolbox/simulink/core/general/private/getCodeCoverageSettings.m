



function codeCovSettings = getCodeCoverageSettings( modelNameOrGetParamFn, instrumSettingsModel )

persistent isSlCovInstalled
if isempty( isSlCovInstalled )
isSlCovInstalled = coder.internal.isSLCovInstalled(  );
end 

if nargin < 2
instrumSettingsModel = '';
end 

modelName = '';
if isa( modelNameOrGetParamFn, 'function_handle' )
if ~isempty( instrumSettingsModel ) && bdIsLoaded( instrumSettingsModel )

modelName = instrumSettingsModel;
getParamFn = @( name )get_param( modelName, name );
else 
getParamFn = modelNameOrGetParamFn;
end 
else 
modelName = modelNameOrGetParamFn;
getParamFn = @( name )get_param( modelName, name );
end 

codeCovSettings = getParamFn( 'CodeCoverageSettings' );





if isSlCovInstalled &&  ...
strcmpi( codeCovSettings.CoverageTool, 'None' ) &&  ...
~isa( modelNameOrGetParamFn, 'Simulink.ConfigSet' )

codeCovSettings.TopModelCoverage = getParamFn( 'RecordCoverage' );
slCovIsEnabled = strcmpi( codeCovSettings.TopModelCoverage, 'on' );

switch lower( getParamFn( 'CovModelRefEnable' ) )
case 'all'
codeCovSettings.ReferencedModelCoverage = 'on';
slCovIsEnabled = true;

case { 'off', 'none' }
codeCovSettings.ReferencedModelCoverage = 'off';

otherwise 
codeCovSettings.ReferencedModelCoverage = 'on';
slCovIsEnabled = true;
end 

if slCovIsEnabled
codeCovSettings.CoverageTool = SlCov.getCoverageToolName(  );

if ~isempty( modelName ) &&  ...
( SlCov.CodeCovUtils.isAtomicSubsystem( modelName ) ||  ...
SlCov.CodeCovUtils.isReusableLibrarySubsystem( modelName ) )
codeCovSettings.ReferencedModelCoverage = 'on';
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp1magXj.p.
% Please follow local copyright laws when handling this file.

