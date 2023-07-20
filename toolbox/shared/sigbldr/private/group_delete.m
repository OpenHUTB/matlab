function UD=group_delete(UD,deleteIdx)




    grpCnt=length(UD.dataSet);

    if grpCnt<2
        return;
    end

    if nargin<2||isempty(deleteIdx)
        deleteIdx=UD.current.dataSetIdx;
    end

    tobeDeleted=sort(deleteIdx(:),'ascend')';

    if(isempty(find(tobeDeleted==UD.current.dataSetIdx,1)))


        newActiveGroup=UD.current.dataSetIdx;
        relativeActiveGroupIdx=UD.current.dataSetIdx-length(find(tobeDeleted<UD.current.dataSetIdx));

        if(newActiveGroup==grpCnt)
            newActiveGroup=relativeActiveGroupIdx;
        end
    elseif(length(deleteIdx)==grpCnt)
        newActiveGroup=tobeDeleted(1);
        tobeDeleted=tobeDeleted(2:end);
        relativeActiveGroupIdx=1;
    elseif(tobeDeleted(1)==1)
        tobeDeletedPadded=[tobeDeleted,zeros(1,grpCnt-length(deleteIdx))];
        tbdIdx=find(1:grpCnt~=tobeDeletedPadded);
        newActiveGroup=tbdIdx(1);
        relativeActiveGroupIdx=1;
    else
        newActiveGroup=tobeDeleted(1)-1;
        relativeActiveGroupIdx=tobeDeleted(1)-1;
    end



    UD=group_activate(UD,newActiveGroup,false,true,relativeActiveGroupIdx);


    for i=length(tobeDeleted):-1:1
        sigbuilder_tabselector('removeentry',UD.hgCtrls.tabselect.axesH,tobeDeleted(i));
        if isfield(UD,'common')&&UD.common.dirtyFlag~=1
            UD=set_dirty_flag(UD);
        end
    end
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,relativeActiveGroupIdx,1);
    UD.dataSet(tobeDeleted)=[];



    if tobeDeleted==1
        UD.current.dataSetIdx=1;
    end
    UD=dataSet_sync_menu_state(UD);



    set(UD.dialog,'UserData',UD)
    vnv_notify('sbBlkGroupDelete',UD.simulink.subsysH,tobeDeleted);
