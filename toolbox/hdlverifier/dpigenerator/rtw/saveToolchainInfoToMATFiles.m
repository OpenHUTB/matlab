function saveToolchainInfoToMATFiles()

    tc_tmp=Simulator_Toolchains;
    ToolchainName={'QuestaSim_Win64','QuestaSim_Win32','QuestaSim_Linux64','Xcelium_Linux64'};
    for idx=1:numel(tc_tmp)
        tc=tc_tmp(idx);
        save(ToolchainName{idx},'tc');
    end
