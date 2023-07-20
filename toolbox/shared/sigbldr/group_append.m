function UD=group_append(input,SBSigSuite)









    if ishandle(input)
        blockH=input;
        figH=get_param(blockH,'UserData');
        if~isempty(figH)&&ishghandle(figH,'figure')
            guiOpen=1;
            UD=get(figH,'UserData');
        else
            guiOpen=0;


            fromWsH=find_system(blockH,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all','BlockType','FromWorkspace');
            UD=get_param(fromWsH,'SigBuilderData');
        end
    else
        blockH=input.simulink.subsysH;
        guiOpen=1;
        UD=input;
    end
    channels=UD.channels;
    dataSet=UD.dataSet;

    grpCnt=SBSigSuite.NumGroups;
    ActiveGroup=SBSigSuite.ActiveGroup;
    sigCnt=SBSigSuite.Groups(ActiveGroup).NumSignals;

    curGrpCnt=length(dataSet);


    newGrpCnt=grpCnt-curGrpCnt;




    if newGrpCnt>=1
        visibility=set_group_visibility(sigCnt,newGrpCnt);
        dispIdx=flipud(find(visibility(:,1)));
        dispIdx=dispIdx';
    end
    for i=newGrpCnt:-1:1






        grpName=SBSigSuite.Groups(curGrpCnt+i).Name;
        timeVec=SBSigSuite.Groups(curGrpCnt+i).Signals(1).XData;
        newDataSet(i)=dataSet_data_struct(grpName,[timeVec(1),timeVec(end)],dispIdx);
    end


    if~isfield(dataSet,'displayRange')
        for idx=1:length(dataSet)
            dataSet(idx).displayRange=dataSet(idx).timeRange;
        end
    end

    for n=1:sigCnt
        channels(n).label=SBSigSuite.Groups(ActiveGroup).Signals(n).Name;
    end

    dataSet=[dataSet,newDataSet];


    if guiOpen
        UD.channels=channels;
        UD.dataSet=dataSet;
        UD.sbobj=SBSigSuite;
        for i=1:newGrpCnt

            grpName=SBSigSuite.Groups(curGrpCnt+i).Name;
            sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,grpName);
        end
        UD=dataSet_sync_menu_state(UD);

        for sigIdx=1:sigCnt
            sigName=SBSigSuite.Groups(ActiveGroup).Signals(sigIdx).Name;
            UD=G_signal_rename(UD,sigIdx,sigName);
        end
        UD=trimDataPoints(UD);
        set(UD.dialog,'UserData',UD)
    else
        UD.channels=channels;
        UD.dataSet=dataSet;
        UD.sbobj=SBSigSuite;
        UD=trimDataPoints(UD);
        set_param(fromWsH,'SigBuilderData',UD);
    end



    handleStruct=sigbuilder_block('create_handleStruct',blockH);
    renameDuplicatePorts(handleStruct,channels,sigCnt);

    for idx=1:newGrpCnt
        vnv_notify('sbBlkGroupAdd',blockH,curGrpCnt+idx);
    end
end
