function setCacheFolder()



    persistent cacheFolder;

    f1=get_param(0,'CacheFolder');
    f2=get_param(0,'CodeGenFolder');


    if isempty(cacheFolder)||isempty(f1)||isempty(f2)
        cacheFolder=tempname;
        mkdir(cacheFolder);
        disp(message('stm:MultipleReleaseTesting:cacheFolderSet',cacheFolder).string());
        set_param(0,'CacheFolder',cacheFolder);
        set_param(0,'CodeGenFolder',cacheFolder);
    end
end

