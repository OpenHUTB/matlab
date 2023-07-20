classdef block<handle








    properties(Access=public)

PacketsPerCapture
        StateTS={}
    end

    properties(SetAccess=private,GetAccess=public)

DeviceType
BlockName
NumberOfTapPoints
HasStatesVector
EnabledTapPoints
Overflow
ChannelNames
SampleRates
BitWidths
NumStateSignals
StateSignalNames
    end

    properties(Hidden=true)
SysClkRate
StreamWidth
MaxPacketSizeWords
MaxPacketSizeBytes
    end

    properties(Access=protected)
TapPointChannels
StatesChannel
PayloadSizes
        HeaderLength=128
        PacketSequencer=0xFEDCBA9876543210
SequencerLengthWords
HeaderLengthWords
    end

    methods
        function obj=block(blockConfig)
            if~isa(blockConfig,'wt.internal.utils.tappoints.config')
                error(message('wt:tappoints:BadConfig'));end
            if(str2double(blockConfig.StreamWidth)~=32&&str2double(blockConfig.StreamWidth)~=64)
                error(message('wt:tappoints:BadStreamWidth'));end

            obj.StreamWidth=str2double(blockConfig.StreamWidth);
            obj.DeviceType=blockConfig.DeviceType;
            obj.BlockName=blockConfig.BlockName;
            obj.NumberOfTapPoints=str2double(blockConfig.NumberOfTapPoints);
            obj.SysClkRate=str2double(blockConfig.SysClkRate);
            obj.HasStatesVector=blockConfig.HasStatesVector;
            obj.ChannelNames=blockConfig.TapPointNames;
            obj.BitWidths=blockConfig.BitWidths;
            obj.SampleRates=blockConfig.SampleRates;
            obj.PayloadSizes=blockConfig.PayloadSizes;

            if blockConfig.HasStatesVector
                obj.NumStateSignals=blockConfig.NumStateSignals;
                obj.StateSignalNames=blockConfig.StateSignalNames;
                for i=1:obj.NumStateSignals

                    obj.StateTS{i}=timeseries(obj.StateSignalNames{i});

                end
            end


            for i=1:obj.NumberOfTapPoints
                obj.TapPointChannels{i}=wt.internal.utils.tappoints.channel(obj.ChannelNames(i),...
                obj.SampleRates(i),obj.SysClkRate/obj.SampleRates(i));
            end

            obj.PacketsPerCapture=100;
            obj.EnabledTapPoints=([1,2,3]);
            obj.calcMaxPacketSize;
        end

        function plot(obj,varargin)

            if nargin>1
                TPsToPlot=varargin{1};
            else
                TPsToPlot=obj.EnabledTapPoints;
            end



            for i=1:length(TPsToPlot)
                tpIdx=TPsToPlot(i);

                if isempty(obj.TapPointChannels{tpIdx}.TimeSeries)
                    TPsToPlot(i)=0;

                elseif isempty(obj.TapPointChannels{tpIdx}.TimeSeries.Time)
                    TPsToPlot(i)=0;
                end
            end
            TPsToPlot=TPsToPlot(TPsToPlot~=0);

            if isempty(TPsToPlot)
                warning(message('wt:tappoints:NoDataReceived'));
                return
            end

            hold on;
            earliestTimeStamp=obj.getEarliestTimeStamp(TPsToPlot);

            for i=1:length(TPsToPlot)
                tpIdx=TPsToPlot(i);

                obj.TapPointChannels{tpIdx}.TimeSeries.Time=...
                obj.TapPointChannels{tpIdx}.TimeSeries.Time-earliestTimeStamp;

                p=plot(obj.TapPointChannels{tpIdx}.TimeSeries,...
                'DisplayName',[obj.TapPointChannels{tpIdx}.TimeSeries.Name{1},' - ',...
                num2str(obj.SampleRates(tpIdx)),'MSPS']);
                p.Marker='*';
                legend;
            end
        end

        function data=getTapPointData(obj,TapPointID)
            idx=obj.getStreamID(TapPointID);
            try
                data=obj.TapPointChannels{idx}.TimeSeries.Data;
            catch
                data=[];
            end
        end

        function timeSeries=getTapPointTimeSeries(obj,TapPointID)
            idx=obj.getStreamID(TapPointID);
            try
                timeSeries=obj.TapPointChannels{idx}.TimeSeries;
            catch
                timeSeries=[];
            end
        end

        function parseSimulationData(obj,TDataStream,TLastStream)

            while nnz(TLastStream)
                packetLength=find(TLastStream,1,'first');
                packetData=TDataStream(1:packetLength);
                obj.parse(packetData');

                TDataStream=TDataStream(packetLength+1:end);
                TLastStream=TLastStream(packetLength+1:end);
            end
        end

    end

    methods(Hidden=true)
        function tapPointID=parse(obj,rxPacket)


            if obj.StreamWidth==32
                rxPacketFi=typecast(rxPacket,'uint32');
                rxPacketSeq=wt.internal.rfnoc.FPTools.bitConcat(rxPacketFi(2),...
                rxPacketFi(1)...
                );
            elseif obj.StreamWidth==64
                rxPacketFi=typecast(rxPacket,'uint64');
                rxPacketSeq=rxPacketFi(1);
            end



            if~all(rxPacketSeq==obj.PacketSequencer)
                error(message('wt:tappoints:BadHeader'));
            end



            headerData=rxPacketFi(obj.SequencerLengthWords+1:...
            (obj.SequencerLengthWords+obj.HeaderLengthWords));


            blockID=uint8(wt.internal.rfnoc.FPTools.bitGet(headerData(1),8,5));%#ok
            tapPointID=uint8(wt.internal.rfnoc.FPTools.bitGet(headerData(1),16,9));
            overflow=logical(wt.internal.rfnoc.FPTools.bitGet(headerData(1),19,19));


            if overflow
                obj.Overflow=true;
            end

            if obj.StreamWidth==32
                payloadLength=double(headerData(2));
            else
                payloadLength=double(wt.internal.rfnoc.FPTools.bitGet(headerData(1),64,33));
            end

            if obj.HeaderLengthWords==1
                error(message('wt:tappoints:BadStreamWidth'));


            elseif obj.HeaderLengthWords==2
                timestamp=double(headerData(2));
            elseif obj.HeaderLengthWords==4
                timestamp=double(wt.internal.rfnoc.FPTools.bitConcat(typecast(headerData(4),'uint32'),...
                typecast(headerData(3),'uint32')...
                ));
            end


            lowerIdx=obj.SequencerLengthWords+obj.HeaderLengthWords+1;
            upperIdx=obj.SequencerLengthWords+obj.HeaderLengthWords+payloadLength;
            payloadData=rxPacketFi(lowerIdx:upperIdx);

            if tapPointID==0

                for i=1:obj.NumStateSignals
                    obj.StateTS{i}=append(obj.StateTS{i},...
                    timeseries(payloadData(i),timestamp));
                    obj.StateTS{i}.Name=obj.StateSignalNames{i};
                end

                obj.StatesChannel.OverflowFlag=logical(wt.internal.rfnoc.FPTools.bitGet(headerData(1),18,18));
                obj.StatesChannel.ContiguousFlag=logical(wt.internal.rfnoc.FPTools.bitGet(headerData(1),18,18));

            else

                obj.TapPointChannels{tapPointID}.OverflowFlag=logical(wt.internal.rfnoc.FPTools.bitGet(headerData(1),18,18));
                obj.TapPointChannels{tapPointID}.ContiguousFlag=logical(wt.internal.rfnoc.FPTools.bitGet(headerData(1),18,18));



                if obj.BitWidths(tapPointID)~=obj.StreamWidth
                    samplesPerWord=floor(obj.StreamWidth/obj.BitWidths(tapPointID));
                    payloadSamples=ones(1,payloadLength*samplesPerWord);
                    for i=1:payloadLength
                        for j=1:samplesPerWord
                            LSB=((j-1)*obj.BitWidths(tapPointID))+1;
                            MSB=j*obj.BitWidths(tapPointID);
                            outputIdx=((i-1)*samplesPerWord)+j;
                            payloadSamples(outputIdx)=wt.internal.rfnoc.FPTools.bitGet(payloadData(i),MSB,LSB);
                        end
                    end
                    rxPayload=payloadSamples;
                else
                    rxPayload=payloadData;
                end



                rxTimeSeries=timeseries(double(rxPayload'));
                rxTimeSeries=setuniformtime(rxTimeSeries,...
                'StartTime',timestamp,'Interval',obj.TapPointChannels{tapPointID}.ClksPerValid);

                obj.TapPointChannels{tapPointID}.TimeSeries=append(obj.TapPointChannels{tapPointID}.TimeSeries,rxTimeSeries);

                obj.TapPointChannels{tapPointID}.TimeSeries.Name=convertStringsToChars(obj.ChannelNames(tapPointID));
            end
        end
    end

    methods(Hidden=true)
        function enablesAsUint32=enableArray2Uint32(obj,TapPointsToEnable)


            obj.EnabledTapPoints=TapPointsToEnable;
            enablesAsUint32=uint32(0);
            if TapPointsToEnable
                for i=1:length(TapPointsToEnable)


                    enablesAsUint32=enablesAsUint32+pow2(TapPointsToEnable(i)-1);
                end
            end
        end

        function initialiseRx(obj)
            obj.Overflow=false;
            for i=1:obj.NumberOfTapPoints
                obj.TapPointChannels{i}.TimeSeries=timeseries();
                obj.TapPointChannels{i}.OverflowFlag=false;
            end
        end
    end

    methods(Access=protected)


        function idx=getStreamID(obj,TapPointID)
            if isnumeric(TapPointID)
                validID=(TapPointID>0)&&(TapPointID<=obj.NumberOfTapPoints);
                if validID
                    idx=TapPointID;
                end
            else
                [validID,idx]=ismember(TapPointID,obj.ChannelNames);
            end

            if~validID
                error(message('wt:tappoints:InvalidID',TapPointID));
            end
        end

        function earliestTimeStamp=getEarliestTimeStamp(obj,TapPointIds)
            earliestTimeStamp=0;
            for i=1:length(TapPointIds)
                tpIdx=TapPointIds(i);
                currentTimeStamp=obj.TapPointChannels{tpIdx}.TimeSeries.Time(1);
                if(earliestTimeStamp==0)||(currentTimeStamp<earliestTimeStamp)
                    earliestTimeStamp=currentTimeStamp;
                end
            end

        end

        function calcMaxPacketSize(obj)





            L=64;
            obj.SequencerLengthWords=L/obj.StreamWidth;
            obj.HeaderLengthWords=obj.HeaderLength/obj.StreamWidth;

            largestPayloadSizeWords=max(obj.PayloadSizes);
            obj.MaxPacketSizeWords=(obj.SequencerLengthWords+obj.HeaderLengthWords...
            +largestPayloadSizeWords);
            obj.MaxPacketSizeBytes=obj.MaxPacketSizeWords*(obj.StreamWidth/8);

        end

    end

end
