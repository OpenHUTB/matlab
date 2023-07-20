



classdef nullsrcsink_block<wt.internal.uhd.mcos.block
    properties
    end

    methods
        function obj=nullsrcsink_block(radio,blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.block(blockName,varargin);
            obj.ctrl=uhd.internal.nullsrcsink;
            makeBlock(obj,radio);
        end
    end

    methods
        function issueStreamCommand(obj,stream_mode,num_samples,varargin)

            nullsrcblock=obj.ctrl;
            try
                nullsrcblock.issueStreamCmd(stream_mode,num_samples);
            catch ME
                rethrow(ME);
            end
        end

        function setBytesPerPacket(obj,num_bytes)
            nullsrcblock=obj.ctrl;
            nullsrcblock.setBytesPerPacket(num_bytes);
        end
    end

end
