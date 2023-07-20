classdef ExportProfile19bAction<handle




    methods
        function tag=getTag(~)
            tag='ExportR2019bBtn';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:ExportRelease19b');
        end

        function icon=getDisplayIcon(~)
            icon='';
        end

        function is=getEnabled(~)
            is=true;
        end
    end

end
