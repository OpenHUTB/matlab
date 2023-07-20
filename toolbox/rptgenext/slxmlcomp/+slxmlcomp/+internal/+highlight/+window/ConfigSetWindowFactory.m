classdef ConfigSetWindowFactory<slxmlcomp.internal.highlight.WindowFactory




    properties(Access=private)
        ConfigSetType="ConfigSet"
    end

    methods(Access=public)

        function bool=canDisplay(obj,location)
            bool=location.Type==obj.ConfigSetType;
        end

        function window=create(~,location)
            window=slxmlcomp.internal.highlight.window.ConfigSetHighlightWindow(...
location...
            );
        end

    end

end
