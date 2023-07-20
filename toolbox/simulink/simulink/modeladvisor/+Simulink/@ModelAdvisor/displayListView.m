function displayListView(this,ListViewParameterStruct,varargin)





    persistent me;
    persistent melistener;%#ok<PUSE>
    persistent c;


    if this.NOBROWSER
        return
    end


    if isempty(ListViewParameterStruct.Data)
        warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MANoItemToDispaly'));
        set(warndlgHandle,'Tag','MANoItemToDisplay');
        return
    end

    if nargin>2
        TaskObj=varargin{1};
    else
        TaskObj=[];
    end

    if nargin>3
        reuseMode=varargin{2};
    else
        reuseMode=false;
    end


    if~isa(ListViewParameterStruct,'ModelAdvisor.ListViewParameter')
        if~isfield(ListViewParameterStruct,'Attributes')||~isfield(ListViewParameterStruct,'Data')
            DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.ListViewParameter object');
        end
    end


    if iscell(ListViewParameterStruct.Data)
        cacheObj=[];
        for i=1:length(ListViewParameterStruct.Data)
            currentObj=ListViewParameterStruct.Data{i};
            if isa(currentObj,'DAStudio.Object')||isa(currentObj,'Simulink.DABaseObject')
                cacheObj=[cacheObj,currentObj];%#ok<AGROW>
            elseif ishandle(currentObj)
                cacheObj=[cacheObj,get_param(currentObj,'object')];%#ok<AGROW>
            else
                MSLDiagnostic('Simulink:tools:MAUnsupportDataType').reportAsWarning;
                return
            end
        end
        ListViewParameterStruct.Data=cacheObj;
    end


    if~isa(ListViewParameterStruct.Data,'DAStudio.Object')&&(~isa(ListViewParameterStruct.Data,'Simulink.DABaseObject')||any(~isvalid(ListViewParameterStruct.Data)))
        DAStudio.error('ModelAdvisor:engine:ListViewDataOutofDate');
    end


    if~isa(me,'DAStudio.Explorer')
        me=daexplore(ListViewParameterStruct.Data,ListViewParameterStruct.Attributes,false);

        if isa(this.MAExplorer,'DAStudio.Explorer')
            me.position=this.MAExplorer.position;
        else
            screenSize=get(0,'ScreenSize');
            height=screenSize(4);
            width=screenSize(3);
            height=floor(height/1.5);
            width=floor(width/1.5);
            me.position=[0,0,width,height];
        end
    else
        if~reuseMode
            oldposition=me.position;
            event.type='MEPostHide';
            closeMECallback(me,event);
            me.delete;
            me=daexplore(ListViewParameterStruct.Data,ListViewParameterStruct.Attributes,false);
            me.position=oldposition;
        else
            event.type='MEPostHide';
            closeMECallback(me,event);
            daexplore(ListViewParameterStruct.Data,ListViewParameterStruct.Attributes,false,me);
        end
    end

    if~reuseMode

        am=DAStudio.ActionManager;
        tb=am.createToolBar(me);

        filterText=am.createToolBarText(tb);
        filterText.setText([DAStudio.message('Simulink:tools:MAShow'),': ']);
        selectComboBox=am.createToolBarComboBox(tb);

        currentItemIndex=0;
        if isa(TaskObj,'ModelAdvisor.Task')
            checkObj=TaskObj.MAObj.CheckCellArray{TaskObj.MACindex};
            pulldownList={};
            for i=1:length(checkObj.ListViewParameters)
                if strcmp(checkObj.ListViewParameters{i}.Name,ListViewParameterStruct.Name)
                    currentItemIndex=i-1;
                end
                pulldownList{end+1}=checkObj.ListViewParameters{i}.Name;%#ok<AGROW>
            end
        else
            pulldownList={ListViewParameterStruct.Name};
        end
        selectComboBox.insertItems(0,pulldownList);
        selectComboBox.setCurrentItem(currentItemIndex);

        schema.prop(selectComboBox,'Listener','handle');
        selectComboBox.Listener=handle.listener(selectComboBox,'SelectionChangedEvent',{@doFilterSelectionChanged,TaskObj});
        tb.addWidget(filterText);
        tb.addWidget(selectComboBox);

        t=am.createToolBarText(tb);
        t.setText(['  ',DAStudio.message('Simulink:tools:MAFor'),': ']);
        c=am.createToolBarComboBox(tb);
        c.insertItems(0,{DAStudio.message('Simulink:tools:MACurrentSystem'),DAStudio.message('Simulink:tools:MACurrentSystemAndBelow')});
        c.setCurrentItem(1);

        schema.prop(c,'Listener','handle');
        c.Listener=handle.listener(c,'SelectionChangedEvent',{@doSelectionChanged,me});

        tb.addWidget(t);
        tb.addWidget(c);

        if isa(this.MAExplorer,'DAStudio.Explorer')
            if isnumeric(this.MAExplorer.position)&&length(this.MAExplorer.position)==4
                me.position=[this.MAExplorer.position(1)+25,this.MAExplorer.position(2)+25,this.MAExplorer.position(3),this.MAExplorer.position(4)];
            else
                me.position=this.MAExplorer.position;
            end
        end

        event.type='SetActiveTaskObj';
        event.TaskObj=TaskObj;
        closeMECallback(me,event);
        melistener=handle.listener(me,'MEPostHide',{@closeMECallback});

        me.showTreeView(true);
        me.show;
        this.ListExplorer=me;
    end



    rootObj=me.getRoot;
    if isprop(rootObj,'Recursive')
        c.setEnabled(true);
    else
        c.setEnabled(false);
    end

    if isprop(ListViewParameterStruct,'Name')
        me.Title=[DAStudio.message('ModelAdvisor:engine:MAResultExplorer'),' - ',ListViewParameterStruct.Name];
    else
        me.Title=DAStudio.message('ModelAdvisor:engine:MAResultExplorer');
    end



    function closeMECallback(this,event)%#ok<INUSL>
        persistent activeTaskObj;
        switch(event.type)
        case 'MEPostHide'

            if isa(activeTaskObj,'ModelAdvisor.Node')
                if~isempty(activeTaskObj.MAObj.CheckCellArray{activeTaskObj.MACindex}.ListViewCloseCallback)
                    activeTaskObj.MAObj.CheckCellArray{activeTaskObj.MACindex}.ListViewCloseCallback(activeTaskObj);
                end
            end
        case 'SetActiveTaskObj'
            activeTaskObj=event.TaskObj;
        otherwise
            DAStudio.error('Simulink:tools:MAUnknownEventReceived');
        end


        function doSelectionChanged(this,event,me)%#ok<INUSL>
            recursive=true;
            if event.index==0
                recursive=false;
            end

            me.Recursive=recursive;

            function doFilterSelectionChanged(h,event,TaskObj)%#ok<INUSL>
                checkObj=TaskObj.MAObj.CheckCellArray{TaskObj.MACindex};
                if checkObj.SelectedListViewParamIndex==event.index+1
                    return
                end
                checkObj.SelectedListViewParamIndex=event.index+1;

                if~isempty(checkObj.ListViewActionCallback)
                    checkObj.ListViewActionCallback(TaskObj);
                end
                ListViewParameterStruct=checkObj.ListViewParameters{event.index+1};

                if isempty(ListViewParameterStruct.Data)
                    warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MANoItemToDispaly'));
                    set(warndlgHandle,'Tag','MANoItemToDisplay');
                    return
                end
                reuseMode=true;
                displayListView(TaskObj.MAObj,ListViewParameterStruct,TaskObj,reuseMode);
