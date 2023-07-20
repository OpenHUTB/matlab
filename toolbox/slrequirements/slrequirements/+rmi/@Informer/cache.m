function result=cache(option)





    persistent workDir cacheDir baseDir sessionId webviewCacheDir;
    if isempty(workDir)
        workDir=fullfile(tempdir,'RMI');
        if exist(workDir,'dir')~=7
            mkdir(workDir);
        end
        cacheDir=fullfile(workDir,'cached');
        baseDir='..';
        sessionId=0;
        webviewCacheDir=fullfile(workDir,'webviewCache');
    end

    if~ischar(option)
        warning(message('Slvnv:rmi:informer:UnsupportedMethod',class(option),'rmi.Informer.cache()'));
        result='';
        return;
    end

    switch lower(option)


    case 'workdir'
        result=workDir;
    case 'cachedir'
        result=cacheDir;
    case 'basedir'
        result=baseDir;
    case 'list'
        result=dir(cacheDir);


    case 'on'
        if exist(cacheDir,'dir')~=7
            mkdir(cacheDir);
        end
    case 'off'
        if exist(cacheDir,'dir')==7
            rmdir(cacheDir,'s');
        end


    case 'clear'
        if exist(cacheDir,'dir')==7
            rmdir(cacheDir,'s');
        end
        mkdir(cacheDir);
        result=dir(workDir);
    case 'clearall'
        if exist(workDir,'dir')==7
            rmdir(workDir,'s');
        end
        mkdir(workDir);
        baseDir='..';
        result=dir(workDir);


    case 'getsessionid'
        result=sessionId;
    case 'incrementsessionid'
        sessionId=sessionId+1;
    case 'clearwebview'
        if exist(webviewCacheDir,'dir')==7
            rmdir(webviewCacheDir,'s');
        end
        mkdir(webviewCacheDir);
        result=webviewCacheDir;
    case 'webviewcacheddir'
        result=webviewCacheDir;
    otherwise


        if any(option=='/')
            baseDir=option;

        elseif rmisl.isSidString(option)||exist(option,'file')==4
            sid=option;

            result=sidToCachePath(cacheDir,sid);
            refresh=false;
            if exist(cacheDir,'dir')~=7
                rmi.Informer.cache('on');
                refresh=true;
            elseif exist(result,'file')~=2
                refresh=true;
            end
            if refresh
                try
                    load_system(strtok(sid,':'));
                    reqs=rmi.getReqs(sid);
                    if isempty(reqs)
                        result='';
                    else
                        rmi.Informer.makeContents(sid,reqs);
                    end
                catch
                    result='';
                end
            end
        else
            error(message('Slvnv:rmi:informer:UnsupportedMethod',option,'rmi.Informer.cache()'));
        end
    end
end

function htmPath=sidToCachePath(parentDir,sid)
    fname=[strrep(sid,':','__'),'.htm'];
    htmPath=fullfile(parentDir,fname);
end
