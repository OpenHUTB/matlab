function ret=getRapidAccelStreamoutBlockData(buildData,slvrSettings,runID)











    mdl=buildData.mdl;
    repo=sdi.Repository(1);
    isFinalOutput=~runID;


    if isFinalOutput&&sdi.Repository.sessionRequiresRaccelImport()
        Simulink.sdi.internal.importCompletedRapidAccelRuns(mdl,false);
    end


    if isFinalOutput
        runID=Simulink.sdi.internal.safeTransaction(@locGetStreamingRunID,mdl);
    end

    if~runID
        ret=struct.empty();
        return
    end


    locWriteLoggedFiles(mdl,runID,repo,buildData.toFileBlocks);

    ret=Simulink.sdi.internal.safeTransaction(@locGetWorkspaceVarsAndCleanup,mdl,runID,isFinalOutput,slvrSettings);
end

function runID=locGetStreamingRunID(mdl)
    repo=sdi.Repository(1);
    runID=repo.getCurrentStreamingRunID(mdl);
end

function ret=locGetWorkspaceVarsAndCleanup(mdl,runID,isFinalOutput,slvrSettings)
    repo=sdi.Repository(1);


    ret=locGetWorkspaceVariables(mdl,runID,repo,slvrSettings);


    if isFinalOutput
        locCleanupPendingVars(mdl,runID,repo);
    end
end


function ret=locGetWorkspaceVariables(mdl,runID,repo,slvrSettings)
    ret=struct.empty();
    INTERVALS=slvrSettings.slvrOpts.LoggingIntervals;
    if isempty(INTERVALS)||isequal(INTERVALS,[Inf,Inf])||isequal(INTERVALS,[-Inf,-Inf])
        INTERVALS='[]';
    else
        INTERVALS=locGetIntervalAsString(INTERVALS);
    end


    vars=repo.getPendingStreamoutWksVars(mdl,runID);
    domains={vars.Domain};
    fmts={vars.Format};
    data=Simulink.sdi.internal.getExportDataForStreamout(...
    mdl,...
    domains,...
    fmts,...
    INTERVALS,...
    runID);
    for idx=1:numel(vars)
        try
            ret(end+1).var=vars(idx).Name;%#ok<AGROW>
            ret(end).data=data{idx};
            ret(end).BlockPath=vars(idx).BlockPath;
        catch me %#ok<NASGU>

            continue
        end
    end
end


function locWriteLoggedFiles(mdl,runID,repo,toFileBlocks)

    fm=containers.Map;
    for idx=1:numel(toFileBlocks)
        fm(toFileBlocks{idx}.originalFileName)=toFileBlocks{idx}.blockPath;
    end


    files=Simulink.sdi.internal.safeTransaction(@locGetPendingStreamoutFiles,mdl,runID);
    for idx=1:numel(files)

        if fm.isKey(files(idx).FilePath)
            msg=message(...
            'record_playback:errors:RapidAccelFileClash',...
            files(idx).BlockPath,...
            files(idx).FilePath,...
            fm(files(idx).FilePath));
            Simulink.sdi.internal.warning(msg);
            continue
        end
        fm(files(idx).FilePath)=files(idx).BlockPath;


        try
            switch files(idx).FileType
            case 'mat'
                locCreateMATFile(files(idx),runID,repo);
            case 'mldatx'
                locCreateMLDATXFile(files(idx),runID);
            case 'xlsx'
                locCreateXLSFile(files(idx),runID,repo);
            end
        catch me %#ok<NASGU>
            msg=message(...
            'record_playback:errors:RapidAccelFileError',...
            files(idx).BlockPath,...
            files(idx).FilePath);
            Simulink.sdi.internal.warning(msg);
        end
    end
end


function ret=locGetPendingStreamoutFiles(mdl,runID)
    repo=sdi.Repository(1);
    ret=repo.getPendingStreamoutFiles(mdl,runID);
end


function locCreateMATFile(fi,runID,repo)

    dsr=Simulink.sdi.DatasetRef(runID,fi.Domain,repo);
    ds=dsr.fullExport();


    fname=fi.FilePath;
    [~,~,ext]=fileparts(fname);
    if~strcmpi(ext,'.mat')
        fname=[fname,'.mat'];
    end


    varName='ans';
    if isfield(fi.Options,'varname')
        varName=fi.Options.varname;
    end


    S.(sprintf(varName,'%s'))=ds;
    save(fname,'-struct','S','-v7.3');
end


function locCreateMLDATXFile(fi,runID)

    fname=fi.FilePath;
    [~,~,ext]=fileparts(fname);
    if~strcmpi(ext,'.mldatx')
        fname=[fname,'.mldatx'];
    end


    Simulink.sdi.internal.exportDomainToMLDATX(fname,runID,fi.Domain);
end


function locCreateXLSFile(fi,runID,repo)

    fname=fi.FilePath;
    [~,~,ext]=fileparts(fname);
    if~strcmpi(ext,'.xlsx')
        fname=[fname,'.xlsx'];
    end


    idsToRec=int32.empty();
    ids=repo.getAllSignalIDs(runID,'leaf');
    for idx=1:numel(ids)
        if strcmp(repo.getSignalDomainType(ids(idx)),fi.Domain)
            idsToRec(end+1)=ids(idx);%#ok<AGROW>
        end
    end


    opts.overwrite='file';
    opts.shareTimeColumn='on';
    opts.metadata=struct();
    if isfield(fi.Options,'dataType')
        opts.metadata.dataType=fi.Options.dataType;
    end
    if isfield(fi.Options,'units')
        opts.metadata.units=fi.Options.units;
    end
    if isfield(fi.Options,'interp')
        opts.metadata.interp=fi.Options.interp;
    end
    if isfield(fi.Options,'blockPath')
        opts.metadata.blockPath=fi.Options.blockPath;
    end
    if isfield(fi.Options,'portIndex')
        opts.metadata.portIndex=fi.Options.portIndex;
    end
    if isfield(fi.Options,'shareTimeColumn')
        opts.shareTimeColumn=fi.Options.shareTimeColumn;
    end

    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.exportSignalsToXLS(idsToRec,fname,opts);

end


function locCleanupPendingVars(mdl,runID,repo)
    repo.removePendingStreamoutWksVars(mdl,runID);
end


function ret=locGetIntervalAsString(val)
    sz=size(val);
    ret='';
    for idx=1:sz(1)
        if idx~=1
            ret=[ret,';'];%#ok<AGROW>
        end
        str=sprintf('%.16f,',val(idx,:));
        ret=[ret,str(1:end-1)];%#ok<AGROW>
    end
    ret=sprintf('[%s]',ret);
end

