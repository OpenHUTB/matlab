function[foldername,userCanceled]=volgetfolder(varargin)



    persistent cached_path;


    need_to_initialize_path=isempty(cached_path);
    if need_to_initialize_path
        cached_path='';
    end

    foldername=uigetdir(cached_path,getString(message('images:volumeViewerToolgroup:chooseDicomFolder')));



    userCanceled=(foldername==0);
    if~userCanceled
        cached_path=fileparts(foldername);
    else
        foldername='';
    end


