classdef ExclusionEditor<Advisor.ExclusionEditorBase




    methods(Access=public)
        function this=ExclusionEditor(modelName,windowId)
            this=this@Advisor.ExclusionEditorBase(modelName,windowId);
            this.fetchDataFromBackend();
        end

        result=openCheckSelectorWithData(this,rowNum,checkIds);

        showCheckSelectorUI(this,callbackInfo);
        refreshExclusions(this,varargin);
    end




    methods(Access=protected)
        fetchDataFromBackend(this);
        updateBackend(this);
    end
end


