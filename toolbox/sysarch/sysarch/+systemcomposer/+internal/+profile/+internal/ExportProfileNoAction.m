classdef ExportProfileNoAction<handle




    methods
        function tag=getTag(~)
            tag='ExportNoneBtn';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:ExportReleaseNone');
        end

        function icon=getDisplayIcon(~)
            icon='';
        end

        function is=getEnabled(~)
            is=true;
        end
    end

end