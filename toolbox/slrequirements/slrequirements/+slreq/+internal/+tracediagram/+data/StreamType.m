classdef StreamType<int8

    enumeration
        Upstream(1)
        Downstream(-1)
        Unset(-128)
        Midstream(0)
    end
    methods
        function out=isUpstream(this)
            out=this==1||this==0;
        end

        function out=isDownstream(this)
            out=this==-1||this==0;
        end

    end
end
