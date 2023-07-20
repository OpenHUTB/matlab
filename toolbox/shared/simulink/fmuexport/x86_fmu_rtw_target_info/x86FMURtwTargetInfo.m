function rtwTargetInfo(tr)


    tr.registerTargetInfo(@createToolchainRegistryFor32BitMSVCToolchain);
end

function config=createToolchainRegistryFor32BitMSVCToolchain
    config(1)=coder.make.ToolchainInfoRegistry;
    config(1).Name='MSVC 32 Bit Toolchain for FMU Export';
    config(1).FileName=fullfile(fileparts(mfilename('fullpath')),'msvc_32bit_fmuexport.mat');
    config(1).TargetHWDeviceType={'MATLAB Host','Intel->x86-32 (Windows32)','AMD->x86-32 (Windows32)','Generic->Unspecified (assume 32-bit Generic)'};
    config(1).Platform={'win64'};
end
