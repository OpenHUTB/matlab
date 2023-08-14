function data=getDefaultExclusionState(this)


    data={};
    keys=this.defaultExclusionState.keys;
    for i=1:length(keys)
        switch(keys{i})
        case{'ModelReference_BlockType','LibraryLinks_Library','InactiveRegions_BlockType'}
            continue;
        otherwise
            data=[data;getRowData(this,keys{i})];%#ok<AGROW>
        end
    end

    if isempty(data)
        data={'','','',''};
    end

    rowIdx=1;
    this.defaultTableIdxMap.remove(this.defaultTableIdxMap.keys());
    for idx=1:numel(keys)
        prop=this.defaultExclusionState(keys{idx});
        this.defaultTableIdxMap(rowIdx)=prop;
        rowIdx=rowIdx+1;
    end


    function rowData=getRowData(this,key)
        checkIDs=this.defaultExclusionState(key).checkIDs;
        checkIDStr='{ ';
        for j=1:length(checkIDs)
            checkIDStr=[checkIDStr,',',checkIDs{j}];%#ok<AGROW>
        end
        checkIDStr(3)='';
        checkIDStr=[checkIDStr,' }'];
        if strcmp(checkIDs{1},'.*')
            checkIDStr='All checks';
        end

        rowData={strrep(this.defaultExclusionState(key).value,newline,' '),...
        strrep(get_param(this.exclusionState(key).value,'BlockType'),newline,' '),...
        strrep(this.exclusionState(key).rationale,newline,' ')
        };
