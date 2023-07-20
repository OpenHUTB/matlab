




classdef rx_stream<wt.internal.uhd.mcos.stream
    properties(Hidden)
        started_continuous=false
stream_mode
    end

    methods
        function obj=rx_stream(block,varargin)
            obj=obj@wt.internal.uhd.mcos.stream(block,varargin{1});
            obj.streamer=uhd.internal.rx_stream;
            obj.streamer.setGraph(obj.radio_name);
        end
    end

    methods
        function getRxStream(obj,num_channels,varargin)
            obj.num_channels=num_channels;
            stream_args=obj.setStreamArgs(varargin{:});
            obj.streamer.makeRxStreamer(obj.cpu_format,obj.otw_format,stream_args,obj.num_channels);
        end

        function stop(obj)

            obj.streamer.stop(obj.num_channels);
            obj.started_continuous=false;
        end

        function configure(obj,streamMode,samples,varargin)
            if nargin<4
                timeOffset=0.1;
            else
                timeOffset=varargin{1};
            end
            obj.stream_mode=streamMode;
            obj.streamer.configRxStreamer(streamMode,samples,timeOffset,obj.num_channels);
        end

        function[data,num_rx_samps,overflow]=receive(obj,sampleLength,timeout,varargin)




            timeOffset=0.2;
            onexit_fn={};

            if~isempty(varargin)&&isstruct(varargin{1})
                onexit_fn=obj.parseStreamCmds(varargin{1},timeOffset);
                varargin(1)=[];
            end
            if~isempty(varargin)
                onePacket=varargin{1};
            else
                onePacket=false;
            end



            if~isempty(obj.stream_mode)
                if(isequal(obj.stream_mode,"continuous"))
                    if~obj.started_continuous
                        obj.streamer.issueStreamCmd();
                        obj.started_continuous=true;
                    end
                else
                    obj.streamer.issueStreamCmd();
                end
            end

            try
                switch(lower(obj.cpu_format))
                case{'fc64'}

                    [data,num_rx_samps,overflow]=receiveFC64(obj,sampleLength,timeout,onePacket);
                case{'fc32'}

                    [data,num_rx_samps,overflow]=receiveFC32(obj,sampleLength,timeout,onePacket);
                case{'sc16'}

                    [data,num_rx_samps,overflow]=receiveSC16(obj,sampleLength,timeout,onePacket);
                case{'sc8'}

                    [data,num_rx_samps,overflow]=receiveSC8(obj,sampleLength,timeout,onePacket);
                case{'uc8'}

                    [data,num_rx_samps,overflow]=receiveUC8(obj,sampleLength,timeout,onePacket);






                case{'s16'}

                    [data,num_rx_samps,overflow]=receiveS16(obj,sampleLength,timeout,onePacket);
                case{'s8'}

                    [data,num_rx_samps,overflow]=receiveS8(obj,sampleLength,timeout,onePacket);
                case{'u8'}

                    [data,num_rx_samps,overflow]=receiveU8(obj,sampleLength,timeout,onePacket);
                otherwise
                    error(message("wt:rfnoc:host:InvalidDataFormat"));
                end
            catch ME
                rethrow(ME);
            end

            cellfun(@(c)c(),onexit_fn,'UniformOutput',false);
        end

        function[data,num_rx_samps,overflow]=receiveFC32(obj,sampleLength,timeout,onePacket)
            data=obj.streamer.recv_FC32_data(sampleLength,timeout,onePacket);
            overflow=data{3};
            num_rx_samps=data{2};
            data=data{1};
        end

        function[data,num_rx_samps,overflow]=receiveSC8(obj,sampleLength,timeout,onePacket)
            data=obj.streamer.recv_SC8_data(sampleLength,timeout,onePacket);
            overflow=data{3};
            num_rx_samps=data{2};
            data=data{1};
        end

        function[data,num_rx_samps,overflow]=receiveUC8(obj,sampleLength,timeout,onePacket)
            data=obj.streamer.recv_UC8_data(sampleLength,timeout,onePacket);
            overflow=data{3};
            num_rx_samps=data{2};
            data=data{1};
        end

        function[data,num_rx_samps,overflow]=receiveSC16(obj,sampleLength,timeout,onePacket)
            recv_info=obj.streamer.recv_SC16_data(sampleLength,timeout,onePacket);
            overflow=recv_info{3};
            num_rx_samps=recv_info{2};
            data=recv_info{1};
        end

        function[data,num_rx_samps,overflow]=receiveFC64(obj,sampleLength,timeout,onePacket)

            recv_info=obj.streamer.recv_FC64_data(sampleLength,timeout,onePacket);
            overflow=recv_info{3};
            num_rx_samps=recv_info{2};
            data=recv_info{1};
        end








        function[data,num_rx_samps,overflow]=receiveS8(obj,sampleLength,timeout,onePacket)
            recv_info=obj.streamer.recv_S8_data(sampleLength,timeout,onePacket);
            overflow=recv_info{3};
            num_rx_samps=recv_info{2};
            data=recv_info{1};
        end


        function[data,num_rx_samps,overflow]=receiveU8(obj,sampleLength,timeout,onePacket)
            recv_info=obj.streamer.recv_U8_data(sampleLength,timeout,onePacket);
            overflow=recv_info{3};
            num_rx_samps=recv_info{2};
            data=recv_info{1};
        end

        function[data,num_rx_samps,overflow]=receiveS16(obj,sampleLength,timeout,onePacket)
            recv_info=obj.streamer.recv_S16_data(sampleLength,timeout,onePacket);
            overflow=recv_info{3};
            num_rx_samps=recv_info{2};
            data=recv_info{1};
        end










        function onfnexitarray=parseStreamCmds(obj,upstreamBlockConfig,time)
            onfnexitarray={};
            obj.streamer.setTimeSpec(time);
            for n=1:length(upstreamBlockConfig)
                block=upstreamBlockConfig(n).block;


                if length(upstreamBlockConfig)>1
                    block.issueStreamCommand(upstreamBlockConfig(n).mode,upstreamBlockConfig(n).len,upstreamBlockConfig(n).channel,time);
                else
                    time=0;
                    block.issueStreamCommand(upstreamBlockConfig(n).mode,upstreamBlockConfig(n).len,upstreamBlockConfig(n).channel);
                end
                fh=[];
                if strcmp(upstreamBlockConfig(n).mode,"continuous")
                    fh=@()(block.issueStreamCommand("stop",0,upstreamBlockConfig(n).channel));
                end
                onfnexitarray{end+1}=fh;%#ok
            end
            pause(time);
        end

        function count=numberOfPorts(obj)
            count=obj.in_count;
        end
    end
end


