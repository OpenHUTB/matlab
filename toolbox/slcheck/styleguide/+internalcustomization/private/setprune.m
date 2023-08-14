










function tree=setprune(trunk,branch,option)


    tree=trunk;

    ChildBlocks={};
    for n=1:length(branch)

        tempChildren=find_system(branch{n,1},...
        'SearchDepth',1,...
        'FollowLinks','on',...
        'LookUnderMasks','on',...
        'Type','Block');
        if length(tempChildren)>1
            ChildBlocks=[ChildBlocks;...
            tempChildren(2:end,1)];%#ok<AGROW>
        end
    end

    if strcmpi(option,'NoSubSystems')



        ChildBlockTypes=get_param(ChildBlocks,'BlockType');
        ChildBlocks=ChildBlocks(~strcmpi(ChildBlockTypes,'SubSystem'));
    end


    tree=setdiff(tree,ChildBlocks);
end