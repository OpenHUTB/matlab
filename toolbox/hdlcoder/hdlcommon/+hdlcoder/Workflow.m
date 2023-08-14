


classdef Workflow




    enumeration
IPCoreGeneration
SimulinkRealTimeFPGAIO
DeepLearningProcessor
    end

    methods(Static)

        function workflowName=getWorkflowName(workflowEnum)

            switch workflowEnum
            case hdlcoder.Workflow.IPCoreGeneration
                workflowName='IP Core Generation';
            case hdlcoder.Workflow.SimulinkRealTimeFPGAIO
                workflowName='Simulink Real-Time FPGA I/O';
            case hdlcoder.Workflow.DeepLearningProcessor
                workflowName='Deep Learning Processor';
            end
        end

        function workflowEnum=getWorkflowEnum(workflowName)

            switch workflowName
            case 'IP Core Generation'
                workflowEnum=hdlcoder.Workflow.IPCoreGeneration;
            case 'Simulink Real-Time FPGA I/O'
                workflowEnum=hdlcoder.Workflow.IPCoreGeneration;
            case 'Deep Learning Processor'
                workflowEnum=hdlcoder.Workflow.DeepLearningProcessor;
            end
        end

    end

end
