function installedToolbox = install(fileName, varargin)
%   INSTALL Install add-on
%   NEWADDON = MATLAB.ADDONS.INSTALL(FILENAME,INSTALLOPTION) 
%   使用指定的安装选项 INSTALLOPTION 安装 FILENAME 指定的加载项，
%   并返回有关已安装加载项的信息。
%   FILENAME 必须是有效的工具箱安装文件（*.mltbx）。
%   可以将 FILENAME 指定为绝对路径或相对路径。
%
%   INSTALLOPTION must be:
%      'overwrite' - (default) Overwrite all previously installed versions
%                    of the add-on.
%      'add'       - Install the add-on without overwriting previously
%                    installed versions of the add-on.
%   If INSTALLOPTION is not specified, it is set to 'overwrite' by default.
%
%   NEWADDON = MATLAB.ADDONS.INSTALL(FILENAME,AGREETOLICENSE) installs the
%   add-on using the specified AGREETOLICENSE option. If a version of the
%   add-on is already installed, INSTALL overwrites the previous version.
%
%   AGREETOLICENSE must be:
%      true      - If the add-on contains a license agreement, MATLAB installs
%                    the add-on without opening the license agreement dialog. By setting
%                    AGREETOLICENSE to 'silent', you accept the terms of license agreement.
%                    Be sure that you have reviewed the license agreement before installing
%                    the add-on.
%      false     - (default) If the add-on contains a license agreement, MATLAB
%                    displays a dialog prompting to agree to the licensing terms or
%                    cancel installation.
%   If AGREETOLICENSE is not specified, it is set to false by default.
%
%   NEWADDON = MATLAB.ADDONS.INSTALL(FILENAME,INSTALLOPTION,AGREETOLICENSE) installs
%   the specified add-on using the specified INSTALLOPTION and
%   AGREETOLICENSE.
%
%   NEWADDON is a table of strings with these fields:
%           Name - Name of the installed add-on
%        Version - Version of the installed add-on
%        Enabled - Whether the add-on is enabled
%     Identifier - Unique identifier of the installed add-on
%
%   Note: INSTALL only supports toolboxes
%
%   Examples:
%
%   1. Install a toolbox, overwriting any existing versions.
%
%   matlab.addons.install("C:\myAddons\GUI Layout Toolbox 2.1.2.mltbx",true)
%
%   ans =
%
%   1x4 table
%
%             Name            Version    Enabled                  Identifier
%     ____________________    _______    _______    ______________________________________
%
%     "GUI Layout Toolbox"    "2.1.2"     true      "e5af5a78-4a80-11e4-9553-005056977bd0"
%
%
%   2. Install a toolbox, without overwriting any existing versions.
%
%   matlab.addons.install("C:\myAddons\GUI Layout Toolbox 2.1.3.mltbx",'add',true)
%
%   ans =
%
%   1x4 table
%
%             Name            Version    Enabled                  Identifier
%     ____________________    _______    _______    ______________________________________
%
%     "GUI Layout Toolbox"    "2.1.3"     true      "e5af5a78-4a80-11e4-9553-005056977bd0"
%
%   See also: matlab.addons.installedAddons,
%   matlab.addons.uninstall

% Copyright 2018-2021 The MathWorks Inc.

narginchk(1,3);

% Allowed values for INSTALLOPTION
installOptionAdd = 'add';
installOptionOverwrite = 'overwrite';

% Initialize optional parameters
installOption = '';
agreeToLicense = '';


fileName = char(fileName);

%%%%%%%%%%%%    Begin: Validate input parameters   %%%%%%%%%%%%

% Validate fileName
validateattributes(fileName,{'char','string'},{'scalartext'}, ...
    'matlab.addons.install','FILENAME',1)

[~,~,ext] = fileparts(fileName);
% Supports installing toolboxes only
if ~strcmpi(ext,'.mltbx')
    error(message('matlab_addons:install:invalidFileType'));
end

if ~isfile(fileName)
    error(message('matlab_addons:install:invalidFilePath', fileName));
end

% Validate and parse optional parameters
if nargin > 1
    secondParameter = varargin{1};
    validateOptionalParameter(secondParameter);
    if islogical(secondParameter)
        agreeToLicense = secondParameter;
    else
        validateInstallOption(secondParameter);
        secondParameter = convertStringsToChars(secondParameter);
        installOption = secondParameter;
    end

    if nargin == 3
        thirdParameter = varargin{2};
        if ~isempty(installOption)
            if islogical(thirdParameter)
                agreeToLicense = thirdParameter;
            else
                error(message('matlab_addons:install:invalidAgreeToLicense'));
            end
        else
            validateattributes(thirdParameter,{'char','string'},{'scalartext'}, ...
            'matlab.addons.install', 'INSTALLOPTION')
            validateInstallOption(thirdParameter);
            thirdParameter = convertStringsToChars(thirdParameter);
            installOption = thirdParameter;
        end
    end
end

%%%%%%%%%%%%    End: Validate input parameters   %%%%%%%%%%%%

% Assign default values to optional arguments
if isempty(installOption)
    installOption = installOptionOverwrite;
end

if isempty(agreeToLicense)
    agreeToLicense = false;
end

installedToolbox = table.empty;
try
    addonProperties = mlAddonGetProperties(fileName);
catch ex
    error(message('toolboxmanagement_matlab_api:installToolbox:invalidToolboxFile'));
end
identifier = addonProperties.GUID;
version = addonProperties.version;
addonName = addonProperties.name;

% g1780615 - Initialize cache and ensure future object is available upfront
% This avoids cache getting initialized when adding the new installation, causing thread lock
addOnsInstallationFolder = matlab.internal.addons.util.retrieveAddOnsInstallationFolder;
if isempty(char(addOnsInstallationFolder))
	setAddOnsInstallationFolderToDefault;
end
installedAddonsCache = com.mathworks.addons_common.notificationframework.InstalledAddOnsCache.getInstance;
installedAddonsCache.getInstalledAddOnsMap();

toolboxPackage = matlab.internal.addons.metadata.MltbxMetadataReader(fileName);
if hasLicense(toolboxPackage) && ~agreeToLicense
    % 调用matlab\java\jar\addons_common.jar压缩文件中的com\mathworks\addons_common\util\MatlabDesktopUtils.class
    parent = com.mathworks.addons_common.util.MatlabDesktopUtils.getMatlabDesktopFrame;
    title = message('matlab_addons:install:licenseAgreementDialogTitle', addonName).getString;
    text = toolboxPackage.getLicense.text;
    licenseAgreementDialog = javaObjectEDT('com.mathworks.license_agreement_dialog.LicenseAgreementDialog', parent, title, text, true);
    licenseAgreementDialog.show;
    if licenseAgreementDialog.isConfirmedByUser
        launchInstallation;
    end
else
    launchInstallation;
end

    function validateOptionalParameter(value)
        if ~(ischar(value) || isstring(value) || isStringScalar(value) || islogical(value))
            error(message('matlab_addons:install:invalidAgreeToLicenseOrInstallOption'));
        end
    end
    function validateInstallOption(value)
        validateattributes(value,{'char','string'},{'scalartext'}, ...
            'matlab.addons.install', 'INSTALLOPTION')
        value = convertStringsToChars(value);
        % Validate installOption
        if ~any(strcmpi({installOptionAdd, installOptionOverwrite}, value))
            error(message('matlab_addons:install:invalidInstallOption'));
        end
    end

    function launchInstallation
        if (strcmpi(installOption, installOptionOverwrite) == 1)
            % If there are multiple versions installed, uninstall all
            % versions before installing new one
            if hasAnyVersionInstalled(identifier)
                matlab.addons.uninstall(identifier, 'All');
            end
        else
            if installedAddonsCache.hasAddonWithIdentifierAndVersion(identifier, version)
                matlab.addons.uninstall(identifier, version);
            end
        end
        % Currently enabled version should be disabled before notifying
        % Add-on Management since the notification does not take care of
        % disabling the enabled version when notified from MATLAB API
        % ToDo: Perform disable in install.m
        disabledOtherVersion = false;
        if installedAddonsCache.hasAddonWithIdentifier(identifier) && installedAddonsCache.hasEnabledVersion(identifier)
            addOnToDisable = installedAddonsCache.retrieveEnabledAddOnVersion(identifier);
            versionOfAddOnToDisable = addOnToDisable.getVersion;
            matlab.addons.disableAddon(identifier, versionOfAddOnToDisable);
            disabledOtherVersion = true;
        end
        try
            installToolbox(fileName);
            % Enable add-on
            matlab.addons.enableAddon(identifier, version);
            installedToolbox = table;
            installedToolbox.Name = string(addonName);
            installedToolbox.Version = string(version);
            installedToolbox.Enabled = logical(matlab.addons.isAddonEnabled(identifier, version));
            installedToolbox.Identifier = string(identifier);
        catch ex
            if disabledOtherVersion
                matlab.addons.enableAddon(identifier, versionOfAddOnToDisable);
            end
            % Determine if 'Not writable' message needs to be displayed
            if isprop(ex, 'ExceptionObject') && ...
                    (~isempty(strfind(ex.ExceptionObject.getClass, 'AccessDeniedException')) || ...
                    ~isempty(strfind(ex.ExceptionObject.getClass, 'IOException')))
                error(message('toolboxmanagement_matlab_api:installToolbox:accessDeniedInstallationPath'));
            elseif isprop(ex, 'ExceptionObject') && ...
                    ~isempty(strfind(ex.ExceptionObject.getClass, 'AddonPackageIOException'))
                error(message('toolboxmanagement_matlab_api:installToolbox:invalidToolboxFile'));
            else
                error(ex.message);
            end
        end
    end
    
    function containsLicense = hasLicense(toolboxProperties)
        try
            if isempty(toolboxProperties.getLicense.text)
                containsLicense = false;
            else
                containsLicense = true;
            end
        catch ex
            containsLicense = false;
        end
    end
end
