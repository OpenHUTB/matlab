function isAbsolute=isAbsolutePath(filePath)

    narginchk(1,1);

    if ispc
        isDrive=~isempty(regexp(filePath,'^[a-zA-Z]:','once'));

        isAbsolute=isDrive||startsWith(filePath,'\\');
    else
        isAbsolute=startsWith(filePath,'/');
    end
end

