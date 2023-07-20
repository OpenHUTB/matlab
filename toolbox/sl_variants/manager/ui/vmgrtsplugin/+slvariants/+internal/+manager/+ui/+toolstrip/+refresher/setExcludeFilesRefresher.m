function setExcludeFilesRefresher(cbinfo,action)



    action.text=cell2str(cbinfo.Context.Object.App.ReductionOptions.ExcludeFiles);
end

function str=cell2str(cellArray)






    if isempty(cellArray)
        str="";
        return;
    end

    for i=1:length(cellArray)
        cellArray{i}=mat2str(cellArray{i});
    end
    str="{"+join(string(cellArray),", ")+"}";
end
