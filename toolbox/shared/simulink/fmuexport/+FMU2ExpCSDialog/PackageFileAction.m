classdef PackageFileAction<handle


    properties(Access=private)
        editor;
    end

    methods
        function this=PackageFileAction(editor)
            this.editor=editor;
        end

        function tag=getTag(~)
            tag='fileButtonAction';
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageFileLabel');
        end

        function path=getDisplayIcon(~)
            path='';
        end

        function is=getEnabled(~)
            is=true;
        end
    end
end