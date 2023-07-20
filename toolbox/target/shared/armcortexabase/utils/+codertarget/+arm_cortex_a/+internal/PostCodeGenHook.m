classdef PostCodeGenHook
%

%   Copyright 2018-2021 The MathWorks, Inc.
    
    properties
        BoardName
        QemuRunCmd
    end
    
    methods
        function obj = PostCodeGenHook(varargin)
            
        end
        
        function run(obj, hCS, buildInfo)
            % If hardware selection is 'ARM Cortex-A9 (QEMU), check if all third party
            % tools have been installed (QEMU, OpenVPN, BusyBox Linux).
            data = codertarget.data.getData(hCS);
            
            % Check the positive priority order and throw an error
            loc_checkPositivePriorityOrderSetting(hCS);
            
            %% Replace host-specific UDP block files with target-specific ones
            fileToFind = fullfile('$(MATLAB_ROOT)','toolbox','shared','spc', 'src_ml','extern','src','DAHostLib_Network.c');
            found = loc_findInBuildInfoSrc(buildInfo, fileToFind);
            
            if ~isempty(found)
                rootDir = codertarget.arm_cortex_a.internal.getSpPkgRootDir();
                loc_addUDPBlocksToBuildInfo(hCS, buildInfo, rootDir);
            end
            
            %% Replace RTIOStreamTCPIP core file with custom VxWorks 7 implementation
            if strcmpi(data.RTOS, 'VxWorks')
                fileToFind = fullfile('$(MATLAB_ROOT)','toolbox','coder','rtiostream', 'src', 'rtiostreamtcpip','rtiostream_tcpip.c');
                [found, idx] = loc_findInBuildInfoSrc(buildInfo, fileToFind);
                if ~isempty(found)
                    rootDir = codertarget.arm_cortex_a_base.internal.getSpPkgRootDir();
                    loc_replaceExtmodeSource(buildInfo, rootDir, idx);
                end
            end
            %% Add the assembler files to buildInfo local group if CRL is set to "ARM Cortex-A"
            %  and Shared code placement is set to "Shared location"
            sharedUtilsDir = loc_getsharedutildir(buildInfo);
            isCRLUsingSharedUtils = strcmpi(get_param(hCS, 'UtilityFuncGeneration'),'Shared location') && ...
                strcmpi(get_param(hCS, 'CodeReplacementLibrary'),'ARM Cortex-A');
            if isCRLUsingSharedUtils && exist(sharedUtilsDir,'dir')
                allSharedAsmFiles = dir(fullfile(sharedUtilsDir,'*.s'));
                for i=1:numel(allSharedAsmFiles)
                    buildInfo.addSourceFiles(allSharedAsmFiles(i).name,...
                        sharedUtilsDir, 'rtwshared.lib');
                end
            end
            
            %% Register block resources
            res = codertarget.resourcemanager.getAllResources(hCS);
            
            % ALSA blocks
            if isfield(res, 'ALSA')
                rootDir = codertarget.arm_cortex_a.internal.getSpPkgRootDir;
                buildInfo.addSourceFiles('MW_alsa_audio.c', fullfile(rootDir,'src'));
                buildInfo.addIncludeFiles(fullfile(rootDir,'include','MW_alsa_audio.h'));
                buildInfo.addLinkFlags('-lasound');
            end
            
            % V4L2 Video Capture block
            if isfield(res, 'V4L2')
                rootDir = codertarget.arm_cortex_a.internal.getSpPkgRootDir;
                %% armcortexa_v4l2_capture.c is added as an S-function module on the block
                %buildInfo.addSourceFiles('armcortexa_v4l2_capture.c', fullfile(rootDir,'blocks','sfcn','src'));
                buildInfo.addSourceFiles('armcortexa_v4l2_capture_linux.c', fullfile(rootDir,'blocks','sfcn','src'));
            end
            
            % Analog Input blocks
            if isfield(res, 'AI')
                rootDir = codertarget.arm_cortex_a.internal.getSpPkgRootDir;
                buildInfo.addSourceFiles('MW_analogInput.c', fullfile(rootDir,'src'));
                buildInfo.addIncludeFiles(fullfile(rootDir,'include','MW_analogInput.h'));
            end
            
            % PWM blocks
            if isfield(res, 'PWM')
                rootDir = codertarget.arm_cortex_a.internal.getSpPkgRootDir;
                buildInfo.addSourceFiles('MW_pwm.c', fullfile(rootDir,'src'));
                buildInfo.addIncludeFiles(fullfile(rootDir,'include','MW_pwm.h'));
            end
            
            % LED blocks
            if isfield(res, 'LED')
                rootDir = codertarget.arm_cortex_a.internal.getSpPkgRootDir;
                buildInfo.addSourceFiles('MW_led.c', fullfile(rootDir,'src'));
                buildInfo.addIncludeFiles(fullfile(rootDir,'include','MW_led.h'));
            end
            
            % GPIO blocks
            if isfield(res, 'GPIO')
                rootDir = codertarget.arm_cortex_a.internal.getSpPkgRootDir;
                buildInfo.addSourceFiles('MW_gpio.c', fullfile(rootDir,'src'));
                buildInfo.addIncludeFiles(fullfile(rootDir,'include','MW_gpio.h'));
            end
            
            %% Check for Target-Hardware Build action and start QEMU
            % Check if the "Generate code only" option is enabled
            isGenCodeOnly = strcmpi(get_param(hCS, 'GenCodeOnly'), 'on');
            if ~isGenCodeOnly && isequal(data.TargetHardware, obj.BoardName)
                if isfield(data.Runtime, 'BuildAction') && ...
                        isequal(data.Runtime.BuildAction, 'Build, load, and run')
                    % check if have any UDP receive block in the QEMU target to open
                    % those ports
                    % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
                    % instead use the post-compile filter activeVariants() - g2598484
                    allUDPReceiveBlocks = find_system(get_param(getModel(hCS), 'Name'),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'UDP Receive' ); % look only inside active choice of VSS
                    if isempty(allUDPReceiveBlocks)
                        feval(obj.QemuRunCmd);
                    else
                        portArray = get_param(allUDPReceiveBlocks,'localPort');
                        numSMP = 2; % Start emulators with 2 CPUs
                        gdbPort = []; % We don't want to start emulator in GDB mode
                        feval(obj.QemuRunCmd, gdbPort, numSMP, portArray);
                    end
                end
            end
            
        end
    end
end

function [found, idx] = loc_findInBuildInfoSrc(buildInfo, filename)
filename = strrep(filename, '$(MATLAB_ROOT)', matlabroot);
found = [];
idx = [];
for j=1:length(buildInfo.Src.Files)
    iFile = fullfile(buildInfo.Src.Files(j).Path, buildInfo.Src.Files(j).FileName);
    iFile = strrep(iFile, '$(MATLAB_ROOT)', matlabroot);
    if contains(iFile, filename)
        found = iFile;
        idx = j;
        break;
    end
end
end


%--------------------------------------------------------------------------
% Find shared utilities directory
function sharedutilsdir = loc_getsharedutildir (buildInfo)
sharedutilsdir = '';
for i=1:length(buildInfo.BuildArgs)
    if strcmpi(buildInfo.BuildArgs(i).Key,'SHARED_SRC_DIR')
        sharedutilsdir = strtrim (buildInfo.BuildArgs(i).Value);
    end
end
if ~isempty(sharedutilsdir)
    sharedutilsdir = fullfile (pwd, sharedutilsdir);
end
end

%--------------------------------------------------------------------------
function loc_checkPositivePriorityOrderSetting(hCS)
% Check the positive priority order and throw an error
% If operating system is VxWorks - PositivePriorityOrder should be 'off'
% If operating system is Linux - PositivePriorityOrder should be 'off'

if strcmpi(get_param(hCS, 'SampleTimeConstraint'), 'STIndependent')
    % positive priority order cannot be set when SampleTimeConstraint is set to STIndependent
    return;
end

if slprivate('getIsExportFcnModel', get_param(getModel(hCS),'Name'))
    % if generating code for export function model, do not check positive
    % priority order
    return;
end

osName = codertarget.targethardware.getTargetRTOS(hCS);
switch (lower(osName))
    case {'linux', 'vxworks'}
        if ~isequal(get_param(hCS, 'PositivePriorityOrder'), 'on')
            error(message('arm_cortex_a:utils:WrongPriorityOrder', get(hCS.getModel, 'Name'), 'on'));
        end
end
end

function loc_replaceExtmodeSource(buildInfo, rootDir, idx)
filePathToAdd = fullfile(rootDir,'src');
fileNameToAdd = 'rtiostream_tcpip_vxworks.c';
if exist(fullfile(filePathToAdd, fileNameToAdd),'file')
    % delete the file
    buildInfo.Src.Files(idx) = [];
    buildInfo.addSourceFiles(fileNameToAdd, filePathToAdd, 'SkipForInTheLoop');
    buildInfo.addSourceFiles(fileNameToAdd, filePathToAdd);
else
    warning(message('ERRORHANDLER:utils:FileNotFoundError',...
        fullfile(filePathToAdd, fileNameToAdd)));
end
end
%--------------------------------------------------------------------------
function loc_addUDPBlocksToBuildInfo(hCS, buildInfo, rootDir)
osName = codertarget.targethardware.getTargetRTOS(hCS);

if isempty(osName)
    return;
end

% Wind River supports two compilers, GCC and DIAB, based on which the
% dynamic linker flags are different
toolChain = get_param(hCS, 'Toolchain');

switch (lower(osName))
    case 'linux'
        filePathToAdd = fullfile(rootDir,'src');
        fileNameToAdd = 'linuxUDP.c';
        buildInfo.addLinkFlags('-ldl');
    case 'vxworks'
        filePathToAdd = fullfile(rootDir,'src');
        fileNameToAdd = 'vxworksUDP.c';
        buildInfo.addDefines('_VXWORKS_');
        if contains(toolChain, 'DIAB')
            buildInfo.addLinkFlags('-lnet');
            buildInfo.addLinkFlags('-Xdynamic');
        elseif contains(toolChain, 'GNU')
            % there is an issue with -non-static/-ldl flag in linker in
            % windriver gnu toolchain, use diab instead
        end
    otherwise
        % UDP not supported for current operating system
end

if exist(fullfile(filePathToAdd, fileNameToAdd),'file')
    buildInfo.addSourceFiles(fileNameToAdd, filePathToAdd, 'SkipForInTheLoop');
    buildInfo.addSourceFiles(fileNameToAdd, filePathToAdd);
    buildInfo.addDefines('_USE_TARGET_UDP_');
else
    % Could not find a valid UDP.c file; assuming this is a custom
    % target hardware, warn and proceed with code-generation
    warning(message('ERRORHANDLER:utils:FileNotFoundError',...
        fullfile(filePathToAdd, fileNameToAdd)));
end

end
