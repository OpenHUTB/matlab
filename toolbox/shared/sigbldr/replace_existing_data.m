function UD=replace_existing_data(input,SBSigSuite)








    blockH=input.simulink.subsysH;
    UD=input;

    curSigCnt=length(UD.channels);
    curGrpCnt=length(UD.dataSet);

    newSigCnt=SBSigSuite.Groups(1).NumSignals;
    ActiveGroup=SBSigSuite.ActiveGroup;






    set(UD.hgCtrls.chanListbox,'Value',1);



    if(curGrpCnt>1)
        UD=signals_delete(UD,1:curSigCnt,2:curGrpCnt);
    end

    if(curSigCnt==newSigCnt)

        UD=signal_replace_rename(UD,SBSigSuite,newSigCnt);

    elseif(curSigCnt>newSigCnt)

        UD=signals_delete(UD,(newSigCnt+1):curSigCnt,1);

        UD=signal_replace_rename(UD,SBSigSuite,newSigCnt);

    else

        UD=signal_replace_rename(UD,SBSigSuite,curSigCnt);


        partialSbobj=SBSigSuite.copyObj;
        partialSbobj=partialSbobj.groupSignalSelect(1,1:newSigCnt);


        drawnow();
        UD=signal_append(UD,partialSbobj);
    end


    newName=SBSigSuite.Groups(1).Name;
    UD.dataSet(1).name=newName;
    UD.sbobj.Groups(1).Name=newName;
    sigbuilder_tabselector('rename',UD.hgCtrls.tabselect.axesH,1,newName);





    grpCnt=SBSigSuite.NumGroups;
    newGrpCnt=grpCnt-1;
    curGrpCnt=length(UD.dataSet);




    if newGrpCnt>=1
        visibility=set_group_visibility(newSigCnt,newGrpCnt);
        dispIdx=flipud(find(visibility(:,1)));
        dispIdx=dispIdx';
    end
    for i=newGrpCnt:-1:1
        grpName=SBSigSuite.Groups(curGrpCnt+i).Name;
        timeVec=SBSigSuite.Groups(curGrpCnt+i).Signals(1).XData;
        newDataSet(i)=dataSet_data_struct(grpName,[timeVec(1),timeVec(end)],dispIdx);
    end
    if newGrpCnt>=1
        UD.dataSet=[UD.dataSet,newDataSet];
    end

    for n=1:newSigCnt
        UD.channels(n).label=SBSigSuite.Groups(ActiveGroup).Signals(n).Name;
    end


    for i=1:newGrpCnt
        UD.sbobj.groupAppend(SBSigSuite.Groups(curGrpCnt+i));

        grpName=SBSigSuite.Groups(curGrpCnt+i).Name;
        sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,grpName);
    end
    UD=dataSet_sync_menu_state(UD);

    for sigIdx=1:newSigCnt
        sigName=SBSigSuite.Groups(ActiveGroup).Signals(sigIdx).Name;
        UD=G_signal_rename(UD,sigIdx,sigName);
    end
    set(UD.dialog,'UserData',UD)




    handleStruct=sigbuilder_block('create_handleStruct',blockH);
    for sigIdx=1:newSigCnt
        sigbuilder_block('rename_outport',handleStruct,sigIdx,UD.channels(sigIdx).label);
    end


    for idx=1:newGrpCnt
        vnv_notify('sbBlkGroupAdd',blockH,curGrpCnt+idx);
    end
end


function UD=signals_delete(UD,signalIdx,groupIdx)
    SBSigSuite=UD.sbobj;
    ActiveGroup=SBSigSuite.ActiveGroup;
    grpCnt=SBSigSuite.NumGroups;
    sigCnt=SBSigSuite.Groups(ActiveGroup).NumSignals;

    removeGroups=groupIdx;
    if isequal(signalIdx,1:sigCnt)
        groupRemove(SBSigSuite,removeGroups(:));
        UD=group_delete(UD,removeGroups(:)');
        return;
    elseif isequal(groupIdx,1:grpCnt)
        removeSignals=signalIdx;

        groupSignalRemove(SBSigSuite,removeSignals);
        for sigIdx=sort(removeSignals(:),'descend')'
            UD=remove_channel(UD,sigIdx);
        end
        set(UD.dialog,'UserData',UD)
        return;
    end

end

function UD=signal_replace_rename(UD,SBSigSuite,newSigCnt)



    for n=newSigCnt:-1:1
        channels(n).label=SBSigSuite.Groups(1).Signals(n).Name;
    end
    handleStruct=UD.simulink;
    renameDuplicatePorts(handleStruct,channels,newSigCnt);


    for idx=newSigCnt:-1:1

        xData=SBSigSuite.Groups(1).Signals(idx).XData;
        yData=SBSigSuite.Groups(1).Signals(idx).YData;
        tstart=min(SBSigSuite.Groups(1).Signals(idx).XData);
        tend=max(SBSigSuite.Groups(1).Signals(idx).XData);
        UD.common.dispTime=[tstart,tend];
        UD.common.maxTime=tend;
        UD.common.minTime=tstart;
        UD.dataSet.displayRange=[tstart,tend];
        UD.dataSet.timeRange=[tstart,tend];
        UD=apply_new_channel_data(UD,idx,xData,yData,1);

        axesIdx=UD.channels(idx).axesInd;
        if(axesIdx~=0)
            UD=rescale_axes_to_fit_data(UD,UD.channels(idx).axesInd,idx);
            set(UD.axes(axesIdx).handle,'XLim',UD.dataSet.timeRange);
        end


        sigName=SBSigSuite.Groups(1).Signals(idx).Name;
        UD=G_signal_rename(UD,idx,sigName);
    end

    UD=trimDataPoints(UD);
end



