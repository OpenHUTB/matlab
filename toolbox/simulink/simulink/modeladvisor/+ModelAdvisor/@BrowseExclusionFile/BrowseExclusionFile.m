



classdef BrowseExclusionFile<handle
    properties(Access=private)
        exclusionEditorObj;
        idx;
    end

    properties(Access=public)
        fDialogHandle;
    end

    methods(Access=public)
        show(aObj);
    end

    methods(Access=public)
        loadExclusionFile(aObj);
        detachExclusionFile(aObj);
        saveAsExclusionFile(aObj);

        function obj=BrowseExclusionFile(parent)
            obj.exclusionEditorObj=parent;
        end

        function editor=getExclusionEditor(aObj)
            editor=aObj.exclusionEditorObj;
            return;
        end

        function setSelectedIndex(aObj,idx)
            aObj.index=idx;
        end

        function out=getSelectedIndex(aObj)
            out=aObj.index;
        end
    end
end