classdef Driver<handle





    properties(SetAccess=immutable)
driverImpl
Radio
App
    end
    properties(Access=protected)
TransmitStreams
ReceiveStreams
Graph
    end

    properties
        SPP=512;
    end
    methods(Abstract,Access=protected)
        [graph,rx_stream,tx_stream]=getGraph(obj)
    end
    methods
        function obj=Driver(radioObj,appObj)
            obj.Radio=radioObj;
            obj.App=appObj;
            func=str2func(getDriver(obj.Radio));
            obj.driverImpl=func();
            obj.ReceiveStreams=containers.Map();
            obj.TransmitStreams=containers.Map();
        end

        function[tf,missingBlocks]=radioHasBlocks(obj,blockList,idList)
            tf=true;
            missingBlocks=[];
            obj.driverImpl.makeDevice(getDeviceArgs(obj.Radio));
            for n=1:length(blockList)
                if~hasBlockName(obj.driverImpl,blockList(n))
                    missingBlocks=[missingBlocks,blockList(n)];%#ok<AGROW>
                end
            end

            for n=1:length(idList)
                if~hasBlockID(obj.driverImpl,idList(n))
                    missingBlocks=[missingBlocks,idList(n)];%#ok<AGROW>
                end
            end


            if~isempty(missingBlocks)
                tf=false;
            end
        end
        function configure(obj,proplist)


            if ismember('SampleRate',proplist)
                [masterClockRate,farrowFactor,~,possibleRate]=getClockInfo(obj.Radio,obj.App.SampleRate);
                obj.Radio.setMasterClockRate(masterClockRate);
            end

            obj.driverImpl.makeDevice(getDeviceArgs(obj.Radio));




            [obj.Graph,rx_stream,tx_stream]=obj.getGraph();
            obj.driverImpl.defineGraph(obj.Graph);


            for n=1:3:length(rx_stream)
                obj.ReceiveStreams(rx_stream(n))=obj.driverImpl.getReceiveStream(rx_stream(n),rx_stream(n+1),rx_stream(n+2));
            end

            for n=1:3:length(tx_stream)
                obj.TransmitStreams(tx_stream(n))=obj.driverImpl.getTransmitStream(tx_stream(n),tx_stream(n+1),tx_stream(n+2));
            end


            obj.driverImpl.buildGraph();


            validateAntennas(obj);


            if~isempty(obj.ReceiveStreams)&&isstring(obj.App.ReceiveAntennas)
                for n=1:length(obj.App.ReceiveAntennas)
                    if ismember('SampleRate',proplist)
                        obj.setFarrowRate(obj.App.ReceiveAntennas(n),farrowFactor,1);
                        obj.setDDCRate(obj.App.ReceiveAntennas(n),masterClockRate/farrowFactor,obj.App.SampleRate);
                    end
                    if ismember('ReceiveGain',proplist)
                        obj.setReceiveGain(obj.App.ReceiveAntennas(n),getExpandedValue(obj.App,obj.App.ReceiveGain,n));
                    end
                    if ismember('ReceiveCenterFrequency',proplist)
                        obj.setReceiveCenterFrequency(obj.App.ReceiveAntennas(n),getExpandedValue(obj.App,obj.App.ReceiveCenterFrequency,n));
                    end
                end
            end
            if~isempty(obj.TransmitStreams)&&isstring(obj.App.TransmitAntennas)
                for n=1:length(obj.App.TransmitAntennas)
                    if ismember('SampleRate',proplist)
                        obj.setDUCRate(obj.App.TransmitAntennas(n),possibleRate,obj.Radio.MasterClockRate);
                    end
                    if ismember('TransmitGain',proplist)
                        obj.setTransmitGain(obj.App.TransmitAntennas(n),getExpandedValue(obj.App,obj.App.TransmitGain,n));
                    end
                    if ismember('TransmitCenterFrequency',proplist)
                        obj.setTransmitCenterFrequency(obj.App.TransmitAntennas(n),getExpandedValue(obj.App,obj.App.TransmitCenterFrequency,n));
                    end
                end
            end

        end

        function disconnect(obj)
            if~isempty(obj.Graph)
                obj.driverImpl.destroyGraph();
            end
        end


        function actualfreq=getReceiveCenterFrequency(obj,antenna)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualfreq=block.getReceiveCenterFrequency(channel);
        end
        function actualgain=getReceiveGain(obj,antenna)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualgain=block.getReceiveGain(channel);
        end
        function actualgain=getTransmitGain(obj,antenna)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualgain=block.getTransmitGain(channel);
        end
        function actualfreq=getTransmitCenterFrequency(obj,antenna)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualfreq=block.getTransmitCenterFrequency(channel);
        end
        function decimationFactor=getDDCFactor(obj,antenna)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            pat=digitsPattern(1)+"/Radio#";
            device_num=extractAfter(radioblock,pat);
            block=getBlock(obj.driverImpl,strcat("0/DDC#",device_num));
            decimationFactor=block.getInputRate(channel)/block.getOutputRate(channel);
        end

        function actualfreq=setReceiveCenterFrequency(obj,antenna,freq)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualfreq=block.setReceiveCenterFrequency(freq,channel);
        end
        function actualgain=setReceiveGain(obj,antenna,freq)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualgain=block.setReceiveGain(freq,channel);
        end
        function actualgain=setTransmitGain(obj,antenna,freq)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualgain=block.setTransmitGain(freq,channel);
        end
        function actualfreq=setTransmitCenterFrequency(obj,antenna,freq)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            block=getBlock(obj.driverImpl,radioblock);
            actualfreq=block.setTransmitCenterFrequency(freq,channel);
        end
        function actualOutputRate=setDDCRate(obj,antenna,inputRate,outputRate)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            pat=digitsPattern(1)+"/Radio#";
            device_num=extractAfter(radioblock,pat);
            block=getBlock(obj.driverImpl,strcat("0/DDC#",device_num));
            block.setInputRate(inputRate,channel);
            actualOutputRate=block.setOutputRate(outputRate,channel);
        end
        function actualInputRate=setDUCRate(obj,antenna,inputRate,outputRate)
            [radioblock,channel]=getAntennaInfo(obj.Radio,antenna);
            pat=digitsPattern(1)+"/Radio#";
            device_num=extractAfter(radioblock,pat);
            block=getBlock(obj.driverImpl,strcat("0/DUC#",device_num));
            block.setOutputRate(outputRate,channel);
            actualInputRate=block.setInputRate(inputRate,channel);
        end

        function setFarrowRate(obj,antenna,farrowFactor,pktsize)
            farrowID=obj.getFarrowBlockName(antenna);



            farrowBlock=obj.driverImpl.getBlock(farrowID);
            farrowBlock.writeRegister(8*128,uint32(wt.internal.rfnoc.FPTools.FPConvert(farrowFactor,1,26,24)));
            farrowBlock.writeRegister(8*129,pktsize);
            farrowBlock.writeRegister(8*130,uint32(1));
            farrowBlock.writeRegister(8*130,uint32(0));


        end

    end
    methods(Access=protected)



        function validateAntennas(obj)


            if~isempty(obj.ReceiveStreams)&&isstring(obj.App.ReceiveAntennas)
                for n=1:length(obj.App.ReceiveAntennas)

                    [radioblock,channel]=getAntennaInfo(obj.Radio,obj.App.ReceiveAntennas(n));
                    block=getBlock(obj.driverImpl,radioblock);

                    availableAntennas=block.getReceiveAntennas(channel);
                    splitAntenna=strsplit(obj.App.ReceiveAntennas(n),":");
                    antennaId=splitAntenna(2);
                    if~any(strcmp(antennaId,availableAntennas))
                        error(message("wt:rfnoc:hardware:AntennaNotConnected",obj.App.ReceiveAntennas(n)));
                    end

                end
            end

            if~isempty(obj.TransmitStreams)&&isstring(obj.App.TransmitAntennas)
                for n=1:length(obj.App.TransmitAntennas)
                    [radioblock,channel]=getAntennaInfo(obj.Radio,obj.App.TransmitAntennas(n));
                    block=getBlock(obj.driverImpl,radioblock);

                    availableAntennas=block.getTransmitAntennas(channel);
                    splitAntenna=strsplit(obj.App.TransmitAntennas(n),":");
                    antennaId=splitAntenna(2);
                    if~any(strcmp(antennaId,availableAntennas))
                        error(message("wt:rfnoc:hardware:AntennaNotConnected",obj.App.TransmitAntennas(n)));
                    end
                end
            end
        end



        function[num_samples,underflow]=transmitToStream(obj,data,timeout,stream_name)
            tx=obj.TransmitStreams(stream_name);
            num_samples=tx.send(data,timeout);
            underflow=false;
        end
        function stopReceiveFromStream(obj,stream_name)
            rx=obj.ReceiveStreams(stream_name);
            rx.stop();
        end
        function[data,num_samples,overflow]=continuousReceiveFromStream(obj,len,timeout,stream_name)
            rx=obj.ReceiveStreams(stream_name);
            rx.configure("continuous",len);
            [data,num_samples,overflow]=rx.receive(len,timeout);

        end

        function customStreamCommand=getCustomStreamCommandSetSPP(obj,receiveLength,varargin)
            mode="burst";
            if nargin>2,mode=varargin{1};end

            for antIdx=1:length(obj.App.ReceiveAntennas)
                [RadioID,RadioChannel]=getAntennaInfo(obj.Radio,obj.App.ReceiveAntennas(antIdx));
                customStreamCommand(antIdx).block=obj.driverImpl.getBlock(RadioID);%#ok
                customStreamCommand(antIdx).channel=RadioChannel;%#ok

                customStreamCommand(antIdx).mode=mode;%#ok
                [mcr,fr,~,~]=getClockInfo(obj.Radio,obj.App.SampleRate);
                preDecLen=ceil(mcr/obj.App.SampleRate*fr*receiveLength);
                preDecLen=ceil(preDecLen/obj.SPP)*obj.SPP;
                customStreamCommand(antIdx).len=preDecLen;%#ok
                radioBlock=obj.driverImpl.getBlock(RadioID);
                radioBlock.setProperties("spp="+num2str(obj.SPP),uint64(RadioChannel))
            end
        end

        function[data,num_samples,overflow]=burstReceiveFromStream(obj,len,timeout,stream_name,varargin)
            rx=obj.ReceiveStreams(stream_name);
            rx.configure("burst",len);
            [data,num_samples,overflow]=rx.receive(len,timeout,varargin{:});
        end

        function name=getFarrowBlockName(obj,antenna)
            [RadioBlock,RadioChannel]=getAntennaInfo(obj.Radio,antenna);
            name=obj.getFarrowBlockNameFromBlockChan(RadioBlock,RadioChannel);
        end

        function name=getFarrowBlockNameFromBlockChan(obj,radioBlock,radioChannel)
            charRadioBlock=char(radioBlock);
            rn=str2double(charRadioBlock(end));
            NUM_RADIO_BLOCKS=2;
            cpr=length(obj.Radio.AvailableReceiveAntennas)/NUM_RADIO_BLOCKS;
            rc=radioChannel;
            number=char(num2str(cpr*rn+rc));
            name=['0/Block#',number];
        end

        function data=receiveBurstFromStreamViaReplayBlockWM(obj,receiveLength,stream_name,timeout,varargin)
            data=receiveBurstFromStreamViaReplayBlock(obj,receiveLength,stream_name,timeout,varargin{:});
        end

        function data=receiveBurstFromStreamViaReplayBlock(obj,receiveLength,stream_name,timeout,customBlockConfig)
            streamer=obj.ReceiveStreams(stream_name);

            for n=1:numberOfPorts(streamer)
                [replay_block_name,~,~]=streamer.getInConnection(n);
                if contains(replay_block_name,"Replay")
                    break;
                end
            end
            wt_replay_block=getBlock(obj.driverImpl,replay_block_name);
            data=wt_replay_block.receive(streamer,receiveLength,timeout,customBlockConfig);
        end
        function transmitRepeatToStreamViaReplayBlock(obj,data,stream_name)
            transmitToStreamViaReplayBlock(obj,"continuous",data,stream_name)
        end
        function stopTransmitRepeatViaReplayBlock(obj,stream_name)
            streamer=obj.TransmitStreams(stream_name);
            for n=1:numberOfPorts(streamer)
                [~,replay_block_name,~]=streamer.getOutConnection(n);
                if contains(replay_block_name,"Replay")
                    break;
                end
            end
            wt_replay_block=getBlock(obj.driverImpl,replay_block_name);
            wt_replay_block.stopRepeatedTransmission;
        end
        function transmitBurstToStreamViaReplayBlock(obj,data,stream_name)
            transmitToStreamViaReplayBlock(obj,"burst",data,stream_name)
        end
        function transmitToStreamViaReplayBlock(obj,mode,data,stream_name)

            streamer=obj.TransmitStreams(stream_name);
            for n=1:numberOfPorts(streamer)
                [~,replay_block_name,~]=streamer.getOutConnection(n);
                if contains(replay_block_name,"Replay")
                    break;
                end
            end

            wt_replay_block=getBlock(obj.driverImpl,replay_block_name);

            wt_replay_block.transmit(streamer,data,mode)
        end


        function writeBlockRegister(obj,blockName,reg,regVal,varargin)
            obj.driverImpl.writeRegister(blockName,reg,regVal,varargin{:});
        end

        function regVal=readBlockRegister(obj,blockName,reg,varargin)
            regVal=obj.driverImpl.readRegister(blockName,reg,varargin{:});
        end
    end

    methods

        function[waveform,farrowFactor]=prepareTxWaveform(obj,inputWaveform,SampleRate,transmitAntennas,mode)

            [~,numWaveforms]=size(inputWaveform);
            if numWaveforms~=length(transmitAntennas)
                error(message('wt:baseband_rf:TransmitColumnPerAntenna'))
            end


            [~,farrowFactor,~,possibleRate]=getClockInfo(obj.Radio,SampleRate);

            if farrowFactor~=1

                oClass=class(inputWaveform);
                waveform=double(inputWaveform);
                frc=dsp.FarrowRateConverter('InputSampleRate',SampleRate,...
                'OutputSampleRate',possibleRate);
                waveform=frc(waveform);
                waveform=cast(waveform,oClass);







                [waveformLength,numWaveforms]=size(waveform);
                if rem(waveformLength,2)
                    if(mode==wt.internal.TransmitModes.continuous)
                        waveform=repmat(waveform,[2,1]);
                    else
                        waveform=[waveform;zeros(1,numWaveforms)];
                    end
                end
            else
                waveform=inputWaveform;
            end

        end
    end
end


