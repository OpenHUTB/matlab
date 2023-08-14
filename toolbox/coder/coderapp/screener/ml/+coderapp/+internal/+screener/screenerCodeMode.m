function report=screenerCodeMode(aCodeStruct)
    if~(isstruct(aCodeStruct)&&isfield(aCodeStruct,'Code')&&isfield(aCodeStruct,'Path'))
        error(message('Coder:common:ScreenerCodeInputStruct'));
    end
    files=string.empty;
    pathMap=containers.Map('KeyType','char','ValueType','char');



    origPath=path;
    addpath(pwd);
    tempfiles=repmat("",1,numel(aCodeStruct));
    ME=[];
    try
        for k=1:numel(aCodeStruct)
            [pathMap,tempfiles(k)]=addFcnInfo(aCodeStruct(k),pathMap);
            files=[files,tempfiles(k)];%#ok<AGROW>
        end
    catch ME
    end
    cleaner=onCleanup(@()cleanup(origPath,tempfiles));
    if~isempty(ME)
        rethrow(ME);
    end

    report=coderapp.internal.screener.screener(files,false,coder.internal.ScreenerOptions,pathMap);
end

function[pathMap,filepath]=addFcnInfo(fcnInfo,pathMap)
    filepath=tempname+".m";
    pathMap(filepath)=fcnInfo.Path;
    fid=fopen(filepath,'w');
    assert(fid>0,"Couldn't open %s for writing",filepath);
    closer=onCleanup(@()fclose(fid));
    fprintf(fid,"%s\n",fcnInfo.Code);
end

function cleanup(origPath,filepaths)
    path(origPath);
    for k=1:numel(filepaths)
        filepath=filepaths(k);
        if isfile(filepath)
            delete(filepath);
        end
    end
end
