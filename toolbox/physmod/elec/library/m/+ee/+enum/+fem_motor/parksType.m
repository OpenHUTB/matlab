classdef parksType<int32
    enumeration
        QleadsD_AphaseToDaxis(1)
        QleadsD_AphaseToQaxis(2)
        DleadsQ_AphaseToDaxis(3)
        DleadsQ_AphaseToQaxis(4)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('QleadsD_AphaseToDaxis')='physmod:ee:library:comments:enum:fem_motor:parksType:map_QleadsD_AphaseToDaxis';
            map('QleadsD_AphaseToQaxis')='physmod:ee:library:comments:enum:fem_motor:parksType:map_QleadsD_AphaseToQaxis';
            map('DleadsQ_AphaseToDaxis')='physmod:ee:library:comments:enum:fem_motor:parksType:map_DleadsQ_AphaseToDaxis';
            map('DleadsQ_AphaseToQaxis')='physmod:ee:library:comments:enum:fem_motor:parksType:map_DleadsQ_AphaseToQaxis';
        end
    end
end