function dirty=taskMapButtonCallback(hMask,hDlg,tag,dlgType)%#ok<INUSD>



    dirty=false;
    mdlName=get_param(hMask.getModel,'Name');
    tskMgrBlk=soc.internal.connectivity.getTaskManagerBlock(mdlName,true);


    if~isempty(tskMgrBlk)
        openTaskMapDlgs=[];

        tag='SoCBlocksetTaskMapDlg';
        openDlgsWithTag=findDDGByTag(tag);
        if~isempty(openDlgsWithTag)
            tgtSrc='TaskManagerDlg.TaskManagerMap';
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
    else
        str=DAStudio.message('codertarget:utils:TaskManagerMissing');
        lbl=DAStudio.message('codertarget:utils:TaskMapErrDlgLabel');
        fig=errordlg(str,lbl,'modal');
        waitfor(fig);
    end
end
