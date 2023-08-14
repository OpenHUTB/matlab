classdef PackageFolderAction<handle


    properties(Access=private)
        editor;
    end

    methods
        function this=PackageFolderAction(editor)
            this.editor=editor;
        end

        function tag=getTag(~)
            tag='folderButtonAction';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageFolderLabel');
        end

        function path=getDisplayIcon(~)
            path='';
        end

        function is=getEnabled(~)
            is=true;
        end
    end
end