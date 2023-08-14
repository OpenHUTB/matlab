function relativePath=rtw_relativize(absolutePath,anchorDir)







    match=findstr(absolutePath,anchorDir);
    if isempty(match)
        DAStudio.error('RTW:utility:cannotFindAnchorDir',anchorDir,absolutePath);
    end


    if strcmp(anchorDir(end),filesep)

        startIdx=length(anchorDir)+1;
    else

        startIdx=length(anchorDir)+2;
    end
    relativePath=absolutePath(startIdx:end);

