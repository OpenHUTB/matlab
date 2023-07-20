classdef ExclusionEditor<Advisor.ExclusionEditorBase




    properties(Access=private)
        AppID='ClonesExclusionEditor';


        UpdateDialogAction=struct('Save',1,'Dirty',2);
        ExternalFilePath='';
    end

    methods(Access=public)
        function this=ExclusionEditor(modelName,windowId)
            this=this@Advisor.ExclusionEditorBase(modelName,windowId);
            this.GlobalExclusionsData.ExcludeModelReferences=false;
            this.GlobalExclusionsData.ExcludeLibraryLinks=false;
            this.GlobalExclusionsData.ExcludeInactiveRegions=false;
            this.setPropDefaults();
            this.fetchDataFromBackend();
        end

        propMap=getProperties(this,ssid,sel);
        result=editRationale(this,rowData);
        result=consoleLog(this,logMessage);

        function result=updateTable(~,~)

            result=[];
        end

        function filePath=getExternalFilePath(this)
            filePath=this.ExternalFilePath;
        end

        function setTableStale(this,status)
            setTableStale@Advisor.ExclusionEditorBase(this,status);
            CloneDetector.Exclusions.clearFilterManagerForModel(this.model);
        end
    end

    methods(Access=public,Hidden=true)
        function setExternalFilePath(this,filePath)
            this.ExternalFilePath=filePath;
            this.setTableStale(true);
        end
    end



    methods(Access=protected)
        fetchDataFromBackend(this);
        updateBackend(this);
        setPropDefaults(this);
    end

    methods(Access=private)
        updateDialogForAction(this,actionName,actionData);
    end
end


