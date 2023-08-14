function ids=getSortedSignalIDs(this)
    if isempty(this.SignalIDs)
        this.SignalIDs=...
        this.Repo.safeTransaction(@locGetSortedSignalIDs,this);
    end
    ids=this.SignalIDs;
end


function ids=locGetSortedSignalIDs(this)
    if ischar(this.Domain)
        ids=locGetFilteredSignalIDs(this);
    else
        ids=getAllSignalIDs(this.Repo,this.RunID,'top');
    end
end


function ids=locGetFilteredSignalIDs(this)
    ids=Simulink.sdi.getSortedTopLevelSignalIDs(...
    this.Repo,...
    this.RunID,...
    this.Domain,...
    this.IncludeHidden,...
    this.SortStatesForLegacyFormats);
    ids=loc_applyDataLoggingOverride(...
    ids,...
    this.Repo,...
    this.LoggingOverride);
end


function ids=loc_applyDataLoggingOverride(ids,repo,dlo)
    if isempty(dlo)||strcmp(dlo.LoggingMode,'LogAllAsSpecifiedInModel')
        return
    end
    bLogTopAsSpecified=getLogAsSpecifiedInModel(dlo,dlo.Model);


    idxToRemove=[];
    for idx=1:numel(ids)
        props=repo.getSignalExportProps(ids(idx));
        bIsRefSignal=length(props.BlockPath)>1;
        if bIsRefSignal
            bLogAsSpecified=getLogAsSpecifiedInModel(dlo,props.BlockPath{1},false);
        else
            bLogAsSpecified=bLogTopAsSpecified;
        end

        if~bLogAsSpecified
            [~,sigInfo]=getSettingsForSignal(...
            dlo,...
            props.BlockPath,...
            props.PortIndex,...
            props.SubPath,...
            false,...
            props.SignalName);
            if isempty(sigInfo)||~sigInfo.LoggingInfo.DataLogging
                idxToRemove(end+1)=idx;%#ok<AGROW>
            end
        end
    end


    ids(idxToRemove)=[];
end
