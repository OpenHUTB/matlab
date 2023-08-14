function[fileName,userCanceled]=videogetfile()














    persistent cached_path;


    needToInitPath=isempty(cached_path);
    if needToInitPath
        cached_path='';
    end


    filterSpec=VideoReader.getFileFormats().getFilterSpec();


    dialogTitle=getString(message('vision:labeler:LoadVideoDialogTitle'));
    [fileName,filePath,filterIndex]=uigetfile(filterSpec,dialogTitle,cached_path,'MultiSelect','off');



    userCanceled=(filterIndex==0);
    if~userCanceled
        cached_path=filePath;
        fileName=fullfile(filePath,fileName);
    else
        fileName='';
    end

end
