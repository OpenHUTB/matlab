function rtwTargetInfo(tr)




    tr.registerTargetInfo(@loc_createToolchain);

end

function config=loc_createToolchain
    config=coder.make.ToolchainInfoRegistry;
    archName=computer('arch');

    config(end+1).Name='AUTOSAR Adaptive | CMake';
    config(end).TargetHWDeviceType={'*'};
    config(end).FileName=fullfile(autosarroot,'adaptive_deployment','toolchain',['generate_autosar_adaptive_tc_cmake_',archName,'_v1.0.mat']);
    config(end).Platform={archName};

    if~strcmpi(computer('arch'),'maci64')
        config(end+1).Name='AUTOSAR Adaptive Linux Executable';
        config(end).TargetHWDeviceType={'*'};
        config(end).FileName=fullfile(autosarroot,'adaptive_deployment','toolchain',['generate_mw_autosar_adaptive_tc_cmake_',archName,'_v1.0.mat']);
        config(end).Platform={archName};
    end
end


