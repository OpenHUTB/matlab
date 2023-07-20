function[obj]=WorkflowConfig(varargin)






    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    p=inputParser;
    p.addParameter('TargetWorkflow','Generic ASIC/FPGA');
    p.addParameter('SynthesisTool','Xilinx Vivado');
    p.parse(varargin{:});
    inputArgs=p.Results;

    hWorkflowList=hdlworkflow.getWorkflowList;
    isDynamicWorkflowLoaded=hWorkflowList.isInWorkflowList(inputArgs.TargetWorkflow);




    if(~ischar(inputArgs.TargetWorkflow))
        error(message('hdlcoder:workflow:ParamValueNotString','TargetWorkflow'));
    end

    if(~ischar(inputArgs.SynthesisTool))
        error(message('hdlcoder:workflow:ParamValueNotString','SynthesisTool'));
    end

    isVivado=strcmp(inputArgs.SynthesisTool,'Xilinx Vivado');
    isISE=strcmp(inputArgs.SynthesisTool,'Xilinx ISE');
    isQuartus=strcmp(inputArgs.SynthesisTool,'Altera QUARTUS II');
    if strcmp(inputArgs.SynthesisTool,'Microsemi Libero SoC')
        isLiberoSoC=true;
        inputArgs.SynthesisTool='Microchip Libero SoC';
    elseif strcmp(inputArgs.SynthesisTool,'Microchip Libero SoC')
        isLiberoSoC=true;
    else
        isLiberoSoC=false;
    end
    isQuartusPro=strcmp(inputArgs.SynthesisTool,'Intel Quartus Pro');


    if(~(isVivado||isISE||isQuartus||isLiberoSoC||isQuartusPro||isDynamicWorkflowLoaded))
        error(message('hdlcoder:workflow:InvalidSynthesisTool',inputArgs.SynthesisTool));
    end

    if(strcmp(inputArgs.TargetWorkflow,'FPGA Turnkey')&&~(isISE||isQuartus))
        error(message('hdlcoder:workflow:InvalidSynthesisToolTurnkey',inputArgs.SynthesisTool));
    end


    if isDynamicWorkflowLoaded
        hWorkflow=hWorkflowList.getWorkflow(inputArgs.TargetWorkflow);
        obj=hWorkflow.hdlcli_WorkflowConfig(inputArgs.TargetWorkflow,inputArgs.SynthesisTool);
        return;
    end

    switch[inputArgs.TargetWorkflow]
    case 'IP Core Generation'
        obj=hwcli.config.IPCoreConfig(inputArgs.SynthesisTool);
    case 'Generic ASIC/FPGA'
        obj=hwcli.config.GenericConfig(inputArgs.SynthesisTool);
    case 'FPGA Turnkey'
        obj=hwcli.config.TurnkeyConfig(inputArgs.SynthesisTool);
    case 'Simulink Real-Time FPGA I/O'
        obj=hwcli.config.RealtimeConfig(inputArgs.SynthesisTool);
    case 'FPGA-in-the-Loop'
        obj=hwcli.config.FILConfig(inputArgs.SynthesisTool);
    case 'Deep Learning Processor'
        obj=hwcli.config.DeepLearningConfig(inputArgs.SynthesisTool);
    otherwise
        error(message('hdlcoder:workflow:WorkflowNotValid',inputArgs.TargetWorkflow));
    end

end


