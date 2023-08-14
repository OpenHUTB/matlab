classdef SimulationMode







    properties(Constant)



        SimulationModeSIL='Software-in-the-loop (SIL)';
        SimulationModePIL='Processor-in-the-loop (PIL)';
        SimulationModeNormal='Normal';
        SimulationModeAccel='Accelerator';
        CodeInterfaceTopModel='Top model';
    end

    methods(Access=public,Static)
        function ret=isSIL(modelBlock)
            Simulink.ModelReference.internal.SimulationMode.validateBlock(modelBlock);
            lSimulationMode=get_param(modelBlock,'SimulationMode');
            ret=strcmp(lSimulationMode,Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL);
        end

        function ret=isPIL(modelBlock)
            Simulink.ModelReference.internal.SimulationMode.validateBlock(modelBlock);
            lSimulationMode=get_param(modelBlock,'SimulationMode');
            ret=strcmp(lSimulationMode,Simulink.ModelReference.internal.SimulationMode.SimulationModePIL);
        end

        function ret=isNormal(modelBlock)
            Simulink.ModelReference.internal.SimulationMode.validateBlock(modelBlock);
            lSimulationMode=get_param(modelBlock,'SimulationMode');
            ret=strcmp(lSimulationMode,Simulink.ModelReference.internal.SimulationMode.SimulationModeNormal);
        end

        function ret=isAccel(modelBlock)
            Simulink.ModelReference.internal.SimulationMode.validateBlock(modelBlock);
            lSimulationMode=get_param(modelBlock,'SimulationMode');
            ret=strcmp(lSimulationMode,Simulink.ModelReference.internal.SimulationMode.SimulationModeAccel);
        end

        function ret=isXIL(modelBlock)
            ret=...
            Simulink.ModelReference.internal.SimulationMode.isSIL(modelBlock)||...
            Simulink.ModelReference.internal.SimulationMode.isPIL(modelBlock);

        end

        function ret=isTopModelCodeInterface(modelBlock)
            lCodeInterface=get_param(modelBlock,'CodeInterface');
            ret=strcmp(lCodeInterface,Simulink.ModelReference.internal.SimulationMode.CodeInterfaceTopModel);
        end
    end

    methods(Access=private,Static)
        function validateBlock(modelBlock)
            assert(strcmp(get_param(modelBlock,'Type'),'block'),'Input modelBlock is not a block');
            assert(strcmp(get_param(modelBlock,'BlockType'),'ModelReference'),'Input modelBlock is not a ModelReference block');
        end
    end
end