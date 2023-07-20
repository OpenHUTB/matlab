function save(this,varargin)




    if isempty(varargin)
        filName=this.fileName;
    else
        filName=varargin{1};
        mdlFlag=varargin{2};
    end

    filName=deblank(filName);

    if isempty(filName)&&~this.storeInSLX
        DAStudio.error('ModelAdvisor:engine:ExclusionFileNameEmpty');
    end

    if mdlFlag
        values=this.exclusionState.values;
    else

        return;
    end

    exList={};

    for idx=1:numel(values)
        prop=values{idx};


        ex=ModelAdvisor.Exclusion;
        if iscell(prop.checkIDs)
            ex.CheckIDs=prop.checkIDs;
        else
            ex.CheckIDs={prop.checkIDs};
        end

        rule=ModelAdvisor.Rule;
        if~strcmpi(prop.Type,'custom')
            rule.Type=prop.Type;
        end


        if isfield(prop,'sid')&&strcmpi(prop.sid,'on')
            rule.SID='on';
            index=strfind(prop.value,':');
        else
            index=strfind(prop.value,'/');
        end

        if strcmpi(prop.Type,'custom')
            rule=prop.userdata;
        else
            if mdlFlag&&(strcmpi(prop.Type,'Subsystem')||strcmpi(prop.Type,'Block'))
                rule.Value=prop.value(index(1)+1:end);
            else
                rule.Value=prop.value;
            end
            ex.Rationale=prop.rationale;
        end


        ex.Rules=rule;
        ex.CheckType=prop.checkType;
        exList{end+1}=ex;
    end
    this.setExclusions(exList);
    if~isempty(this.fDialogHandle)
        if strcmp(class(this),'ModelAdvisor.ExclusionEditor')
            this.fDialogHandle.setTitle(DAStudio.message('ModelAdvisor:engine:ModelAdvisorExclusionEditor'));
        else
            this.fDialogHandle.setTitle(DAStudio.message('sl_pir_cpp:creator:cloneDetectionExclusionEditor'));
        end
    end
    this.writeToFile(exList);

