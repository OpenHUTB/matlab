classdef pipelinePresSpec<int32




    enumeration
        same(1)
        custom(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('same')='The same initial pressure for all nodes';
            map('custom')='Custom';
        end
    end
end