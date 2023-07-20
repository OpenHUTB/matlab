

classdef(Abstract)StreamingBasedVDMA<hdlturnkey.interface.InterfaceBase


    properties


        hVDMAPort=[];

    end

    properties(Abstract=true)

PairedInterfaceID
    end

    methods

        function obj=StreamingBasedVDMA(interfaceID)


            obj=obj@hdlturnkey.interface.InterfaceBase(interfaceID);


            obj.setupInterfaceAssignment;

        end

        function isa=isStreamBasedVDMAInterface(obj)%#ok<MANU>
            isa=true;
        end

    end


    methods

        function setupInterfaceAssignment(obj)



            obj.hVDMAPort=hdlturnkey.data.VDMAPort;
        end

        function cleanInterfaceAssignment(obj,~)


            obj.hVDMAPort.cleanAssignment;
        end

    end


    methods

        function assignBitRange(obj,portName,bitRangeStr,hTableMap)

            obj.hVDMAPort.parseBitRangeStr(bitRangeStr,obj.InterfaceID);

            hTableMap.setBitRangeData(portName,bitRangeStr);
        end

        function validatePortForInterface(obj,hIOPort,hTableMap)


            hTurnkey=hTableMap.hTable.hTurnkey;

            if hTurnkey.isCoProcessorMode
                currentMode=hTurnkey.hD.get('ExecutionMode');
                freerunMode=hTurnkey.hExecMode.FreeRun;
                copModeMsg=message('HDLShared:hdldialog:HDLWAInputFPGAExecutionModeStr');
                copModeName=copModeMsg.getString;
                error(message('hdlcommon:workflow:StreamCopNotSupported',...
                currentMode,freerunMode,copModeName));
            end


            portWidth=hIOPort.WordLength;
            if portWidth~=32
                error(message('hdlcommon:workflow:BaseBitWidth32Bits',obj.InterfaceID,hIOPort.PortName));
            end


            if hIOPort.isVector
                error(message('hdlcommon:workflow:VectorPortUnsupported',obj.InterfaceID,hIOPort.PortName));
            end

        end

        function result=showInInterfaceChoice(~,hTurnkey)


            result=~hTurnkey.isCoProcessorMode;
        end

    end


    methods

        function bitrangeStr=getTableCellBitRangeStr(~,portName,hTableMap)

            bitrangeStr=hTableMap.getBitRangeData(portName);
        end

    end


    methods

        function allocateUserSpecBitRange(obj,portName,hTableMap)



            bitrangeStr=hTableMap.getBitRangeData(portName);


            subPortName=bitrangeStr;
            obj.hVDMAPort.assignSubPort(portName,subPortName);

        end

        function allocateDefaultBitRange(obj,portName,hTableMap)



            subPortName=obj.hVDMAPort.allocateSubPort(portName,obj.InterfaceID);


            bitRangeData=subPortName;
            hTableMap.setBitRangeData(portName,bitRangeData);
        end

    end


    methods

        function getRegisterCacheLogic(~,hN,data_in,transfer,cache_enb,cache_use,data_out)

            cacheType=data_in.Type;
            cache_out=hN.addSignal(cacheType,'cache_out');
            switch_out=hN.addSignal(cacheType,'switch_out');


            pirelab.getUnitDelayEnabledComp(hN,data_in,cache_out,cache_enb,'reg_cache');


            pirelab.getSwitchComp(hN,[cache_out,data_in],switch_out,cache_use,'switch_cache','==',1);


            pirelab.getUnitDelayEnabledComp(hN,switch_out,data_out,transfer,'reg_transfer');
        end


        function getStreamingFIFOComp(~,hN,InSignals,OutSignals,fifoSize,fifoName,statusOut)


            if nargin<7
                statusOut=true;
            end


            info.fifo_size=fifoSize;
            info.address_size=ceil(log2(fifoSize));
            info.input_rate=1;
            info.output_rate=1;
            info.num_on=false;
            info.name=fifoName;
            info.rst_on=false;

            if statusOut
                info.empty_on=true;
                info.full_on=true;
            else
                info.empty_on=false;
                info.full_on=false;
            end


            hFIFONet=pirelab.getFIFONetwork(hN,InSignals,OutSignals,info);


            pirelab.instantiateNetwork(hN,hFIFONet,InSignals,OutSignals,...
            sprintf('%s_inst',fifoName));

        end

    end

end


