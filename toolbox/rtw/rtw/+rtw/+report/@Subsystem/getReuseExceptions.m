function retVal=getReuseExceptions(obj)
    retVal={};
    diagInfo=obj.ReuseDiag;
    for i=1:length(diagInfo)
        if isempty(diagInfo(i).Blockers)
            continue
        end
        if isempty(diagInfo(i).BlockSID)
            continue
        end
        nl=sprintf('\n');
        nameCol=obj.getHyperlink(diagInfo(i).BlockSID,sprintf('<S%d>',diagInfo(i).SystemID));
        currStr=['<A NAME="S',int2str(diagInfo(i).SystemID),'blker">',DAStudio.message('RTW:report:ReuseExceptionReason',nameCol),' </B><BR />',nl];
        retVal{end+1}=currStr;
        for k=1:length(diagInfo(i).Blockers)
            blk=getfullname(diagInfo(i).Blockers(k).SrcBlock);
            srcName=obj.getHyperlink(diagInfo(i).Blockers(k).SrcBlock,blk);
            retVal{end+1}=['<ul>',nl];
            retVal{end+1}=['<li>',diagInfo(i).Blockers(k).Reason,' [',srcName,']</li>'];
            retVal{end+1}=['</ul>',nl];
        end
    end
end
