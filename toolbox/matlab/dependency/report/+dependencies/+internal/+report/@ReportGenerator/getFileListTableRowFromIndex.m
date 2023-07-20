function row=getFileListTableRowFromIndex(this,index,docType)





    fileNode=this.FileNodes(index);
    location=fileNode.Location{1};
    problems=formatProblems(this.Problems(location));
    fileType=dependencies.internal.viewer.getFileType(location);
    fileName=this.getFileName(index,docType);
    row={fileName,fileType,problems};
end
