function stmt=addPathInformation(group,pathList,outValue)












    if isempty(group)
        stmt=group;
    end

    for i=1:length(group)
        thisStmt=group(i);
        if~isfield(thisStmt,'pathList')
            thisStmt.pathList=pathList;
        else
            thisStmt.pathList=[thisStmt.pathList,pathList];
        end

        if(nargin>2)
            thisStmt.outValue=outValue;
        elseif~isfield(thisStmt,'outValue')
            thisStmt.outValue='';
        end
        stmt(i)=thisStmt;
    end
end

