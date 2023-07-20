classdef SaveAsButtonAction<handle

    properties(Access=private)
        editor;
    end

    methods
        function this=SaveAsButtonAction(editor)
            this.editor=editor;
        end

        function tag=getTag(~)
            tag='saveAsButtonAction';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:SaveAs');
        end

        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+profile','resources','exportProfile.png');
        end

        function is=getEnabled(this)
            profile=this.editor.getCurrentProfile();
            is=~isempty(profile);
        end
    end

end