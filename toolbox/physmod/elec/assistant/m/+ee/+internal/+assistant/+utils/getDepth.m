function depthList=getDepth(blockList)






    n=numel(blockList);
    depthList=zeros(n,1);
    for idxBlock=1:n
        thisBlock=blockList{idxBlock};
        depth=1;
        while~isempty(get_param(thisBlock,'parent'))
            thisBlock=get_param(thisBlock,'parent');
            depth=depth+1;
        end
        depthList(idxBlock)=depth;
    end

end