classdef stream<wt.internal.uhd.clibgen.node




    properties(Access=protected)

stream_handle

cpu_data_type

otw_data_type

num_ports

md

graph
    end

    methods(Access={?handle})

        function make(obj,stream_type,graph,num_ports,cpu,otw,varargin)

            obj.num_ports=num_ports;
            obj.cpu_data_type=cpu;
            obj.otw_data_type=otw;
            obj.graph=graph;
            args=obj.makeArgs(cpu,otw,varargin{:});
            switch(lower(stream_type))
            case{'tx'}
                obj.md=clib.wt_uhd.uhd.tx_metadata_t;
                obj.stream_handle=graph.create_tx_streamer(obj.num_ports,args);
            case{'rx'}
                obj.md=clib.wt_uhd.uhd.rx_metadata_t;
                obj.stream_handle=graph.create_rx_streamer(obj.num_ports,args);
            otherwise
                error(message("wt:rfnoc:host:InvalidStreamDirection"));
            end
        end
    end
    methods(Access=protected)
        function args=makeArgs(~,cpu,otw,varargin)
            if nargin<4
                deviceArgs=clib.wt_uhd.uhd.device_addr_t("");
            else
                deviceArgs=clib.wt_uhd.uhd.device_addr_t(varargin{:});
            end
            args=clib.wt_uhd.uhd.stream_args_t(cpu,otw);
            args.args=deviceArgs;
        end
    end

    methods

        function count=numberOfPorts(obj)
            count=obj.num_ports;
        end

        function count=bytesPerDeviceSample(obj)

            switch(lower(obj.otw_data_type))
            case{'u8','s8'}
                count=1;
            case{'u16','s16','uc8','sc8'}
                count=2;
            case{'f32','uc16','sc16'}
                count=4;
            case{'f64','fc32'}
                count=8;
            case{'fc64'}
                count=16;
            otherwise
                error(message("wt:rfnoc:host:InvalidDataFormat"));
            end
        end
        function dataTypeStr=getMATLABDataType(obj)

            switch(lower(obj.cpu_data_type))
            case{'u8','uc8'}
                dataTypeStr='uint8';
            case{'s8','sc8'}
                dataTypeStr='int8';
            case{'u16','uc16'}
                dataTypeStr='uint16';
            case{'s16','sc16'}
                dataTypeStr='int16';
            case{'f32','fc32'}
                dataTypeStr='single';
            case{'f64','fc64'}
                dataTypeStr='double';
            otherwise
                error(message("wt:rfnoc:host:InvalidDataFormat"));
            end
        end

        function stream=getID(obj)

            stream=obj.stream_handle;
        end

        function count=getMaxSamplesPerPacket(obj)
            count=obj.stream_handle.get_max_num_samps();
        end

        function ts=getTimeSpec(obj,offset)
            ts=clib.wt_uhd.mw.helper.stream.future_time(obj.graph,0,0,offset);
        end

        function stream_cmd=configureStreamCommand(obj,stream_mode,num_samples,varargin)


            if nargin>3
                time_spec=varargin{1};
                stream_cmd=wt.internal.uhd.clibgen.stream.getStreamCommand(stream_mode,num_samples,time_spec);
            elseif getInCount(obj)>1
                stream_cmd=wt.internal.uhd.clibgen.stream.getStreamCommand(stream_mode,num_samples,getTimeSpec(obj,0.1));
            else
                stream_cmd=wt.internal.uhd.clibgen.stream.getStreamCommand(stream_mode,num_samples);
            end
        end
    end

    methods(Static)
        function stream_cmd=getStreamCommand(stream_mode,num_samples,varargin)


            switch(lower(stream_mode))
            case{'continuous'}
                stream_mode=clib.wt_uhd.uhd.stream_cmd_t.stream_mode_t.STREAM_MODE_START_CONTINUOUS;
            case{'burst'}
                stream_mode=clib.wt_uhd.uhd.stream_cmd_t.stream_mode_t.STREAM_MODE_NUM_SAMPS_AND_DONE;
            case 'stop'
                stream_mode=clib.wt_uhd.uhd.stream_cmd_t.stream_mode_t.STREAM_MODE_STOP_CONTINUOUS;
            otherwise
                stream_mode=clib.wt_uhd.uhd.stream_cmd_t.stream_mode_t.STREAM_MODE_NUM_SAMPS_AND_DONE;
            end

            if nargin>2
                stream_now=false;
                timespec=varargin{1};
            else
                stream_now=true;
                timespec=clib.wt_uhd.uhd.time_spec_t;
            end

            stream_cmd=clib.wt_uhd.mw.helper.stream.make_stream_cmd_t(...
            stream_mode,...
            num_samples,...
            stream_now,...
timespec...
            );
        end
    end
end


