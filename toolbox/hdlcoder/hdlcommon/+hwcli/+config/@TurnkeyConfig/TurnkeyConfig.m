


classdef TurnkeyConfig<hwcli.base.TurnkeyBase&hwcli.base.DeployBase






    properties



    end





    methods
        function obj=TurnkeyConfig(tool)
            obj=obj@hwcli.base.TurnkeyBase('FPGA Turnkey',tool);
            obj=obj@hwcli.base.DeployBase();




            if(strcmp(tool,'Xilinx Vivado'))
                obj.Tasks={...
                'RunTaskGenerateRTLCode',...
                'RunTaskCreateProject',...
                'RunTaskRunSynthesis',...
                'RunTaskRunImplementation',...
                'RunTaskGenerateProgrammingFile',...
                'RunTaskProgramTargetDevice'};
            else
                obj.Tasks={...
                'RunTaskGenerateRTLCode',...
                'RunTaskCreateProject',...
                'RunTaskPerformLogicSynthesis',...
                'RunTaskPerformMapping',...
                'RunTaskPerformPlaceAndRoute',...
'RunTaskGenerateProgrammingFile'...
                ,'RunTaskProgramTargetDevice'};

            end


        end
    end





    methods


    end
end


