function[className,replaceTLC]=tfile_classname(targetFileId)




    className=[];
    replaceTLC=[];

    targetFileContents=fread(targetFileId);
    if isempty(targetFileContents)
        DAStudio.error('RTW:utility:fileIOError','system target file','read');
    end

    targetFileContents=char(targetFileContents');

    startToken=' BEGIN_CONFIGSET_TARGET_COMPONENT';
    endToken=' END_CONFIGSET_TARGET_COMPONENT';
    startPoint=strfind(targetFileContents,startToken);
    endPoint=strfind(targetFileContents,endToken);

    if(isempty(startPoint))


        return;
    elseif(isempty(endPoint))
        DAStudio.error('RTW:configSet:stfTokenMissing',endToken);
    end

    contentStr=targetFileContents(startPoint+length(startToken):endPoint);

    try
        eval(contentStr);
        className=targetComponentClass;
        className=strrep(className,' ','');
    catch

    end


    if exist('replaceSTFWith','var')
        replaceTLC=replaceSTFWith;
    end
end


