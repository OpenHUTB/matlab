classdef ViewSettingsManager<handle







    properties
        saveFilePath='';
        ViewSettings=containers.Map('KeyType','char','ValueType','Any');
    end

    properties(Constant)
        SaveFileName='slreqViewSettings.mat';
    end

    properties(Access=?slreq.app.MainManager)
        viewManager;
    end
    methods(Access=private)
        function tf=filteredView(this)
            tf=reqmgt('rmiFeature','FilteredView');
        end
    end

    methods
        function this=ViewSettingsManager()
            this.saveFilePath=fullfile(prefdir,this.SaveFileName);
            this.loadFromPrefDir();




            this.viewManager=slreq.app.ViewManager(this);

        end

        function delete(this)
            if~isempty(this.viewManager)
                this.viewManager.delete();
                this.viewManager=[];
            end
        end

        function saveViewSettingsFor(this,viewObj)
            if~any(strcmp(viewObj.reqColumns,'Index'))...
                ||any(strcmp(viewObj.linkColumns,'Index'))



                rmiut.warnNoBacktrace(getString(message('Slvnv:slreq:InvalidColumnSetting')));
                return;
            end

            thisViewSettings=struct(...
            'isReqView',viewObj.isReqView);
            thisViewSettings.reqColumns=viewObj.reqColumns;
            thisViewSettings.linkColumns=viewObj.linkColumns;
            thisViewSettings.reqSortInfo=viewObj.reqSortInfo;
            thisViewSettings.linkSortInfo=viewObj.linkSortInfo;
            [reqColumnWidths,linkColumnWidths]=viewObj.getColumnWidths();
            thisViewSettings.reqColumnWidths=reqColumnWidths;
            thisViewSettings.linkColumnWidths=linkColumnWidths;
            thisViewSettings.displayChangeInformation=viewObj.displayChangeInformation;
            [thisViewSettings.ssWidth,thisViewSettings.ssHeight]=viewObj.getSpreadSheetSize();

            if isa(viewObj,'slreq.gui.ReqSpreadSheet')
                studio=viewObj.getStudio;
                if isvalid(viewObj.mComponent)&&studio.isComponentVisible(viewObj.mComponent)
                    thisViewSettings.ssDockPosition=...
                    studio.getComponentDockPosition(viewObj.mComponent);
                end
            else

                thisViewSettings.ssDockPosition='Bottom';
            end

            this.ViewSettings(viewObj.getViewSettingID)=thisViewSettings;
            if this.filteredView
                d=this.viewManager.getCurrentView.getDisplaySettings(viewObj.getViewSettingID,true);
                this.viewManager.takeOldSettings(thisViewSettings,d);
                this.viewManager.saveUserViews();
            else
                this.saveViewSettings();
            end
        end

        function saveViewSettings(this)
            if this.filteredView
                this.viewManager.saveViews();
            else
                this.saveToFile(this.saveFilePath);
            end
        end

        function loadViewSettings(this)


            this.loadFromPrefDir();
        end

        function viewSetting=getViewSettings(this,viewObj)
            viewSetting=[];
            if ischar(viewObj)
                viewSettingID=viewObj;
            else
                viewSettingID=viewObj.getViewSettingID;
            end
            if this.filteredView
                viewSetting=this.viewManager.getOldSettings(this.viewManager.getCurrentSettings(viewSettingID));
            else
                if isKey(this.ViewSettings,viewSettingID)
                    viewSetting=this.ViewSettings(viewSettingID);
                end
            end
        end

        function tf=hasStorage(this)
            if this.filteredView
                this.viewManager.hasStorage;
            else
                tf=exist(this.saveFilePath,'file')==2;
            end
        end

        function wipeAllViews(this)
            if this.filteredView
                this.viewManager.wipeAllViews;
            end
        end

        function resetFor(this,target)
            if this.filteredView
                this.viewManager.resetFor(target);
                return;
            end

            appmgr=slreq.app.MainManager.getInstance;
            switch target
            case 'all'

                this.ViewSettings=containers.Map('KeyType','char','ValueType','Any');
                if~isempty(appmgr.requirementsEditor)
                    appmgr.requirementsEditor.resetViewSettings();
                end
                if~isempty(appmgr.spreadsheetManager)
                    appmgr.spreadsheetManager.resetAllViews();
                end

            case 'editor'
                if isKey(this.ViewSettings,'standalone')
                    this.ViewSettings.remove('standalone');
                end
                if~isempty(appmgr.requirementsEditor)
                    appmgr.requirementsEditor.resetViewSettings();
                end

            otherwise
                try
                    if isnumeric(target)
                        modelName=get_param(target,'Name');
                    else
                        modelName=target;
                    end
                catch ex
                    error(message('Slvnv:slreq:InvalidTargetSpecified'));
                end
                if isKey(this.ViewSettings,modelName)
                    this.ViewSettings.remove(modelName);
                end
                if appmgr.hasEditor()


                    spObj=appmgr.getSpreadSheetObject(modelName);
                    if~isempty(spObj)
                        spObj.resetViewSettings();
                    end
                end
            end
            this.saveViewSettings()
        end

        function importViewSettings(this,viewSettingFile,overwriteExisting)


            if this.filteredView
                this.viewManager.importViewSettings(viewSettingFile,overwriteExisting);
                return;
            end

            t=load(viewSettingFile);
            theirs=t.viewSettings;
            keys=theirs.keys;
            for n=1:length(keys)
                key=keys{n};
                if isKey(this.ViewSettings,key)
                    if overwriteExisting
                        this.ViewSettings(key)=theirs(key);
                    else

                    end
                else
                    this.ViewSettings(key)=theirs(key);
                end
            end
            this.restoreAllViews();
        end

        function exportViewSettings(this,filePath)
            this.saveAllViews();
            if this.filteredView
                this.viewManager.exportViewSettings(filePath);
            else

                this.saveToFile(filePath);
            end
        end

    end

    methods(Access=?slreq.app.ViewManager)
        function loadFromPrefDir(this)
            if exist(this.saveFilePath,'file')==2
                t=load(this.saveFilePath);
                this.ViewSettings=t.viewSettings;
            end
        end

        function saveToFile(this,filePath)
            viewSettings=this.ViewSettings;
            try
                save(filePath,'viewSettings');
            catch ME %#ok<NASGU>
                rmiut.warnNoBacktrace(getString(message('Slvnv:slreq:UnableToSave',filePath)));
            end
        end

        function saveAllViews(this)

            appmgr=slreq.app.MainManager.getInstance;
            if~isempty(appmgr.requirementsEditor)&&appmgr.requirementsEditor.isVisible
                this.saveViewSettingsFor(appmgr.requirementsEditor);
            end
            if~isempty(appmgr.spreadsheetManager)
                allModelH=appmgr.spreadsheetManager.getAllModelHandles;
                for n=1:length(allModelH)
                    spObjs=appmgr.spreadsheetManager.getAllSpreadSheetObjects(allModelH);
                    for m=1:length(spObjs)
                        this.saveViewSettingsFor(spObjs(m));
                    end
                end
            end
        end

        function restoreAllViews(this)%#ok<MANU>
            appmgr=slreq.app.MainManager.getInstance;
            if~isempty(appmgr.requirementsEditor)&&appmgr.requirementsEditor.isVisible
                appmgr.requirementsEditor.restoreViewSettings()
            end
            if~isempty(appmgr.spreadsheetManager)
                allModelH=appmgr.spreadsheetManager.getAllModelHandles;
                for n=1:length(allModelH)
                    spObjs=appmgr.spreadsheetManager.getAllSpreadSheetObjects(allModelH);
                    for m=1:length(spObjs)
                        spObjs(m).restoreViewSettings();
                    end
                end
            end



            appmgr.updateRollupStatusAndChangeInformationIfNeeded();
        end
    end

    methods(Static)
        function newColWidthJson=revertShownColWidth(currentColWidth,prevColWidth)




            current=jsondecode(currentColWidth);
            currentColNames={current.columns.name};
            prev=jsondecode(prevColWidth);
            prevColNames={prev.columns.name};
            addedCols=setdiff(currentColNames,prevColNames);

            for n=1:length(prevColNames)
                colName=prevColNames{n};
                idx=strcmp(currentColNames,colName);
                if any(idx)
                    current.columns(idx).width=prev.columns(n).width;
                end
            end

            for n=1:length(addedCols)
                colName=addedCols{n};
                idx=strcmp(currentColNames,colName);
                current.columns(idx).width=50;
            end
            newColWidthJson=jsonencode(current);
        end
    end
end
