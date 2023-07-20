function[errTxt,hasDelimiters]=check_generated_filename(fileName,reqExt)












    errTxt='';
    hasDelimiters=false;

    if isempty(fileName)
        errTxt='File name empty.';
        return;
    end

    if(((fileName(1)=='"')&&(fileName(end)=='"'))||...
        ((fileName(1)=='<')&&(fileName(end)=='>')))
        fileName=fileName(2:end-1);
        hasDelimiters=true;
    end

    [fPath,fName,fExt]=fileparts(fileName);
    if~isempty(fPath)
        errTxt='File name cannot contain directories.';
    elseif~iscvar(fName)
        errTxt='File name must be a valid C identifier.';
    elseif(~isempty(fExt)&&~isequal(fExt,reqExt))
        errTxt=sprintf('File name extension must be ''%s''.',reqExt);
    end


