classdef filtertype<int32



    enumeration
        BPsingle(1)
        BPdouble(2)
        HPsecondorder(3)
        HPctype(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('BPsingle')='physmod:ee:library:comments:enum:filtertype:map_BandPassFilterSingleTuned';
            map('BPdouble')='physmod:ee:library:comments:enum:filtertype:map_BandPassFilterDoubleTuned';
            map('HPsecondorder')='physmod:ee:library:comments:enum:filtertype:map_HighPassFilterSecondOrder';
            map('HPctype')='physmod:ee:library:comments:enum:filtertype:map_HighPassFilterCType';
        end
    end
end

