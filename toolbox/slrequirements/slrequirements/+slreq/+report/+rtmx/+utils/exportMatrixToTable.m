function out=exportMatrixToTable(data)



    NO_NAME_HOLDER='(NoName)';

    sourceData=jsondecode(data);
    tableData=struct2table(sourceData.content);
    colHeaderNames=struct2cell(sourceData.colInfo);
    colVariables=containers.Map;
    headerNames=cell(size(colHeaderNames));



    maxLenghOfHeaderName=63-length(num2str(length(colHeaderNames)))-8;
    hasTruncated=false;
    hasDuplicated=false;
    hasEmptyName=false;
    for index=1:length(colHeaderNames)
        cHeaderName=colHeaderNames{index};
        if length(cHeaderName)>maxLenghOfHeaderName
            hasTruncated=true;
            headerName=['...',cHeaderName(end-maxLenghOfHeaderName:end)];
        else
            headerName=cHeaderName;
        end

        if isKey(colVariables,headerName)
            hasDuplicated=true;
            headerName=[headerName,'_col',num2str(index)];%#ok<AGROW>
        end
        colVariables(headerName)=true;

        headerNames{index}=headerName;
    end

    rowHeaderNames=struct2cell(sourceData.rowInfo);
    rowNames=cell(size(rowHeaderNames));
    rowVariables=containers.Map;
    for index=1:length(rowHeaderNames)
        cHeaderName=rowHeaderNames{index};

        if isempty(strtrim(cHeaderName))

            hasEmptyName=true;
            cHeaderName=NO_NAME_HOLDER;
        end

        if isKey(rowVariables,cHeaderName)

            hasDuplicated=true;
            cHeaderName=[cHeaderName,'_row',num2str(index)];%#ok<AGROW>
        end
        rowVariables(cHeaderName)=true;
        rowNames{index}=cHeaderName;
    end

    tableData.Properties.RowNames=rowNames;
    tableData.Properties.VariableNames=headerNames;
    sourceData.MATLABVersion=version;
    sourceData.MATLABRelease=version('-release');
    tableData.Properties.UserData=sourceData;

    assignin('base','slrtmxData',tableData);
    out='slrtmxData';

    if hasTruncated||hasDuplicated||hasEmptyName
        rmiut.warnNoBacktrace('Slvnv:slreq_rtmx:ErrorOnExportingDueToTableLimitation');
    end
end