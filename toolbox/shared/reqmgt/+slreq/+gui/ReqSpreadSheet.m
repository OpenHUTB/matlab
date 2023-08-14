classdef ReqSpreadSheet<slreq.utils.Observable






















    properties

        mComponent;

        listeners={};


        toolbar;
        currentSelectedObj;

        Menus=struct;

        displayComment=true;

        displayImplementationStatus=false;

        displayVerificationStatus=false;



        displayChangeInformation=false;

        importListener;


        studioEvents;
    end

    properties(Access=private)

        selectedObjMap;



        isUnifiedViewAcrossModels=true;

        rootModelH;
        currentModelH;
        cStudio;

        reqColumnWidths;
        linkColumnWidths;


        selectionStatus=slreq.gui.SelectionStatus.None;
    end

    properties(SetAccess=private,GetAccess=public)






        modelHsInSpreadsheetMaps;
    end
    properties(Dependent)


        reqColumns;
        linkColumns;


        Columns;
        linkSortInfo;
        reqSortInfo;
        SortInfo;
        isReqView;
    end


    properties(Dependent,Access=private)



dasLinkSet

        mData;
    end

    properties(Constant,Access=private)
        mComponentName='RequirementsSpreadsheet';

    end

    properties(Dependent)


        sourceID;
    end

    events
ViewChanged

Toggled

SelectionChanged

BrowserToggled
    end

    methods
        function this=ReqSpreadSheet(modelH,currentModelH,cStudio)
            this=this@slreq.utils.Observable();

            appmgr=slreq.app.MainManager.getInstance;

            this.studioEvents=struct(...
            'eventName',{'GLUE2:ActiveEditorChanged','WindowActivatedEvents'},...
            'eventHandler',{@this.handleEditorChanged,@this.handleWindowActivated},...
            'id',{[],[]});


            this.rootModelH=rmisl.getOwnerModelFromHarness(modelH);
            currentModelH=rmisl.getOwnerModelFromHarness(currentModelH);

            this.currentModelH=currentModelH;
            this.cStudio=cStudio;
            this.selectedObjMap=containers.Map('KeyType','double','ValueType','any');
            this.modelHsInSpreadsheetMaps=containers.Map('KeyType','double','ValueType','logical');
            this.listeners{end+1}=appmgr.addlistener('SleepUI',@(s,e)setUISleep(this,true));
            this.listeners{end+1}=appmgr.addlistener('WakeUI',@(s,e)setUISleep(this,false));

            comp=this.findRequirementsSpreadsheetComponent();

            this.getOrCreateRootSpreadSheetData();
            this.getOrCreateCurrentSpreadSheetData();

            if isempty(comp)
                this.createMComponent();
                this.mComponent.setSource(this.getViewData());
                this.restoreViewSettings()

                this.setTitleBar();

                this.openPropertyInspector();

                this.refreshRollupStatusIfNecessary();

                this.update();


                eventData=slreq.gui.ReqSpreadSheetToggled();
                eventData.modelH=this.rootModelH;
                eventData.state=true;
                eventData.studio=this.getStudio();
                eventData.mDataModelH=currentModelH;
                this.notifyObservers('Toggled',eventData);
            else
                this.mComponent=comp;
                this.mComponent.setSource(this.getViewData);
                this.restoreViewSettings();
                this.refreshRollupStatusIfNecessary();
                this.setTitleBar();
                this.show(this.cStudio,true);
            end
        end

        function[width,height]=getSpreadSheetSize(this)
            if isempty(this.mComponent)||~isvalid(this.mComponent)
                width=-1;
                height=-1;
                return;
            end

            try
                sz=this.mComponent.getSize();
                width=sz(1);
                height=sz(2);
            catch
                width=-1;
                height=-1;
            end
        end

        function setSpreadSheetSize(this,w,h)
            if isempty(this.mComponent)||~isvalid(this.mComponent)
                return;
            end

            try
                this.mComponent.setSize(w,h);
            catch
            end
        end


        function refreshRollupStatusIfNecessary(this)
            appmgr=slreq.app.MainManager.getInstance;
            if this.displayVerificationStatus
                appmgr.reqRoot.refreshVerificationStatus();
            end

            if this.displayImplementationStatus
                appmgr.reqRoot.refreshImplementationStatus();
            end
        end


        function addModelHToInSpreadsheet(this,modelH)
            this.modelHsInSpreadsheetMaps(modelH)=true;
        end


        function out=getOrCreateCurrentSpreadSheetData(this)
            appmgr=slreq.app.MainManager.getInstance;
            spreadSheetDataManager=appmgr.spreadSheetDataManager;
            out=spreadSheetDataManager.getOrCreateDataObj(this.getCurrentModelH);
            this.addModelHToInSpreadsheet(this.getCurrentModelH);
        end


        function out=getOrCreateRootSpreadSheetData(this)
            appmgr=slreq.app.MainManager.getInstance;
            spreadSheetDataManager=appmgr.spreadSheetDataManager;
            out=spreadSheetDataManager.getOrCreateDataObj(this.rootModelH);
            this.addModelHToInSpreadsheet(this.rootModelH);
        end


        function delete(this)




            this.currentSelectedObj=[];
            this.selectedObjMap=containers.Map('KeyType','double','ValueType','any');
            appmgr=slreq.app.MainManager.getInstance;
            appmgr.setLastOperatedView([]);
            try
                this.mComponent.hide;
                this.mComponent.setSource(slreq.das.BaseObject);

                this.mComponent.update();


                this.stopListeningForImportedReqSets();

            catch ex %#ok<NASGU>
            end
        end


        function out=getRootModelH(this)
            out=this.rootModelH;
        end



        function r=getRoot(this)
            if this.isReqView
                r=this.getViewReqRoot;
            else
                r=this.getViewLinkRoot;
            end
        end


        function out=getCurrentModelH(this)
            if~ishandle(this.currentModelH)






                currentStudio=slreq.utils.DAStudioHelper.getAllStudios(this.rootModelH);
                if isempty(currentStudio)

                    this.currentModelH=this.rootModelH;
                else
                    studioHelper=slreq.utils.DAStudioHelper.createHelper(currentStudio(1));
                    this.currentModelH=studioHelper.ActiveModelHandle;
                end
            end
            out=this.currentModelH;
        end


        function out=get.dasLinkSet(this)
            out=this.getCurrentSpreadSheetData().dasLinkSet;
        end


        function out=get.isReqView(this)
            out=this.getStudioRootData.isReqView;
        end


        function set.isReqView(this,value)
            this.getStudioRootData().isReqView=value;
        end


        function out=get.Columns(this)
            if this.isUnifiedViewAcrossModels
                out=this.getStudioRootData().getColumns(this.isReqView);
            else
                out=this.getCurrentSpreadSheetData().getColumns;
            end
        end


        function out=get.reqColumns(this)
            if this.isUnifiedViewAcrossModels
                out=this.getStudioRootData().reqColumns;
            else
                out=this.getCurrentSpreadSheetData().reqColumns;
            end
        end


        function out=get.linkColumns(this)
            if this.isUnifiedViewAcrossModels
                out=this.getStudioRootData().linkColumns;
            else
                out=this.getCurrentSpreadSheetData().linkColumns;
            end
        end


        function set.reqColumns(this,val)
            if this.isUnifiedViewAcrossModels
                this.getStudioRootData().reqColumns=val;
            else
                this.getCurrentSpreadSheetData().reqColumns=val;
            end
        end


        function set.linkColumns(this,val)
            if this.isUnifiedViewAcrossModels
                this.getStudioRootData().linkColumns=val;
            else
                this.getCurrentSpreadSheetData().linkColumns=val;
            end
        end

        function set.Columns(this,val)
            if this.isReqView
                this.reqColumns=val;
            else
                this.linkColumns=val;
            end
        end


        function out=get.SortInfo(this)
            if this.isUnifiedViewAcrossModels
                out=this.getStudioRootData().getSortInfo(this.isReqView);
            else
                out=this.getCurrentSpreadSheetData().getSortInfo;
            end
        end


        function out=get.reqSortInfo(this)
            if this.isUnifiedViewAcrossModels
                out=this.getStudioRootData().reqSortInfo;
            else
                out=this.getCurrentSpreadSheetData().reqSortInfo;
            end
        end


        function out=get.linkSortInfo(this)
            if this.isUnifiedViewAcrossModels
                out=this.getStudioRootData().linkSortInfo;
            else
                out=this.getCurrentSpreadSheetData().linkSortInfo;
            end
        end


        function children=getChildren(this,component)%#ok<INUSD>
            children=this.getViewData();
        end


        function columns=getColumns(this)
            columns=this.Columns;
        end

        function comp=getComponent(this)
            comp=this.mComponent;
        end

        function update(this,skipRefreshingPropertyInspector)

            slreq.utils.assertValid(this);
            if~isvalid(this.mComponent)
                return;
            end
            this.setTitle();
            if nargin<2
                skipRefreshingPropertyInspector=false;
            end
            sortInfo=this.SortInfo;
            this.mComponent.setColumns(this.Columns,sortInfo.Col,'',sortInfo.Order);

            if~isempty(this.mComponent)
                if isvalid(this.mComponent)&&~isempty(this.getViewData())

                    this.mComponent.setSource(this.getViewData());
                    this.mComponent.update();
                    this.mComponent.updateTitleView()
                end
            end











            if~skipRefreshingPropertyInspector&&~isempty(this.currentSelectedObj)
                dlgs=DAStudio.ToolRoot.getOpenDialogs(this.currentSelectedObj);
                slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(dlgs);
            end






        end

        function refreshUI(this,obj)
            if this.isComponentVisible
                if nargin<2
                    this.mComponent.update();
                else
                    this.mComponent.update({obj});
                end
            end
        end

        function studio=getStudio(this)
            studio=[];
            if~isempty(this.mComponent)&&isvalid(this.mComponent)
                studio=this.mComponent.getStudio;
            end
        end

        function out=isComponentVisible(this)
            out=~isempty(this.mComponent)&&isvalid(this.mComponent)&&this.mComponent.isVisible;
        end

        function show(this,callerStudio,showPI)


















            if nargin<3
                showPI=isempty(slmle.api.getActiveEditor);
            end





            targetEditor=[];

            if~isempty(this.mComponent)&&isvalid(this.mComponent)

                origstudio=this.mComponent.getStudio;

                modelHandle=origstudio.App.blockDiagramHandle;
                targetEditor=rmisl.modelEditors(modelHandle,true,true);
                currentStudio=targetEditor.getStudio;
                studioHelper=slreq.utils.DAStudioHelper.createHelper(currentStudio);

                this.currentModelH=studioHelper.ActiveModelHandle;
                if origstudio==callerStudio

                    if~strcmp(origstudio.getComponentLocation(this.mComponent),'Invisible')&&~this.mComponent.isVisible

                        origstudio.showComponent(this.mComponent)
                    else
                        origstudio.moveComponentToDock(this.mComponent,this.mComponentName,this.getSpreadsheetDockPosition,'stacked');
                    end
                else



                    origstudio.destroyComponent(this.mComponent);

                    studioHelper=slreq.utils.DAStudioHelper.createHelper(callerStudio);
                    this.rootModelH=rmisl.getOwnerModelFromHarness(studioHelper.TopModelHandle);
                    this.currentModelH=studioHelper.ActiveModelHandle;
                    this.cStudio=callerStudio;
                    this.createMComponent();

                    this.getOrCreateCurrentSpreadSheetData();
                    this.mComponent.setSource(this.getViewData());
                    this.setTitleBar();
                end
            else

                studioHelper=slreq.utils.DAStudioHelper.createHelper(callerStudio);
                this.rootModelH=rmisl.getOwnerModelFromHarness(studioHelper.TopModelHandle);
                this.currentModelH=studioHelper.ActiveModelHandle;
                this.cStudio=callerStudio;

                this.createMComponent();



                this.getOrCreateCurrentSpreadSheetData();
                this.mComponent.setSource(this.getViewData());
                this.setTitleBar();
            end



            if showPI
                this.openPropertyInspector();
            end

            this.setTitle();
            this.update();


            eventData=slreq.gui.ReqSpreadSheetToggled();
            eventData.modelH=this.rootModelH;
            eventData.state=true;
            if~isempty(targetEditor)
                eventData.studio=targetEditor.getStudio;
            end
            this.notifyObservers('Toggled',eventData);

            this.registerStudioListener();
        end


        function registerStudioListener(this)
            if isempty(this.mComponent)

            else
                unRegisterStudioListener(this);

                studio=this.mComponent.getStudio;
                for i=1:numel(this.studioEvents)
                    c=studio.getService(this.studioEvents(i).eventName);
                    this.studioEvents(i).id=c.registerServiceCallback(this.studioEvents(i).eventHandler);
                end
            end
        end


        function unRegisterStudioListener(this)
            if isempty(this.mComponent)

            else
                studio=this.mComponent.getStudio;
                for i=1:numel(this.studioEvents)
                    c=studio.getService(this.studioEvents(i).eventName);
                    if~isempty(this.studioEvents(i).id)

                        c.unRegisterServiceCallback(this.studioEvents(i).id);
                        this.studioEvents(i).id=[];
                    end
                end
            end
        end

        function hide(this)


            this.stopListeningForImportedReqSets();
            appmgr=slreq.app.MainManager.getInstance;

            appmgr.getViewSettingsManager.saveViewSettingsFor(this);

            studio=[];
            if~isempty(this.mComponent)&&isvalid(this.mComponent)
                studio=this.mComponent.getStudio;
                studio.moveComponentToInvisible(this.mComponent);
                unRegisterStudioListener(this);

            else



            end


            eventData=slreq.gui.ReqSpreadSheetToggled();
            eventData.modelH=this.rootModelH;
            eventData.mDataModelH=this.getCurrentModelH;

            eventData.studio=studio;
            eventData.state=false;
            this.notifyObservers('Toggled',eventData);
        end

        function hideBrowser(this)

            appmgr=slreq.app.MainManager.getInstance;

            appmgr.getViewSettingsManager.saveViewSettingsFor(this);
            if~isempty(this.mComponent)&&isvalid(this.mComponent)
                studio=this.mComponent.getStudio;
                studio.moveComponentToInvisible(this.mComponent);
                unRegisterStudioListener(this);
            end
        end


        function switchToCurrentView(this)
            appmgr=slreq.app.MainManager.getInstance;
            view=appmgr.viewManager.getCurrentView;
            if isempty(view)
                error('view cannot be empty');
            end

            dispSettings=view.getDisplaySettings(this.getViewSettingID,true);
            this.reqColumns=dispSettings.reqColumns;
            this.linkColumns=dispSettings.linkColumns;
            this.reqColumnWidths=dispSettings.reqColumnWidths;
            this.linkColumnWidths=dispSettings.linkColumnWidths();
            if dispSettings.reqActive
                columToUpdate=dispSettings.reqColumnWidths;

            else
                columToUpdate=dispSettings.linkColumnWidths;

            end
            this.isReqView=dispSettings.reqActive;

            sortInfo=this.SortInfo;
            sortCol=sortInfo.Col;
            sortOrder=sortInfo.Order;

            if~isempty(columToUpdate)
                this.mComponent.setColumns(columToUpdate);
            end
            this.mComponent.setColumns(this.Columns,sortCol,'',sortOrder);
            this.mComponent.setMinimizeTabTitle(view.name);



            this.currentSelectedObj=slreq.das.BaseObject.empty();
            this.addSelectedObjToMap(this.currentSelectedObj);



            linkRoot=this.getViewLinkRoot;
            if~isempty(linkRoot)&&isvalid(linkRoot)
                linkRoot.update();
            end

            this.mComponent.setSource(this.getRoot());
            this.mComponent.update();

            this.setSpreadSheetSize(dispSettings.spreadsheetWidth,dispSettings.spreadsheetHeight);


            this.mComponent.updateTitleView()
            this.setTitle();
        end

        function switchView(this)


            appmgr=slreq.app.MainManager.getInstance;
            if isvalid(appmgr)
                if this.isReqView
                    this.reqColumnWidths=this.getColumnWidths();
                    columToUpdate=this.linkColumnWidths;
                else
                    this.linkColumnWidths=this.getColumnWidths();
                    columToUpdate=this.reqColumnWidths;
                end
                this.isReqView=~this.isReqView;
                sortInfo=this.SortInfo;
                sortCol=sortInfo.Col;
                sortOrder=sortInfo.Order;

                this.mComponent.setSource(this.getViewData());

                if~isempty(columToUpdate)
                    this.mComponent.setColumns(columToUpdate);
                end
                this.mComponent.setColumns(this.Columns,sortCol,'',sortOrder);

                this.currentSelectedObj=slreq.das.BaseObject.empty();
                this.addSelectedObjToMap(this.currentSelectedObj);
                this.mComponent.update();
                this.mComponent.updateTitleView()
                this.setTitle();
            end


            eventData=slreq.gui.ReqSpreadSheetViewChanged();
            eventData.isReqsView=this.isReqView;
            this.notifyObservers('ViewChanged',eventData);
        end

        function cmp=findRequirementsSpreadsheetComponent(this)
            if isempty(this.mComponent)||~isvalid(this.mComponent)
                studio=this.cStudio;
            else
                studio=this.mComponent.getStudio;
                this.cStudio=studio;
            end
            cmp=studio.getComponent('GLUE2:SpreadSheet',this.mComponentName);
        end

        function destroy(this)
            if isempty(this.mComponent)||~isvalid(this.mComponent)
                editor=rmisl.modelEditors(this.rootModelH,true);
                studio=editor.getStudio;
            else
                studio=this.mComponent.getStudio;
            end
            studio.destroyComponent(this.mComponent);
        end

        function setSelectedObject(this,targetObj)
            if~isempty(targetObj)
                if isa(targetObj,'slreq.das.Requirement')...
                    ||isa(targetObj,'slreq.das.RequirementSet')
                    if~this.isReqView
                        this.switchView;
                    end
                    this.mComponent.view(targetObj);
                elseif isa(targetObj,'slreq.das.Link')...
                    ||isa(targetObj,'slreq.das.LinkSet')
                    if this.isReqView
                        this.switchView;
                    end
                    this.mComponent.view(targetObj);
                end
            end


            this.currentSelectedObj=targetObj;

            appmgr=slreq.app.MainManager.getInstance;
            appmgr.setSelectedObject(targetObj);
            this.addSelectedObjToMap(targetObj);
        end

        function stat=getSelectionStatus(this)
            stat=this.selectionStatus;
        end

        function addSelectedObjToMap(this,targetObj)
            if~isempty(targetObj)
                this.selectedObjMap(this.getCurrentModelH)=targetObj;
            end
        end

        function out=getSelectedObjFromMap(this)
            if isKey(this.selectedObjMap,this.getCurrentModelH)
                out=this.selectedObjMap(this.getCurrentModelH);
            else
                out=slreq.das.BaseObject.empty();
            end
        end

        function setHighlightedObject(this,targetObj,driveView)


            if driveView
                if isa(targetObj,'slreq.das.Requirement')...
                    ||isa(targetObj,'slreq.das.RequirementSet')
                    if~this.isReqView
                        this.switchView;
                    end
                elseif isa(targetObj,'slreq.das.Link')...
                    ||isa(targetObj,'slreq.das.LinkSet')
                    if this.isReqView
                        this.switchView;
                    end
                end
            end

            this.mComponent.highlight(targetObj);
        end


        function selectObjectByUuid(this,uuids)
            dasObj=slreq.utils.findDASbyUUID(uuids);
            if~isempty(dasObj)
                this.setSelectedObject(dasObj)
            end
        end


        function removeReqLinkSetFromSpreadSheet(this,clearObj)

            if isa(clearObj,'slreq.das.RequirementSet')
                root=this.getViewReqRoot;
            elseif isa(clearObj,'slreq.das.LinkSet')
                root=this.getViewLinkRoot;
            else

                return;
            end

            removedIndex=this.getCurrentSpreadSheetData().removeReqLinkSet(clearObj);
            if removedIndex>0

                if isempty(root.children)
                    this.setSelectedObject(slreq.das.BaseObject.empty);
                else
                    indexToBeSelected=max(removedIndex-1,1);
                    this.setSelectedObject(root.children(indexToBeSelected));
                end
            end
        end


        function createAndRegisterLinkSet(this,reqSetDas)



            reqData=slreq.data.ReqData.getInstance;
            modelFileName=get_param(this.getCurrentModelH,'FileName');
            dataLinkSet=reqData.getLinkSet(modelFileName);
            if isempty(dataLinkSet)
                dataLinkSet=reqData.createLinkSet(modelFileName,'linktype_rmi_simulink');
            end



            dataLinkSet.addRegisteredRequirementSet(reqSetDas.dataModelObj);
            dasLinkSet=dataLinkSet.getDasObject();%#ok<PROPLC>


            this.getCurrentSpreadSheetData().addReqLinkSet(dasLinkSet);%#ok<PROPLC>
            this.getCurrentSpreadSheetData().addReqLinkSet(reqSetDas);
        end


        function addReqLinkSet(this,reqLinkSetDas)


            [isVisible,root]=this.isReqOrLinkSetRegistered(reqLinkSetDas);
            if~isVisible
                if isempty(root.children)
                    root.children=reqLinkSetDas;
                else
                    root.children(end+1)=reqLinkSetDas;
                end

            end
        end

        function displayLinkSetIfNeeded(this)
            if isempty(this.dasLinkSet)
                r=slreq.data.ReqData.getInstance;
                lSet=r.getLinkSet(get_param(this.modelH,'FileName'));
                if~isempty(lSet)
                    this.dasLinkSet=lSet.getDasObject();















                    if~isempty(this.dasLinkSet)
                        this.addReqLinkSet(this.dasLinkSet);
                    end
                end
            end
        end


        function obj=getCurrentSelection(this)
            obj=this.currentSelectedObj;
            if numel(obj)>1&&isa(obj,'slreq.das.Requirement')

                obj=slreq.das.Requirement.sortByIndex(obj);
            end
        end

        function clearCurrentObj(this,clearObj,forceClear)


            if forceClear...
                ||(isempty(this.currentSelectedObj)&&isempty(clearObj))...
                ||any(arrayfun(@(e)isequal(e,clearObj),this.currentSelectedObj))

                this.currentSelectedObj=slreq.das.ReqLinkBase.empty();
                this.selectionStatus=slreq.gui.SelectionStatus.None;
            end
        end




        function out=startListeningForImportedReqSets(this)
            if isempty(this.importListener)
                reqData=slreq.data.ReqData.getInstance();
                this.importListener=reqData.addlistener('ReqDataChange',@this.onReqSetImported);

                out=true;
            else
                out=false;
            end
        end


        function out=stopListeningForImportedReqSets(this)
            if~isempty(this.importListener)
                this.importListener.Enabled=false;
                delete(this.importListener);
                this.importListener=[];

                out=true;
            else
                out=false;
            end
        end



        function onReqSetImported(this,~,eventInfo)

            switch eventInfo.type


            case{'Requirement Pasted'}
                req=eventInfo.eventObj;

                if isa(req,'slreq.data.Requirement')
                    dataReqSet=req.getReqSet;
                elseif isa(req,'slreq.data.RequirementSet')
                    dataReqSet=req;
                end

                dasReqSet=dataReqSet.getDasObject();
                this.createAndRegisterLinkSet(dasReqSet);
                this.update();



                this.stopListeningForImportedReqSets();
            end
        end

        function tf=isInspectorVisible(this)%#ok<MANU>
            rootModel=slreq.utils.DAStudioHelper.getCurrentBDHandle();
            editor=rmisl.modelEditors(rootModel,true);
            studio=editor.getStudio;
            pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            tf=pi.isVisible;
        end

        function hidePropertyInspector(this)
            studio=this.cStudio;
            pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            studio.hideComponent(pi);
        end

        function srcID=get.sourceID(this)
            try

                srcID=get_param(this.getCurrentModelH,'Name');
            catch ME %#ok<NASGU>

                srcID='';
            end
        end

        function srcID=getViewSettingID(this)
            try

                srcID=get_param(this.getRootModelH,'Name');
            catch ME %#ok<NASGU>

                srcID='';
            end
        end


        function refreshDisplayedInfo(this)








            this.updateDisplayedReqSet();

            this.update;
        end

        function updateDisplayedReqSet(this)
            this.getCurrentSpreadSheetData().updateDisplayedReqSet;
        end


        function updateAfterClearLinkSet(this,modelH)






            if this.getCurrentModelH==modelH
                this.setSelectedObject(slreq.das.BaseObject.empty);
            end

            this.update;

        end

        function tf=fitForHorizontalAlignment(this)


            tf=false;
            if~isempty(this.mComponent)
                studio=this.mComponent.getStudio;
                if studio.isComponentVisible(this.mComponent)...
                    &&any(strcmp(studio.getComponentDockPosition(this.mComponent),{'Top','Bottom'}))
                    tf=true;
                end
            end
        end


        function toggleOnImplementationStatus(this)
            if~contains(this.reqColumns,'Implemented')
                this.reqColumns=[this.reqColumns,{'Implemented'}];
                this.update;
            end
            appmgr=slreq.app.MainManager.getInstance;
            appmgr.reqRoot.refreshImplementationStatus();
            this.displayImplementationStatus=true;
        end


        function toggleOffImplementationStatus(this)
            this.displayImplementationStatus=false;
            newReqCols=this.reqColumns;
            idx=strcmp(newReqCols,'Implemented');
            newReqCols(idx)=[];
            this.reqColumns=newReqCols;
            this.update;
        end


        function toggleOnVerificationStatus(this)
            if~contains(this.reqColumns,'Verified')
                this.reqColumns=[this.reqColumns,{'Verified'}];
                this.update;
            end
            appmgr=slreq.app.MainManager.getInstance;
            appmgr.reqRoot.refreshVerificationStatus();
            this.displayVerificationStatus=true;
            this.update;
        end


        function toggleOffVerificationStatus(this)
            this.displayVerificationStatus=false;
            newReqCols=this.reqColumns;
            idx=strcmp(newReqCols,'Verified');
            newReqCols(idx)=[];
            this.reqColumns=newReqCols;
            this.update;
        end


        function toggleOnChangeInformation(this)

            this.displayChangeInformation=true;
            appmgr=slreq.app.MainManager.getInstance;
            appmgr.showChangeInformation(this);
            this.update;
        end


        function toggleOffChangeInformation(this)
            this.displayChangeInformation=false;
            appmgr=slreq.app.MainManager.getInstance;
            appmgr.hideChangeInformation(this);
            this.update;
        end

        function updateToolbar(this)
            if~isempty(this.toolbar)
                this.mComponent.setTitleViewSource(this.toolbar)
            end
        end

        function setUIBlock(this,block)
            if~isempty(this.mComponent)&&isvalid(this.mComponent)
                if block
                    this.mComponent.disable;
                else
                    this.mComponent.enable;
                end
            end
        end

        function setUISleep(this,isBusy)
            if isvalid(this)
                dlg=DAStudio.ToolRoot.getOpenDialogs(this.toolbar);
                if~isempty(dlg)

                    dlg.getSource.busy=isBusy;
                    dlg.refresh;
                end
            end
        end


        function[tf,root]=isReqOrLinkSetRegistered(this,targetObj)
            [tf,root]=this.getCurrentSpreadSheetData().isReqOrLinkSetRegistered(targetObj);
        end

        function tf=canUpdateCustomAttributeFromColumn(this,attrName)



            if~any(strcmp(this.reqColumns,attrName))

                tf=false;
                return;
            end

            reqData=slreq.data.ReqData.getInstance();
            reqSetsWithThisAttr=reqData.getReqSetsThatHaveCustomAttribute(attrName);
            if~isempty(reqSetsWithThisAttr)
                for m=1:length(reqSetsWithThisAttr)
                    if this.isReqOrLinkSetRegistered(reqSetsWithThisAttr(m))


                        tf=false;
                        return;
                    end
                end
            end
            tf=true;
        end

        function resetViewSettings(this)
            this.reqColumns=slreq.app.MainManager.DefaultRequirementColumns;
            this.linkColumns=slreq.app.MainManager.DefaultLinkColumns;
            this.displayChangeInformation=slreq.app.MainManager.DefaultDisplayChangeInformation;
            this.isReqView=true;
            this.update;
        end

        function tf=isSortDisabled(this)
            sortInfo=this.SortInfo;

            tf=isempty(sortInfo.Col);
        end


        function out=getViewReqRoot(this)
            if false&&reqmgt('rmiFeature','FilteredView')


                vm=slreq.app.MainManager.getInstance.viewManager;
                dispSettings=vm.getCurrentSettings(this.sourceID,true);
                dispSettings.activate();
                out=dispSettings.getDasReqRoot();
            else

                if isempty(this.getCurrentSpreadSheetData())
                    out=slreq.das.BaseObject;
                else
                    out=this.getCurrentSpreadSheetData().reqRoot;
                end
            end
        end


        function out=getViewLinkRoot(this)
            if false&&reqmgt('rmiFeature','FilteredView')
                vm=slreq.app.MainManager.getInstance.viewManager;
                dispSettings=vm.getCurrentSettings(this.sourceID,true);
                dispSettings.activate();
                out=dispSettings.getDasLinkRoot();
            else
                if isempty(this.getCurrentSpreadSheetData())
                    out=slreq.das.BaseObject;
                else
                    out=this.getCurrentSpreadSheetData().linkRoot;
                end
            end
        end

        function expandAll(this,currentObj)
            this.mComponent.expand(currentObj,true);
        end

        function collapseAll(this,currentObj)
            this.mComponent.collapse(currentObj,true);
        end


        function restoreViewSettings(this)

            appmgr=slreq.app.MainManager.getInstance;
            viewSettings=appmgr.getViewSettingsManager.getViewSettings(this);
            if isempty(viewSettings)
                viewReqRoot=this.getViewReqRoot;
                viewLinkRoot=this.getViewLinkRoot;
                this.displayChangeInformation=slreq.app.MainManager.DefaultDisplayChangeInformation;
                if isempty(viewReqRoot.children)...
                    &&~isempty(viewLinkRoot.children)...
                    &&~isempty(viewLinkRoot.children(1).children)




                    this.isReqView=false;
                else

                    this.isReqView=true;
                end
                return;
            end

            this.setViewSettings(viewSettings);

            columns=this.Columns;

            if any(contains(columns,'Verified'))
                this.displayVerificationStatus=true;
            end

            if any(contains(columns,'Implemented'))
                this.displayImplementationStatus=true;
            end
        end

        function[reqWidth,linkWidth]=getColumnWidths(this)
            reqWidth='';
            linkWidth='';
            if isempty(this.mComponent)||~isvalid(this.mComponent)



                return;
            end
            cWidth=this.mComponent.getColumnWidths();
            if this.isReqView
                this.reqColumnWidths=cWidth;
            else
                this.linkColumnWidths=cWidth;
            end
            reqWidth=this.reqColumnWidths;
            linkWidth=this.linkColumnWidths;
        end

        function currentWidth=getCurrentColumnWidths(this)
            currentWidth='';
            if isempty(this.mComponent)||~isvalid(this.mComponent)
                return;
            end
            currentWidth=this.mComponent.getColumnWidths();
        end

        function restoreColumnWidth(this,prevColWidths)
            currentColWidth=this.getCurrentColumnWidths();
            newColWidth=slreq.app.ViewSettingsManager.revertShownColWidth(currentColWidth,prevColWidths);
            if~isempty(newColWidth)
                this.mComponent.setColumns(newColWidth);
            end
        end

        function showNotficationInMessageBanner(this,notificationId,msgId,varargin)








            msg=getString(message(msgId,varargin{:}));
            editor=this.cStudio.App.getActiveEditor;

            editor.deliverInfoNotification(notificationId,msg);
        end

        function removeNotificationBanner(this,notificationId)
            if isvalid(this.cStudio)
                editor=this.cStudio.App.getActiveEditor;
                editor.closeNotificationByMsgID(notificationId);
            end

        end
    end

    methods(Access=private)

        function pos=getSpreadsheetDockPosition(this)
            pos='Bottom';
            appmgr=slreq.app.MainManager.getInstance;
            viewSettings=appmgr.getViewSettingsManager.getViewSettings(this);
            if isfield(viewSettings,'ssDockPosition')
                pos=viewSettings.ssDockPosition;
            end
        end

        function createMComponent(this)












            studio=this.cStudio;
            this.mComponent=GLUE2.SpreadSheetComponent(studio,this.mComponentName,true);
            this.mComponent.onSelectionChange=...
            @slreq.gui.ReqSpreadSheet.handleSelectionChange;
            this.mComponent.onDrag=@slreq.gui.ReqSpreadSheet.onDrag;
            this.mComponent.onDrop=@slreq.gui.ReqSpreadSheet.onDrop;
            this.mComponent.onContextMenuRequest=...
            @slreq.gui.ReqSpreadSheet.handleContextMenuRequest;
            this.mComponent.onSortChange=...
            @(src,col,order)slreq.gui.ReqSpreadSheet.handleSortChange(src,col,order,this);
            this.mComponent.onCloseClicked=@(src)slreq.gui.ReqSpreadSheet.onCloseClicked(src);
            this.mComponent.setAcceptedMimeTypes(slreq.das.Requirement.getMimeTypes());
            studio.registerComponent(this.mComponent);
            studio.moveComponentToDock(this.mComponent,...
            getString(message('Slvnv:slreq:RequirementsSpreadsheetReqsView',get_param(this.rootModelH,'Name'))),...
            this.getSpreadsheetDockPosition,'stacked');
            this.mComponent.setDragCursor('move',slreq.gui.IconRegistry.instance.reqDragIconMoving);
            this.mComponent.setDragCursor('copy',slreq.gui.IconRegistry.instance.reqDragIconLinking);

            this.registerStudioListener();
        end


        function handleWindowActivated(this,~)
            app=slreq.app.MainManager.getInstance;
            app.setLastOperatedView(this);
        end

        function handleEditorChanged(this,varargin)
















            studio=this.getStudio();
            studioHelper=slreq.utils.DAStudioHelper.createHelper(studio);
            currentActiveModel=studioHelper.ActiveModelHandle;
            currentActiveModel=rmisl.getOwnerModelFromHarness(currentActiveModel);
            if this.getCurrentModelH~=currentActiveModel


                this.currentModelH=currentActiveModel;
                appmgr=slreq.app.MainManager.getInstance;
                spreadsheetDataManager=appmgr.spreadSheetDataManager;
                spreadsheetDataManager.getOrCreateDataObj(currentActiveModel);
                this.addModelHToInSpreadsheet(currentActiveModel);
                this.mComponent.setSource(this.getViewData());

                this.clearCurrentObj([],true);

                this.setTitleBar();
                this.update;

                badgeManager=appmgr.badgeManager;

                if~badgeManager.getStatus(currentActiveModel)

                    badgeManager.enableBadges(currentActiveModel);
                end


                mmgr=appmgr.markupManager;
                mmgr.showMarkupsAndConnectorsForModelIfNeeded(currentActiveModel);
            end
        end

        function setTitleBar(this)
            this.toolbar=slreq.gui.ReqSpreadSheetMenu(this);
            this.mComponent.setTitleViewSource(this.toolbar);
        end


        function setTitle(this)
            modelName=get_param(this.getCurrentModelH,'Name');
            if this.isReqView
                title=getString(message('Slvnv:slreq:RequirementsSpreadsheetReqsView',modelName));
            else
                title=getString(message('Slvnv:slreq:RequirementsSpreadsheetLinksView',modelName));
            end

            if reqmgt('rmiFeature','FilteredView')
                app=slreq.app.MainManager.getInstance;
                vm=app.viewManager;
                if~vm.isVanillaActive()
                    title=[title,' | Filter: ',app.viewManager.getCurrentView.getLabel(false)];
                end
            end

            if isvalid(this.mComponent)
                this.mComponent.setTitle(title);
                this.mComponent.setMinimizeTabTitle(title);
            end
        end


        function out=getViewData(this)

            if this.isReqView
                out=this.getViewReqRoot;
            else
                out=this.getViewLinkRoot;
            end
        end


        function out=getCurrentSpreadSheetData(this)

            appmgr=slreq.app.MainManager.getInstance;
            spreadSheetDataManager=appmgr.spreadSheetDataManager;
            out=spreadSheetDataManager.getSpreadSheetDataObject(this.getCurrentModelH);
        end


        function out=getStudioRootData(this)

            appmgr=slreq.app.MainManager.getInstance;
            spreadSheetDataManager=appmgr.spreadSheetDataManager;
            out=spreadSheetDataManager.getSpreadSheetDataObject(this.rootModelH);
        end


        function setSortInfo(this,col,order)
            if this.isUnifiedViewAcrossModels
                this.getStudioRootData().setSortInfo(col,order,this.isReqView);
            else
                this.getCurrentSpreadSheetData().setSortInfo(col,order);
            end
        end


        function setViewSettings(this,viewSettings)
            if this.isUnifiedViewAcrossModels
                currentData=this.getStudioRootData();
            else
                currentData=this.getCurrentSpreadSheetData();
            end
            if currentData.isReqView~=viewSettings.isReqView
                this.switchView();
            end
            currentData.isReqView=viewSettings.isReqView;
            currentData.reqColumns=viewSettings.reqColumns;
            currentData.linkColumns=viewSettings.linkColumns;

            currentData.reqSortInfo=viewSettings.reqSortInfo;
            currentData.linkSortInfo=viewSettings.linkSortInfo;
            if isfield(viewSettings,'displayChangeInformation')
                currentData.displayChangeInformation=viewSettings.displayChangeInformation;
                this.displayChangeInformation=viewSettings.displayChangeInformation;
            end
            hasJSONColumSetting=false;
            if isfield(viewSettings,'reqColumnWidths')...
                &&~isempty(viewSettings.reqColumnWidths)
                hasJSONColumSetting=true;
                this.reqColumnWidths=viewSettings.reqColumnWidths;
            end

            if isfield(viewSettings,'linkColumnWidths')...
                &&~isempty(viewSettings.linkColumnWidths)
                hasJSONColumSetting=true;
                this.linkColumnWidths=viewSettings.linkColumnWidths;
            end


            if isempty(this.mComponent)
                return;
            end
            this.mComponent.setColumns(this.Columns,this.SortInfo.Col,'',this.SortInfo.Order);
            if hasJSONColumSetting
                if viewSettings.isReqView&&~isempty(this.reqColumnWidths)
                    this.mComponent.setColumns(this.reqColumnWidths);
                end
                if~viewSettings.isReqView&&~isempty(this.linkColumnWidths)
                    this.mComponent.setColumns(this.linkColumnWidths);
                end
            end
        end


    end

    methods(Static)
        function result=handleSelectionChange(comp,sels)
            result=false;

            appmgr=slreq.app.MainManager.getInstance();
            sp=appmgr.spreadsheetManager.getSpreadSheetObject(comp.getStudio.App.blockDiagramHandle);

            if isempty(sp)
                return;
            end

            if isempty(sels)

                eventData=slreq.gui.ReqSpreadSheetSelectionChanged();
                eventData.selection=sels;
                sp.notifyObservers('SelectionChanged',eventData);
                return;
            else
                [sp.currentSelectedObj,sp.selectionStatus]=slreq.gui.SelectionStatus.getCurrentSelectionAndType(sels);



                oDlgs=DAStudio.ToolRoot.getOpenDialogs(sels{end});
                slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(oDlgs);
            end

            sp.addSelectedObjToMap(sp.currentSelectedObj);


            appmgr.setSelectedObject(sp.currentSelectedObj);
            if slreq.gui.SelectionStatus.isDragNDropLinkingAllowed(sp)


                sp.currentSelectedObj(1).updateMimeData(sp.currentSelectedObj);
                if numel(sp.currentSelectedObj)>1
                    for n=2:numel(sp.currentSelectedObj)
                        sp.currentSelectedObj(n).updateMimeData([]);
                    end
                end
                sp.mComponent.setMimeInfo(sp.currentSelectedObj(1),slreq.das.Requirement.getMimeType(sp.getStudio()),sp.currentSelectedObj(1).mimeData);
            end
            sp.mComponent.updateTitleView();

            eventData=slreq.gui.ReqSpreadSheetSelectionChanged();
            eventData.selection=sels;
            sp.notifyObservers('SelectionChanged',eventData);
            result=true;
        end

        function result=handleTabChange(comp,sels)%#ok<INUSD>
            result=true;
        end

        function allow=onDrag(comp,source,destination,location,action)%#ok<INUSL>
            appmgr=slreq.app.MainManager.getInstance();
            allow=appmgr.callbackHandler.onDrag(source,destination,location,action);
        end

        function onDrop(comp,source,destination,location,action)%#ok<INUSL>
            appmgr=slreq.app.MainManager.getInstance();
            appmgr.callbackHandler.onDrop(source,destination,location,action);
        end

        function onCloseClicked(comp)
            appmgr=slreq.app.MainManager.getInstance();
            sp=appmgr.spreadsheetManager.getSpreadSheetObject(comp.getStudio.App.blockDiagramHandle);
            appmgr.hideDeferredAnalysisNotifications(sp);

            eventData=slreq.gui.ReqSpreadSheetToggled();
            eventData.modelH=sp.rootModelH;
            eventData.state=false;
            eventData.studio=sp.getStudio();
            sp.notifyObservers('BrowserToggled',eventData)
        end


        function result=handleContextMenuRequest(comp,sel)


            appmgr=slreq.app.MainManager.getInstance();
            studioHelper=slreq.utils.DAStudioHelper.createHelper(comp.getStudio);
            sp=appmgr.spreadsheetManager.getSpreadSheetObject(studioHelper.TopModelHandle);


            appmgr.setSelectedObject(sel);


            menu=DAStudio.UI.Widgets.Menu;
            [~,~,currentBDRoot]=slreq.utils.DAStudioHelper.getCurrentBDHandle();


            menuItem=sel.getContextMenuItems(get_param(currentBDRoot,'Handle'));
            result=slreq.gui.ContextMenuBuilder.createActions(menuItem);
        end


        function handleSortChange(~,col,order,this)




            this.setSortInfo(col,order);
            this.update;
        end


        function generateTraceDiagram(selectedItem)
            dataObj=selectedItem.dataModelObj;
            slreq.internal.tracediagram.utils.generateTraceDiagram(dataObj);
        end


        function openPropertyInspector()
            bdrootHandle=slreq.utils.DAStudioHelper.getCurrentBDHandle();
            editor=rmisl.modelEditors(bdrootHandle,true);
            studio=editor.getStudio;
            pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            if~pi.isVisible
                studio.showComponent(pi);
                mgr=slreq.app.MainManager.getInstance;
                view=mgr.getCurrentView;


                if~isempty(view)&&isvalid(view)
                    currentObj=view.getCurrentSelection();
                    if~isempty(currentObj)
                        pi.updateSource('GLUE2:PropertyInspector',currentObj);
                    end
                end
            end
        end




        function removeReqSetFromLinkSet()


            mgr=slreq.app.MainManager.getInstance;
            spObj=mgr.getCurrentView;
            if~isempty(spObj)
                reqSetDas=spObj.getCurrentSelection();
                if isa(reqSetDas,'slreq.das.RequirementSet')
                    reqSet=reqSetDas.dataModelObj;
                    r=slreq.data.ReqData.getInstance;
                    modelFileName=get_param(spObj.getCurrentModelH,'FileName');
                    linkSet=r.getLinkSet(modelFileName);


                    if slreq.utils.removeReqSetFromLinkSet(reqSet,linkSet)

                        spObj.removeReqLinkSetFromSpreadSheet(reqSetDas);
                        spObj.update;
                    end
                end
            end
        end
    end
end
