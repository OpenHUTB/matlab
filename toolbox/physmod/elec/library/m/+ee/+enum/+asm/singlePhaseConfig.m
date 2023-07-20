classdef singlePhaseConfig<int32





    enumeration
        splitphase(1)
        capacitorstart(2)
        capacitorstartrun(3)
        twowindings(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('splitphase')='physmod:ee:library:comments:enum:asm:singlePhaseConfig:map_splitphase';
            map('capacitorstart')='physmod:ee:library:comments:enum:asm:singlePhaseConfig:map_capacitorstart';
            map('capacitorstartrun')='physmod:ee:library:comments:enum:asm:singlePhaseConfig:map_capacitorstartcapacitorrun';
            map('twowindings')='physmod:ee:library:comments:enum:asm:singlePhaseConfig:map_mainAndAuxiliaryWindings';
        end
    end
end