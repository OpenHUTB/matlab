function[fileName,pathName,userCanceled]=uigetmatfile(initialPath,title)



    persistent cached_path;


    need_to_initialize_path=isempty(cached_path);
    if need_to_initialize_path
        cached_path='';
    end

    filterSpec={'*.mat','MAT-files (*.mat)'};

    if(isempty(initialPath))
        [fileName,pathName,filterIndex]=uigetfile(filterSpec,...
        title,...
        cached_path);
    else
        [fileName,pathName,filterIndex]=uigetfile(filterSpec,...
        title,...
        initialPath);
    end

    userCanceled=(filterIndex==0);

    if~userCanceled
        cached_path=pathName;
    else
        fileName='';
    end