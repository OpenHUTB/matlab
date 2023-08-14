classdef nullsrcsink_block<wt.internal.uhd.clibgen.block





    methods(Access=protected)
        function control=getCustomBlockController(obj)
            control=obj.graph.get_block_uhd__rfnoc__null_block_control_(getID(obj));
        end
    end

    methods
        function issueStreamCommand(obj,stream_mode,num_samples,varargin)

            stream_args={stream_mode,num_samples};
            stream_cmd=wt.internal.uhd.clibgen.stream.getStreamCommand(stream_args{:});
            obj.ctrl.issue_stream_cmd(stream_cmd);
        end

        function setBytesPerPacket(obj,num_bytes)
            obj.ctrl.set_bytes_per_packet(uint32(num_bytes));
        end
    end

end

