function data=getExclusionState(this)



    data={};
    keys=this.exclusionState.keys;


    orderedIdx=zeros(1,length(keys));
    for i=1:length(keys)
        orderedIdx(i)=this.exclusionState(keys{i}).idx;
    end
    [~,sortedIdx]=sort(orderedIdx);
    keys=keys(sortedIdx);


    for i=1:length(keys)
        data=[data;getRowData(this,keys{i})];%#ok<AGROW>
    end

    if isempty(data)
        data={'','','',''};
    end

    rowIdx=1;
    this.tableIdxMap.remove(this.tableIdxMap.keys());
    for idx=1:numel(keys)
        prop=this.exclusionState(keys{idx});
        this.tableIdxMap(rowIdx)=prop;
        rowIdx=rowIdx+1;
    end


    function rowData=getRowData(this,key)
        checkIDs=this.exclusionState(key).checkIDs;
        checkIDStr='{ ';
        for j=1:length(checkIDs)
            checkIDStr=[checkIDStr,',',checkIDs{j}];%#ok<AGROW>
        end
        checkIDStr(3)='';
        checkIDStr=[checkIDStr,' }'];
        if strcmp(checkIDs{1},'.*')
            checkIDStr='All checks';
        end
        rowData={strrep(this.exclusionState(key).rationale,sprintf('\n'),' '),...
        strrep(this.exclusionState(key).Type,sprintf('\n'),' '),...
        strrep(this.exclusionState(key).value,sprintf('\n'),' '),...
        strrep(checkIDStr,sprintf('\n'),' ')};
