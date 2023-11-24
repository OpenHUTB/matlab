classdef replay_block<wt.internal.uhd.clibgen.block

    properties(Access=private)
        word_size;
        mem_size;
        base_addr=0;
repeatedTransmissionChannels
        repeatedTransmissionBaseAddress=0;
    end
    properties(Constant)
        pageSize=4096;
    end

    methods(Access=protected)

        function control=getCustomBlockController(obj)
            control=obj.graph.get_block_uhd__rfnoc__replay_block_control_(getID(obj));
            obj.word_size=control.get_word_size();
            obj.mem_size=control.get_mem_size();
        end

    end
    methods

        function flushReplayMemory(obj,channel)

            fullness=obj.ctrl.get_record_fullness(channel);
            retriesLeft=500;


            while(fullness)&&retriesLeft
                obj.ctrl.record_restart(channel);
                pause(0.01);
                fullness=obj.ctrl.get_record_fullness(channel);
                retriesLeft=retriesLeft-1;
            end

            if~retriesLeft
                error(message("wt:rfnoc:driver:FailedToFlushBuffer"));
            end
        end

        function[maxReplayPacketLength,isBurstAllowed]=getMaxReplayPacketLength(obj,streamer)



            packetCapacity=getMaxSamplesPerPacket(streamer);
            sampleBytes=bytesPerDeviceSample(streamer);
            numChannels=numberOfPorts(streamer);
            channelSampleBytes=sampleBytes*numChannels;

            maxChannelAlignedPacketLength=floor(double(packetCapacity)/numChannels);

            maxReplayPacketLength=floor(maxChannelAlignedPacketLength/channelSampleBytes)*channelSampleBytes;

            isBurstAllowed=~mod(packetCapacity*sampleBytes,obj.word_size);
        end
        function load(obj,streamer,data,timeout,channelList)

            currentSampleCount=0;

            totalLength=length(data);

            currentPacketsPerBurstIndex=1;
            rateIncreaseThreshold=10;
            rateReductionThreshold=20;
            successfulBurstCount=0;

            sampleBytes=bytesPerDeviceSample(streamer);
            totalBytes=totalLength*length(channelList)*sampleBytes;
            if(mod(totalBytes,obj.word_size))
                warning(message("wt:rfnoc:host:ReplayDataUnaligned"));
            end
            [maxPacketLength,isBurstAllowed]=obj.getMaxReplayPacketLength(streamer);
            if isBurstAllowed
                packetsPerBurstList=[250,100,50,25,10,5,2,1];
            else
                packetsPerBurstList=1;
            end

            currentPacketsPerBurst=packetsPerBurstList(currentPacketsPerBurstIndex);


            while currentSampleCount<totalLength
                transmitAttemptCount=0;

                chunkStart=currentSampleCount+1;

                chunkEnd=currentSampleCount+min(maxPacketLength*currentPacketsPerBurst,totalLength-currentSampleCount);
                chunkLength=chunkEnd-chunkStart+1;
                chunk=data(chunkStart:chunkEnd,:);

                while currentSampleCount~=chunkEnd
                    num_tx_samps=streamer.send(chunk,timeout);
                    currentSampleCount=currentSampleCount+num_tx_samps;

                    if num_tx_samps==chunkLength
                        successfulBurstCount=successfulBurstCount+1;
                    else
                        chunk=data(currentSampleCount+1:chunkEnd);
                        transmitAttemptCount=transmitAttemptCount+1;
                        successfulBurstCount=0;
                        if transmitAttemptCount>rateReductionThreshold
                            break;
                        end
                    end
                end


                if successfulBurstCount>=rateIncreaseThreshold

                    currentPacketsPerBurstIndex=mod(currentPacketsPerBurstIndex-1,length(packetsPerBurstList))+1;
                elseif transmitAttemptCount>rateReductionThreshold

                    if currentPacketsPerBurstIndex==1
                        error(message("wt:rfnoc:host:ReplayLoadFailed"));
                    else
                        currentPacketsPerBurstIndex=currentPacketsPerBurstIndex+1;
                    end
                end
            end
        end

        function timed_replay_start(obj,streamer,mode,len,channelList,time)



            ts=getTimeSpec(streamer,time);

            for n=1:length(channelList)
                obj.issueStreamCommand(mode,len,channelList(n),ts)
            end
            pause(time);
        end
        function replay(obj,mode,len,channel)



            obj.issueStreamCommand(mode,len,channel);
        end

        function stopRepeatedTransmission(obj)
            for n=1:length(obj.repeatedTransmissionChannels)
                stop(obj,obj.repeatedTransmissionChannels(n));
            end
            obj.base_addr=obj.repeatedTransmissionBaseAddress;
        end
        function stop(obj,channel)



            obj.issueStreamCommand("stop",0,channel);
        end

        function record(obj,base_addr,size,channel)
            obj.ctrl.record(base_addr,size,channel);
        end

        function configPlay(obj,base_addr,size,channel)
            obj.ctrl.config_play(base_addr,size,channel);
        end

        function val=getRecordFullness(obj,varargin)
            narginchk(1,2);
            if nargin==2
                val=obj.ctrl.get_record_fullness(varargin{1});

            else
                val=obj.ctrl.get_record_fullness();

            end
        end

        function play(obj,base_addr,size,channel,varargin)
            narginchk(4,6);
            if nargin>4
                obj.ctrl.play(base_addr,size,channel,varargin{:});
            else
                obj.ctrl.play(base_addr,size,channel);
            end
        end

        function val=getWordSize(obj)
            val=obj.ctrl.get_word_size();
        end

        function onfnexitarray=parseStreamCmds(~,streamer,upstreamBlockConfig,time)
            onfnexitarray={};
            ts=getTimeSpec(streamer,time);
            for n=1:length(upstreamBlockConfig)
                block=upstreamBlockConfig(n).block;


                if length(upstreamBlockConfig)>1
                    block.issueStreamCommand(upstreamBlockConfig(n).mode,upstreamBlockConfig(n).len,upstreamBlockConfig(n).channel,ts);
                else
                    block.issueStreamCommand(upstreamBlockConfig(n).mode,upstreamBlockConfig(n).len,upstreamBlockConfig(n).channel);
                    time=0;
                end
                fh=[];
                if strcmp(upstreamBlockConfig(n).mode,"continuous")
                    fh=@()(block.issueStreamCommand("stop",0,upstreamBlockConfig(n).channel));
                end
                onfnexitarray{end+1}=fh;%#ok
            end
            pause(time);
        end

        function data=receive(obj,streamer,len,timeout,upstreamBlockConfig)



            timeOffset=0.2;
            channelList=[];
            baseList=[];
            otw_bytes=bytesPerDeviceSample(streamer);
            total_bytes_per_channel=otw_bytes*len;
            checkAvailableMemory(obj,numberOfPorts(streamer),len,otw_bytes);
            savedBaseAddress=obj.base_addr;
            for n=1:numberOfPorts(streamer)
                [~,channel,~]=streamer.getInConnection(n);
                channelList(end+1)=channel;%#ok<AGROW>

                base=allocate(obj,total_bytes_per_channel);
                baseList(end+1)=base;%#ok<AGROW>
                obj.record(base,total_bytes_per_channel,channel);
                obj.flushReplayMemory(channel);
            end



            onexit_fn=obj.parseStreamCmds(streamer,upstreamBlockConfig,timeOffset);

            successfulLoad=verifyFillLevel(obj,total_bytes_per_channel,channelList,timeout);

            cellfun(@(c)c(),onexit_fn,'UniformOutput',false);

            if successfulLoad

                [data,receiveFailed]=obj.receiveFromReplay(streamer,len,baseList,channelList);
            end




            for n=1:length(channelList)
                obj.flushReplayMemory(channelList(n));
            end


            obj.base_addr=savedBaseAddress;

            if~successfulLoad
                error(message("wt:rfnoc:driver:FailedToBufferSamplesFromRadio"));
            end

            if receiveFailed
                error(message("wt:rfnoc:driver:FailedToGetSamplesFromBuffer"));
            end
        end
        function[data,receiveFailed,info]=receiveFromReplay(obj,streamer,receiveLength,baseAddresses,channelNumbers)
            data=zeros(receiveLength,length(channelNumbers),streamer.getMATLABDataType);
            receiveFailed=false;

            currentOffset=0;
            maxPacketSize=double(obj.getMaxReplayPacketLength(streamer));
            timeout=1;
            bytesPerSample=bytesPerDeviceSample(streamer);
            packetsPerBurstList=[250,100,50,25,10,5,2,1];
            currentPacketsPerBurstIndex=1;
            currentPacketsPerBurst=packetsPerBurstList(currentPacketsPerBurstIndex);
            requestedBurstSize=calculateBurstParameters(obj,receiveLength,maxPacketSize,currentPacketsPerBurst);

            rateIncreaseThreshold=10;
            rateReductionThreshold=20;

            successfulBurstCount=0;
            receiveAttemptCount=1;
            currentSampleCount=0;
            info=struct(...
            'currentSampleCount',currentSampleCount,...
            'requestedBurstSize',requestedBurstSize,...
            'receiveAttemptCount',receiveAttemptCount,...
            'successfulBurstCount',successfulBurstCount...
            );
            while currentSampleCount<receiveLength



                if currentSampleCount+requestedBurstSize>receiveLength
                    requestedBurstSize=receiveLength-currentSampleCount;
                end


                for n=1:length(channelNumbers)
                    obj.configPlay(baseAddresses(n)+currentOffset,requestedBurstSize*bytesPerSample,channelNumbers(n));
                end
                if length(channelNumbers)>1

                    timeOffset=0.0;
                    timed_replay_start(obj,streamer,"burst",requestedBurstSize,channelNumbers,timeOffset);
                else
                    obj.replay("burst",requestedBurstSize,channelNumbers(1));
                end

                samplesRemaining=requestedBurstSize;
                burstRetriesLeft=10;
                while samplesRemaining&&burstRetriesLeft
                    [dataChunk,receivedSamplesLength,overflow]=streamer.receive(samplesRemaining,timeout);
                    samplesRemaining=samplesRemaining-receivedSamplesLength;
                    data(currentSampleCount+1:currentSampleCount+receivedSamplesLength,:)=dataChunk(1:receivedSamplesLength,:);
                    currentOffset=currentOffset+receivedSamplesLength*bytesPerSample;
                    currentSampleCount=currentSampleCount+receivedSamplesLength;
                    info.currentSampleCount=currentSampleCount;




                    if overflow
                        break;
                    end


                    if~receivedSamplesLength
                        burstRetriesLeft=burstRetriesLeft-1;
                    end
                end

                if~samplesRemaining
                    successfulBurstCount=successfulBurstCount+1;
                else
                    successfulBurstCount=0;
                    receiveAttemptCount=receiveAttemptCount+1;

                    for n=1:length(channelNumbers)
                        obj.ctrl.stop(channelNumbers(n));
                    end




                    [~,drainedSamplesLength,drainOverflow]=streamer.receive(samplesRemaining,timeout);
                    samplesRemaining=samplesRemaining-drainedSamplesLength;
                    while drainedSamplesLength||drainOverflow
                        [~,drainedSamplesLength,drainOverflow]=streamer.receive(samplesRemaining,timeout);
                        samplesRemaining=samplesRemaining-drainedSamplesLength;
                    end
                end



                if receiveAttemptCount>rateReductionThreshold
                    info.requestedBurstSize(end+1)=requestedBurstSize;
                    info.receiveAttemptCount(end+1)=receiveAttemptCount;
                    info.successfulBurstCount(end+1)=successfulBurstCount;
                    currentPacketsPerBurstIndex=currentPacketsPerBurstIndex+1;
                    if currentPacketsPerBurstIndex>length(packetsPerBurstList)
                        receiveFailed=true;
                        return
                    end
                    currentPacketsPerBurst=packetsPerBurstList(currentPacketsPerBurstIndex);
                    requestedBurstSize=calculateBurstParameters(obj,receiveLength-currentSampleCount,maxPacketSize,currentPacketsPerBurst);
                    receiveAttemptCount=1;


                elseif currentPacketsPerBurstIndex>=2...
                    &&receiveAttemptCount==1...
                    &&successfulBurstCount>=rateIncreaseThreshold
                    info.requestedBurstSize(end+1)=requestedBurstSize;
                    info.receiveAttemptCount(end+1)=receiveAttemptCount;
                    info.successfulBurstCount(end+1)=successfulBurstCount;

                    currentPacketsPerBurstIndex=currentPacketsPerBurstIndex-1;
                    currentPacketsPerBurst=packetsPerBurstList(currentPacketsPerBurstIndex);
                    requestedBurstSize=calculateBurstParameters(obj,receiveLength-currentSampleCount,maxPacketSize,currentPacketsPerBurst);
                    successfulBurstCount=0;
                else

                    info.receiveAttemptCount(end)=receiveAttemptCount;
                    info.successfulBurstCount(end)=successfulBurstCount;
                end
            end
        end
        function transmit(obj,streamer,data,mode)



            timeOffset=0.2;

            channelList=[];
            len=length(data);
            otw_bytes=bytesPerDeviceSample(streamer);
            checkAvailableMemory(obj,numberOfPorts(streamer),len,otw_bytes);
            total_bytes_per_channel=otw_bytes*len;
            savedBaseAddress=obj.base_addr;
            for n=1:numberOfPorts(streamer)



                [~,~,channel]=streamer.getOutConnection(n);
                channelList(end+1)=channel;%#ok<AGROW>
                base=allocate(obj,total_bytes_per_channel);

                obj.stop(channel);
                obj.record(base,total_bytes_per_channel,channel);
                obj.configPlay(base,total_bytes_per_channel,channel);
                obj.flushReplayMemory(channel);
            end

            timeout=1;
            obj.load(streamer,data,timeout,channelList);

            successfulLoad=verifyFillLevel(obj,total_bytes_per_channel,channelList,timeout);
            if~successfulLoad

                for n=1:length(channelList)
                    obj.flushReplayMemory(channelList(n));
                end
                obj.base_addr=savedBaseAddress;
                error(message("wt:rfnoc:driver:FailedToBufferSamplesToRadio"));
            end

            if length(channelList)>1
                obj.timed_replay_start(streamer,mode,len,channelList,timeOffset);
            else
                obj.replay(mode,len,channelList(1));
            end

            if mode=="burst"
                obj.repeatedTransmissionChannels=[];
                obj.base_addr=savedBaseAddress;
            else
                obj.repeatedTransmissionChannels=channelList;
                obj.repeatedTransmissionBaseAddress=savedBaseAddress;
            end
        end
        function[success,actualByteCount]=verifyFillLevel(obj,expectedByteCount,channelList,timeout)
            step=0.001;
            success=false;
            actualByteCount=zeros(1,length(channelList));
            startTime=tic;

            while toc(startTime)<=timeout

                for n=1:length(channelList)
                    actualByteCount(n)=obj.getRecordFullness(channelList(n));
                end

                if all(actualByteCount==expectedByteCount)
                    success=true;
                    return;
                else
                    pause(step);
                end
            end
        end
        function checkAvailableMemory(obj,numChannels,length,bytesPerSample)
            channelBytes=length*bytesPerSample;


            channelAllocation=obj.pageSize*ceil(channelBytes/obj.pageSize);
            totalByteAllocation=channelAllocation*numChannels;
            if obj.base_addr+totalByteAllocation>obj.mem_size
                error(message("wt:rfnoc:driver:BufferSpaceExceeded",length,floor(obj.mem_size-obj.base_addr)/bytesPerSample));
            end
        end
        function address=allocate(obj,size_in_bytes)




            offset=obj.pageSize*ceil(size_in_bytes/obj.pageSize);

            address=obj.base_addr;
            obj.base_addr=address+offset;
        end
        function burst_size=calculateBurstParameters(~,receiveLength,packet_size,packetsPerBurst)
            burst_size=min(receiveLength,double(packetsPerBurst*packet_size));
        end
    end
end
