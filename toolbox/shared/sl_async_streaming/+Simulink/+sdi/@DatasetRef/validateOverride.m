function ret=validateOverride(this)




    if~ischar(this.Domain)||...
        ~isempty(this.Domain)||...
        isempty(this.LoggingOverride)||...
        strcmp(this.LoggingOverride.LoggingMode,'LogAllAsSpecifiedInModel')
        ret=[];
    else
        ret=...
        this.Repo.safeTransaction(@locValidateOverride,this);
    end
end


function ret=locValidateOverride(this)
    ret=[];
    dlo=this.LoggingOverride;
    ids=Simulink.sdi.getSortedTopLevelSignalIDs(...
    this.Repo,...
    this.RunID,...
    this.Domain);
    bLogTopAsSpecified=getLogAsSpecifiedInModel(...
    dlo,dlo.Model);


    bUpdateDLO=false;
    for idx=1:numel(ids)
        props=this.Repo.getSignalExportProps(ids(idx));
        bIsRefSignal=length(props.BlockPath)>1;
        if bIsRefSignal
            bLogAsSpecified=getLogAsSpecifiedInModel(dlo,props.BlockPath{1},false);
        else
            bLogAsSpecified=bLogTopAsSpecified;
        end

        if~bLogAsSpecified
            [~,~,~,bNameChange,dlo]=getSettingsForSignal(...
            dlo,...
            props.BlockPath,...
            props.PortIndex,...
            props.SubPath,...
            false,...
            props.SignalName);
            if bNameChange
                bUpdateDLO=true;
            end
        end
    end


    if bUpdateDLO
        ret=dlo;
    end
end
