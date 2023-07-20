function dirty=taskMapButtonCallback(hMask,hDlg,tag,dlgType)%#ok<INUSD>




    dirty=false;
    mdlName=get_param(hMask.getModel,'Name');


    hwiBlk=codertarget.internal.taskmapper.findHWI(mdlName);

    if codertarget.utils.isTaskManagerFound(mdlName)
        tskMgrBlk=soc.internal.connectivity.getTaskManagerBlock(mdlName,true);
        openTaskMapDlgs=[];

        tag='SoCBlocksetTaskMapDlg';
        openDlgsWithTag=findDDGByTag(tag);
        if~isempty(openDlgsWithTag)
            tgtSrc='TaskManagerDlg.SoCBTaskManagerMap';
            idx=arrayfun(@(x)isa(x.getDialogSource,tgtSrc),openDlgsWithTag);
            if~isempty(idx),openTaskMapDlgs=openDlgsWithTag(idx);end
        end
        switch(numel(openTaskMapDlgs))
        case 0
            blkHandle=get_param(tskMgrBlk,'Handle');
            if iscell(blkHandle),blkHandle=cell2mat(blkHandle);end
            taskMapObj=TaskManagerDlg.TaskManagerMap(blkHandle);
            DAStudio.Dialog(taskMapObj);
        case 1
            openTaskMapDlgs.show;
        otherwise
            assert(false,'Multiple Task Map dialogs open');
        end
    elseif~isempty(hwiBlk)


        openTaskMapDlgs=[];
        tag='SoCBlocksetTaskMapDlg';
        openDlgsWithTag=findDDGByTag(tag);
        if~isempty(openDlgsWithTag)
            tgtSrc='TaskManagerAppDlg.TaskManagerAppMap';
            idx=arrayfun(@(x)isa(x.getDialogSource,tgtSrc),openDlgsWithTag);
            if~isempty(idx),openTaskMapDlgs=openDlgsWithTag(idx);end
        end
        switch(numel(openTaskMapDlgs))
        case 0
            blkHandle=get_param(hwiBlk,'Handle');
            if iscell(blkHandle),blkHandle=cell2mat(blkHandle);end
            taskMapObj=TaskManagerAppDlg.TaskManagerAppMap(blkHandle,mdlName);
            DAStudio.Dialog(taskMapObj);
        case 1
            openTaskMapDlgs.show;
        otherwise
            assert(false,'Multiple Task Map dialogs open');
        end
    else
        if isequal(get_param(getActiveConfigSet(mdlName),'HardwareBoardFeatureSet'),'SoCBlockset')
            str=DAStudio.message('codertarget:taskmap:TaskManagerMissing');
        else
            str=DAStudio.message('codertarget:taskmap:HWIMissing');
        end
        lbl=DAStudio.message('codertarget:taskmap:TaskMapErrDlgLabel');
        fig=errordlg(str,lbl,'modal');
        waitfor(fig);
    end
end
