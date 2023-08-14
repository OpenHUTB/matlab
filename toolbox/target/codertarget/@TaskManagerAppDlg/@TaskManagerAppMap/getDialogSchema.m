function dialog=getDialogSchema(h,~)




    dialog.LayoutGrid=[2,1];
    dialog.RowStretch=[0,1];
    dialog.CloseMethod='closeCallback';
    dialog.CloseMethodArgs={'%dialog'};
    dialog.CloseMethodArgsDT={'handle'};
    dialog.PreApplyMethod='taskManagerAppMapPreApplyCallback';
    dialog.PreApplyArgs={'%dialog'};
    dialog.PreApplyArgsDT={'handle'};
    dialog.HelpMethod='codertarget.internal.taskmapper.helpview';
    dialog.HelpArgs={'codertarget_taskmapping'};
    dialog.HelpArgsDT={'string'};
    dialog.DialogTag='SoCBlocksetTaskMapDlg';
    dlgItems={};
    dlgItems{end+1}=locConstructInfoText(h,[1,1],[1,1]);
    dlgItems{end+1}=locConstructMapGroup(h,[2,2],[1,1]);
    dialog.Items=dlgItems;
    dialog.DialogTitle=DAStudio.message('codertarget:taskmap:TaskMapDlgTitle');
    simStatus=h.Root.SimulationStatus;
    if any(strcmp(simStatus,{'running','paused','external'}))
        dialog=h.disableNontunables(dialog);
    end
end


function txt=locConstructInfoText(h,rowSpan,colSpan)
    descr=DAStudio.message('codertarget:taskmap:TaskMapDesc');
    txt=makeText(h,descr,'_DescriptionTag',rowSpan,colSpan,1,1);
end


function group=locConstructMapGroup(h,rowSpan,colSpan)
    label='Task Mapping';
    layout=[2,2];
    showAutoTaskMap=1;
    group=makeGroup(h,label,'_MappingGroupTag',{},rowSpan,colSpan,...
    layout,[],[1,0],1,1);
    items{1}=locConstructTaskMappingTable(h);

    for i=1:numel(h.TskMgrBlocks)
        thisMgr=h.TskMgrBlocks(i);
        mdlName=bdroot(thisMgr.getFullName);
        hwBoard=get_param(mdlName,'HardwareBoard');
        if isequal(get_param(getActiveConfigSet(mdlName),'HardwareBoardFeatureSet'),'SoCBlockset')

            tgtHWInfo=codertarget.targethardware.getTargetHardwareFromNameForSoC(hwBoard);
            if~tgtHWInfo.TaskMap.useAutoMap
                showAutoTaskMap=0;
            end
        else
            showAutoTaskMap=0;
        end


        break;
    end
    if showAutoTaskMap
        items{2}=locConstructTaskMapAutoMapButton(h);
        items{3}=locConstructTaskMapCheckMapButton(h);
    end
    group.Items=items;
end


function tbl=locConstructTaskMappingTable(h)
    import soc.internal.taskmanager.*
    import soc.internal.connectivity.*
    colHead={'Task name','Event source'};
    rowSpan=[1,2];
    colSpan=[1,1];
    [nTasks,~]=size(h.taskMappingData);
    autoAssigned=DAStudio.message('codertarget:taskmap:AutoAssigned');
    for i=1:nTasks
        tblCellType{i,1}='edit';%#ok<*AGROW>
        tblCellType{i,2}='combobox';
        tblCellEntries{i,1}={};
        tblCellEntries{i,2}=h.eventList;
        tblCellEnb(i,1)=0;
        tblCellEnb(i,2)=~isequal(h.taskMappingData{i,3},autoAssigned);
    end
    tip=DAStudio.message('codertarget:taskmap:TaskMapTip');
    tbl=makeTable(h,colHead,'_TaskMapTableTag',h.taskMappingData,...
    tblCellType,tblCellEntries,tblCellEnb,...
    rowSpan,colSpan,1,1,tip);
end


function btn=locConstructTaskMapAutoMapButton(h)

    align_top_center=3;
    rowSpan=[1,1];
    colSpan=[2,2];
    lbl=DAStudio.message('soc:taskmap:TaskMapAutoMapLbl');
    tip=DAStudio.message('soc:taskmap:TaskMapAutoMapTip');
    enb=locHasEventDrivenTasks(h);
    btn=makeButton(h,lbl,'_TaskMapAutoAssignButtonTag',...
    'soc.internal.taskmanager.autoassignTaskMapButtonCallback',...
    rowSpan,colSpan,enb,1,tip,align_top_center);
end


function btn=locConstructTaskMapCheckMapButton(h)

    align_top_center=3;
    rowSpan=[2,2];
    colSpan=[2,2];
    lbl=DAStudio.message('soc:taskmap:TaskMapCheckMapLbl');
    tip=DAStudio.message('soc:taskmap:TaskMapCheckMapTip');
    enb=locHasEventDrivenTasks(h);
    btn=makeButton(h,lbl,'_TaskMapVerifyButtonTag',...
    'soc.internal.taskmanager.verifyTaskMapButtonCallback',...
    rowSpan,colSpan,enb,1,tip,align_top_center);
end


function out=locHasEventDrivenTasks(h)
    out=false;
    for i=1:numel(h.TskMgrBlocks)
        thisMgr=h.TskMgrBlocks(i);
        out=out||soc.internal.taskmanager.hasEventDrivenTasks(thisMgr.getFullName);
    end
end
