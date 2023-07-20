function output=removeFiles(h,selectionStruct)






    eventName=selectionStruct.Event;
    fileList=selectionStruct.FileList;

    switch eventName
    case getString(message('evolutions:ui:RemovingFromActive'))
        output=fileList;
    otherwise
        output=cell.empty;
    end

    if h.TestMode
        output=selection;
    end
end
