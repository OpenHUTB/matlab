

function setTargetCodeGenerationParams(hModel,targetOption,objectiveOption,blockLatencyOption,xilinxSimLib)



    if strcmpi(targetOption,'Altera Floating-point Megafunctions')
        setTransientCLI(hModel,'UseAlteraMegaFunctions','on');
        setTransientCLI(hModel,'Objective',objectiveOption);
        if strcmpi(blockLatencyOption,'Min output latency')
            setTransientCLI(hModel,'DelaySelectionStrategy','MIN_DELAY');
        elseif strcmpi(blockLatencyOption,'Max output latency')
            setTransientCLI(hModel,'DelaySelectionStrategy','MAX_DELAY');
        end
    else
        setTransientCLI(hModel,'UseAlteraMegaFunctions','off');
    end

    if strcmpi(targetOption,'Xilinx Floating-point Coregen Blocks')
        setTransientCLI(hModel,'UseXilinxCoregenBlocks','on');
        setTransientCLI(hModel,'Objective',objectiveOption);
        if strcmpi(blockLatencyOption,'Min output latency')
            setTransientCLI(hModel,'DelaySelectionStrategy','MIN_DELAY');
        elseif strcmpi(blockLatencyOption,'Max output latency')
            setTransientCLI(hModel,'DelaySelectionStrategy','MAX_DELAY');
        end
        hdlset_param(hModel,'XilinxSimulatorLibPath',xilinxSimLib);
    else
        setTransientCLI(hModel,'UseXilinxCoregenBlocks','off');
    end

end


