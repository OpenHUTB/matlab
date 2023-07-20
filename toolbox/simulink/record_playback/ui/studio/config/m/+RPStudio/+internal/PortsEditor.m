classdef PortsEditor<handle

    properties(Hidden)
App
BlockHandle
Component
DataModel
DataProvider
Editor
EditorCallbacks
Listeners
    end

    properties(Hidden,Constant)
        AddIconPath='toolbox/simulink/record_playback/icons/ToolStrip/add-16px.png'
        DeleteIconPath='toolbox/simulink/record_playback/icons/ToolStrip/delete2-16px.png'
        ClearFilterIconPath='toolbox/simulink/record_playback/icons/ToolStrip/clear-filter-16px.png'
        NumColumns=8
    end

    methods

        function this=PortsEditor(blockHandle,editor)
            this.BlockHandle=blockHandle;
            this.Editor=editor;
            if~isempty(this.BlockHandle)&&strcmp(get_param(...
                this.BlockHandle,'BlockType'),'Playback')

                this.App=mdom.App;
                this.App.beginTransaction();
                this.DataProvider=RPStudio.internal.PortsEditorDataProvider(...
                this.BlockHandle);
                this.DataModel=mdom.DataModel(this.DataProvider);


                this.populateLayout();


                this.App.endTransaction();
                this.App.start();
            end
        end


        function populateLayout(this)

            panel=this.App.createWidget('mdom.Panel');
            layout=this.App.createWidget('mdom.GridLayout');
            panel.layout=layout;
            layout.setColumnStretch(1,0);
            layout.setColumnStretch(2,1);
            layout.setColumnStretch(3,0);
            layout.setColumnStretch(4,0);
            layout.setColumnStretch(5,5);
            layout.setColumnStretch(6,2);
            layout.setColumnStretch(7,0);
            layout.setRowStretch(1,0);
            layout.setRowStretch(2,1);


            numPortsLabelText=DAStudio.message(...
            'record_playback:dialogs:NumPortsLabel');
            numPortsLabel=this.App.createWidget('mdom.Text',...
            struct('tag','NumPortsLabel',...
            'text',numPortsLabelText));


            numPortsEditor=this.App.createWidget('mdom.Edit',...
            struct('tag','NumPortsEditor',...
            'clearable',true));
            numPortsEditor.onEditFinish.registerHandler(...
            @(w,e)this.handleNumPortsCB(w,e));


            addBtnLabel=DAStudio.message(...
            'record_playback:dialogs:AddPortLabel');
            addButton=this.App.createWidget('mdom.Button',...
            struct('tag','AddButton',...
            'enabled',false,...
            'label',addBtnLabel,...
            'icon',connector.getBaseUrl(this.AddIconPath)));
            addButton.onClick.registerHandler(...
            @(w,e)this.handleAddCB(w,e));


            delBtnLabel=DAStudio.message(...
            'record_playback:dialogs:DeletePortLabel');
            deleteButton=this.App.createWidget('mdom.Button',...
            struct('tag','DeleteButton',...
            'enabled',false,...
            'label',delBtnLabel,...
            'icon',connector.getBaseUrl(this.DeleteIconPath)));
            deleteButton.onClick.registerHandler(...
            @(w,e)this.handleDeleteCB(w,e));


            filterPlaceholder=DAStudio.message(...
            'record_playback:dialogs:FilterPlaceholder');
            filterEditor=this.App.createWidget('mdom.Edit',...
            struct('tag','FilterEditor',...
            'clearable',true,...
            'placeholder',filterPlaceholder));
            filterEditor.onEdit.registerHandler(...
            @(w,e)this.handleFilterCB(w,e));


            clearFilterLabel=DAStudio.message(...
            'record_playback:dialogs:ClearFilterLabel');
            clearFilterBtn=this.App.createWidget('mdom.Button',...
            struct('tag','ClearFilter',...
            'tooltip',clearFilterLabel,...
            'enabled',false,...
            'icon',connector.getBaseUrl(this.ClearFilterIconPath)));
            clearFilterBtn.onClick.registerHandler(...
            @(w,e)this.handleClearFilterCB(w,e));


            portTable=this.App.createWidget('mdom.TreeTable',...
            struct('tag','PortTable',...
            'dataModel',this.DataModel.getID(),...
            'selectionMode',mdom.SelectionMode.Multiple,...
            'sortEnabled',true));
            portTable.onCellFocused.registerHandler(...
            @(w,e)this.updateDeleteBtn(w,e));


            layout.addItem(numPortsLabel,1,1,1,1);
            layout.addItem(numPortsEditor,1,2,1,1);
            layout.addItem(addButton,1,3,1,1);
            layout.addItem(deleteButton,1,4,1,1);
            layout.addItem(filterEditor,1,6,1,1);
            layout.addItem(clearFilterBtn,1,7,1,1);
            layout.addItem(portTable,2,1,1,8);
        end


        function show(this)

            this.DataModel.columnChanged(this.NumColumns,{});


            numPorts=get_param(this.BlockHandle,'NumPorts');
            this.DataModel.rowChanged('',numPorts,{});


            numPortsEditor=this.App.findByTag('NumPortsEditor');
            numPortsEditor.text=num2str(numPorts);


            this.updateAddBtn(numPorts);

            url=this.App.getUrl('toolbox/mdom/web/index.html',true);

            this.openInDockedDDG(url);

        end


        function hide(this)
            if~isempty(this.Editor)&&isvalid(this.Editor)
                studio=this.Editor.getStudio();
                componentName=this.getTitle();
                this.Component=studio.getComponent(...
                'GLUE2:DDG Component',componentName);
                if~isempty(this.Component)
                    studio.hideComponent(this.Component);
                end
            end
        end


        function id=getDataModelID(this)
            id=this.DataModel.getID;
        end
    end

    methods(Access=private)

        function handleNumPortsCB(this,target,event)
            try
                set_param(this.BlockHandle,'NumPorts',str2double(event.text));
            catch me
                sldiagviewer.reportError(me);
                numPorts=get_param(this.BlockHandle,'NumPorts');
                target.text=num2str(numPorts);
            end
        end


        function handleAddCB(this,~,~)
            numPorts=get_param(this.BlockHandle,'NumPorts');
            set_param(this.BlockHandle,'NumPorts',numPorts+1);
        end


        function updateAddBtn(this,numPorts)
            addBtn=this.App.findByTag('AddButton');
            addBtn.enabled=~(numPorts>=100);
        end


        function handleDeleteCB(this,~,~)
            portTable=this.App.findByTag('PortTable');
            selectedRange=portTable.selectedRange.toArray;
            len=length(selectedRange);
            portIndices=double.empty(0,len);
            for idx=1:len
                portNum=this.DataProvider.getCellData(...
                selectedRange(idx).row,0);
                portIndices(idx)=str2double(portNum);
            end
            if~isempty(portIndices)
                Simulink.playback.internal.deletePorts(...
                this.BlockHandle,portIndices);

                this.App.beginTransaction();
                portTable.selectedRange.clear;
                this.App.endTransaction();
                delBtn=this.App.findByTag('DeleteButton');
                delBtn.enabled=false;
            end
        end


        function updateDeleteBtn(this,~,event)
            delBtn=this.App.findByTag('DeleteButton');
            delBtn.enabled=~isempty(event.cell.rowID);
        end


        function handleFilterCB(this,~,event)
            clearFilterBtn=this.App.findByTag('ClearFilter');
            criteria.value=event.text;

            if isempty(criteria.value)
                clearFilterBtn.enabled=false;
            else
                clearFilterBtn.enabled=true;
            end
            this.DataProvider.onFilterRequest(jsonencode(criteria));
        end


        function handleClearFilterCB(this,target,~)
            criteria.value='';
            filterEditor=this.App.findByTag('FilterEditor');
            filterEditor.text=criteria.value;
            target.enabled=false;
            this.DataProvider.onFilterRequest(jsonencode(criteria));
        end


        function openInDockedDDG(this,url)
            ddgHost=RPStudio.internal.ddgHost(url);


            if~isempty(this.Editor)&&isvalid(this.Editor)
                studio=this.Editor.getStudio();
                componentName=this.getTitle();
                this.Component=studio.getComponent(...
                'GLUE2:DDG Component',componentName);


                if isempty(this.Component)||~isvalid(this.Component)
                    this.Component=GLUE2.DDGComponent(studio,...
                    componentName,ddgHost);
                    this.Component.DestroyOnHide=true;
                    studio.registerComponent(this.Component);


                    this.addListeners(studio);
                end


                studio.moveComponentToDock(this.Component,componentName,...
                'Bottom','Tabbed');


                this.fastRestartChanged();
            end
        end


        function title=getTitle(this)
            portEditorLabel=DAStudio.message(...
            'record_playback:dialogs:PortEditorLabel');
            title=[portEditorLabel,': ',getfullname(this.BlockHandle)];
        end


        function toggleView(this,enableFlag)
            if~isempty(this.Component)&&isvalid(this.Component)
                mdl=bdroot(this.BlockHandle);
                isSimulating=false;
                if~strcmp(get_param(mdl,'simulationStatus'),'stopped')...
                    &&get_param(mdl,'InteractiveSimInterfaceExecutionStatus')~=2

                    isSimulating=true;
                end
                isBuilding=strcmp(get_param(mdl,'BuildInProgress'),'on');
                if enableFlag&&~isSimulating&&~isBuilding
                    this.Component.enable;
                else
                    this.Component.disable;
                end
            end
        end


        function addListeners(this,studio)

            this.Listeners{end+1}=addlistener(this.Component,...
            'ObjectBeingDestroyed',@(~,~)this.deleteListeners);


            if isempty(this.EditorCallbacks)
                service=studio.getService('GLUE2:EditorClosed');
                this.EditorCallbacks(1)=service.registerServiceCallback(...
                @this.editorClosedCB);

                service=studio.getService('GLUE2:ActiveEditorChanged');
                this.EditorCallbacks(2)=service.registerServiceCallback(...
                @(e)this.activeEditorChangedCB);
            end


            config=[];
            config.BlockId=get_param(this.BlockHandle,'BlockId');
            mainApp=Simulink.playback.mainApp.getController(...
            config);
            this.Listeners{end+1}=addlistener(mainApp,...
            'UpdatePortEditor',@this.updateView);


            this.Listeners{end+1}=Simulink.listener(this.BlockHandle,...
            'NameChangeEvent',@(~,~)locNameChanged(this));


            cosObj=get_param(bdroot(this.BlockHandle),'InternalObject');
            this.Listeners{end+1}=addlistener(cosObj,...
            'SLExecEvent::SIMSTATUS_RUNNING',...
            @(~,~)this.toggleView(0));
            this.Listeners{end+1}=addlistener(cosObj,...
            'SLExecEvent::SIMSTATUS_COMPILED',...
            @(~,~)this.toggleView(0));
            this.Listeners{end+1}=addlistener(cosObj,...
            'SLExecEvent::SIMSTATUS_EXTERNAL',...
            @(~,~)this.toggleView(0));
            this.Listeners{end+1}=addlistener(cosObj,...
            'SLExecEvent::SIMSTATUS_STOPPED',...
            @(~,~)this.toggleView(1));
        end


        function editorClosedCB(this,cbInfo)
            if~isempty(this.Editor)&&isvalid(this.Editor)&&...
                strcmp(this.Editor.ID,cbInfo.EventData.ID)
                studio=this.Editor.getStudio();
                if~isempty(this.Component)&&isvalid(this.Component)
                    studio.destroyComponent(this.Component);
                end
            end
        end


        function activeEditorChangedCB(this)
            if~isempty(this.Editor)&&isvalid(this.Editor)...
                &&~this.Editor.isVisible
                studio=this.Editor.getStudio();
                if~isempty(this.Component)&&isvalid(this.Component)
                    studio.destroyComponent(this.Component);
                end
            end
        end


        function updateView(this,~,~)
            numPorts=get_param(this.BlockHandle,'NumPorts');
            oldSize=length(this.DataProvider.DataArray);
            this.DataProvider.updateInfo;
            newSize=length(this.DataProvider.DataArray);
            if oldSize~=newSize
                this.DataModel.rowChanged('',numPorts,{});
            end
            this.DataModel.refreshView;

            filterEditor=this.App.findByTag('FilterEditor');
            if~isempty(filterEditor.text)
                criteria.value=filterEditor.text;
                this.DataProvider.onFilterRequest(jsonencode(criteria));
            end

            if~isempty(this.DataProvider.SortInfo)
                sortOption=struct;
                sortOption.columnIndex=this.DataProvider.SortInfo.column;
                sortOption.order=upper(this.DataProvider.SortInfo.order);
                this.DataProvider.onSortRequest(jsonencode(sortOption));
            end

            numPortsEditor=this.App.findByTag('NumPortsEditor');
            numPortsEditor.text=num2str(numPorts);

            this.updateAddBtn(numPorts);

            if~numPorts
                delBtn=this.App.findByTag('DeleteButton');
                delBtn.enabled=false;
            end
        end


        function fastRestartChanged(this)
            mdl=bdroot(this.BlockHandle);

            isFastRestartInitialized=get_param(mdl,...
            'InteractiveSimInterfaceExecutionStatus')==2;
            this.toggleView(~isFastRestartInitialized);
        end


        function locNameChanged(this)
            if~isempty(this.Editor)&&isvalid(this.Editor)
                studio=this.Editor.getStudio();
                if~isempty(this.Component)&&isvalid(this.Component)
                    componentName=this.getTitle();
                    studio.setDockComponentTitle(this.Component,componentName);
                end
            end
        end


        function deleteListeners(this)
            for n=1:length(this.Listeners)
                delete(this.Listeners{n});
            end
            this.Listeners={};
            if~isempty(this.Editor)&&isvalid(this.Editor)
                studio=this.Editor.getStudio();
                service=studio.getService('GLUE2:EditorClosed');
                service.unRegisterServiceCallback(this.EditorCallbacks(1));
                service=studio.getService('GLUE2:ActiveEditorChanged');
                service.unRegisterServiceCallback(this.EditorCallbacks(2));
                this.EditorCallbacks=[];
            end

            try
                set_param(this.BlockHandle,'PortEditorStatus','Off');
            catch

            end
        end

    end

end