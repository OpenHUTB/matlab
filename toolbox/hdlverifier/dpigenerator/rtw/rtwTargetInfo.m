function rtwTargetInfo(tr)




    tr.registerTargetInfo(@loc_createToolchain);

end




function config=loc_createToolchain


    config(1)=coder.make.ToolchainInfoRegistry;
    config(1).Name='Mentor Graphics QuestaSim/Modelsim (64-bit Linux)';
    config(1).FileName=fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','rtw','QuestaSim_Linux64.mat');
    config(1).TargetHWDeviceType={'*'};
    config(1).Platform={'glnxa64','win64'};


    config(2)=coder.make.ToolchainInfoRegistry;
    config(2).Name='Cadence Xcelium (64-bit Linux)';
    config(2).FileName=fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','rtw','Xcelium_Linux64.mat');
    config(2).TargetHWDeviceType={'*'};
    config(2).Platform={'glnxa64','win64'};


    if ispc
        config(3)=coder.make.ToolchainInfoRegistry;
        config(3).Name='Mentor Graphics QuestaSim/Modelsim (32-bit Windows)';
        config(3).FileName=fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','rtw','QuestaSim_Win32.mat');
        config(3).TargetHWDeviceType={'*'};
        config(3).Platform={'win32','win64'};
    end


    if strcmp(computer,'PCWIN64')
        config(4)=coder.make.ToolchainInfoRegistry;
        config(4).Name='Mentor Graphics QuestaSim/Modelsim (64-bit Windows)';
        config(4).FileName=fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','rtw','QuestaSim_Win64.mat');
        config(4).TargetHWDeviceType={'*'};
        config(4).Platform={'win64'};
    end

end


