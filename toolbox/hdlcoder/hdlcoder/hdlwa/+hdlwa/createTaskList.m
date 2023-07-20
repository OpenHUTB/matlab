function taskList=createTaskList(hDI,workflow,keyTerms)





















    toolSet={...
    'Altera QUARTUS II',...
    'Xilinx ISE',...
    'Xilinx Vivado',...
    'Microchip Libero SoC',...
    'Intel Quartus Pro',...
    'No synthesis tool specified',...
    'No synthesis tool available on system path'};

    switch workflow





    case 'Generic ASIC/FPGA'
        tool=keyTerms{1};
        isCosim=keyTerms{2};

        taskList={};
        taskList{end+1}={0,'com.mathworks.HDL.WorkflowAdvisor'};
        taskList{end+1}={1,'com.mathworks.HDL.SetTarget'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetDevice'};
        taskList{end+1}={2,'com.mathworks.HDL.SetGenericTargetFrequency'};
        taskList{end+1}={1,'com.mathworks.HDL.ModelPreparation'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckModelSettings'};
        taskList{end+1}={1,'com.mathworks.HDL.HDLCodeAndTestbenchGeneration'};
        taskList{end+1}={2,'com.mathworks.HDL.SetHDLOptions'};
        taskList{end+1}={2,'com.mathworks.HDL.GenerateHDLCodeAndReport'};
        if(isCosim)
            taskList{end+1}={2,'com.mathworks.HDL.VerifyCosim'};
        end
        if(ismember(tool,toolSet(1:5)))
            taskList{end+1}={1,'com.mathworks.HDL.FPGAImplementation'};
            taskList{end+1}={2,'com.mathworks.HDL.CreateProject'};
            taskList{end+1}={2,'com.mathworks.HDL.RunSynthesisTasks'};
            if(ismember(tool,toolSet(1:2))||ismember(tool,toolSet(5)))
                taskList{end+1}={3,'com.mathworks.HDL.RunLogicSynthesis'};
                taskList{end+1}={3,'com.mathworks.HDL.RunMapping'};
                taskList{end+1}={3,'com.mathworks.HDL.RunPandR'};
            elseif(ismember(tool,toolSet(3)))
                taskList{end+1}={3,'com.mathworks.HDL.RunVivadoSynthesis'};
                taskList{end+1}={3,'com.mathworks.HDL.RunImplementation'};
            elseif(ismember(tool,toolSet(4)))
                taskList{end+1}={3,'com.mathworks.HDL.RunVivadoSynthesis'};
                taskList{end+1}={3,'com.mathworks.HDL.RunImplementation'};
            end

            if(ismember(tool,toolSet(1:3)))
                taskList{end+1}={2,'com.mathworks.HDL.AnnotateModel'};
            end
        end





    case 'FPGA Turnkey'

        tool=keyTerms{1};

        taskList={};
        taskList{end+1}={0,'com.mathworks.HDL.WorkflowAdvisor'};
        taskList{end+1}={1,'com.mathworks.HDL.SetTarget'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetDevice'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetInterface'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetFrequency'};
        taskList{end+1}={1,'com.mathworks.HDL.ModelPreparation'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckModelSettings'};
        taskList{end+1}={1,'com.mathworks.HDL.HDLCodeAndTestbenchGeneration'};
        taskList{end+1}={2,'com.mathworks.HDL.SetHDLOptions'};
        taskList{end+1}={2,'com.mathworks.HDL.GenerateRTLCode'};
        if(ismember(tool,toolSet(1:3)))
            taskList{end+1}={1,'com.mathworks.HDL.FPGAImplementation'};
            taskList{end+1}={2,'com.mathworks.HDL.CreateProject'};
            taskList{end+1}={2,'com.mathworks.HDL.RunSynthesisTasks'};
            if(ismember(tool,toolSet(1:2)))
                taskList{end+1}={3,'com.mathworks.HDL.RunLogicSynthesis'};
                taskList{end+1}={3,'com.mathworks.HDL.RunMapping'};
                taskList{end+1}={3,'com.mathworks.HDL.RunPandR'};
            elseif(ismember(tool,toolSet(3)))
                taskList{end+1}={3,'com.mathworks.HDL.RunVivadoSynthesis'};
                taskList{end+1}={3,'com.mathworks.HDL.RunImplementation'};
            end
            taskList{end+1}={1,'com.mathworks.HDL.DownloadToTarget'};
            taskList{end+1}={2,'com.mathworks.HDL.GenerateBitstream'};
            taskList{end+1}={2,'com.mathworks.HDL.ProgramDevice'};
        end





    case{'IP Core Generation','Deep Learning Processor'}
        showEmbeddedTasks=keyTerms{1};
        showTargetFrequency=keyTerms{2};
        showCustomSWModelGeneration=keyTerms{3};
        isBoardEmpty=keyTerms{4};

        taskList={};
        taskList{end+1}={0,'com.mathworks.HDL.WorkflowAdvisor'};
        taskList{end+1}={1,'com.mathworks.HDL.SetTarget'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetDevice'};






































        if~isBoardEmpty
            if(showEmbeddedTasks)
                taskList{end+1}={2,'com.mathworks.HDL.SetTargetReferenceDesign'};
            end
            taskList{end+1}={2,'com.mathworks.HDL.SetTargetInterfaceAndMode'};

            if(~showEmbeddedTasks)



                taskList{end+1}={2,'com.mathworks.HDL.SetGenericTargetFrequency'};
            elseif(showTargetFrequency)


                taskList{end+1}={2,'com.mathworks.HDL.SetTargetFrequency'};
            end
        end

        taskList{end+1}={1,'com.mathworks.HDL.ModelPreparation'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckModelSettings'};
        taskList{end+1}={1,'com.mathworks.HDL.HDLCodeAndTestbenchGeneration'};
        taskList{end+1}={2,'com.mathworks.HDL.SetHDLOptions'};
        taskList{end+1}={2,'com.mathworks.HDL.GenerateIPCore'};

        if(showEmbeddedTasks)
            taskList{end+1}={1,'com.mathworks.HDL.EmbeddedIntegration'};
            taskList{end+1}={2,'com.mathworks.HDL.EmbeddedProject'};
            if(showCustomSWModelGeneration)
                taskList{end+1}={2,'com.mathworks.HDL.EmbeddedCustomModelGen'};
            else
                taskList{end+1}={2,'com.mathworks.HDL.EmbeddedModelGen'};
            end
            taskList{end+1}={2,'com.mathworks.HDL.EmbeddedSystemBuild'};
            taskList{end+1}={2,'com.mathworks.HDL.EmbeddedDownload'};
        end





    case 'Simulink Real-Time FPGA I/O'
        tool=keyTerms{1};
        showEmbeddedTasks=keyTerms{2};
        isIPCoreGen=keyTerms{3};
        showTargetFrequency=keyTerms{4};

        taskList={};
        taskList{end+1}={0,'com.mathworks.HDL.WorkflowAdvisor'};
        taskList{end+1}={1,'com.mathworks.HDL.SetTarget'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetDevice'};

        if isIPCoreGen
            taskList{end+1}={2,'com.mathworks.HDL.SetTargetReferenceDesign'};
        end
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetInterfaceAndMode'};

        if(showTargetFrequency)
            taskList{end+1}={2,'com.mathworks.HDL.SetTargetFrequency'};
        end

        taskList{end+1}={1,'com.mathworks.HDL.ModelPreparation'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckModelSettings'};
        taskList{end+1}={1,'com.mathworks.HDL.HDLCodeAndTestbenchGeneration'};
        taskList{end+1}={2,'com.mathworks.HDL.SetHDLOptions'};

        if isIPCoreGen
            taskList{end+1}={2,'com.mathworks.HDL.GenerateIPCore'};
            if(showEmbeddedTasks)
                taskList{end+1}={1,'com.mathworks.HDL.EmbeddedIntegration'};
                taskList{end+1}={2,'com.mathworks.HDL.EmbeddedProject'};
                taskList{end+1}={2,'com.mathworks.HDL.EmbeddedSystemBuild'};
                taskList{end+1}={1,'com.mathworks.HDL.DownloadToTarget'};
                taskList{end+1}={2,'com.mathworks.HDL.GeneratexPCInterface'};
            end
        else
            taskList{end+1}={2,'com.mathworks.HDL.GenerateRTLCode'};
            if(ismember(tool,toolSet(1:3)))
                taskList{end+1}={1,'com.mathworks.HDL.FPGAImplementation'};
                taskList{end+1}={2,'com.mathworks.HDL.CreateProject'};
                taskList{end+1}={2,'com.mathworks.HDL.RunSynthesisTasks'};
                if(ismember(tool,toolSet(1:2)))
                    taskList{end+1}={3,'com.mathworks.HDL.RunLogicSynthesis'};
                    taskList{end+1}={3,'com.mathworks.HDL.RunMapping'};
                    taskList{end+1}={3,'com.mathworks.HDL.RunPandR'};
                elseif(ismember(tool,toolSet(3)))
                    taskList{end+1}={3,'com.mathworks.HDL.RunVivadoSynthesis'};
                    taskList{end+1}={3,'com.mathworks.HDL.RunImplementation'};
                end
                taskList{end+1}={1,'com.mathworks.HDL.DownloadToTarget'};
                taskList{end+1}={2,'com.mathworks.HDL.GenerateBitstream'};
                taskList{end+1}={2,'com.mathworks.HDL.GeneratexPCInterface'};

            end
        end

    case 'FPGA-in-the-Loop'
        isCosim=keyTerms{1};

        taskList={};
        taskList{end+1}={0,'com.mathworks.HDL.WorkflowAdvisor'};
        taskList{end+1}={1,'com.mathworks.HDL.SetTarget'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetDevice'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetFrequency'};
        taskList{end+1}={1,'com.mathworks.HDL.ModelPreparation'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckModelSettings'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckFIL'};
        taskList{end+1}={1,'com.mathworks.HDL.HDLCodeAndTestbenchGeneration'};
        taskList{end+1}={2,'com.mathworks.HDL.SetHDLOptions'};
        taskList{end+1}={2,'com.mathworks.HDL.GenerateHDLCodeAndReport'};
        if(isCosim)
            taskList{end+1}={2,'com.mathworks.HDL.VerifyCosim'};
        end
        taskList{end+1}={1,'com.mathworks.HDL.FILImplementation'};
        taskList{end+1}={2,'com.mathworks.HDL.FILOption'};
        taskList{end+1}={2,'com.mathworks.HDL.RunFIL'};

    case 'Customization for the USRP(R) Device'
        isCosim=keyTerms{1};

        taskList={};
        taskList{end+1}={0,'com.mathworks.HDL.WorkflowAdvisor'};
        taskList{end+1}={1,'com.mathworks.HDL.SetTarget'};
        taskList{end+1}={2,'com.mathworks.HDL.SetTargetDevice'};
        taskList{end+1}={1,'com.mathworks.HDL.ModelPreparation'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckModelSettings'};
        taskList{end+1}={2,'com.mathworks.HDL.CheckUSRP'};
        taskList{end+1}={1,'com.mathworks.HDL.HDLCodeAndTestbenchGeneration'};
        taskList{end+1}={2,'com.mathworks.HDL.SetHDLOptions'};
        taskList{end+1}={2,'com.mathworks.HDL.GenerateHDLCodeAndReport'};
        if(isCosim)
            taskList{end+1}={2,'com.mathworks.HDL.VerifyCosim'};
        end
        taskList{end+1}={1,'com.mathworks.HDL.RunUSRP'};

    otherwise

        if hDI.hWorkflowList.isInWorkflowList(workflow)

            hWorkflow=hDI.hWorkflowList.getWorkflow(workflow);
            taskList=hWorkflow.hdlwa_createTaskList(keyTerms);
        end

    end

end






