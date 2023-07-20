classdef nPorts<int32



    enumeration
        Three(3)
        Two(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Three')='physmod:ee:library:comments:enum:passive:potentiometer:nPorts:Three';
            map('Two')='physmod:ee:library:comments:enum:passive:potentiometer:nPorts:Two';
        end
    end
end
