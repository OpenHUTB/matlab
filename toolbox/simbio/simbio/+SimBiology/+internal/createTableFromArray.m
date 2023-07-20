function dataTable=createTableFromArray(data,variableNames,suffix)




















    assert(isa(suffix,'char'));
    suffixLength=numel(suffix);

    dataTable=array2table(data);


    numVariables=numel(variableNames);
    maxVarNameLength=55-suffixLength-ceil(log10(numVariables));

    if numVariables>0
        varNames=cell(1,numVariables);
        tfConflictWithReservedName=...
        matlab.internal.tabular.private.varNamesDim.checkReservedNames(variableNames);
        for i=1:numVariables
            varNames{i}=variableNames{i};
            if length(varNames{i})>maxVarNameLength

                varNames{i}=[varNames{i}(1:maxVarNameLength),'...'];
                if sum(strncmp(variableNames{i},variableNames,maxVarNameLength))>1

                    varNames{i}=[varNames{i},sprintf(' (%s %d)',suffix,i)];
                end
            elseif tfConflictWithReservedName(i)

                varNames{i}=[varNames{i},sprintf(' (%s %d)',suffix,i)];
            end





            n=length(varNames{i});j=0;
            while any(strcmp(varNames{i},varNames(1:i-1)))
                j=j+1;
                varNames{i}=[varNames{i}(1:n),sprintf(' (%d)',j)];
            end
        end
        dataTable.Properties.VariableNames=varNames;
        dataTable.Properties.VariableDescriptions=variableNames;
    end

end