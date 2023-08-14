function newPath=relativePathToSLPath(this,relativePath)




    newPath=this.normalizePathName(relativePath);

    newPath=regexprep(newPath,'^\.',this.ModelName);

end
