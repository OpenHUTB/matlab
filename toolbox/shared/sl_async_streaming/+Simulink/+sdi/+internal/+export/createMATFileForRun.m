function createMATFileForRun(runID,domain,filename,varName,bAddToStreamedRun,leafFmt,inactiveVariants,loggingFilePtr,modelName)




    if nargin<5
        bAddToStreamedRun=false;
    end
    if nargin<6
        leafFmt='timeseries';
    end
    if nargin<7
        inactiveVariants=[];
    end
    if nargin<8
        loggingFilePtr=[];
    end
    if nargin<9
        modelName='';
    end
    Simulink.sdi.internal.safeTransaction(@locCreateMATFileForRun,...
    runID,domain,filename,varName,bAddToStreamedRun,leafFmt,inactiveVariants,loggingFilePtr,modelName);
end


function locCreateMATFileForRun(runID,domain,filename,varName,bAddToStreamedRun,leafFmt,inactiveVariants,loggingFilePtr,modelName)
    bHierarchy=true;
    sigID=int32.empty();
    chunkNums=int32.empty();
    timeRange=double.empty();


    [~,~,ext]=fileparts(filename);
    if~strcmpi(ext,'.mat')
        filename=[filename,'.mat'];
    end




    bStreamedOnly=ischar(domain);
    if~bStreamedOnly
        domain='';
    end


    if~runID
        assert(~isempty(inactiveVariants));
        dsinfo=locCreateEmptyDS(varName,filename);
        if~exist(filename,'file')
            Simulink.sdi.createEmptyR2MATFile(filename);
        end
    else
        repo=sdi.Repository(1);
        bSortStatesForLegacyFormats=false;
        dsinfo=Simulink.sdi.exportRunData(...
        repo,...
        runID,...
        bHierarchy,...
        bStreamedOnly,...
        domain,...
        sigID,...
        chunkNums,...
        timeRange,...
        bSortStatesForLegacyFormats,...
        filename,...
        varName,...
        bAddToStreamedRun,...
        leafFmt);
    end



    if isempty(dsinfo)
        return
    end


    if~isempty(inactiveVariants)
        if iscell(inactiveVariants)
            dsinfo=locAddMissingVariantsForRaccel(dsinfo,inactiveVariants);
        else
            dsinfo=locAddInactiveVariants(dsinfo,inactiveVariants,leafFmt);
        end
    end


    if isempty(dsinfo.Dataset.Elements)
        return
    end


    ds=Simulink.SimulationData.Dataset;
    ds=ds.utfillfromstruct(dsinfo);


    if isempty(loggingFilePtr)&&~isempty(modelName)
        loggingFilePtr=Simulink.sdi.getOpenR2MATFileHandle(modelName);
    end

    if~isempty(loggingFilePtr)&&any(loggingFilePtr)
        sz=numel(loggingFilePtr);
        loggingFilePtr=reshape(loggingFilePtr,[1,sz]);
        sigstream_mapi(...
        'saveMxArrayToOpenMatFile',...
        ds,...
        varName,...
        loggingFilePtr);
    else



        fullPath=which(filename);
        if isempty(fullPath)
            fullPath=filename;
        end

        eval(sprintf('%s = ds;',varName));
        save(fullPath,'-append',varName);
    end
end


function dsinfo=locAddInactiveVariants(dsinfo,inactiveVariants,leafFmt)
    for idx=1:numel(inactiveVariants)
        el=struct(...
        'ElementType','signal',...
        'Name',inactiveVariants(idx).m_sigName,...
        'PropagatedName',inactiveVariants(idx).m_propName,...
        'BlockPath',{inactiveVariants(idx).m_blockPath},...
        'PortType','inport',...
        'PortIndex',1,...
        'Values',struct('LeafMarker','','ElementType',leafFmt,'IsEmpty',true));
        pos=inactiveVariants(idx).m_orderIdx;
        dsinfo.Dataset.Elements=[...
        dsinfo.Dataset.Elements(1:pos-1);...
        {el};...
        dsinfo.Dataset.Elements(pos:end)];
    end
end


function dsinfo=locAddMissingVariantsForRaccel(dsinfo,outportList)
    for idx=1:numel(outportList)
        if idx>numel(dsinfo.Dataset.Elements)
            dsinfo.Dataset.Elements=[dsinfo.Dataset.Elements;outportList(idx:end)];
            break;
        elseif~strcmp(dsinfo.Dataset.Elements{idx}.BlockPath{1},outportList{idx}.BlockPath)
            dsinfo.Dataset.Elements=[...
            dsinfo.Dataset.Elements(1:idx-1);...
            outportList(idx);...
            dsinfo.Dataset.Elements(idx:end)];
        end
    end
end


function dsinfo=locCreateEmptyDS(varName,filename)
    dsinfo=struct(...
    'DatasetStorageType','MatFileDatasetStorage',...
    'Dataset',struct('Name',varName,'FileName',filename));
    dsinfo.Dataset.Elements={};
end