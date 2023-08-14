function boolFlag=hasCodegenPragmaInClassDef(classFileName)




    filePath=which(classFileName);
    if endsWith(filePath,'.p')
        boolFlag=true;



    else
        commentsInFile=mtree(filePath,'-file','-comments').mtfind('Kind','COMMENT').strings();
        boolFlag=any(strcmpi(strtrim(commentsInFile),"%#codegen"));

    end
end
