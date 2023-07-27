function addons = installedAddons

% installedAddons 返回已安装功能的列表
%
%   ADDONS = matlab.addons.installedAddons 返回当前安装的附加功能的列表
%   指定为包含这些字段的字符串表格：
% 
%           Name - 附件功能的名称
%        Version - 附加功能的版本
%        Enabled - 附加功能是否启用
%     Identifier - 附加功能的唯一标识符
% 
%   例子:  获取已安装附加功能的列表
% 
%   addons = matlab.addons.installedAddons
%
%   addons =
%
%   1x4 table
%
%                      Name                           Version    Enabled                   Identifier
%   _____________________________________________    _________   _______   ______________________________________
%
%   "Simulink"                                       "R2018b"     true                      "SL"
%
%   See also: matlab.addons.disableAddon,
%   matlab.addons.enableAddon,   
%   matlab.addons.isAddonEnabled

% Copyright 2017-2021 The MathWorks Inc.

% ToDo: Delete this if condition after installed Products and Support
% Packages register with Registration Framework
if usejava('jvm')
    addons = getInstalledAddOns();
    return;
end

addons = table(string.empty(0,1),string.empty(0,1),logical.empty(0,1),string.empty(0,1),...
        'VariableNames',{'Name','Version','Enabled','Identifier'}); 

addonsStruct = struct([]);

try
    installedAddOns = matlab.internal.addons.registry.getInstalledAddOnsMetadata;
    
    for addonIndex = 1:length(installedAddOns)
        addonsStruct(addonIndex).Name = string(installedAddOns(addonIndex).name);
        addonsStruct(addonIndex).Version = string(installedAddOns(addonIndex).version);
        addonsStruct(addonIndex).Enabled = logical(installedAddOns(addonIndex).enabled);
        addonsStruct(addonIndex).Identifier = string(installedAddOns(addonIndex).identifier);
    end
    
    if size(addonsStruct) > 0
        addons = struct2table(addonsStruct);
    end
    
catch ex
    error(ex.identifier, ex.message);
end

end