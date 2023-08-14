


classdef ExecutionMode<handle


    properties

    end

    properties(Access=private)


        hExecModeOption=[];


        hTurnkey=[];

    end

    properties(Constant,Hidden=true)

        FreeRun='Free running';
        BlockingCop='Coprocessing - blocking';
        DelayedCop='Coprocessing - nonblocking with delay';
    end

    methods

        function obj=ExecutionMode(hTurnkey)

            obj.hTurnkey=hTurnkey;
        end

        function initExecutionMode(obj)

            if~showExecutionMode(obj)
                return;
            end

            if obj.hTurnkey.hD.isSLRTWorkflow

                AllExecMode={obj.FreeRun};
                obj.hExecModeOption=downstream.Option('Turnkey',...
                'ExecutionMode',obj.FreeRun,AllExecMode);
            elseif obj.hTurnkey.hD.isIPWorkflow
                AllExecMode={obj.FreeRun,obj.BlockingCop};
                obj.hExecModeOption=downstream.Option('Turnkey',...
                'ExecutionMode',obj.FreeRun,AllExecMode);
            end
        end

        function updateExecutionMode(obj)


            if~obj.hTurnkey.hD.isIPCoreGen
                return;
            end



            hRD=obj.hTurnkey.hD.hIP.getReferenceDesignPlugin;
            if isempty(hRD)
                hasAXI=true;
            else
                hasAXI=hRD.isAXI4SlaveInterfaceInUse;
            end

            hStream=obj.hTurnkey.hStream;
            if isempty(hStream)
                hasStream=false;
                hasMaster=false;
            else
                hasStream=hStream.hasStreamingInterface;
                hasMaster=hStream.hasAXI4MasterInterface;
            end

            if hasStream||hasMaster||~hasAXI
                AllExecMode={obj.FreeRun};
                obj.hExecModeOption=downstream.Option('Turnkey',...
                'ExecutionMode',obj.FreeRun,AllExecMode);

            else
                obj.initExecutionMode;
            end
        end

        function setExecutionMode(obj,optionValue)

            if~isempty(obj.hTurnkey)&&showExecutionMode(obj)
                hOption=getExecutionModeOption(obj);


                hOption.Value=optionValue;



                obj.hTurnkey.refreshTableInterface;

                try


                    obj.hTurnkey.hTable.updateInterfaceTable;

                catch ME

                    warnMsg=message('hdlcommon:workflow:CoProcessorSwitch',optionValue,ME.message);
                    cmdDisplay=obj.hTurnkey.hD.cmdDisplay;
                    downstream.tool.generateWarning(warnMsg,cmdDisplay);
                end
            end
        end

        function isOn=showExecutionMode(obj)

            isOn=obj.hTurnkey.hD.isxPCTargetBoard||...
            obj.hTurnkey.hD.isIPCoreGen;
        end

        function hOption=getExecutionModeOption(obj)
            hOption=obj.hExecModeOption;
        end

        function isMode=isCoProcessorMode(obj)
            executionMode=obj.hTurnkey.hD.get('ExecutionMode');
            if obj.hTurnkey.hD.isXPCWorkflow
                isMode=strcmp(executionMode,obj.BlockingCop)...
                ||strcmp(executionMode,obj.DelayedCop);
            else
                isMode=strcmp(executionMode,obj.BlockingCop);
            end
        end

        function imageName=getExecModeImage(obj,execMode)

            if strcmp(execMode,obj.FreeRun)
                imageNameStr='free_running';
            elseif strcmp(execMode,obj.BlockingCop)
                imageNameStr='coprocessing_blocking';
            elseif strcmp(execMode,obj.DelayedCop)
                imageNameStr='coprocessing_delayed';
            else
                error(message('hdlcommon:workflow:InvalidModeForImage',execMode));
            end
            imageName=sprintf('%s.jpg',imageNameStr);
        end


        function validateCell=validateExecutionMode(obj,validateCell)


            if obj.hTurnkey.hD.isIPCoreGen
                if obj.hTurnkey.hStream.isAXI4VDMAMode||...
                    obj.isCoProcessorMode






                    allportRate=0;
                    hIOPortList=obj.hTurnkey.hTable.hIOPortList;
                    for ii=1:length(hIOPortList.InputPortNameList)
                        portName=hIOPortList.InputPortNameList{ii};
                        hIOPort=hIOPortList.getIOPort(portName);
                        portRate=hIOPort.PortRate;
                        allportRate=validatePortRate(obj,portName,portRate,allportRate);
                    end
                    for ii=1:length(hIOPortList.OutputPortNameList)
                        portName=hIOPortList.OutputPortNameList{ii};
                        hIOPort=hIOPortList.getIOPort(portName);
                        portRate=hIOPort.PortRate;
                        allportRate=validatePortRate(obj,portName,portRate,allportRate);
                    end
                end

            end
        end

        function allportRate=validatePortRate(obj,portName,portRate,allportRate)
            if allportRate==0
                allportRate=portRate;
            else
                if allportRate~=portRate
                    if obj.hTurnkey.hStream.isAXI4VDMAMode
                        error(message('hdlcommon:workflow:StreamSingleRateInterface',portName));
                    else
                        error(message('hdlcommon:workflow:MismatchPortRate',portName));
                    end
                end
            end
        end

    end


end



