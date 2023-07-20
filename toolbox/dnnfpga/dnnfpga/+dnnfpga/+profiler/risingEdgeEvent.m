classdef risingEdgeEvent<dnnfpga.profiler.abstractEvent



    methods(Access=public)
        function triggered=isTriggered(this,rawLog)
            assert(length(this.m_bitRange)==1);
            triggered=logical(bitget(rawLog,this.m_bitRange+1));
        end

        function val=parse(this,rawLog)
            val=this.isTriggered(rawLog);
        end
    end
end

