function UD=dataSet_reorder(UD,old2NewIdx,newActiveIdx)




    UD.dataSet=UD.dataSet(old2NewIdx);
    UD.sbobj.groupReorder(old2NewIdx);
    UD.current.dataSetIdx=newActiveIdx;
    UD.sbobj.ActiveGroup=newActiveIdx;


    deltaIdx=old2NewIdx-(1:(length(old2NewIdx)));
    destIdx=find(deltaIdx==max(abs(deltaIdx))|deltaIdx==-max(abs(deltaIdx)));
    destIdx=destIdx(1);
    srcIdx=find(deltaIdx~=0);
    if deltaIdx(destIdx)>0
        srcIdx=srcIdx(end);
    else
        srcIdx=srcIdx(1);
    end

    sigbuilder_tabselector('movetab',UD.hgCtrls.tabselect.axesH,srcIdx,destIdx);
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,newActiveIdx,1);
    UD=dataSet_sync_menu_state(UD);


    remap(old2NewIdx)=1:(length(UD.dataSet));
    vnv_notify('sbBlkGroupMove',UD.simulink.subsysH,remap,newActiveIdx);
