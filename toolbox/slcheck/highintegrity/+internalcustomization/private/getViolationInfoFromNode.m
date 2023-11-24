function violationObj=getViolationInfoFromNode(object,node,issue)

    violationObj=ModelAdvisor.ResultDetail;
    try
        nodeStrCell=strsplit(node.tree2str,newline);
    catch
        nodeStrCell='';
    end
    if isa(object,'struct')
        ModelAdvisor.ResultDetail.setData(violationObj,'FileName',object.FileName,'Expression',[strtrim(nodeStrCell{1}),'...'],'TextStart',node.position,'TextEnd',node.endposition);
    else
        ModelAdvisor.ResultDetail.setData(violationObj,'SID',object,'Expression',[strtrim(nodeStrCell{1}),'...'],'TextStart',node.position-1,'TextEnd',node.endposition);
    end

    if~isempty(issue)
        violationObj.RecAction=issue;
    end

end