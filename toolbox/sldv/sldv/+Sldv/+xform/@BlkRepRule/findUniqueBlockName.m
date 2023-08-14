function blockName=findUniqueBlockName(system,baseName)




    allBlocks=find_system(system,'searchdepth',1,'FollowLinks','on');
    names=get_param(allBlocks,'name');
    names(1)=[];

    index=strmatch(baseName,names);
    sizeindex=length(index);
    if sizeindex==0
        blockName=baseName;
    else
        blockName=[baseName,num2str(floor(sizeindex/3))];
    end

end