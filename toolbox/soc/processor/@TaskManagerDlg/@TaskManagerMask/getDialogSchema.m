function dialog=getDialogSchema(h,~)





    dialog.LayoutGrid=[4,1];
    dialog.RowStretch=[0,0,1,0];
    dialog.CloseMethod='closeCallback';
    dialog.CloseMethodArgs={'%dialog'};
    dialog.CloseMethodArgsDT={'handle'};
    dialog.PreApplyMethod='taskManagerPreApplyCallback';
    dialog.PreApplyArgs={'%dialog'};
    dialog.PreApplyArgsDT={'handle'};
    dialog.HelpMethod='slhelp';
    dialog.HelpArgs={h,h.Block.Handle};
    dialog.HelpArgsDT={'handle'};










    dlgItems={};
    dlgItems{end+1}=mkInfoGroup(h,[1,1],[1,1]);
    dlgItems{end+1}=mkCtrlGroup(h,[2,2],[1,1]);
    dlgItems{end+1}=mkTaskGroup(h,[3,3],[1,1]);
    dialog.Items=dlgItems;
    simStatus=h.Root.SimulationStatus;
    if any(strcmp(simStatus,{'running','paused','external'}))
        dialog=h.disableNontunables(dialog);
    end
end

function g=mkInfoGroup(h,rows,cols)
    name='Task Manager (mask)';
    g=mkGroup(h,name,'TaskMgrTag',{},rows,cols,[1,1],[],[],1,1);
    name=DAStudio.message('soc:scheduler:TaskMgrDesc');
    items{1}=mkText(h,name,'DescriptionTag',[1,1],[1,1],1,1);
    g.Items=items;
end

function g=mkCtrlGroup(h,rows,cols)
    name='';
    g=mkGroup(h,name,'CtrlGroupTag',{},rows,cols,[1,1],[],[],1,1);
    name=DAStudio.message('soc:scheduler:TaskMgrEnableSim');
    items{1}=mkCheckbox(h,name,'enableTaskSimulation',true,'',...
    [1,1],[1,1],1,1,true);
    g.Items=items;
end

function g=mkTaskGroup(h,rows,cols)







    name='Task simulation';
    g=mkGroup(h,name,'TaskSimTag',{},rows,cols,[1,2],[],[],1,1);
    items{1}=mkTaskListGroup(h,[1,1],[1,1]);
    if~isequal(numel(h.taskList),0)
        items{2}=mkTaskPropGroup(h,[1,1],[2,2]);
    end
    g.Items=items;
end

function g=mkTaskListGroup(h,rows,cols)
    name='';
    g=mkGroup(h,name,'TaskListTag',{},rows,cols,[6,3],[],[],1,1);
    items{1}=mkWidget(h,'','selectedTask','listbox',...
    h.taskList,true,...
    'onTaskSelectionChange',[4,4],[1,3],1,1,true);
    items{1}.MultiSelect=0;
    [found,idx]=ismember(h.selectedTask,h.taskList);
    if found,items{1}.SelectedItem=idx-1;end
    addTaskBtnLbl=DAStudio.message('soc:scheduler:AddBtn');
    items{2}=mkButton(h,addTaskBtnLbl,'AddTaskBtnTag',...
    'soc.internal.dialog.onAddTask',[5,5],[1,1],...
    true,numel(h.taskList)<h.customizationInfo.maxnumtasks,...
    DAStudio.message('soc:scheduler:AddTaskBtnTip'));
    delTaskBtnLbl=DAStudio.message('soc:scheduler:DelBtn');
    items{3}=mkButton(h,delTaskBtnLbl,'DelTaskBtnTag',...
    'soc.internal.dialog.onDeleteTask',[5,5],[2,2],...
    true,numel(h.taskList)>1,...
    DAStudio.message('soc:scheduler:DelTaskBtnTip'));
    g.Items=items;
end

function group=mkTaskPropGroup(h,rows,cols)
    name=DAStudio.message('soc:scheduler:Properties');
    group=mkGroup(h,name,'TaskPropsTag',{},rows,cols,[2,1],[],[],1,1);
    items={};
    if h.customizationInfo.scheduleeditorsupported
        label=DAStudio.message('soc:scheduler:ChkBoxScheduleEditor');
        items{end+1}=mkCheckbox(h,label,'useScheduleEditor',true,'',...
        [1,1],[1,1],1,1,true);
    end
    items{end+1}=mkTaskMainPanel(h,[2,2],[1,1]);
    group.Items=items;
end

function panel=mkTaskMainPanel(h,rows,cols)
    tab1.Name='Main';
    tab1.Items={mkMainTaskTab(h,[1,1],[1,1])};
    container.Name='tabcont';
    container.Type='tab';
    container.Tabs{1}=tab1;
    if h.enableTaskSimulation
        tab2.Name='Simulation';
        tab2.Items=mkSimulationTaskTab(h);
        container.Tabs{2}=tab2;
    end
    panel=mkPanel('MainTaskPanel',{},rows,cols,[1,1],1,1,1);
    panel.Items={container};
end

function g=mkMainTaskTab(h,rows,cols)
    name='';
    g=mkGroup(h,name,'MainTab',{},rows,cols,[8,1],[],[],1,1);
    enb=numel(h.taskList)>0;
    idx=1;
    items{idx}=mkEdit(h,DAStudio.message('soc:scheduler:TaskName'),...
    'taskName',true,'onTaskNameChange',[idx,idx],[1,1],enb,1);
    if~isequal(numel(h.customizationInfo.tasktypessupported),1)
        idx=idx+1;
        items{idx}=mkCombobox(h,DAStudio.message('soc:scheduler:TaskType'),...
        'taskType',{'Event-driven','Timer-driven'},true,...
        'onTaskTypeChange',[idx,idx],[1,1],enb,1);
    end
    vis=isequal(h.taskType,'Timer-driven');
    idx=idx+1;
    items{idx}=mkEdit(h,DAStudio.message('soc:scheduler:TaskPeriod'),...
    'taskPeriod',true,'onTaskParameterChange',[idx,idx],[1,1],enb,vis);
    if h.enableTaskSimulation
        if h.customizationInfo.coreassignmentsupported
            idx=idx+1;
            items{idx}=mkEdit(h,DAStudio.message('soc:scheduler:TaskCore'),...
            'coreNum',true,'onTaskParameterChange',[idx,idx],[1,1],true,true);
        end
        vis=isequal(h.taskType,'Event-driven')&&~h.UseScheduleEditor;
        idx=idx+1;
        items{idx}=mkEdit(h,DAStudio.message('soc:scheduler:TaskPriority'),...
        'taskPriority',true,'onTaskParameterChange',[idx,idx],[1,1],enb,vis);
        vis=isequal(h.taskType,'Event-driven')&&...
        isequal(h.get_param('SupportEventPorts'),'off');
        idx=idx+1;
        items{idx}=mkEdit(h,'Event:','taskEvent',true,...
        'onTaskParameterChange',[idx,idx],[1,1],enb,vis);
        if h.customizationInfo.taskdropsupported
            idx=idx+1;
            items{idx}=mkCheckbox(h,...
            DAStudio.message('soc:scheduler:TaskDropOverrun'),...
            'dropOverranTasks',true,'onTaskParameterChange',[idx,idx],...
            [1,1],enb,1,false);
        end
    end
    g.Items=items;
end

function widgets=mkSimulationTaskTab(h)
    enb=numel(h.taskList)>0;
    vis=h.customizationInfo.playbacksupported;
    widgets{1}=mkCheckbox(h,DAStudio.message('soc:scheduler:TaskMgrPlayback'),...
    'playbackRecorded',true,'onTaskParameterChange',[1,1],[2,2],enb,vis,false);
    if~h.playbackRecorded

        entries=h.customizationInfo.taskdurationsourcesupported;
        widgets{end+1}=mkCombobox(h,...
        DAStudio.message('soc:scheduler:SpecifyDurationVia'),...
        'taskDurationSource',entries,true,'onTaskDurationSourceChange',...
        [2,2],[2,2],enb,1);
        if isequal(h.taskDurationSource,'Dialog')
            widgets{end+1}=mkTaskDurationGroup(h);
        end
    end
    if h.playbackRecorded||h.isDurationSourceDiagFile()
        name='';
        g=mkGroup(h,name,'DiagFileTag',{},[3,3],[1,1],[2,2],[],[1,0],1,1);
        items{1}=mkEdit(h,'File name:','diagnosticsFile',true,...
        'onDiagnosticsFileChange',[1,1],[1,1],enb,1);
        items{2}=mkButton(h,'Browse...','BrowseDiagFileBtn',...
        'soc.internal.dialog.onBrowseDiagnosticsFile',...
        [1,1],[2,2],enb,1,'Select task diagnostics file');
        g.Items=items;
        widgets{end+1}=g;
    end
end

function g=mkTaskDurationGroup(h)
    name=DAStudio.message('soc:scheduler:DurationSettings');
    g=mkGroup(h,name,'DurSettsTag',{},[3,3],[2,4],[1,2],[],[],1,1);
    str=DAStudio.message('soc:scheduler:TaskMgrDistTblDesc');
    text=mkText(h,str,'text1Tag',[1,1],[1,3],true,true);
    table=mkDistributionTable(h,'Task execution times',...
    [2,2],[1,3],true,true);
    [nRegions,~]=size(h.taskDurationData);
    addBtnLbl=DAStudio.message('soc:scheduler:AddBtn');
    addRegionWidget=mkButton(h,addBtnLbl,'AddDistBtnTag',...
    'soc.internal.dialog.onAddRegion',[3,3],[1,1],true,nRegions<5,...
    DAStudio.message('soc:scheduler:AddDistBtnTip'));
    delBtnLbl=DAStudio.message('soc:scheduler:DelBtn');
    deleteRegionWidget=mkButton(h,delBtnLbl,'DelDistBtnTag',...
    'soc.internal.dialog.onDeleteRegion',[3,3],[3,3],true,nRegions>1,...
    DAStudio.message('soc:scheduler:DelDistBtnTip'));
    g.Items={text,table,addRegionWidget,deleteRegionWidget};
end

function widget=mkDistributionTable(h,name,row,col,enb,vis)%#ok<INUSL>
    colHeaders={'Percent','Mean','SD','Min','Max'};
    DataTable=h.taskDurationData;
    widget.Type='table';
    widget.Tag='taskDurationTable';
    tabledata=cell(size(DataTable,1),length(colHeaders));
    for j=1:size(DataTable,1)
        for k=1:length(colHeaders)
            tabledata{j,k}.Type='edit';
            tabledata{j,k}.Value=DataTable{j,k};
            tabledata{j,k}.Enabled=true;
            tabledata{j,k}.BackgroundColor=[255,255,255];
        end
    end
    widget.Visible=vis;
    widget.Enabled=enb;
    widget.RowSpan=row;
    widget.ColSpan=col;
    widget.Size=size(tabledata);
    widget.ColHeader=colHeaders;
    widget.Editable=true;
    widget.Data=tabledata;
    widget.SelectionBehavior='row';
    widget.Grid=true;
    widget.ColumnCharacterWidth=[5,5,5,5,5];
    widget.ColumnHeaderHeight=1;
    widget.HeaderVisibility=ones(1,length(colHeaders));
    widget.ColumnStretchable=[1,1,1,1,1];
    widget.SelectedRow=h.selectedTableRow-1;
    widget.ValueChangedCallback=@h.tableValueChangedCallback;
    widget.CurrentItemChangedCallback=@h.tableCurrentItemChangedCallback;
    widget.ToolTip=DAStudio.message('soc:scheduler:TaskMgrDistTblTip');
end



function widget=mkText(h,textStr,tag,rows,cols,enb,vis)%#ok<INUSL>
    widget.Tag=tag;
    widget.Name=textStr;
    widget.Type='text';
    widget.WordWrap=1;
    widget.RowSpan=rows;
    widget.ColSpan=cols;
    widget.Visible=vis;
    widget.Enabled=enb;
end

function edit=mkEdit(h,name,obj,isObjMeth,method,rows,cols,enb,vis)
    edit=mkWidget(h,name,obj,'edit',{},isObjMeth,method,rows,...
    cols,enb,vis,false);
end

function checkbox=mkCheckbox(h,name,obj,isObjMeth,method,...
    rows,cols,enb,vis,mode)
    checkbox=mkWidget(h,name,obj,'checkbox',{},isObjMeth,...
    method,rows,cols,enb,vis,mode);
end

function combobox=mkCombobox(h,label,obj,entries,isObjMeth,...
    method,rows,cols,enb,vis)
    combobox=mkWidget(h,label,obj,'combobox',entries,isObjMeth,...
    method,rows,cols,enb,vis,false);
end

function panel=mkPanel(name,items,rows,cols,layout,colStretch,...
    enabled,visible)
    panel.Name=name;
    panel.Type='panel';
    panel.Tag=[strrep(strrep(name,' ',''),':',''),'Tag'];
    panel.RowSpan=rows;
    panel.ColSpan=cols;
    panel.LayoutGrid=layout;
    panel.ColStretch=colStretch;
    panel.Enabled=enabled;
    panel.Visible=visible;
    panel.Items=items;
end

function widget=mkWidget(h,name,obj,type,entries,isObjMeth,...
    method,row,col,enb,vis,mode)
    widget.Name=name;
    if~isempty(obj)
        widget.ObjectProperty=obj;
        widget.Tag=[widget.ObjectProperty,'Tag'];
    end
    widget.Type=type;
    widget.Entries=entries;
    widget.RowSpan=row;
    widget.ColSpan=col;
    if isObjMeth
        widget.ObjectMethod=method;
        widget.MethodArgs={'%dialog',obj,'%value'};
        widget.ArgDataTypes={'handle','mxArray','mxArray'};
    elseif~isempty(method)
        widget.MatlabMethod=method;
        widget.MatlabArgs={h.Root.getActiveConfigSet};
    end
    widget.Visible=vis;
    widget.Enabled=enb;
    widget.Tunable=false;
    widget.DialogRefresh=true;
    widget.Mode=mode;
    widget.Tunable=false;
end

function widget=mkButton(h,name,tag,method,rows,cols,enb,vis,tip)
    widget.Name=name;
    widget.Tag=tag;
    widget.Type='pushbutton';
    widget.RowSpan=rows;
    widget.ColSpan=cols;
    widget.ToolTip=tip;
    widget.MatlabMethod=method;
    widget.MatlabArgs={h,'%dialog'};
    widget.Visible=vis;
    widget.Enabled=enb;
    widget.DialogRefresh=true;
end

function widget=mkGroup(h,name,tag,items,row,col,layout,...
    rowStretch,colStretch,enb,vis)%#ok<INUSL>
    if isempty(rowStretch),rowStretch=[zeros(1,layout(1)-1),1];end
    if isempty(colStretch),colStretch=[zeros(1,layout(2)-1),1];end
    widget.Name=name;
    widget.Tag=tag;
    widget.Type='group';
    widget.RowSpan=row;
    widget.ColSpan=col;
    widget.LayoutGrid=layout;
    widget.RowStretch=rowStretch;
    widget.ColStretch=colStretch;
    widget.Visible=vis;
    widget.Enabled=enb;
    widget.Items=items;
end

function tableValueChangedCallback(h,hDlg,row,col,value)%#ok<DEFNU>
    if~isvarname(value)&&~h.validateTableValue(hDlg,value)

        oldValue=h.taskDurationData(row+1,col+1);
        hDlg.setTableItemValue('taskDurationTable',row,col,oldValue);
        return
    end
    h.taskDurationData{row+1,col+1}=value;
    soc.internal.dialog.updateTaskDurationData(h);
end

function tableCurrentItemChangedCallback(h,~,row,col)%#ok<DEFNU>
    h.selectedTableRow=row+1;
    h.selectedTableCol=col+1;
end

function res=isDurationSourceDiagFile(h)%#ok<DEFNU>
    res=isequal(h.taskDurationSource,'Recorded task execution statistics');
end

function ret=validateTableValue(~,~,value)%#ok<DEFNU>
    try
        numVal=str2num(value);%#ok<ST2NM>
        ret=isnumeric(numVal)&&isreal(numVal)&&isscalar(numVal);
    catch ME %#ok<NASGU>
        ret=0;
    end
    if~ret
        txt=DAStudio.message('soc:utils:InvalidDurTableValue');
        errordlg(txt,'Error');
    end
end
