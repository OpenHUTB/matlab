


classdef RealtimeConfig<hwcli.base.IPCoreBase&hwcli.base.TurnkeyBase






    properties

RunTaskGenerateSimulinkRealTimeInterface


    end





    methods
        function obj=RealtimeConfig(tool)
            obj=obj@hwcli.base.TurnkeyBase('Simulink Real-Time FPGA I/O',tool);
            obj=obj@hwcli.base.IPCoreBase('Simulink Real-Time FPGA I/O',tool);


            obj.RunTaskGenerateSimulinkRealTimeInterface=true;
            obj.RunExternalBuild=false;
            obj.EnableDesignCheckpoint=false;


            if(strcmp(tool,'Xilinx Vivado'))

                obj.EnableIPCaching=true;

                obj.Tasks={...
                'RunTaskGenerateRTLCodeAndIPCore',...
                'RunTaskCreateProject',...
                'RunTaskBuildFPGABitstream',...
                'RunTaskGenerateSimulinkRealTimeInterface'};
            else
                obj.Tasks={...
                'RunTaskGenerateRTLCode',...
                'RunTaskCreateProject',...
                'RunTaskPerformLogicSynthesis',...
                'RunTaskPerformMapping',...
                'RunTaskPerformPlaceAndRoute',...
'RunTaskGenerateProgrammingFile'...
                ,'RunTaskGenerateSimulinkRealTimeInterface'};

            end


        end
    end





    methods
        function set.RunTaskGenerateSimulinkRealTimeInterface(obj,val)
            obj.errorCheckTask('RunTaskGenerateSimulinkRealTimeInterface',val);
            obj.RunTaskGenerateSimulinkRealTimeInterface=val;
        end

    end
end


