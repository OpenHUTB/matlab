function output=addFiles(h,selectionStruct)






    eventName=selectionStruct.Event;
    fileList=selectionStruct.FileList;

    switch eventName
    case getString(message('evolutions:ui:AddFileOnly'))
        output=fileList;
    case getString(message('evolutions:ui:AddWithDependencies'))
        output=h.getFileDependencies(fileList);
    otherwise
        output=cell.empty;
    end

    if h.TestMode
        output=selection;
    end
end



