function hyperName=getFileName(this,index,docType)




    fileNode=this.FileNodes(index);
    name=getNameFromFileNode(fileNode);
    hyperName=mlreportgen.dom.InternalLink(string(index),name);
    if docType~="HTML-FILE"
        return
    end
    url="matlab:dependencies.internal.report.openNode('"+...
    fileNode.Location{1}+"')";
    hyperName=addOpenActionIcon(hyperName,url,name);
end
