function out=mapDirect(str,num)

    if isnumeric(str)
        out=str(num);
    else
        str=erase(str,';');
        str=strip(str);
        if startsWith(str,'[')
            cellArray=split(str,{' ',';',',','[',']'});
            cellArray=cellArray(~strcmp(cellArray,''));
            if num>numel(cellArray)
                error('Parameter format not supported.');
            else
                out=cellArray{num};
            end
        else
            out=strcat(str,'(',num2str(num),')');
        end
    end
end
