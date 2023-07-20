function status = setTargetHardware(modelName, boardName)
%setTargetHardware Configure the given model for a Target Hardware

% Copyright 2013-2015 The MathWorks, Inc.

narginchk(2,2);

status = false; % only use pass or fail; caller expect one of these values
cs = getActiveConfigSet(modelName);
origCS = cs.copy;
if isequal(get_param(modelName, 'Dirty'), 'on')
    warning(message('codertarget:build:UpgradeAdvisorModelDirty'));
    return;
end


% TODO check if the processor matches the one of the supported ones otherwise, return
cs.switchTarget('ert.tlc', '');
% g1006028 To force BTI to be used even if optimizations are on
cs.setProp('RTWCompilerOptimization','off');
cs.setProp('BuildConfiguration','Faster Runs');
comps = cs.getComponent;
toKeep = getSettingsToKeep();
for i=1:numel(comps)
    if ~isequal(comps{i}, 'Target Hardware Resources')
        updateComponent(origCS, cs, comps{i}, toKeep);
    end
end
% set_param(cs, 'IgnoreCustomStorageClasses', get_param(origCS, 'IgnoreCustomStorageClasses'));
% Turn off inline Parameters; to enable tunable parameters
set_param(cs, 'InlineParams','off');
set_param(cs,'HardwareBoard',boardName);
set_param(cs,'ProdEqTarget','on');
status = true;
end
%--------------------------------------------------------------------------

function updateComponent(origCS, cs, componentName, settingsToKeep)
componentOrig = origCS.getComponent(componentName);
componentNew = cs.getComponent(componentName);
propsOrig = componentOrig.getProp;
propsNew = componentNew.getProp;
props = intersect(propsNew, propsOrig);
props = setdiff(props, settingsToKeep);
for i=1:length(props)
    prop = props{i};
    if isequal(prop, 'MultiInstanceERTCode')
        continue
    end
    try
        val = get_param(componentOrig, prop);
        enabledState = componentOrig.getPropEnabled(prop);
        componentNew.setPropEnabled(prop, 'on');
        set_param(componentNew, prop, val);
        componentNew.setPropEnabled(prop, enabledState);
    catch me %#ok<NASGU>
        % property may be read-only
    end
end
end

%--------------------------------------------------------------------------
function settingsToKeep = getSettingsToKeep
% These properties will be kept as set by the new target i.e. they will not
% get reapplied from the original model
settingsToKeep = { ...
    'TemplateMakefile', ...
    'SystemTargetFile', ...
    'GenerateMakefile', ...
    'Description', ...
    'IsERTTarget',...
    'ERTFirstTimeCompliant', ...
    'CombineOutputUpdateFcns',  ...
    'ERTCustomFileBanners', ...
    'SupportContinuousTime', ...
    'SupportNonInlinedSFcns', ...
    'CustomSymbolStrFcn', ...
    'UseToolchainInfoCompliant', ...
    'GenerateSampleERTMain', ...
    'RTWCompilerOptimization', ...
    'CodeInterfacePackaging', ...
    'MultiInstanceERTCode', ...
    'CompOptLevelCompliant'};
end

