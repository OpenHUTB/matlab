classdef(Hidden=true)ConstellationWebScopesStyleSpecification<dsp.webscopes.style.StyleSpecification







    methods(Access=protected)

        function marker=getDefaultMarker(~)
            marker=".";
        end
        function lineStyle=getDefaultLineStyle(~)
            lineStyle="NONE";
        end
    end



    methods(Hidden)

        function n=getMaxNumChannels(~)
            n=20;
        end
    end
end