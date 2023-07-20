classdef(Sealed)BuildMode
    properties(Constant)
        TOPMODELBUILD=1;
        MODELREFBUILD=2;
        SUBSYSTEMBUILD=3;
    end

    methods(Access=private)
        function out=BuildMode
        end
    end
end