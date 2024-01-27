classdef AppView<handle

    properties(Access=private)

AppController
ModelName
PeripheralInfoCache
TaskInfoCache
UnsavedChanges
Callbacks
Dependencies        AppState=codertarget.peripherals.AppState.TERMINATED
PeripheralTypes
SelectedPeripheralType
SelectedParameterType
        SelectedBlockIndex=1;
SelectedTemplateInfo
SelectedModelInfo
    end


    properties(Constant)
        IconPath=fullfile(matlabroot,'toolbox','target','shared','peripherals','icons');
        WindowTitle=message('codertarget:peripherals:AppTitle').getString();
        WidgetFactory=codertarget.peripherals.AppWidgetFactory;
    end


    properties(Access=private)
AppContainer
Title
Browser
BrowserTree
ApplyButton
HighlightButton
AutomapButton
ReportButton
HelpButton
TaskTable
ProgressBar
FigureDocument
SelectedBrowserNode
BrowserNodeGridMap
SelectedGrid
ParameterWidgets
ParameterGroupsMap
    end


    methods(Access=?codertarget.peripherals.AppController)
        function out=getPeripheralInfo(obj)
            out=obj.PeripheralInfoCache;
        end
        function out=getTaskInfo(obj)
            out=obj.TaskInfoCache;
        end
    end


    methods(Static)
        function obj=getInstance()
            persistent instance;
            if isempty(instance)
                instance=codertarget.peripherals.AppView();
            end
            obj=instance;
        end
    end


    methods
        function createApp(obj,appController)
            obj.AppController=appController;
            obj.AppState=codertarget.peripherals.AppState.INITIALIZING;
            obj.createAppWindow();
            obj.createToolstrip();
            obj.createBrowser();
            obj.createFigureDocument();
            obj.AppContainer.Visible=true;
            obj.AppContainer.Busy=true;
            obj.UnsavedChanges=false;
        end


        function initializeApp(obj,modelName,peripheralsInfo,taskInfo)

            obj.ModelName=modelName;
            obj.PeripheralInfoCache=peripheralsInfo;
            obj.TaskInfoCache=taskInfo;

            obj.SelectedBlockIndex=1;
            obj.SelectedPeripheralType='';
            obj.SelectedParameterType='';
            obj.Dependencies=[];
            obj.ParameterWidgets=[];
            obj.ParameterGroupsMap=[];

            obj.addBrowserNodes();
            obj.selectDefaultBrowserNode();

            if~isempty(obj.TaskInfoCache)
                obj.TaskInfoCache.IsAutomapSupported=obj.isAutomapSupported();
                if~obj.TaskInfoCache.IsAutomapSupported
                    obj.removeAutomapButton();
                end
            end

            if obj.isCPUSelected()

                cpuNames=obj.getCPUNames();
                [tasksGrid,tasksTable]=obj.createTaskWidgets(cpuNames{1});
                obj.BrowserNodeGridMap.Tasks.(cpuNames{1})=tasksGrid;
                obj.TaskTable.(cpuNames{1})=tasksTable;
                obj.enableAutomapButton(obj.TaskInfoCache.IsAutomapSupported);

                obj.SelectedGrid=tasksGrid;
            elseif obj.isPeripheralBlockSelected()
                obj.SelectedPeripheralType=obj.getSelectedPeripheralType();
                obj.SelectedParameterType='Block';
                obj.SelectedBlockIndex=obj.getSelectedBlockIndex();
                obj.SelectedTemplateInfo=obj.getSelectedTemplateInfo();
                obj.SelectedModelInfo=obj.getSelectedModelInfo();
                peripheralGrid=obj.createPeripheralWidgets(obj.SelectedTemplateInfo,obj.SelectedModelInfo);
                obj.BrowserNodeGridMap.Peripherals.(obj.SelectedPeripheralType).(obj.SelectedParameterType)=peripheralGrid;
                obj.SelectedGrid=peripheralGrid;
                obj.ReportButton.Enabled=true;
                obj.HighlightButton.Enabled=true;
                obj.enableAutomapButton(false);
            end
            waitfor(obj.FigureDocument,'Opened',true);
            obj.AppState=codertarget.peripherals.AppState.RUNNING;
            obj.AppContainer.Busy=false;
        end


        function closeApp(obj)

            if obj.isAppOpen()
                obj.AppState=codertarget.peripherals.AppState.TERMINATED;
                if~isempty(obj.AppContainer)&&obj.AppContainer.isvalid
                    obj.AppContainer.close();
                    delete(obj.AppContainer);
                end
            end
        end


        function result=canCloseFcn(obj)
            result=true;
            if~obj.UnsavedChanges
                result=true;
                obj.AppState=codertarget.peripherals.AppState.TERMINATED;
                return;
            end
            if~isempty(obj.PeripheralInfoCache)||~isempty(obj.TaskInfoCache)
                selection=obj.showConfirmDlg(message('codertarget:peripherals:CloseConfirmationTitle').getString(),...
                message('codertarget:peripherals:CloseConfirmationText').getString(),...
                {'Cancel','Close'});
                if isequal(selection,'Cancel')
                    result=false;
                else
                    obj.AppState=codertarget.peripherals.AppState.TERMINATED;
                    result=true;
                end
            end
        end


        function out=isAppOpen(obj)
            out=false;
            if~isempty(obj.AppContainer)&&obj.AppContainer.isvalid&&...
                obj.AppState~=codertarget.peripherals.AppState.TERMINATED
                out=obj.AppContainer.Visible;
            end
        end


        function bringToFront(obj)
            if~isempty(obj.AppContainer)&&obj.AppContainer.isvalid
                obj.AppContainer.bringToFront();
            end
        end


        function setBusy(obj,state)
            obj.AppContainer.Busy=state;
        end


        function setDirty(obj,state)
            obj.ApplyButton.Enabled=state;
            obj.AppContainer.Title=[obj.WindowTitle,' * '];
            obj.UnsavedChanges=state;
        end
    end


    methods
        function showProgressDlg(obj,msg)
            if isempty(obj.ProgressBar)||~obj.ProgressBar.isvalid
                obj.ProgressBar=uiprogressdlg(obj.AppContainer);
            end
            obj.ProgressBar.Title=msg;
            obj.ProgressBar.Indeterminate=true;
        end


        function selection=showConfirmDlg(obj,title,msg,options)
            selection=uiconfirm(obj.AppContainer,{msg},title,'Icon','warning',...
            'Options',options);
        end


        function showErrorDlg(obj,title,msg)
            uialert(obj.AppContainer,msg,title);
        end
    end


    methods(Access=private)
        function obj=AppView()
        end
    end


    methods(Access=private)
        function selectDefaultBrowserNode(obj)

            selectedNode=[];
            if~isempty(obj.PeripheralInfoCache)&&...
                isfield(obj.PeripheralInfoCache,'SelectedBlock')
                selectedNode=findobj(obj.BrowserTree.Children,'Text',obj.PeripheralInfoCache.SelectedBlock);
            else
                if~isempty(obj.TaskInfoCache.TaskNames)
                    tasksNodeText=message('codertarget:peripherals:TasksBrowserTitle').getString();
                    selectedNode=findobj(obj.BrowserTree.Children,'Text',tasksNodeText);
                    selectedNode=selectedNode.Children(1);
                elseif~isempty(obj.PeripheralInfoCache)
                    peripheralsNodeText=message('codertarget:peripherals:PeripheralsBrowserTitle').getString();
                    selectedNode=findobj(obj.BrowserTree.Children,'Text',peripheralsNodeText);
                    selectedNode=selectedNode.Children(1).Children(1);
                end
            end
            obj.SelectedBrowserNode=selectedNode;
            obj.BrowserTree.SelectedNodes=selectedNode;
        end


        function out=isCPUSelected(obj)
            out=startsWith(obj.SelectedBrowserNode.Tag,'CPUNAME');
        end


        function out=isPeripheralGroupSelected(obj)
            out=endsWith(obj.SelectedBrowserNode.Tag,'GROUP');
        end


        function out=isPeripheralBlockSelected(obj)
            out=endsWith(obj.SelectedBrowserNode.Tag,['BLOCK',digitsPattern]);
        end


        function out=getSelectedPeripheralType(obj)
            if obj.isPeripheralGroupSelected()
                out=extractBefore(obj.SelectedBrowserNode.Tag,'GROUP');
            elseif obj.isPeripheralBlockSelected()
                out=extractBefore(obj.SelectedBrowserNode.Tag,'BLOCK');
            end
        end


        function out=getSelectedParameterType(obj)
            if obj.isPeripheralGroupSelected()
                out='Group';
            elseif obj.isPeripheralBlockSelected()
                out='Block';
            end
        end


        function out=getSelectedBlockIndex(obj)
            out=1;
            if obj.isPeripheralBlockSelected()
                out=str2double(extractAfter(obj.SelectedBrowserNode.Tag,'BLOCK'));
            end
        end


        function templateInfo=getSelectedTemplateInfo(obj)
            templateInfo=obj.PeripheralInfoCache.Template.(obj.SelectedPeripheralType).(obj.SelectedParameterType);
        end


        function modelInfo=getSelectedModelInfo(obj)
            modelInfo=obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType);
            if isequal(obj.SelectedParameterType,'Block')
                modelInfo=modelInfo.Block(obj.SelectedBlockIndex);
            else
                modelInfo=modelInfo.Group;
            end
        end


        function cpuNames=getCPUNames(obj)
            cpuNames=obj.TaskInfoCache.MappingData(:,5);
            assert(~(numel(cpuNames)>1&&ismember('None',cpuNames)),...
            'The board cannot have multiple CPUs with the name None!');
            cpuNames=unique(cpuNames);
        end
    end


    methods(Access=private)
        function createAppWindow(obj)
            appOptions.Title=obj.WindowTitle;
            appOptions.Tag=strrep(appOptions.Title,' ','');
            appOptions.CanCloseFcn=@(~,~)obj.canCloseFcn;
            obj.AppContainer=obj.WidgetFactory.createAppContainer(appOptions);
        end


        function out=isAutomapSupported(obj)

            out=false;

            if~isempty(obj.TaskInfoCache)
                hCS=getActiveConfigSet(obj.TaskInfoCache.ModelName);
                out=codertarget.targethardware.isAutoMappingSupported(hCS);
            end
        end


        function createToolstrip(obj)
            tabOptions.Title=message('codertarget:peripherals:TabTitle').getString();
            tabOptions.Tag=strrep(obj.WindowTitle,' ','');
            tab=obj.WidgetFactory.createToolstripTab(obj.AppContainer,tabOptions);
            sectionOptions.Title=message('codertarget:peripherals:ModelSectionTitle').getString();
            section=obj.WidgetFactory.createToolstripSection(tab,sectionOptions);
            buttonOptions.Title=message('codertarget:peripherals:HighlightBlockText').getString();
            buttonOptions.Enabled=false;
            buttonOptions.Tag='HighlightBlockButton';
            buttonOptions.Icon=matlab.ui.internal.toolstrip.Icon(fullfile(obj.IconPath,'highlightBlock_24.png'));
            buttonOptions.ButtonPushedFcn=@obj.highlightCallback;
            buttonOptions.Description='Highlight the selected block in model';
            obj.HighlightButton=obj.WidgetFactory.createToolstripButton(section,buttonOptions);
            buttonOptions.Title=message('codertarget:peripherals:AutoMapText').getString();
            buttonOptions.Enabled=false;
            buttonOptions.Tag='AutomapButton';
            buttonOptions.Icon=matlab.ui.internal.toolstrip.Icon(fullfile(obj.IconPath,'automapTasks_24.png'));
            buttonOptions.ButtonPushedFcn=@obj.automapCallback;
            buttonOptions.Description=message('codertarget:peripherals:AutoMapTooltip').getString();
            obj.AutomapButton=obj.WidgetFactory.createToolstripButton(section,buttonOptions);
            buttonOptions.Title=message('codertarget:peripherals:ApplyChangesText').getString();
            buttonOptions.Enabled=false;
            buttonOptions.Tag='ApplyButton';
            buttonOptions.Icon=matlab.ui.internal.toolstrip.Icon.CONFIRM_24;
            buttonOptions.ButtonPushedFcn=@obj.applyCallback;
            buttonOptions.Description='Save parameter values to model';
            obj.ApplyButton=obj.WidgetFactory.createToolstripButton(section,buttonOptions);
            sectionOptions.Title=message('codertarget:peripherals:ReportSectionTitle').getString();
            section=obj.WidgetFactory.createToolstripSection(tab,sectionOptions);
            buttonOptions.Title=message('codertarget:peripherals:ReportButtonText').getString();
            buttonOptions.Enabled=false;
            buttonOptions.Tag='ReportButton';
            buttonOptions.Icon=matlab.ui.internal.toolstrip.Icon(fullfile(obj.IconPath,'reportGenerate_24.png'));
            buttonOptions.ButtonPushedFcn=@obj.generateReportCallback;
            buttonOptions.Description=message('codertarget:peripherals:ReportButtonDescription').getString();
            obj.ReportButton=obj.WidgetFactory.createToolstripButton(section,buttonOptions);
            obj.HelpButton=obj.WidgetFactory.createQABHelpButton(obj.AppContainer);
            obj.HelpButton.ButtonPushedFcn=@obj.helpButtonCallback;
        end


        function createBrowser(obj)

            figPanelOptions.Title='Mapping Browser';
            figPanelOptions.Region='left';
            figPanel=obj.WidgetFactory.createFigurePanel(obj.AppContainer,figPanelOptions);

            grid=obj.WidgetFactory.createBrowserGrid(figPanel.Figure);

            treeOptions.BackgroundColor='w';
            treeOptions.SelectionChangedFcn=@obj.browserSelectionChangedFcn;
            obj.BrowserTree=obj.WidgetFactory.createTree(grid,treeOptions);
        end


        function addBrowserNodes(obj)
            if~isempty(obj.TaskInfoCache.TaskNames)
                obj.addTasksToBrowser();
            end
            if~isempty(obj.PeripheralInfoCache)
                obj.addPeripheralsToBrowser();
            end
            obj.BrowserTree.expand('all');
        end


        function addTasksToBrowser(obj)
            nodeOptions.Text=message('codertarget:peripherals:TasksBrowserTitle').getString();
            nodeOptions.Tag='TASKS';
            tasksNode=obj.WidgetFactory.createTreeNode(obj.BrowserTree,nodeOptions);

            allCPUNames=obj.getCPUNames();
            for i=1:numel(allCPUNames)
                obj.BrowserNodeGridMap.Tasks.(allCPUNames{i})=[];
                nodeOptions.Text=strrep(allCPUNames{i},'None','CPU1');
                nodeOptions.Tag=['CPUNAME',allCPUNames{i}];
                obj.WidgetFactory.createTreeNode(tasksNode,nodeOptions);
            end
        end


        function addPeripheralsToBrowser(obj)
            nodeOptions.Text=message('codertarget:peripherals:PeripheralsBrowserTitle').getString();
            nodeOptions.Tag='PERIPHERALS';
            rootNode=obj.WidgetFactory.createTreeNode(obj.BrowserTree,nodeOptions);

            types=fieldnames(obj.PeripheralInfoCache.Model);
            obj.PeripheralTypes=types;

            for i=1:numel(types)
                groupOptions.Text=obj.PeripheralInfoCache.Template.(types{i}).Mask;
                groupOptions.Tag=[types{i},'GROUP'];
                groupNode=obj.WidgetFactory.createTreeNode(rootNode,groupOptions);
                obj.BrowserNodeGridMap.Peripherals.(types{i}).Group=[];
                obj.BrowserNodeGridMap.Peripherals.(types{i}).Block=[];

                for j=1:numel(obj.PeripheralInfoCache.Model.(types{i}).Block)
                    blockID=obj.PeripheralInfoCache.Model.(types{i}).Block(j).ID;
                    blockOptions.Text=Simulink.ID.getFullName(blockID);
                    blockOptions.Tag=[types{i},'BLOCK',num2str(j)];
                    obj.WidgetFactory.createTreeNode(groupNode,blockOptions);
                end
            end
        end


        function createFigureDocument(obj)
            groupOptions.Tag='DefaultDocumentGroup';
            obj.WidgetFactory.createFigureDocumentGroup(obj.AppContainer,groupOptions);

            docOptions.Title='';
            docOptions.Tag='DefaultFigureDocument';
            docOptions.DocumentGroupTag=groupOptions.Tag;
            docOptions.Closable=false;
            obj.FigureDocument=obj.WidgetFactory.createFigureDocument(obj.AppContainer,docOptions);
        end

        function[taskGrid,taskTable]=createTaskWidgets(obj,selectedCPU)
            taskGrid=obj.WidgetFactory.createTasksGrid(obj.FigureDocument.Figure);
            tableOptions.Tag=['TaskTable',selectedCPU];
            tableOptions.Data=obj.getTaskDataForCPU(selectedCPU);
            tableOptions.CellEditCallback=@obj.taskTableCellCallback;
            taskTable=obj.WidgetFactory.createTasksTable(taskGrid,tableOptions);
        end


        function peripheralGrid=createPeripheralWidgets(obj,templateInfo,modelInfo)
            peripheralGrid=obj.WidgetFactory.createPeripheralGrid(obj.FigureDocument.Figure);
            if~isempty(templateInfo.ParameterTabs)
                tabs=obj.addParameterTabs(peripheralGrid,templateInfo.ParameterTabs);
                parent=tabs{1};
            else
                parent=peripheralGrid;
            end
            obj.addParameters(parent,templateInfo.Parameters{1},modelInfo);
        end


        function out=getTaskDataForCPU(obj,cpuName)
            index=find(strcmp(obj.TaskInfoCache.MappingData(:,5),cpuName));
            dataForThisCPU=obj.TaskInfoCache.MappingData(index,:);
            mappedEventIdx=[dataForThisCPU{:,2}]+1;
            initialMapping=obj.TaskInfoCache.EventNames(mappedEventIdx)';
            tasks=dataForThisCPU(:,1);
            events=categorical(initialMapping,obj.TaskInfoCache.EventNames,'Protected',true);
            out=table(tasks,events);
        end


        function taskTableCellCallback(obj,src,event)
            indices=event.Indices;
            newData=event.NewData;
            localTaskIdx=indices(1);
            eventMappedTo=char(newData);
            internalEvent=message('codertarget:utils:InternalEvent').getString();
            if~isequal(eventMappedTo,internalEvent)
                eventNames=obj.TaskInfoCache.EventNames;
                taskName=src.Data.tasks{localTaskIdx};
                [~,taskIdx]=ismember(taskName,obj.TaskInfoCache.TaskNames);
                [~,idxEvent]=ismember(eventMappedTo,eventNames);
                obj.TaskInfoCache.MappingData{taskIdx,2}=idxEvent-1;
                obj.TaskInfoCache.MappingData{taskIdx,3}='ManuallyAssigned';
                obj.ApplyButton.Enabled=true;
                obj.AppContainer.Title=[obj.WindowTitle,' * '];
                obj.UnsavedChanges=true;
            else
                src.Data{event.Indices(1),event.Indices(2)}=event.PreviousData;
            end
        end


        function tabs=addParameterTabs(obj,parent,tabInfo)
            tabGroupOptions.SelectionChangedFcn=@obj.parameterTabChangedFcn;
            tabGroup=obj.WidgetFactory.createParameterTabGroup(parent,tabGroupOptions);
            tabs=cell(1,numel(tabInfo));
            for i=1:numel(tabs)
                tabOptions.Title=tabInfo{i}.Name;
                tabOptions.Tag=tabInfo{i}.Tag;
                tabs{i}=obj.WidgetFactory.createParameterTab(tabGroup,tabOptions);
                tabs{i}.UserData=struct('Index',i,'BrowserNode',obj.SelectedBrowserNode.Text);
            end
        end


        function addParameters(obj,parent,params,modelInfo)

            if isequal(parent.Type,'uigridlayout')
                parentGrid=parent;
            else
                parentGrid=obj.WidgetFactory.createParameterGrid(parent);
            end

            for i=1:numel(params)
                param=params(i);
                param.Value=modelInfo.(param.Storage);

                parentGrid.RowHeight{end+1}='fit';
                obj.registerDependencies(param);

                widgetOptions=struct;
                widgetOptions.Items=split(param.Entries,';');
                widgetOptions.Text=param.Name;
                widgetOptions.Tag=param.Storage;
                widgetOptions.Type=param.Type;
                widgetOptions.Value=param.Value;
                if isempty(param.Callback)
                    widgetOptions.ValueChangedFcn=@obj.widgetChangedCallback;
                else
                    widgetOptions.ValueChangedFcn=param.Callback;
                end
                widgetOptions.Visible=obj.evaluateAttribute(param,'Visible');
                widgetOptions.Enable=obj.evaluateAttribute(param,'Enable');
                if startsWith(widgetOptions.Items,'callback')
                    widgetOptions.Items=obj.evaluateAttribute(param,'Entries');
                    if~any(matches(widgetOptions.Items,widgetOptions.Value))
                        widgetOptions.Value=widgetOptions.Items{1};

                        obj.setDirty(true);
                        if(isequal(obj.SelectedParameterType,'Group'))
                            obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Group.(param.Storage)=widgetOptions.Value;
                        else
                            obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Block(obj.SelectedBlockIndex).(param.Storage)=widgetOptions.Value;
                        end
                    end
                end
                if~isempty(param.Parent)&&~strcmpi(param.Parent.Type,'tab')
                    parentGroup=findobj(parentGrid,'Tag',param.Parent.Tag);
                    if isempty(parentGroup)
                        groupOptions.Title=param.Parent.Name;
                        groupOptions.Tag=param.Parent.Tag;
                        groupOptions.Type=param.Parent.Type;
                        [panel,grid]=obj.WidgetFactory.createParameterGroup(parentGrid,groupOptions);
                    end

                    obj.ParameterGroupsMap.(obj.SelectedPeripheralType).(param.Storage)=panel;
                    parent=grid;
                    if widgetOptions.Visible&&~panel.Visible
                        panel.Visible=true;
                    end
                    obj.adjustRowHeight(panel);
                else
                    parent=parentGrid;
                end
                widgets=obj.WidgetFactory.createParameterWidget(parent,widgetOptions);
                obj.adjustRowHeight(widgets(1));
                obj.ParameterWidgets.(obj.SelectedPeripheralType).(param.Storage)=widgets;
            end
        end


        function updateParameters(obj,params,modelInfo)

            for i=1:numel(params)
                param=params(i);
                param.Value=modelInfo.(param.Storage);
                widgets=obj.ParameterWidgets.(obj.SelectedPeripheralType).(param.Storage);
                if isequal(widgets(end).Type,'uicheckbox')&&~islogical(param.Value)
                    param.Value=logical(str2double(param.Value));
                end

                if isequal(widgets(end).Type,'uidropdown')&&startsWith(param.Entries,'callback')
                    widgets(end).Items=obj.evaluateAttribute(param,'Entries');
                    if~any(matches(widgets(end).Items,param.Value))
                        param.Value=widgets(end).Items{1};

                        obj.setDirty(true);
                        if(isequal(obj.SelectedParameterType,'Group'))
                            obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Group.(param.Storage)=param.Value;
                        else
                            obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Block(obj.SelectedBlockIndex).(param.Storage)=param.Value;
                        end
                    end
                end
                widgets(end).Value=param.Value;
               set(widgets,'Visible',obj.evaluateAttribute(param,'Visible'));
                set(widgets,'Enable',obj.evaluateAttribute(param,'Enable'));
                obj.adjustRowHeight(widgets(end));
                if~isempty(param.Parent)&&~strcmpi(param.Parent.Type,'tab')
                    parentGroup=obj.ParameterGroupsMap.(obj.SelectedPeripheralType).(param.Storage);
                    parentGroup.Visible=~isempty(findall(widgets(end).Parent.Children,'Visible','on'));
                    obj.adjustRowHeight(parentGroup);
                end
            end
        end
    end


    methods(Access=private)
        function adjustRowHeight(~,widget)
            if~widget.Visible
                widget.Parent.RowHeight{widget.Layout.Row}=0;
            else
                widget.Parent.RowHeight{widget.Layout.Row}='fit';
            end
        end


        function removeAutomapButton(obj)
            if~isempty(obj.AutomapButton)
                obj.AutomapButton.delete();
                obj.AutomapButton=[];
            end
        end


        function enableAutomapButton(obj,state)
            if~isempty(obj.AutomapButton)
                obj.AutomapButton.Enabled=state;
            end
        end


        function validateEditFieldValue(obj,widget)

            paramStorage=widget.Tag;
            allParams=[obj.SelectedTemplateInfo.Parameters{:}];
            paramIdx=find(strcmp({allParams.Storage},paramStorage));
            templateInfoForParam=allParams(paramIdx);%#ok<FNDSB>
            valueRange=templateInfoForParam.ValueRange;

            if~isempty(valueRange)
                try
                    range=str2double(split(valueRange,';'));
                    baseWrks=evalin('base','whos');
                    if ismember(widget.Value,{baseWrks(:).name})
                        validateattributes(evalin('base',widget.Value),...
                        {'numeric'},{'scalar','>',range(1),'<',range(2)});
                    else
                        validateattributes(str2num(widget.Value,'Evaluation','restricted'),...
                        {'numeric'},{'scalar','>',range(1),'<',range(2)});%#ok<ST2NM>
                    end
                catch ex
                    obj.showErrorDlg(message('codertarget:peripherals:ParameterValidationLabel').getString(),...
                    ex.message);

                    widget.Value=obj.SelectedModelInfo.(paramStorage);
                end
            end
        end
    end


    methods(Access=private)
        function registerDependencies(obj,param)
            supportedAttributes={'Enable','Visible','Entries'};
            dependencyForParam=[];
            for i=1:numel(supportedAttributes)
                attrib=supportedAttributes{i};
                if obj.isValueCallback(attrib,param.(attrib))
                    paramBeingChanged=extractBetween(param.(attrib),'''','''')';
                    paramToBeNotified=param.Storage;
                    if isequal(attrib,'Entries')
                        callbackFcn=extractBetween(param.(attrib),'callback:','(');
                        if iscell(callbackFcn)
                            callbackFcn=callbackFcn{1};
                        end
                    else
                        callbackFcn=extractBefore(param.(attrib),'(');
                    end
                    if~isempty(dependencyForParam)
                        paramBeingChanged=setdiff(paramBeingChanged,dependencyForParam);
                    end
                    obj.Dependencies.(obj.SelectedPeripheralType).(paramToBeNotified)=[dependencyForParam,paramBeingChanged];
                    dependencyForParam=obj.Dependencies.(obj.SelectedPeripheralType).(paramToBeNotified);
                    obj.Callbacks.(obj.SelectedPeripheralType).(paramToBeNotified).(attrib)=callbackFcn;
                end
            end
        end


        function out=isValueCallback(~,attrib,value)
            if isequal(attrib,'Entries')
                out=startsWith(value,'callback:');
            else
                out=~isequal(value,'1')&&~isequal(value,'0');
            end
        end


        function out=evaluateAttribute(obj,param,attrib)
            val=param.(attrib);
            if isequal(val,'1')||isequal(val,'0')
                out=logical(val-'0');
            else

                paramName=param.Storage;
                paramsBeingChanged=obj.getDependentParameters(paramName,attrib);
                out=obj.invokeCallback(obj.Callbacks.(obj.SelectedPeripheralType).(paramName).(attrib),paramsBeingChanged);
                if~isequal(attrib,'Entries')
                    if isequal(out,'1')||isequal(out,'0');out=logical(out-'0');end
                end
            end
        end


        function out=getDependentParameters(obj,paramName,attrib)

            out=[];
            if~isempty(obj.Dependencies)&&...
                isfield(obj.Dependencies.(obj.SelectedPeripheralType),paramName)&&...
                isfield(obj.Callbacks.(obj.SelectedPeripheralType).(paramName),attrib)
                dependentParams=obj.Dependencies.(obj.SelectedPeripheralType).(paramName);
                for i=1:numel(dependentParams)
                    paramType={'Block','Group'};
                    for j=1:numel(paramType)
                        params=[obj.PeripheralInfoCache.Template.(obj.SelectedPeripheralType).(paramType{j}).Parameters{:}];
                        idx=find(strcmp({params.Storage},dependentParams{i}),1);
                        if~isempty(idx)
                            out(i).Name=dependentParams{i};%#ok<AGROW>
                            out(i).Visible=params(idx).Visible;%#ok<AGROW>
                            out(i).Enable=params(idx).Enable;%#ok<AGROW>
                            modelInfo=obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).(paramType{j});
                            if isequal(paramType{j},'Block')
                                out(i).BlockID=modelInfo(obj.SelectedBlockIndex).ID;%#ok<AGROW>
                                out(i).Value=modelInfo(obj.SelectedBlockIndex).(dependentParams{i});%#ok<AGROW>
                            else
                                out(i).Model=obj.ModelName;%#ok<AGROW>
                                out(i).Value=modelInfo.(dependentParams{i});%#ok<AGROW>
                                out(i).BlockID=obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Block(1).ID;%#ok<AGROW>
                            end
                            break;
                        end
                    end
                end
            end
        end


        function out=getParametersToBeNotified(obj,paramName)

            out={};
            if isfield(obj.Dependencies,obj.SelectedPeripheralType)
                params=fieldnames(obj.Dependencies.(obj.SelectedPeripheralType));
                for i=1:numel(params)
                    val=obj.Dependencies.(obj.SelectedPeripheralType).(params{i});
                    for j=1:numel(val)
                        if isequal(paramName,val{j})
                            out{end+1}=params{i};%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end


    methods(Access=private)
        function browserSelectionChangedFcn(obj,src,evt)

            obj.SelectedGrid.Visible=false;
            obj.SelectedBrowserNode=src.SelectedNodes;

            if obj.isCPUSelected()
                obj.AppContainer.Busy=true;
                selectedCPU=extractAfter(obj.SelectedBrowserNode.Tag,'CPUNAME');
                taskGrid=obj.BrowserNodeGridMap.Tasks.(selectedCPU);
                if isempty(taskGrid)
                    [taskGrid,tasksTable]=obj.createTaskWidgets(selectedCPU);
                    obj.BrowserNodeGridMap.Tasks.(selectedCPU)=taskGrid;
                    obj.TaskTable.(selectedCPU)=tasksTable;
                end

                [~,eventNames]=...
                codertarget.internal.taskmapper.getTaskMappingInfo(obj.TaskInfoCache.ModelName);
                obj.TaskInfoCache.EventNames=eventNames;
                obj.TaskTable.(selectedCPU).Data.events=setcats(obj.TaskTable.(selectedCPU).Data.events,eventNames');

                obj.SelectedGrid=taskGrid;
                obj.SelectedGrid.Visible=true;
                obj.ReportButton.Enabled=false;
                obj.HighlightButton.Enabled=false;
                obj.enableAutomapButton(obj.TaskInfoCache.IsAutomapSupported);
                obj.SelectedParameterType='';
                obj.SelectedPeripheralType='';
                obj.AppContainer.Busy=false;
            elseif obj.isPeripheralGroupSelected()||obj.isPeripheralBlockSelected()
                selectedPeripheralType=obj.getSelectedPeripheralType();
                selectedParameterType=obj.getSelectedParameterType();
                if~isequal(obj.SelectedPeripheralType,selectedPeripheralType)||...
                    ~isequal(obj.SelectedParameterType,selectedParameterType)
                    obj.SelectedPeripheralType=selectedPeripheralType;
                    obj.SelectedParameterType=selectedParameterType;
                    obj.SelectedBlockIndex=obj.getSelectedBlockIndex();
                    obj.SelectedTemplateInfo=obj.getSelectedTemplateInfo();
                    if isempty(obj.SelectedTemplateInfo.Parameters)
                        obj.HighlightButton.Enabled=false;
                        return
                    end
                    obj.AppContainer.Busy=true;
                    drawnow();
                    obj.SelectedModelInfo=obj.getSelectedModelInfo();

                    peripheralGrid=obj.BrowserNodeGridMap.Peripherals.(selectedPeripheralType).(selectedParameterType);
                    if isempty(peripheralGrid)
                        peripheralGrid=obj.createPeripheralWidgets(obj.SelectedTemplateInfo,obj.SelectedModelInfo);
                        obj.BrowserNodeGridMap.Peripherals.(selectedPeripheralType).(selectedParameterType)=peripheralGrid;
                    end
                    obj.SelectedGrid=peripheralGrid;
                    obj.SelectedGrid.Visible=true;
                    obj.AppContainer.Busy=false;
                else
                    obj.SelectedPeripheralType=selectedPeripheralType;
                    obj.SelectedParameterType=selectedParameterType;
                    obj.SelectedBlockIndex=obj.getSelectedBlockIndex();
                    obj.SelectedTemplateInfo=obj.getSelectedTemplateInfo();
                    if isempty(obj.SelectedTemplateInfo.Parameters)
                        return
                    end
                    obj.SelectedModelInfo=obj.getSelectedModelInfo();
                    obj.AppContainer.Busy=true;
                    drawnow();
                    peripheralGrid=obj.BrowserNodeGridMap.Peripherals.(selectedPeripheralType).Block;
                    if~isempty(obj.SelectedTemplateInfo.ParameterTabs)

                        if isempty(peripheralGrid)
                            peripheralGrid=obj.createPeripheralWidgets(obj.SelectedTemplateInfo,obj.SelectedModelInfo);
                            obj.BrowserNodeGridMap.Peripherals.(selectedPeripheralType).(selectedParameterType)=peripheralGrid;
                        end
                        tabs=peripheralGrid.Children.Children;
                        peripheralGrid.Children.SelectedTab=tabs(1);
                    end
                    obj.updateParameters(obj.SelectedTemplateInfo.Parameters{1},obj.SelectedModelInfo);
                    obj.SelectedGrid=peripheralGrid;
                    obj.SelectedGrid.Visible=true;
                    obj.AppContainer.Busy=false;
                end
                obj.ReportButton.Enabled=true;
                obj.HighlightButton.Enabled=obj.isPeripheralBlockSelected();
                obj.enableAutomapButton(false);
            end

            if contains(evt.PreviousSelectedNodes.Tag,'BLOCK')
                obj.clearHighlight(evt.PreviousSelectedNodes.Text)
            end
        end


        function parameterTabChangedFcn(obj,src,~)

            obj.AppContainer.Busy=true;
            params=obj.SelectedTemplateInfo.Parameters{src.SelectedTab.UserData.Index};
            if isempty(src.SelectedTab.Children)
                params=obj.SelectedTemplateInfo.Parameters{src.SelectedTab.UserData.Index};
                obj.addParameters(src.SelectedTab,params,obj.SelectedModelInfo);
                src.SelectedTab.UserData.BrowserNode=obj.SelectedBrowserNode.Text;
            elseif~isequal(src.SelectedTab.UserData.BrowserNode,obj.SelectedBrowserNode.Text)
                obj.updateParameters(params,obj.SelectedModelInfo);
                src.SelectedTab.UserData.BrowserNode=obj.SelectedBrowserNode.Text;
            end

            obj.AppContainer.Busy=false;
        end


        function widgetChangedCallback(obj,src,~)

            obj.setDirty(true);

            if isequal(src.Type,'uieditfield')
                obj.validateEditFieldValue(src);
            end

            valueToSave=src.Value;
            if islogical(valueToSave)
                valueToSave=num2str(valueToSave);
            end
            obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).(obj.SelectedParameterType)(obj.SelectedBlockIndex).(src.Tag)=valueToSave;

            if~isempty(obj.Dependencies)
                paramsToBeNotified=obj.getParametersToBeNotified(src.Tag);
                for i=1:numel(paramsToBeNotified)
                    widgets=obj.ParameterWidgets.(obj.SelectedPeripheralType).(paramsToBeNotified{i});
                    attribs=fieldnames(obj.Callbacks.(obj.SelectedPeripheralType).(paramsToBeNotified{i}));
                    for j=1:numel(attribs)
                        param=obj.Callbacks.(obj.SelectedPeripheralType).(paramsToBeNotified{i});
                        param.Storage=paramsToBeNotified{i};
                        valueToSet=obj.evaluateAttribute(param,attribs{j});
                        if isequal(attribs{j},'Entries')
                            set(widgets(end),'Items',valueToSet);
                            obj.updatePeripheralInfoCache(param.Storage,widgets(end).Value);

                        else
                            set(widgets,attribs{j},valueToSet);
                        end

                        obj.adjustRowHeight(widgets(1));
                    end

                    if isfield(obj.ParameterGroupsMap,obj.SelectedPeripheralType)&&...
                        isfield(obj.ParameterGroupsMap.(obj.SelectedPeripheralType),paramsToBeNotified{i})
                        parentGroup=obj.ParameterGroupsMap.(obj.SelectedPeripheralType).(paramsToBeNotified{i});
                        parentGroup.Visible=~isempty(findall(widgets(end).Parent.Children,'Visible','on'));
                        obj.adjustRowHeight(parentGroup);
                    end
                end
            end
        end


        function updatePeripheralInfoCache(obj,paramStorage,paramValue)
            blkParams=obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Block;
            groupParams=obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Group;
            if isfield(blkParams(1),paramStorage)
                if(isequal(obj.SelectedParameterType,'Group'))
                    for index=1:numel(blkParams)
                        obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Block(index).(paramStorage)=paramValue;
                    end
                else
                    obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Block(obj.SelectedBlockIndex).(paramStorage)=paramValue;
                end
            elseif isfield(groupParams,paramStorage)
                obj.PeripheralInfoCache.Model.(obj.SelectedPeripheralType).Group.(paramStorage)=paramValue;
            end
        end


        function val=invokeCallback(~,fcn,obj)

            val=true;
            try
                val=feval(fcn,obj);
            catch
            end
        end


        function applyCallback(obj,~,~)
            if obj.UnsavedChanges
                obj.showProgressDlg('Applying changes');
                [status,msg]=obj.AppController.applyMappingInfo();
                if~status
                    obj.showErrorDlg('Invalid mapping',msg);
                else
                    obj.ApplyButton.Enabled=false;
                    obj.AppContainer.Title=obj.WindowTitle;
                    obj.UnsavedChanges=false;
                end
                obj.ProgressBar.close();
            end
        end


        function helpButtonCallback(obj,~,~)
            hCS=getActiveConfigSet(obj.ModelName);
            isSoCBoard=codertarget.utils.isSoCInstalledAndModelConfiguredForSoC(hCS);
            if isSoCBoard
                soc.internal.helpview('soc_hardwaremapping');
            else
                docRoot=codertarget.internal.infineonaurix.getDocRoot();
                helpview(fullfile(docRoot,'helptargets.map'),'ifx_hardwaremapping');
            end
        end


        function automapCallback(obj,~,~)
            [mapData,eventNames]=...
            codertarget.internal.taskmapper.autoassignTaskToEventSource(...
            obj.TaskInfoCache.ModelName,...
            obj.TaskInfoCache.MappingData,...
            obj.TaskInfoCache.EventNames);
            obj.TaskInfoCache.MappingData=mapData;
            obj.TaskInfoCache.EventNames=eventNames;

            taskInfo=obj.TaskInfoCache;
            cpuNames=unique(taskInfo.MappingData(:,5));

            for i=1:numel(cpuNames)
                cpuName=cpuNames{i};
                index=find(strcmp(taskInfo.MappingData(:,5),cpuName));
                dataForThisCPU=taskInfo.MappingData(index,:);
                mappedEventIdx=[dataForThisCPU{:,2}]+1;
                initialMapping=taskInfo.EventNames(mappedEventIdx)';
                tasks=dataForThisCPU(:,1);
                events=categorical(initialMapping,taskInfo.EventNames,'Protected',true);
                tableData=table(tasks,events);
                obj.TaskTable.(cpuName).Data=tableData;
            end

            drawnow();
            obj.ApplyButton.Enabled=true;
            obj.AppContainer.Title=[obj.WindowTitle,' * '];
            obj.UnsavedChanges=true;
        end


        function highlightCallback(obj,~,~)
            hilite_system((obj.BrowserTree.SelectedNodes.Text));
        end


        function generateReportCallback(obj,~,~)
            obj.AppContainer.Busy=true;
            reportGenerator=codertarget.peripherals.ReportGenerator(tempdir);

            for i=1:numel(obj.PeripheralTypes)
                modelInfo=obj.PeripheralInfoCache.Model.(obj.PeripheralTypes{i});
                if isfield(modelInfo,'Group')&&~isempty(fieldnames(modelInfo.Group))

                    tableTitle=obj.PeripheralInfoCache.Template.(obj.PeripheralTypes{i}).Mask;
                    templateInfo=obj.PeripheralInfoCache.Template.(obj.PeripheralTypes{i}).Group;
                    paramTable=obj.getTableDataForReport(tableTitle,templateInfo,modelInfo.Group);

                    reportGenerator.addTable(paramTable);
                end


                for j=1:numel(modelInfo.Block)
                    blockInfo=modelInfo.Block(j);
                    tableTitle=Simulink.ID.getFullName(blockInfo.ID);
                    blockInfo=rmfield(blockInfo,'ID');
                    templateInfo=obj.PeripheralInfoCache.Template.(obj.PeripheralTypes{i}).Block;
                    paramTable=obj.getTableDataForReport(tableTitle,templateInfo,blockInfo);

                    reportGenerator.addTable(paramTable);
                end
            end
            reportGenerator.generate(true);
            obj.AppContainer.Busy=false;
        end


        function clearHighlight(~,blk)
            set_param(blk,'HiliteAncestors','none');
        end


        function out=getTableDataForReport(~,tableTitle,templateInfo,modelInfo)

            paramTable=table();

            paramTable.Properties.Description=strrep(tableTitle,newline,' ');

            allParams=[templateInfo.Parameters{:}];
            allGroups=[templateInfo.ParameterTabs{:}];
            paramTable.Parameter=repmat({''},numel(allGroups)+numel(allParams),1);
            paramTable.Value=repmat({''},numel(allGroups)+numel(allParams),1);
           if~isempty(templateInfo.ParameterTabs)
                k=0;
                for i=1:numel(templateInfo.ParameterTabs)
                    k=k+1;

                    paramTable.Parameter{k}=[templateInfo.ParameterTabs{i}.Name,'GROUP'];
                    params=templateInfo.Parameters{i};
                    for j=1:numel(params)
                        k=k+1;

                        paramTable.Parameter{k}=strrep(params(j).Name,':','');


                        val=modelInfo.(params(j).Storage);
                        if islogical(val)
                            val=num2str(val);
                        end
                        paramTable.Value{k}=val;
                    end
                end
            else
                params=allParams;
                for k=1:numel(params)

                    paramTable.Parameter{k}=strrep(params(k).Name,':','');


                    val=modelInfo.(params(k).Storage);
                    if islogical(val)
                        val=num2str(val);
                    end
                    paramTable.Value{k}=val;
                end
            end
            out=paramTable;
        end
    end
end