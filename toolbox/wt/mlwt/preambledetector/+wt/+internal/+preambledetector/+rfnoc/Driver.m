classdef Driver<wt.internal.rfnoc.Driver


















    properties(Access=protected)
CustomBlockName
RegisterMap
RFBlock
RXAntenna
RXChannel
    end

    properties(Access=protected,Constant)
        COEFF_SEND_TIMEOUT=1;
    end

    methods(Access=protected)
        function[graph,rx_stream_list,tx_stream_list]=getGraph(obj)
            dataTypeMap=containers.Map(...
            ["int16","double","single"],...
            ["sc16","fc64","fc32"]);
            otw_datatype="sc16";
            uhd_datatype_host_rx=dataTypeMap(string(obj.App.CaptureDataType));
            uhd_datatype_host_tx=dataTypeMap(string(obj.App.TransmitDataType));
            numReceiveAntennas=length(obj.App.ReceiveAntennas);
            numTransmitAntennas=length(obj.App.TransmitAntennas);
            if((numReceiveAntennas>1)||(numTransmitAntennas>1))
                error(message('wt:preambledetector:AntennaNumNotValid'))
            else
                for antIdx=1:numReceiveAntennas
                    [RadioBlock,RadioChannel]=getAntennaInfo(obj.Radio,obj.App.ReceiveAntennas(antIdx));
                    charRadioBlock=char(RadioBlock);
                    farrowBlock=obj.getFarrowBlockName(obj.App.ReceiveAntennas(antIdx));
                    ddcBlock=['0/DDC#',charRadioBlock(end)];
                    ddcChannel=RadioChannel;
                    graph_segment_r={RadioBlock,RadioChannel,farrowBlock,0,farrowBlock,0,...
                    ddcBlock,ddcChannel,ddcBlock,ddcChannel};
                    obj.RXAntenna=string(charRadioBlock);
                    obj.RXChannel=RadioChannel;
                end

                for antIdx=1:numTransmitAntennas
                    [RadioBlock,RadioChannel]=getAntennaInfo(obj.Radio,obj.App.TransmitAntennas(antIdx));
                    charRadioBlock=char(RadioBlock);
                    ducBlock=['0/DUC#',charRadioBlock(end)];
                    ducChannel=RadioChannel;
                    graph_segment_t={ducBlock,ducChannel,RadioBlock,RadioChannel};


                    addEdge(obj.driverImpl,{"0/Replay#0",(antIdx-1),ducBlock,ducChannel},false);
                end
                preambleBlockName=obj.getPDBlockName;
                graph=[{...
                "0/TX_STREAM#0",0,"0/Replay#0",0},...
                graph_segment_t,...
                graph_segment_r,{preambleBlockName,0,...
                preambleBlockName,0,"0/Replay#0",1,...
                "0/Replay#0",1,"0/RX_STREAM#0",0,...
                "0/TX_STREAM#1",0,preambleBlockName,1}];
            end
            rx_stream_list=["0/RX_STREAM#0",uhd_datatype_host_rx,otw_datatype];
            tx_stream_list=["0/TX_STREAM#0",uhd_datatype_host_tx,otw_datatype,"0/TX_STREAM#1","sc16","sc16"];
        end

        function flushFilter(obj)
            obj.writeRegister('nRecorderEnable',1);
            obj.writeRegister('dataInEnable',1);
            recordState=obj.readRegister('recorderState');
            recordNum=obj.readRegister('countNum');
            if(recordNum)
                if(recordState==1)

                    obj.writeRegister('forceTLast',0);
                    obj.writeRegister('forceTLast',1);
                    obj.writeRegister('forceTLast',0);
                end
            end
            obj.writeRegister('recorderReset',0);
            obj.writeRegister('recorderReset',1);
            obj.writeRegister('recorderReset',0);
            obj.writeRegister('clearFilter',1);
            obj.RFStreamerOn;
            obj.writeRegister('dataInEnable',0);
            obj.RFStreamerOff;
            obj.writeRegister('clearFilter',0);
            obj.writeRegister('nRecorderEnable',0);
        end
    end

    methods

        function obj=Driver(radioObj,appObj)
            obj=obj@wt.internal.rfnoc.Driver(radioObj,appObj);
        end

        function configure(obj,proplist)
            configure@wt.internal.rfnoc.Driver(obj,proplist);
            [obj.CustomBlockName,obj.RegisterMap]=obj.getCustomBlock;
        end


        function disconnect(obj)

            rfBlock=obj.driverImpl.getBlock(obj.RXAntenna);
            rfBlock.issueStreamCommand("stop",1000,obj.RXChannel);

            obj.stopReceiveFromStream("0/RX_STREAM#0");

            disconnect@wt.internal.rfnoc.Driver(obj);
        end

        function pb_block_name=getPDBlockName(obj)
            [~,pb_block_name]=obj.driverImpl.hasBlockID("0xD8E2543F");
        end

        function[custom_block_name,registermap]=getCustomBlock(obj)
            custom_block_name=obj.getPDBlockName;
            registermap=parseBlockInfo(obj,fullfile(matlabroot,'toolbox','wt',...
            'bitstreams','preambledetector','rfnoc','bitstreams',...
            'preambledetector_wthandoffinfo.mat'));
        end

        function registermap=parseBlockInfo(~,handoffFile)
            load(handoffFile,'PreambleDetector');
            info=PreambleDetector.rfnoc_info;
            registermap=containers.Map;
            if isfield(info,'registers')
                for i=1:numel(info.registers)
                    name=char(fields(info.registers{i}));
                    info.registers{i}.(name).setreg.address=8*str2double(info.registers{i}.(name).setreg.address);
                    info.registers{i}.(name).readback.address=8*str2double(info.registers{i}.(name).readback.address);
                    registermap(name)=info.registers{i}.(name);
                end
            end
        end

        function getRFStreamer(obj)
            obj.RFBlock=obj.driverImpl.getBlock(obj.RXAntenna);
            obj.RFBlock.issueStreamCommand("stop",1000,obj.RXChannel);

            obj.RFBlock.setProperties("spp=512",uint64(obj.RXChannel));
        end

        function RFStreamerOn(obj)
            obj.RFBlock.issueStreamCommand("continuous",0,obj.RXChannel);
        end

        function RFStreamerOff(obj)
            obj.RFBlock.issueStreamCommand("stop",0,obj.RXChannel);
        end

        function writeRegister(obj,regName,val)
            writeBlockRegister(obj,obj.CustomBlockName,obj.RegisterMap(regName).setreg.address,val);
        end
        function val=readRegister(obj,regName)
            val=readBlockRegister(obj,obj.CustomBlockName,obj.RegisterMap(regName).readback.address);
        end

        function writeCoefficients(obj,coeffs)
            [~]=transmitToStream(obj,coeffs,obj.COEFF_SEND_TIMEOUT,"0/TX_STREAM#1");
        end

        function[data,num_samples,overflow]=readPDOutputData(obj,len,timeout)
            if(isempty(obj.RFBlock))
                obj.getRFStreamer;
            end
            flushFilter(obj);
            customStreamCommand=obj.getCustomStreamCommandSetSPP(0,"continuous");
            try
                data=receiveBurstFromStreamViaReplayBlock(obj,len,"0/RX_STREAM#0",timeout,customStreamCommand);
                num_samples=length(data);
            catch ME

                if strcmp(ME.identifier,"wt:rfnoc:driver:FailedToBufferSamplesFromRadio")
                    num_samples=0;
                    data=zeros(len,1,string(obj.App.CaptureDataType));
                else
                    rethrow(ME);
                end
            end
            overflow=false;
            obj.writeRegister('nRecorderEnable',1);
        end

        function transmitRepeat(obj,data)
            transmitRepeatToStreamViaReplayBlock(obj,data,"0/TX_STREAM#0");
        end

        function transmit(obj,data)
            transmitToStream(obj,data,2,"0/TX_STREAM#0");
        end

        function stopTransmitRepeat(obj)
            stopTransmitRepeatViaReplayBlock(obj,"0/TX_STREAM#0");
        end

        function regs=readbackRegisters(obj)
            k=keys(obj.RegisterMap);
            for i=1:length(k)
                regs{i}.regName=k{i};%#ok<AGROW>
                regs{i}.value=readRegister(obj,k{i});%#ok<AGROW>
            end
        end

    end


end


