classdef SD_max_check<int32





    enumeration
        none(0)
        warning(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('none')='None';
            map('warning')='Warning';
        end
    end
end