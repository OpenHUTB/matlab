classdef volume_fraction_error<int32




    enumeration
        none(1)
        warn(2)
        error(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('none')='No Error';
            map('warn')='Warn';
            map('error')='Error';
        end
    end
end