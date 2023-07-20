classdef DataEventsWidget<handle


    properties(Hidden)
App
BlockHandle
Component
DataModel
DataProvider
ModelHandle
addMenu
menuItems
    end

    properties(Access=private)
        deadlineTimeErrorID='';
    end

    properties(Hidden,Constant)
        AddIconPath='toolbox/simulink/record_playback/icons/ToolStrip/add-16px.png'
        DeleteIconPath='toolbox/simulink/record_playback/icons/ToolStrip/delete2-16px.png'
        ScheduleEditorIconPath='toolbox/simulink/core/general/+Simulink/+STOSpreadSheet/icon/SchedulingEditor_16.png'
        NumColumns=3
        maxInputEvents=3;
    end

    methods

        function this=DataEventsWidget(blockHandle)
            this.BlockHandle=blockHandle;
            this.ModelHandle=bdroot(this.BlockHandle);
            if~isempty(this.BlockHandle)

                this.App=mdom.App;
                this.App.beginTransaction();
                this.DataProvider=Simulink.DataEvents.internal.Widget.DataEventsWidgetDataProvider(...
                this.BlockHandle,this.ModelHandle);
                this.DataModel=mdom.DataModel(this.DataProvider);


                msg='Invalid input specified. Timeout should be a positive number';
                n=this.App.createNotification(struct('tag','deadlineTimeError','message',msg));

                this.deadlineTimeErrorID=n.UUID;
                this.DataProvider.deadlineTimeErrorID=this.deadlineTimeErrorID;


                this.populateLayout();


                this.App.endTransaction();
                this.App.start();
            end
        end


        function populateLayout(this)

            panel=this.App.createWidget('mdom.Group',struct('title',...
            message('SimulinkPartitioning:DataEvents:InputEvents').getString()));
            layout=this.App.createWidget('mdom.GridLayout');
            panel.layout=layout;
            layout.setColumnStretch(1,0);
            layout.setColumnStretch(2,0);
            layout.setColumnStretch(3,0);
            layout.setColumnStretch(4,0);
            layout.setColumnStretch(5,5);

            layout.setRowStretch(1,0);
            layout.setRowStretch(2,1);


            addButton=this.App.createWidget('mdom.Button',...
            struct('tag','AddButton',...
            'enabled',true,...
            'icon',connector.getBaseUrl(this.AddIconPath),...
            'tooltip',message('SimulinkPartitioning:DataEvents:AddButtonTT').getString()));

            addButton.onClick.registerHandler(...
            @(w,e)this.handleAddCB(w,e));


            this.addMenu=this.App.createWidget('mdom.ContextMenu');
            this.addMenu.tag='addMenu';


            this.menuItems={};
            this.menuItems{1}=this.App.createWidget('mdom.MenuItem');
            this.menuItems{1}.label=message('SimulinkPartitioning:DataEvents:InputWrite').getString();
            this.menuItems{1}.onInvoke.registerHandler(@(w,e)this.handleMenuItemClick(w,e));


            this.menuItems{2}=this.App.createWidget('mdom.MenuItem');
            this.menuItems{2}.label=message('SimulinkPartitioning:DataEvents:InputWriteLost').getString();
            this.menuItems{2}.onInvoke.registerHandler(@(w,e)this.handleMenuItemClick(w,e));


            this.menuItems{3}=this.App.createWidget('mdom.MenuItem');
            this.menuItems{3}.label=message('SimulinkPartitioning:DataEvents:InputWriteTimeout').getString();
            this.menuItems{3}.onInvoke.registerHandler(@(w,e)this.handleMenuItemClick(w,e));


            deleteButton=this.App.createWidget('mdom.Button',...
            struct('tag','DeleteButton',...
            'enabled',false,...
            'icon',connector.getBaseUrl(this.DeleteIconPath),...
            'tooltip',message('SimulinkPartitioning:DataEvents:DeleteButtonTT').getString()));
            deleteButton.onClick.registerHandler(...
            @(w,e)this.handleDeleteCB(w,e));


            scheduleEditorButton=this.App.createWidget('mdom.Button',...
            struct('tag','ScheduleButton',...
            'enabled',true,...
            'icon',connector.getBaseUrl(this.ScheduleEditorIconPath),...
            'tooltip',message('SimulinkPartitioning:DataEvents:ScheduleButtonTT').getString()));
            scheduleEditorButton.onClick.registerHandler(...
            @(w,e)this.handleScheduleEditorCB(w,e));


            inputEventsTable=this.App.createWidget('mdom.TreeTable',...
            struct('tag','InputEventsTable',...
            'dataModel',this.DataModel.getID(),...
            'selectionMode',mdom.SelectionMode.Single,...
            'sortEnabled',true));
            inputEventsTable.onCellFocused.registerHandler(...
            @(w,e)this.updateDeleteBtn(w,e));


            layout.addItem(addButton,1,1,1,1);
            layout.addItem(deleteButton,1,2,1,1);
            layout.addItem(scheduleEditorButton,1,3,1,1);
            layout.addItem(inputEventsTable,2,1,1,5);
        end


        function show(this)
            this.DataProvider.updateInfo;
            this.DataModel.refreshView;


            this.DataModel.columnChanged(this.NumColumns,{});


            numInputEvents=length(get_param(this.BlockHandle,'EventTriggers'));
            this.DataModel.rowChanged('',numInputEvents,{});

            this.updateAddBtn;
        end


        function id=getDataModelID(this)
            id=this.DataModel.getID;
        end

        function url=getUrl(obj,debug)
            if(debug)
                url=connector.getUrl(obj.App.getUrl());
            else
                url=connector.getUrl(obj.App.getUrl('toolbox/mdom/app/index.html',false));
            end
        end

        function handleMenuItemClick(this,widget,~)







            eventTrigger=strrep(widget.label,' ','');
            blockEvents=get_param(this.BlockHandle,'EventTriggers');
            tmpEvent=strcat('simulink.event.',eventTrigger,'()');
            tmpEvent=eval(tmpEvent);
            tmpEvent.EventName='Auto';
            blockEvents{end+1}=tmpEvent;
            set_param(this.BlockHandle,'EventTriggers',blockEvents);

            this.show;
        end
    end

    methods(Access=private)


        function handleAddCB(this,~,~)
            if(length(get_param(this.BlockHandle,'EventTriggers'))<this.maxInputEvents)


                mdomApp=this.App;
                mdomApp.beginTransaction();

                inputEvents=["simulink.event.InputWrite";...
                "simulink.event.InputWriteLost";...
                "simulink.event.InputWriteTimeout"];


                for j=1:length(inputEvents)
                    this.addMenu.appendMenuItem(this.menuItems{j});
                end


                blockEvents=get_param(this.BlockHandle,'EventTriggers');
                if(~isempty(blockEvents))

                    for i=1:length(blockEvents)
                        for j=1:length(inputEvents)
                            if(isa(blockEvents{i},inputEvents(j)))
                                this.addMenu.removeMenuItem(this.menuItems{j});
                            end
                        end
                    end
                end

                mdomApp.endTransaction();

                mdomApp.showContextMenu(this.addMenu.UUID);
            else
                this.updateAddBtn;
            end
        end


        function updateAddBtn(this)
            addBtn=this.App.findByTag('AddButton');
            addBtn.enabled=(length(get_param(this.BlockHandle,'EventTriggers'))<this.maxInputEvents);
        end

        function handleScheduleEditorCB(this,~,~)
            editor=sltp.internal.ScheduleEditorManager.getEditor(this.ModelHandle);
            editor.show();
        end


        function handleDeleteCB(this,~,~)
            inputEventsTable=this.App.findByTag('InputEventsTable');
            rowID=inputEventsTable.selectedRange.toArray.row+1;


            blockEvents=get_param(this.BlockHandle,'EventTriggers');
            blockEvents(rowID)=[];
            set_param(this.BlockHandle,'EventTriggers',blockEvents);


            delBtn=this.App.findByTag('DeleteButton');
            delBtn.enabled=false;


            this.DataProvider.updateInfo;
            this.DataModel.refreshView;

            this.show;
        end


        function updateDeleteBtn(this,~,event)
            delBtn=this.App.findByTag('DeleteButton');
            delBtn.enabled=~isempty(event.cell.rowID);
        end
    end
end
