classdef noise<int32




    enumeration
        Disabled(0)
        Enabled(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Disabled')='physmod:ee:library:comments:sources:noise:Disabled';
            map('Enabled')='physmod:ee:library:comments:sources:noise:Enabled';
        end
    end
end