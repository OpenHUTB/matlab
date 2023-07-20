function str=decoratePath(str)




    if isempty(str)&&~ischar(str)
        str='';
    end
    if ispc
        str=strrep(str,'\','\\');
        str=strrep(str,'\\\\','\\');
    end
