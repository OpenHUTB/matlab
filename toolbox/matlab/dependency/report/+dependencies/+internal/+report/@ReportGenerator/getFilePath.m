function hyperPath=getFilePath(this,index,root,docType)




    fileNode=this.FileNodes(index);
    location=fileNode.Location{1};
    hyperPath=location;
    if~isempty(root)&&startsWith(location,root)
        hyperPath=regexprep(hyperPath,root,"$");
    end
    if docType~="HTML-FILE"
        return
    end
    fileName=getNameFromFileNode(fileNode);
    url="matlab:dependencies.internal.report.openNode('"+...
    location+"')";
    hyperPath=addOpenActionIcon(hyperPath,url,fileName);
end
