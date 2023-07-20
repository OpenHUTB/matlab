function table=createRptgenRepTable(obj,usedFcns,mergeIdxs)
    tableCol1={obj.getMessage('CodeReplacementColumnFcn')};
    tableCol2={obj.getTableColumnHeader};
    tblIdx=1;
    nl=sprintf('\n');
    for idx=1:2:length(mergeIdxs)
        lowRow=mergeIdxs(idx);
        highRow=mergeIdxs(idx+1);
        tableCol1{end+1}=usedFcns{lowRow,1};
        if lowRow~=highRow
            text=[];
            for idy=lowRow:highRow
                text=[text,usedFcns{idy,2}];%#ok<*AGROW>
                if idy<highRow
                    text=[text,nl];
                end
            end
            tableCol2{end+1}=text;
        else
            tableCol2{end+1}=usedFcns{lowRow,2};
        end
        tblIdx=tblIdx+1;
    end
    table=mlreportgen.dom.Table([tableCol1',tableCol2'],'TableStyleAltRow');
end
