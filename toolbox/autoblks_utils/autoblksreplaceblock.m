function NewBlkHdl=autoblksreplaceblock(ParentBlk,OptionList,SelectedOptionIndex)


    if ischar(ParentBlk)
        FullParentName=ParentBlk;
        ParentBlk=get_param(ParentBlk,'Handle');
    else
        FullParentName=getfullname(ParentBlk);
    end

    OldBlock=find_system(ParentBlk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','Name',OptionList{SelectedOptionIndex,2},'Parent',FullParentName);
    if~isempty(OldBlock)
        NewBlkHdl=OldBlock;
        return;
    end


    for i=1:length(OptionList)
        OldBlock=find_system(ParentBlk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','Name',OptionList{i,2},'Parent',FullParentName);
        if~isempty(OldBlock)
            break
        end

    end
    OldConns=autoblksgetblockconn(OldBlock);


    for i=1:length(OldConns.Inports)
        delete_line(OldConns.Inports(i).LineHdl);
    end


    for i=1:length(OldConns.Outports)
        ChildLinePoints=FindChildLinePoints(OldConns.Outports(i).LineHdl);
        delete_line(OldConns.Outports(i).LineHdl);
        for j=1:length(ChildLinePoints)
            add_line(ParentBlk,ChildLinePoints(j));
        end
    end


    for i=1:length(OldConns.LConns)
        delete_line(OldConns.LConns(i).LineHdl);
    end
    for i=1:length(OldConns.RConns)
        delete_line(OldConns.RConns(i).LineHdl);
    end

    Position=get_param(OldBlock,'Position');
    delete_block(OldBlock);
    NewBlockName=[FullParentName,'/',OptionList{SelectedOptionIndex,2}];
    add_block(OptionList{SelectedOptionIndex,1},NewBlockName,'Position',Position);
    NewBlkHdl=get_param(NewBlockName,'Handle');

    autoblksreconnectblock(NewBlkHdl,OldConns)

end


function ChildLinePoints=FindChildLinePoints(LineHdl)
    ChildLinePoints={};
    LineChildren=get_param(LineHdl,'LineChildren');
    for i=1:length(LineChildren)
        ChildLinePoints=[ChildLinePoints,get_param(LineChildren(i),'Points')];
        ChildLinePoints=[ChildLinePoints,FindChildLinePoints(LineChildren(i))];
    end

end
