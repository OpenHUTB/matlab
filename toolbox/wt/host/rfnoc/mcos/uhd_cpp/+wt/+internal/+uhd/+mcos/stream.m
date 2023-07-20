



classdef stream<wt.internal.uhd.mcos.node
    properties(Access=protected)

cpu_format

otw_format
streamer

radio_name
num_channels
    end

    methods
        function obj=stream(blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.node(blockName);
            obj.radio_name=varargin{1};
        end
    end
    methods
        function stream_args=setStreamArgs(obj,varargin)
            narginchk(1,4);
            if nargin==1
                obj.cpu_format="sc16";
                obj.otw_format="sc16";
                stream_args='';
            elseif nargin<=3
                obj.cpu_format=varargin{1};
                obj.otw_format=varargin{2};
                stream_args='';
            else
                obj.cpu_format=varargin{1};
                obj.otw_format=varargin{2};
                stream_args=varargin{3};
            end
        end

        function max_samps=getMaxSamplesPerPacket(obj)
            max_samps=obj.streamer.getMaxSamplesPerPacket();
        end

        function count=bytesPerDeviceSample(obj)

            switch(lower(obj.otw_format))
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

            switch(lower(obj.cpu_format))
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

        function connectStreamBlocks(obj,block,block_port,stream_port)
            if contains(obj.name,"TX_STREAM")
                obj.connectTxStream(block,block_port,stream_port,false);
            else
                obj.connectRxStream(block,block_port,stream_port,false);
            end
        end

        function connectRxStream(obj,source_block,source_port,stream_port,transport_adapter_id)
            obj.streamer.create_rx_streamer(source_block,source_port,stream_port,transport_adapter_id);
        end

        function connectTxStream(obj,dest_block,dest_port,source_port,transport_adapter_id)
            obj.streamer.create_tx_streamer(dest_block,dest_port,source_port,transport_adapter_id);
        end

    end
end


