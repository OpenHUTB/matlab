function fetchDataFromBackend(this)
    result=[];

    filterPath=get_param(this.model,'MAModelFilterFile');
    if~isempty(filterPath)&&exist(filterPath,'file')==0
        message=DAStudio.message('slcheck:filtercatalog:SerializationFileNotFound',filterPath);
        throw(MException('slcheck:filtercatalog:SerializationFileNotFound',message));
    end
    this.isSaveToSlx=isempty(filterPath);

    manager=slcheck.getAdvisorFilterManager(this.model);
    filters=manager.filters;

    if~isempty(filters)

        for idx=1:filters.Size
            type=slcheck.getFilterTypeString(filters.at(idx).type);
            Summary=filters.at(idx).metadata.summary;

            sid=filters.at(idx).filteredItem.ID;
            extype=lower(type);
            if contains(extype,{'masktype','blocktype','stateflow','blockparameters'})
                id=struct('sid',sid,'name',sid,'link',false);
            else
                name=slcheck.getFullPathFromSID(sid);
                id=struct('sid',sid,'name',name,'link',true);
            end

            checks=filters(idx).checks.toArray;
            if numel(checks)==1&&strcmp(checks{1},'.*')
                checks='{All Checks}';
            else
                checks=['{',strjoin(checks,', '),'}'];
            end
            checkStruct.checks=checks;
            checkStruct.rowNum=idx;

            result{end+1}={id,type,Summary,checkStruct};
        end
    end
    this.TableData=result;
    this.isTableDataValid=true;
end