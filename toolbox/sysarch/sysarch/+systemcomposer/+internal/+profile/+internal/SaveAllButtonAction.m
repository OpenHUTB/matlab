classdef SaveAllButtonAction<handle

    properties(Access=private)
        editor;
    end

    methods
        function this=SaveAllButtonAction(editor)
            this.editor=editor;
        end

        function tag=getTag(~)
            tag='saveAllButtonAction';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:SaveAll');
        end

        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+profile','resources','exportProfile.png');
        end

        function is=getEnabled(this)
            is=this.editor.hasUnsavedProfiles();
        end
    end

end