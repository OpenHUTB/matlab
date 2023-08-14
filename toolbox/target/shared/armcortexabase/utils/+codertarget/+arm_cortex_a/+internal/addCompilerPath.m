function addCompilerPath()
%ADDCOMPILERPATH Add GNU GCC compiler path to the MATLAB shell path

%   Copyright 2013-2018 The MathWorks, Inc.

    % LEGACY
info = getARMCortexAInfo();
tc = [info.ToolChainName, char(32), 'v', info.ToolChainVersion];
rootDir = codertarget.arm_cortex_a.internal.getTpPkgRootDir(tc);
envVar = 'LINARO_TOOLCHAIN_4_8';

binFolder = fullfile(rootDir, 'bin');
if ispc
    compilerPath  = RTW.transformPaths(binFolder, 'pathType', 'alternate');
    compilerPath  = strrep(compilerPath, '\', '/');
else
    compilerPath  = binFolder;
end

setenv(envVar, compilerPath);

end
