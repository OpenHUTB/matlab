function relativePath=getRelativePathFromProject(info,fullPath)






    rootPath=strcat(info.Project.RootFolder,filesep);
    relativePath=strrep(fullPath,rootPath,"");
end


