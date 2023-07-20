function result=actionDisconnectedDividerBlocks(taskobj)












    [rfbLicensed,~]=builtin('license','checkout','rf_blockset');

    if~rfbLicensed
        mdladvObj=taskobj.MAObj;
        result=ModelAdvisor.Paragraph;
        addItem(result,ModelAdvisor.Text(DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_NoneFixed'),{'bold'}));
        addItem(result,[ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        addItem(result,ModelAdvisor.Text(DAStudio.message(...
        'simrf:advisor:NoLicenseForAction'),{'fail'}));
        mdladvObj.setActionEnable(false);
        return
    end


    mdladvObj=taskobj.MAObj;
    checkObj=taskobj.Check;
    if~isa(checkObj,'ModelAdvisor.Check')




        checkObj=mdladvObj.getCheckObj(...
        'mathworks.design.rfblockset.ce.checkDisconnectedDividerBlocks');
    end
    resultDetailObjs=checkObj.ResultDetails;
    assert(~isempty(resultDetailObjs),DAStudio.message(...
    'simrf:advisor:ResultDetailsEmpty','resultDetailObjs'));
    model=Simulink.ID.getModel(resultDetailObjs(1).Data);
    dcblks=cell2mat(Simulink.ID.getHandle({resultDetailObjs.Data}));


    if numel(dcblks)==1
        phPort3=get_param(dcblks,'PortHandles').RConn(2);
    else
        phPort3=cellfun(@(x)x.RConn(2),get_param(dcblks,'PortHandles'));
    end
    curPosPort3=get_param(phPort3,'Position');
    if isnumeric(curPosPort3)&&isequal(size(curPosPort3),[1,2])
        curPosPort3={curPosPort3};
    end
    prevPosPort3=estimatePreviousPort3Position(dcblks,curPosPort3);


    mdlh=get_param(model,'Handle');
    dclines=helperDisconnectedDividerBlocks(mdlh,'findlines');











    dcblkParents=get_param(dcblks,'Parent');
    thresholdDistance=10;

    for idx=1:numel(dclines)
        L=dclines(idx);
        linePts=get_param(L,'Points');
        idxCandidates=find(strcmp(get_param(L,'Parent'),dcblkParents));
        if~isempty(idxCandidates)
            if get_param(L,'SrcBlockHandle')==-1
                dists=vecnorm(...
                linePts(1,:)-vertcat(prevPosPort3{idxCandidates}),2,2);
                minDist=min(dists);
                idxMinDist=find(dists==minDist);
                if numel(idxMinDist)==1&&minDist<thresholdDistance
                    idxBlk=idxCandidates(idxMinDist);
                    linePts(1,:)=curPosPort3{idxBlk};
                    set_param(L,'Points',linePts)
                end
            end
            if get_param(L,'DstBlockHandle')==-1
                dists=vecnorm(...
                linePts(end,:)-vertcat(prevPosPort3{idxCandidates}),2,2);
                minDist=min(dists);
                idxMinDist=find(dists==minDist);
                if numel(idxMinDist)==1&&minDist<thresholdDistance
                    idxBlk=idxCandidates(idxMinDist);
                    linePts(end,:)=curPosPort3{idxBlk};
                    set_param(L,'Points',linePts)
                end
            end
        end
    end


    [fixedBlks,unfixedBlks]=...
    helperDisconnectedDividerBlocks(dcblks,'filterblocks');




    for idx=1:numel(fixedBlks)
        set_param(fixedBlks(idx),'HiliteAncestors','greenWhite')
    end
    for idx=1:numel(unfixedBlks)
        set_param(unfixedBlks(idx),'HiliteAncestors','redWhite')
    end







    overview=ModelAdvisor.FormatTemplate('ListTemplate');
    assert(~isempty(unfixedBlks)||~isempty(fixedBlks),DAStudio.message(...
    'simrf:advisor:FixedAndUnfixedBlockListsBothEmpty',...
    '''fixedBlks''','''unfixedBlks'''))
    if isempty(unfixedBlks)&&~isempty(fixedBlks)
        setCheckText(overview,ModelAdvisor.Text(DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_AllFixed'),{'bold'}));
        resultUnfixed={};
        resultFixed=populateFixedResults(fixedBlks);
    elseif~isempty(unfixedBlks)&&isempty(fixedBlks)
        setCheckText(overview,ModelAdvisor.Text(DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_NoneFixed'),{'bold'}));
        resultUnfixed=populateUnfixedResults(unfixedBlks);
        resultFixed={};
    elseif~isempty(unfixedBlks)&&~isempty(fixedBlks)
        setCheckText(overview,ModelAdvisor.Text(DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_SomeFixed'),{'bold'}));
        resultUnfixed=populateUnfixedResults(unfixedBlks);
        resultFixed=populateFixedResults(fixedBlks);
    end

    linkToRemoveHighlighting=ModelAdvisor.Text(DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_RemoveBlockHighlighting'));
    setHyperlink(linkToRemoveHighlighting,sprintf(...
    'matlab:SLStudio.Utils.RemoveHighlighting(''%s'')',model))

    result=[{overview},resultUnfixed,resultFixed,{linkToRemoveHighlighting}];
    mdladvObj.setActionEnable(false);
end


function prevPosPort3=estimatePreviousPort3Position(blks,curPosPort3)






    prevPosPort3=cell(size(curPosPort3));
    for idx=1:numel(blks)
        blkPos=get_param(blks(idx),'Position');
        switch get_param(blks(idx),'Orientation')
        case 'right'
            prevPosPort3{idx}=curPosPort3{idx}-[blkPos(3)-blkPos(1),0];
        case 'down'
            prevPosPort3{idx}=curPosPort3{idx}-[0,blkPos(4)-blkPos(2)];
        case 'left'
            prevPosPort3{idx}=curPosPort3{idx}+[blkPos(3)-blkPos(1),0];
        case 'up'
            prevPosPort3{idx}=curPosPort3{idx}+[0,blkPos(4)-blkPos(2)];
        end
    end
end


function result=populateUnfixedResults(blks)




    result=ModelAdvisor.FormatTemplate('ListTemplate');
    setCheckText(result,ModelAdvisor.Text(DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_UnfixedBlocksInfo'),...
    {'bold','fail'}));
    setListObj(result,blks);
    setRecAction(result,DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_UnfixedBlocksActions'));
    setSubBar(result,true);
    result={result};
end


function result=populateFixedResults(blks)




    result=ModelAdvisor.FormatTemplate('ListTemplate');
    setCheckText(result,ModelAdvisor.Text(DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_FixedBlocksInfo'),...
    {'bold','pass'}));
    setListObj(result,blks);
    setRecAction(result,DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_FixedBlocksActions'));
    setSubBar(result,true);
    result={result};
end