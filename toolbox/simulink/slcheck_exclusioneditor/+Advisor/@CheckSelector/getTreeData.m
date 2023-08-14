function result=getTreeData(this)

    PreferenceConfigFileInfo=modeladvisorprivate('modeladvisorutil2','ReadConfigPrefFileInfo');
    PreferenceConfigFilePath=PreferenceConfigFileInfo.name;

    if exist(PreferenceConfigFilePath,'file')
        [~,~,ext]=fileparts(PreferenceConfigFilePath);
        if strcmpi(ext,'.mat')
            configVar=load(PreferenceConfigFilePath);
            if isfield(configVar,'jsonString')
                jsonString=configVar.jsonString;
            else
                maObj=Simulink.ModelAdvisor;
                maObj.loadConfiguration(PreferenceConfigFilePath);
                jsonString=Advisor.Utils.exportJSON(maObj,'MACE');
            end
        else
            data=jsondecode(fileread(PreferenceConfigFilePath));
            jsonString=jsonencode(data.Tree);
        end
    else
        am=Advisor.Manager.getInstance;
        am.updateCacheIfNeeded;
        cacheFilePath=am.getCacheFilePath;
        load(cacheFilePath,'MACE_RootLevelFolders');
        jsonString=MACE_RootLevelFolders{1};
    end

    result=jsondecode(jsonString);
    result(1).parent=NaN;

    if~isempty(this.propValues)&&isfield(this.propValues,'checkIDs')
        if numel(this.propValues.checkIDs)==1&&(contains(this.propValues.checkIDs,'All Checks')||strcmp(this.propValues.checkIDs,'{.*}'))
            truVals=num2cell(true(1,numel(result)));
            [result(:).check]=truVals{:};
        elseif iscell(this.propValues.checkIDs)&&numel(this.propValues.checkIDs)>1
            cidIndex={result(:).checkid};
            cidIndex(cellfun(@isempty,cidIndex))={''};
            indices=ismember(cidIndex,this.propValues.checkIDs);
            truVals=num2cell(true(1,numel(find(indices))));
            [result(indices).check]=truVals{:};
        else

        end
    end

    this.TreeData=result;
end