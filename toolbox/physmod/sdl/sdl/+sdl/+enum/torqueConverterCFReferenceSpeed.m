classdef torqueConverterCFReferenceSpeed<int32





    enumeration
        ImpellerSpeedAlways(1)
        ImpellerSpeedLessThanOne(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('ImpellerSpeedAlways')='physmod:sdl:library:enum:TorqueConverterImpellerSpeedAlways';
            map('ImpellerSpeedLessThanOne')='physmod:sdl:library:enum:TorqueConverterImpellerSpeedLessThanOne';
        end
    end
end
