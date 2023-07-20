function rtwTargetInfo(tr)




    tr.registerTargetInfo(@loc_createToolchain);

end




function config=loc_createToolchain

    config=coder.make.ToolchainInfoRegistry;
    toolsDir=fullfile(matlabroot,'toolbox','slrealtime','simulink','coder','tools');

    if strcmpi(computer('arch'),'win64')
        config(1)=coder.make.ToolchainInfoRegistry;
        config(end).Name='Simulink Real-Time Toolchain';
        config(end).FileName=fullfile(toolsDir,'slrealtime_tc_gmake_win64_v1.mat');
        config(end).TargetHWDeviceType={'*'};
        config(end).Platform={'win64'};

        config(end+1)=coder.make.ToolchainInfoRegistry;
        config(end).Name='Simulink Real-Time Remote Build Toolchain';
        config(end).FileName=fullfile(toolsDir,'slrealtime_remote_build_tc_cmake_win64_v1.mat');
        config(end).TargetHWDeviceType={'*'};
        config(end).Platform={'win64'};
    elseif strcmpi(computer('arch'),'glnxa64')
        config(1)=coder.make.ToolchainInfoRegistry;
        config(end).Name='Simulink Real-Time Toolchain';
        config(end).FileName=fullfile(toolsDir,'slrealtime_tc_gmake_glnxa64_v1.mat');
        config(end).TargetHWDeviceType={'*'};
        config(end).Platform={'glnxa64'};

        config(end+1)=coder.make.ToolchainInfoRegistry;
        config(end).Name='Simulink Real-Time Remote Build Toolchain';
        config(end).FileName=fullfile(toolsDir,'slrealtime_remote_build_tc_cmake_glnxa64_v1.mat');
        config(end).TargetHWDeviceType={'*'};
        config(end).Platform={'glnxa64'};
    end
end