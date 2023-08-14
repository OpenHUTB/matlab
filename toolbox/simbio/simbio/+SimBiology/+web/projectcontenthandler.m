function out=projectcontenthandler(action,varargin)











    out={action};

    switch(action)
    case 'deleteCache'
        deleteCache(varargin{:});
    case 'exportCache'
        out=exportCache(varargin{:});
    case 'getContent'
        out=getContent(varargin{:});
    end

end

function out=getContent(input)


    sbioprojectObj=SimBiology.internal.sbioproject(input.name,true);

    newName=sbioprojectObj.loadFilesMatchingRegexp('modelLookup.mat');
    hasModels=false;
    if~isempty(newName)
        d=load(newName{1});
        modelLookup=d.modelLookup;
        hasModels=~isempty(modelLookup);
    end


    bytes=0;
    if hasModels
        newName=sbioprojectObj.loadFilesMatchingRegexp('simbiodata.mat');
        if~isempty(newName)

            finfo=dir(newName{1});
            bytes=finfo.bytes;
            deleteFile(newName{1});


            newName=sbioprojectObj.loadFilesMatchingRegexp('diagram_*');
            for i=1:numel(newName)
                finfo=dir(newName{i});
                bytes=bytes+finfo.bytes;
                deleteFile(newName{i});
            end
        end
    end

    fileInfo.name='All Models';
    fileInfo.type='SimBiology.Model';
    fileInfo.kbytes=round(bytes,1,'significant')/1000;
    fileInfo.cacheName='';


    newName=sbioprojectObj.loadFilesMatchingRegexp('taskLookup.mat');
    d=load(newName{1});
    taskLookup=d.taskLookup;
    deleteFile(newName{1});

    for i=1:length(taskLookup)
        newName=sbioprojectObj.loadFilesMatchingRegexp(taskLookup(i).id);
        next=getFileInfo(newName{1},taskLookup(i).name,'Program');
        fileInfo=[fileInfo,next];%#ok<*AGROW>
    end


    newName=sbioprojectObj.loadFilesMatchingRegexp('externaldata.mat');
    if~isempty(newName)
        next=getFileInfo(newName{1},'Imported Data','Data');
        fileInfo=[fileInfo,next];
    end


    newName=sbioprojectObj.loadFilesMatchingRegexp('taskDataLookup.mat');
    modelCacheLookup=containers.Map('KeyType','char','ValueType','any');
    dataCacheLookup=containers.Map('KeyType','char','ValueType','any');
    if~isempty(newName)
        d=load(newName{1});
        taskDataLookup=d.taskDataLookup;
        deleteFile(newName{1});

        if hasCacheInfo(taskDataLookup)
            for i=1:length(taskDataLookup)
                newName=sbioprojectObj.loadFilesMatchingRegexp(taskDataLookup(i).matfileName);
                programDataName=[taskDataLookup(i).programName,'.',taskDataLookup(i).name];
                next=getFileInfo(newName{1},programDataName,'Program Results');
                fileInfo=[fileInfo,next];


                modelCacheName=taskDataLookup(i).modelCacheName;
                if~isempty(modelCacheName)
                    if~isKey(modelCacheLookup,modelCacheName)


                        modelCacheLookup(modelCacheName)={programDataName};


                        newName=sbioprojectObj.loadFilesMatchingRegexp(modelCacheName);
                        next=getFileInfo(newName{1},'Model Cache','SimBiology.Model',modelCacheName);
                        fileInfo=[fileInfo,next];
                    else


                        value=modelCacheLookup(modelCacheName);
                        modelCacheLookup(modelCacheName)=[value,programDataName];
                    end
                end


                dataCache=taskDataLookup(i).dataCache;
                for j=1:numel(dataCache)
                    dataCacheName=dataCache(j).dataCacheName;
                    if~isempty(dataCacheName)
                        if~isKey(dataCacheLookup,dataCacheName)


                            dataCacheLookup(dataCacheName)={programDataName};


                            newName=sbioprojectObj.loadFilesMatchingRegexp(dataCacheName);
                            next=getFileInfo(newName{1},'Data Cache','Data',dataCacheName);
                            fileInfo=[fileInfo,next];
                        else


                            value=dataCacheLookup(dataCacheName);
                            dataCacheLookup(dataCacheName)=[value,programDataName];
                        end
                    end
                end
            end
        end
    end


    newName=sbioprojectObj.loadFilesMatchingRegexp('plotDocuments.mat');
    if~isempty(newName)
        next=getFileInfo(newName{1},'Plots','Plots');
        fileInfo=[fileInfo,next];
    end


    newName=sbioprojectObj.loadFilesMatchingRegexp('dataSheets.mat');
    if~isempty(newName)
        next=getFileInfo(newName{1},'Datasheets','Datasheets');
        fileInfo=[fileInfo,next];
    end

    out.fileInfo=fileInfo;
    out.modelCacheInfo=map2struct(modelCacheLookup);
    out.dataCacheInfo=map2struct(dataCacheLookup);

end

function out=getFileInfo(filename,label,type,varargin)

    cacheName='';
    if nargin==4
        cacheName=varargin{1};
    end

    finfo=dir(filename);
    bytes=finfo.bytes;
    out.name=label;
    out.type=type;
    out.kbytes=round(bytes,1,'significant')/1000;
    out.cacheName=cacheName;
    delete(filename);

end

function out=hasCacheInfo(lookup)

    if isempty(lookup)
        out=false;
    else
        out=isfield(lookup(1),'modelCacheName');
    end

end

function deleteCache(input)

    for i=1:numel(input.names)
        cacheFile=[SimBiology.web.internal.desktopTempdir,filesep,input.names{i},'.mat'];
        if exist(cacheFile,'file')
            deleteFile(cacheFile);
        end
    end

end

function out=exportCache(input)

    expr=['exist(','''',input.varName,'''',')'];
    varAlreadyExist=evalin('base',expr);
    msg='';

    if(~varAlreadyExist||input.overwrite)
        type=input.type;
        cacheName=input.cacheName;
        data=getCache(type,cacheName);


        warnState=warning('off','MATLAB:namelengthmaxexceeded');
        cleanup=onCleanup(@()warning(warnState));


        assignin('base',input.varName,data)
    else
        msg=sprintf('Variable ''%s'' exists in the MATLAB workspace.',input.varName);
    end

    out.message=msg;

end

function out=getCache(type,name)

    if strcmp(type,'data')
        out=getDataCache(name);
    else
        out=getModelCache(name);
    end

end

function out=getModelCache(name)

    cacheFile=[SimBiology.web.internal.desktopTempdir,filesep,name,'.mat'];
    if exist(cacheFile,'file')
        cache=load(cacheFile);
        out=cache.model;
    else
        out=[];
    end

end

function out=getDataCache(name)

    cacheFile=[SimBiology.web.internal.desktopTempdir,filesep,name,'.mat'];
    if exist(cacheFile,'file')
        cache=load(cacheFile);
        out=cache.data;
    else
        out=[];
    end

end

function out=map2struct(map)

    out=[];
    keys=map.keys;
    for i=1:numel(keys)
        next.key=keys{i};
        next.value=sort(map(next.key));
        out=[out,next];
    end

end

function deleteFile(name)

    oldState=recycle;
    recycle('off');
    delete(name)
    recycle(oldState);end
