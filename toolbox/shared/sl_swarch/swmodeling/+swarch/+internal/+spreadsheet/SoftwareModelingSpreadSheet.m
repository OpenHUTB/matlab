classdef SoftwareModelingSpreadSheet<handle




    properties(Access=private)
        pTabObjects;
        pRootArchitecture;
        pComponent;
        pStudio;
        pBdHandle;
        pDatamodelListener;
        pComponentName;
        pDomainStr;
    end

    properties(Access=?swarch.internal.spreadsheet.AbstractSoftwareModelingTab)
        ActiveTabData;
    end

    methods
        function this=SoftwareModelingSpreadSheet(studio,domainStr)
            this.pStudio=studio;
            this.pDomainStr=domainStr;


            this.createTabs();
            this.createComponent();

            this.initForCurrentEditor();

            this.setupSpreadSheetForCurrentTab();
            this.setAppActive(true);
        end

        function delete(this)
            dataModel=mf.zero.getModel(this.pRootArchitecture);
            if isvalid(dataModel)
                dataModel.removeListener(this.pDatamodelListener);
            end
        end

        function children=getChildren(this)
            children=this.getCurrentTabObj().getChildren();
        end


        function arch=getRootArchitecture(this)
            arch=this.pRootArchitecture;
        end


        function arch=getBdHandle(this)
            arch=this.pBdHandle;
        end

        function setCurrentTab(this,tabNum)
            this.getComponent().setCurrentTab(tabNum);
            this.setupSpreadSheetForCurrentTab();
        end

        function tabNum=getCurrentTab(this)
            tabNum=this.getComponent().getCurrentTab();
        end

        function toggleVisibility(this)
            if this.pComponent.isVisible
                this.hide()
            else
                this.show()
            end
        end

        function hide(this)
            if~isempty(this.pComponent)&&isvalid(this.pComponent)
                this.ActiveTabData=[];
                this.setAppActive(false);
                this.pStudio.hideComponent(this.pComponent);
            end
        end

        function show(this)
            if~isempty(this.pComponent)&&isvalid(this.pComponent)
                this.initForCurrentEditor();
                this.setAppActive(true);
                this.setupSpreadSheetForCurrentTab();
                this.pStudio.showComponent(this.pComponent)
            end
        end

        function update(this,changeReport)
            curTab=this.getCurrentTabObj();

            if curTab.processChangeReport(changeReport)
                this.pComponent.update();
            end
        end


        function columns=getColumns(this)
            columns=this.getCurrentTabObj().getColumnNames();
        end


        function comp=getComponent(this)
            comp=this.pComponent;
        end


        function studio=getStudio(this)
            studio=this.pStudio;
        end

        function sel=getSelectedModelElements(this)

            sel=this.getComponent().imSpreadSheetComponent.getSelection();
            if isempty(sel)||isempty(sel{:})
                sel=[];
            else
                sel=[sel{:}.get()];
            end
        end
    end

    methods(Access=private)
        function createComponent(this)
            comp=this.pStudio.getComponent('GLUE2:SpreadSheet',this.pComponentName);
            if~isempty(comp)
                this.pComponent=comp;
                return;
            end
            this.pComponent=GLUE2.SpreadSheetComponent(this.pStudio,this.pComponentName);

            configOpts='"enablemultiselect": false';
            this.pComponent.setConfig(['{',configOpts,'}']);


            for idx=1:length(this.pTabObjects)
                currDataSource=this.pTabObjects{idx};
                this.pComponent.addTab(currDataSource.getTabName(),...
                currDataSource.getTabName(),...
                currDataSource.getTabName());
            end


            this.pComponent.onTabChange=@(src,event)this.handleTabChange(src,event);


            this.pComponent.onSelectionChange=...
            @(~,selection)this.handleSelectionChange(selection);

            this.pComponent.onCloseClicked=@(~)this.handleCloseClicked();


            this.pComponent.onDrag=@swarch.internal.spreadsheet.SoftwareModelingSpreadSheet.handleDrag;
            this.pComponent.onDrop=@swarch.internal.spreadsheet.SoftwareModelingSpreadSheet.handleDrop;
            this.pComponent.setAcceptedMimeTypes({'application/swarch-mimetype'});

            this.pComponent.enableHierarchicalView(true);

            this.pStudio.registerComponent(this.pComponent);
            this.pStudio.moveComponentToDock(this.pComponent,this.pComponentName,...
            'Bottom','stacked');
        end

        function createTabs(this)
            this.pTabObjects=[];

            if strcmpi(this.pDomainStr,'SoftwareArchitecture')||...
                (strcmpi(this.pDomainStr,'AUTOSARArchitecture')&&...
                ((slfeature('SoftwareModelingAutosar')>0)||(slfeature('FunctionsModelingAutosar')>0)))
                this.pComponentName=getString(...
                message('SoftwareArchitecture:ArchEditor:SoftwareSSComponentName'));


                this.pTabObjects={swarch.internal.spreadsheet.InternalFunctionInfoTab(this)};


                if slfeature('SoftwareModeling')>0&&slfeature('SoftwareModelingIRT')>0
                    this.pTabObjects{end+1}=swarch.internal.spreadsheet.IRTInfoTab(this);
                end


                if slfeature('SoftwareModeling')>0
                    this.pTabObjects{end+1}=swarch.internal.spreadsheet.TaskInfoTab(this);
                end


                if slfeature('SoftwareModelingIC')>0
                    this.pTabObjects{end+1}=swarch.internal.spreadsheet.InitialConditionTab(this);
                end


                if slfeature('ZCEventChain')>0
                    this.pTabObjects{end+1}=swarch.internal.spreadsheet.EventChainInfoTab(this);
                end
            else
                this.pComponentName=getString(...
                message('SoftwareArchitecture:ArchEditor:SystemSSComponentName'));


                assert(slfeature('ZCEventChain')>0);
                this.pTabObjects{end+1}=swarch.internal.spreadsheet.EventChainInfoTab(this);
            end
        end

        function setupSpreadSheetForCurrentTab(this)




            this.ActiveTabData=[];
            curTab=this.getCurrentTabObj();

            [cols,sortCol,groupCol,ascending]=curTab.getColumnInfo();
            this.pComponent.setColumns(cols,sortCol,groupCol,ascending);
            this.pComponent.setSource(curTab);
            this.pComponent.setTitleView(curTab);

            curTab.refreshChildren();
            this.pComponent.update();
        end

        function handleTabChange(this,~,~)
            if~isempty(this.pComponent)
                this.setupSpreadSheetForCurrentTab();
                this.pComponent.expandAll();
            end
        end

        function datasource=getCurrentTabObj(this)
            datasource=this.pTabObjects{1+this.pComponent.getCurrentTab()};
        end


        function result=handleSelectionChange(this,sels)
            if this.getCurrentTabObj().refreshButtonsOnSelectionChange()

                this.pComponent.updateTitleView();
            end

            for i=1:numel(sels)
                if sels{i}.isDragAllowed()||sels{i}.isDropAllowed
                    this.pComponent.setMimeInfo(sels{i},sels{i}.getMimeType(),sels{i}.getMimeData());
                end
            end
            this.getCurrentTabObj().handleSelectionChanged();

            result=true;
        end

        function handleCloseClicked(this)
            this.ActiveTabData=[];
            this.setAppActive(false);
        end

        function setAppActive(this,isActive)
            acm=this.pStudio.App.getAppContextManager;
            appName=...
            swarch.internal.toolstrip.SoftwareModelingSpreadSheetContext.AppName;
            customCtx=acm.getCustomContext(appName);
            if isempty(customCtx)
                customCtx=swarch.internal.toolstrip.SoftwareModelingSpreadSheetContext(this.pComponent.isVisible);
            end

            customCtx.setVisible(isActive);
            if isActive
                acm.activateApp(customCtx);
            else
                acm.deactivateApp(appName);
            end
        end

        function initForCurrentEditor(this)


            zcModel=getTopMostArchModel(this.pStudio,this.pDomainStr);

            if isempty(this.pRootArchitecture)||...
                zcModel.Architecture.getImpl()~=this.pRootArchitecture
                if~isempty(this.pDatamodelListener)
                    dataModel=mf.zero.getModel(this.pRootArchitecture);
                    dataModel.removeListener(this.pDatamodelListener);
                end

                this.pRootArchitecture=zcModel.Architecture.getImpl();
                this.pBdHandle=zcModel.SimulinkHandle;



                this.pDatamodelListener=@(changeReport)this.update(changeReport);
                dataModel=mf.zero.getModel(this.pRootArchitecture);
                dataModel.addObservingListener(this.pDatamodelListener);


                for idx=1:numel(this.pTabObjects)
                    this.pTabObjects{idx}.initForCurrentEditor();
                end
            end



            if(strcmpi(get_param(this.pBdHandle,'SimulinkSubDomain'),'SoftwareArchitecture')||...
                strcmpi(get_param(this.pBdHandle,'SimulinkSubDomain'),'AUTOSARArchitecture'))&&...
                ~isempty(find_system(this.getBdHandle(),'BlockType','ModelReference'))
                swarch.internal.spreadsheet.updateDiagram(this.getBdHandle());
            end
        end
    end

    methods(Static,Access=private)
        function allowed=handleDrag(~,source,dest,location,action)%#ok<INUSD>


            try
                allowed=dest.performDrag(source);
            catch
                allowed=false;
            end
        end

        function allowed=handleDrop(~,source,dest,location,action)%#ok<INUSD>



            try
                allowed=dest.performDrop(source);
            catch
                allowed=false;
            end
        end
    end
end

function zcModel=getTopMostArchModel(studio,domainStr)

    editor=studio.App.getActiveEditor;
    hid=editor.getHierarchyId();
    if(GLUE2.HierarchyService.isTopLevel(hid))

        obj=GLUE2.HierarchyService.getM3IObject(hid).temporaryObject;
        blockPath={obj.getName()};
    else

        hid=GLUE2.HierarchyService.getParent(hid);
        obj=GLUE2.HierarchyService.getM3IObject(hid).temporaryObject;
        hid=GLUE2.HierarchyService.getParent(hid);
        blockPath=Simulink.BlockPath...
        .fromHierarchyIdAndHandle(hid,obj.handle)...
        .convertToCell();
    end



    pathFromRoot=strsplit(blockPath{1},'/');
    topArch=pathFromRoot{1};
    for i=2:numel(pathFromRoot)
        if strcmpi(get_param(topArch,'SimulinkSubDomain'),domainStr)
            break;
        end
        topArch=strcat(topArch,'/',pathFromRoot{i});
    end

    if strcmpi(get_param(topArch,'type'),'block')
        topArch=get_param(topArch,'ModelName');
    end

    zcModel=get_param(topArch,'SystemComposerModel');
end



