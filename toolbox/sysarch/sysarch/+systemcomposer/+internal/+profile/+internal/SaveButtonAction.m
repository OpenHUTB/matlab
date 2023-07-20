classdef SaveButtonAction<handle

    properties(Access=private)
        editor;
    end

    methods
        function this=SaveButtonAction(editor)
            this.editor=editor;
        end

        function tag=getTag(~)
            tag='saveButtonAction';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:Save');
        end

        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+profile','resources','exportProfile.png');
        end

        function is=getEnabled(~)
            is=true;
        end
    end

end