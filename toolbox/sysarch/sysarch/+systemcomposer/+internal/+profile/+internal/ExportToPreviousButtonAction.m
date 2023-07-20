classdef ExportToPreviousButtonAction<handle
    properties(Access=private)
        editor;
    end

    methods(Static)
        function exportTo19b(obj)
            disp('Entered callback');
            disp(obj);
        end
    end

    methods
        function this=ExportToPreviousButtonAction(editor)
            this.editor=editor;
        end

        function tag=getTag(~)
            tag='exportToPreviousButtonAction';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:ExportToPrevious');
        end

        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+profile','resources','exportProfile.png');
        end

        function is=getEnabled(this)
            is=true;
        end
    end

end