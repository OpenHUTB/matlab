function newPath=slPathToRelativePath(this,relativePath)




    newPath=this.normalizePathName(relativePath);

    newPath=regexprep(newPath,['^',this.ModelName,'/'],'./');

end
