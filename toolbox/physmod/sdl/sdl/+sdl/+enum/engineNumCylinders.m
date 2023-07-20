classdef engineNumCylinders<int32




    enumeration
        One(1)
        Two(2)
        Three(3)
        Four(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('One')='physmod:sdl:library:enum:EngineSingleCylinder';
            map('Two')='physmod:sdl:library:enum:EngineTwoCylinders';
            map('Three')='physmod:sdl:library:enum:EngineThreeCylinders';
            map('Four')='physmod:sdl:library:enum:EngineFourCylinders';
        end
    end
end
