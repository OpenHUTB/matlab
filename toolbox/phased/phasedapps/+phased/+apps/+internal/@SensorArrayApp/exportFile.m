function exportFile(obj)






    ExportArray=obj.CurrentArray;


    fileName=generateVariableName(obj);

    [matfile,pathname]=...
    uiputfile({'*.mat',[getString(message('phased:apps:arrayapp:libraryFile')),...
    ' (*.mat)']},'Save as',[fileName,'.mat']);
    isCancelled=isequal(matfile,0)||isequal(pathname,0);
    if isCancelled
        matfilepath='';
    else
        matfilepath=[pathname,matfile];
    end
    if~isempty(matfilepath)
        save(matfilepath,'ExportArray')
    end
end
