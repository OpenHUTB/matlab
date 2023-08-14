classdef ExclusionEditorBase<handle





    properties(Access=protected)
        model;
        windowId;
        isSaveToSlx;
        TableData={};
        GlobalExclusionsData={};
        childWindow=[];
        isTableDataValid=false;
    end

    methods(Access=public)
        function this=ExclusionEditorBase(modelName,windowId)
            this.model=modelName;
            this.windowId=windowId;
            this.isSaveToSlx=true;
        end

        function delete(this)
            this.closeChildWindows();
        end

        function closeChildWindows(this)

            if~isempty(this.childWindow)
                this.childWindow.close();
                this.childWindow=[];
            end
        end

        function bResult=hasChildWindows(this)
            bResult=~isempty(this.childWindow);
        end

        function setChildWindow(this,window)
            this.childWindow=window;
        end

        function setTableStale(this,status)
            this.isTableDataValid=~status;
        end

        function bIsTableDataValid=getIsTableDataValid(this)
            bIsTableDataValid=this.isTableDataValid;
        end

        function bStatus=getSaveToSLX(this)
            bStatus=this.isSaveToSlx;
        end

        function modelName=getModelName(this)
            modelName=this.model;
        end

        function windowId=getWindowID(this)
            windowId=this.windowId;
        end

        function globalExclusions=getGlobalExclusions(this)
            globalExclusions=this.GlobalExclusionsData;
        end

        function setDialogDirty(this,status)
            ExclWindow=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);

            if status
                title=strcat(ExclWindow.getTitle(),'*');
            else
                title=strrep(ExclWindow.getTitle(),'*','');
            end

            if ExclWindow.isOpen()
                ExclWindow.setTitle(title);
                ExclWindow.publishToUI('ExclusionEditor::setDirty',status);
            end
        end
    end

    methods(Abstract,Access=public)
        result=saveToModel(this);
        result=saveToFile(this,fileChooser);
        result=saveToDefaultLocation(this);
        result=loadExclusionsFile(this,fileChooser);
        result=deleteExclusion(this,rowNum);
        result=addExclusion(this,propValues,varargin);
        result=openHelp(this);
        result=highlightID(this,sid);
        result=refreshUI(this);
        result=checkAndCloseWindow(this,msg);
        result=getTableData(this);
        result=updateTable(this,propValues);
    end

    methods(Abstract,Access=protected)
        fetchDataFromBackend(this);
        updateBackend(this);
    end
end

