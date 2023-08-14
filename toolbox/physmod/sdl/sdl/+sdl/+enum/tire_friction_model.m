classdef tire_friction_model<int32




    enumeration
        none(0)
        Magic(1)
        Friction(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:simscape:library:enum:None';
            map('Magic')='physmod:sdl:library:enum:MagicTirePS';
            map('Friction')='physmod:sdl:library:enum:PSFriction';
        end
    end
end
