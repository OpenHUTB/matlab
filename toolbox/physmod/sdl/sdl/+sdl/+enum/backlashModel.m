classdef backlashModel<int32




    enumeration
        Off(0)
        SpringDamper(1)
        Events(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Off')='physmod:sdl:library:enum:BacklashOff';
            map('SpringDamper')='physmod:sdl:library:enum:BacklashSpringDamper';
            map('Events')='physmod:sdl:library:enum:BacklashIdeal';
        end
    end
end
