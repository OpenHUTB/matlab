function onAfterCodeGen(hCS, buildInfo)
%ONAFTERCODEGEN Hook point for after code generation ARM Cortex-A9 (QEMU)

%   Copyright 2013-2019 The MathWorks, Inc.

codeGenHook = codertarget.arm_cortex_a.internal.PostCodeGenHook();
codeGenHook.BoardName = 'ARM Cortex-A9 (QEMU)';
codeGenHook.QemuRunCmd = 'codertarget.arm_cortex_a.runQemu';
codeGenHook.run(hCS, buildInfo);

isESBEnabled = codertarget.utils.isESBEnabled(get_param(hCS.getModel, 'Name'));

%Checking the given model is a top-level or referenced model
[~, buildArgValue] = findBuildArg(buildInfo, 'MODELREF_TARGET_TYPE');
isTopLevel = strcmp(buildArgValue, 'NONE');


if isESBEnabled && isTopLevel
	rootDir = codertarget.arm_cortex_a_base.internal.getSpPkgRootDir;
	isKernelProfilingEnabled = ...
		codertarget.profile.internal.isKernelProfilingEnabled(hCS);
	data = codertarget.data.getData(hCS);
	if isequal(data.ExtMode.Configuration,'XCP on TCP/IP')
		% Add includes
		buildInfo.addIncludePaths(fullfile(rootDir,'include'));
		% Add defines
		buildInfo.addDefines('XCP_CUSTOM_PLATFORM');
		buildInfo.addDefines('XCP_LOCKLESS_SYNC_DATA_TRANSFER_SUPPORT');
    end	
	if isKernelProfilingEnabled
		% Add includes
		buildInfo.addIncludePaths(fullfile(rootDir,'include'));
		buildInfo.addSourcePaths(fullfile(rootDir,'src'));
		% Add sources
		buildInfo.addSourceFiles({'kernelprofiler-tp.c'});
		buildInfo.addLinkFlags('-llttng-ust');
	end
end
end

