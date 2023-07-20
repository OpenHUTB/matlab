classdef ExportProfile19aAction<handle




    methods
        function tag=getTag(~)
            tag='ExportR2019aBtn';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:ExportRelease19a');
        end

        function icon=getDisplayIcon(~)
            icon='';
        end

        function is=getEnabled(~)
            is=true;
        end
    end

end