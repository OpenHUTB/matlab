function str=cell2str(cellArray)
    if isempty(cellArray)
        str="{}";
    else
        for i=1:length(cellArray)
            cellArray{i}=mat2str(cellArray{i});
        end
        str="{"+join(string(cellArray),", ")+"}";
    end
end