



classdef tx_stream<wt.internal.uhd.mcos.stream
    properties(Hidden)
    end
    methods
        function obj=tx_stream(block,varargin)
            obj=obj@wt.internal.uhd.mcos.stream(block,varargin{1});
            obj.streamer=uhd.internal.tx_stream;
            obj.streamer.setGraph(obj.radio_name);
        end
    end
    methods
        function getTxStream(obj,num_channels,varargin)
            obj.num_channels=num_channels;
            stream_args=obj.setStreamArgs(varargin{:});
            obj.streamer.makeTxStreamer(obj.cpu_format,obj.otw_format,stream_args,obj.num_channels);
        end

        function num_tx_samples=send(obj,buff,timeout)

            try
                switch(lower(obj.cpu_format))
                case{'fc64'}
                    dataType="double";
                    strFunc="sendDoubleData";
                    isReal=false;
                case{'fc32'}
                    dataType="single";
                    strFunc="sendFloatData";
                    isReal=false;
                case{'sc16'}
                    dataType="int16";
                    strFunc="sendShortData";
                    isReal=false;
                case{'sc8'}
                    dataType="int8";
                    strFunc="sendCharData";
                    isReal=false;
                case{'uc8'}
                    dataType="uint8";
                    strFunc="sendUCharData";
                    isReal=false;








                case{'s16'}
                    dataType="int16";
                    strFunc="sendShortData";
                    isReal=true;
                case{'s8'}
                    dataType="int8";
                    strFunc="sendCharData";
                    isReal=true;
                case{'u8'}
                    dataType="uint8";
                    strFunc="sendUCharData";
                    isReal=true;
                otherwise
                    error(message("wt:rfnoc:host:InvalidDataFormat"));
                end



                buff=cast(buff(:).',dataType);


                if~isReal&&isreal(buff)
                    buff=complex(buff);
                end
                func=str2func(strFunc);
                num_tx_samples=func(obj,buff,timeout,double(isReal));
            catch ME
                rethrow(ME);
            end
        end

        function num_tx_samples=sendShortData(obj,buff,timeout,isReal)

            num_tx_samples=obj.streamer.send_int16_data(buff,timeout,isReal,convertStringsToChars(obj.name));
        end

        function num_tx_samples=sendUCharData(obj,buff,timeout,isReal)

            num_tx_samples=obj.streamer.send_uint8_data(buff,timeout,isReal,convertStringsToChars(obj.name));
        end

        function num_tx_samples=sendFloatData(obj,buff,timeout,isReal)

            num_tx_samples=obj.streamer.send_float_data(buff,timeout,isReal,convertStringsToChars(obj.name));
        end

        function num_tx_samples=sendCharData(obj,buff,timeout,isReal)

            num_tx_samples=obj.streamer.send_int8_data(buff,timeout,isReal,convertStringsToChars(obj.name));
        end

        function num_tx_samples=sendDoubleData(obj,buff,timeout,isReal)

            num_tx_samples=obj.streamer.send_double_data(buff,timeout,isReal,convertStringsToChars(obj.name));
        end

        function count=numberOfPorts(obj)


            count=obj.out_count;
        end
    end
end


