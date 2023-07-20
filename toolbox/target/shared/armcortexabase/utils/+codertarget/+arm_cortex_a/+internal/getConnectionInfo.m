function [ipAddress,userName,password,downloadFolder,port] = getConnectionInfo(hardwareName)
%GETCONNECTIONINFO Get the connection info for ARM Cortex-A based target

%   Copyright 2014-2015 The MathWorks, Inc.

if isequal(hardwareName,'ARM Cortex-A9 (QEMU)')
    boardInfo = getARMCortexAInfo();
    hBoard = remotetarget.util.BoardParameters(boardInfo.BoardName);
    [ipAddress, userName, password, downloadFolder] = hBoard.getBoardParameters();
    port = hBoard.getParam('sshport');
else
    prefPrefix = 'Hardware_Connectivity_Installer';
    prefName = hardwareName;
    prefName = strrep(prefName,' ','_');
    prefName = strrep(prefName,'(','');
    prefName = strrep(prefName,')','');
    prefName = strrep(prefName,'-','_');
    % Do not use iscvar built-in function since it is only available with
    % Simulink (MATLAB PIL fails).
    if ~i_iscvar(prefName)
        error(message('arm_cortex_a:utils:TargetHardwareNameInvalidForPref', ...
            prefName, hardwareName, hardwareName));
    end
    prefName = [prefPrefix '_' prefName];
    if ispref(prefName)
        pref = getpref(prefName);
        ipAddress = pref.DefaultIpAddress;
        userName = pref.DefaultUserName;
        password = pref.DefaultPasswordPref;
        downloadFolder = pref.DefaultBuildDirPref;
        if isfield(pref,'DefaultsshportPref')
            port =        pref.DefaultsshportPref;
        else
            port =22;
        end
        
        
        
    else
        error(message('arm_cortex_a:utils:TargetHardwarePreferencesNotFound', ...
            hardwareName,prefName,'DefaultIpAddress','DefaultUserName', ...
            'DefaultPasswordPref','DefaultBuildDirPref'));
    end
end
end

%%-------------------------------------------------------------------------
function status = i_iscvar(s)
%ISCVAR  True for valid C variables.
%    For a string S, ISCVAR(S) is 1 for alphanumeric
%    variables starting with [_a-zA-Z] and 0 otherwise.

tmp = regexp(s,'[a-zA-Z_][a-zA-Z0-9_]{0,31}','match','once');
if ~isempty(tmp)
    status = true;
else
    status = false;
end
end
