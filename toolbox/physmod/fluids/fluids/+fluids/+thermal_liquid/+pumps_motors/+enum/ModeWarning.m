classdef ModeWarning<int32




    enumeration
        none(0)
        warn(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:simscape:library:enum:None';
            map('warn')='physmod:simscape:library:enum:Warning';
        end
    end
end