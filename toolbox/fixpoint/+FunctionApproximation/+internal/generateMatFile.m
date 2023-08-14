function generateMatFile(tableData,inputType,filename)





    if tableData.TableDataType.isscalingslopebias
        tableValues=fi(tableData.TableValues,tableData.TableDataType);
    elseif tableData.TableDataType.ishalf
        tableValues=half(tableData.TableValues);
    else
        tableValues=fi(tableData.TableValues,tableData.TableDataType);
    end

    breakpointValues=cell(1,numel(tableData.BreakpointDataTypes));
    for i=1:numel(tableData.BreakpointDataTypes)
        if tableData.BreakpointDataTypes(i).isscalingslopebias
            breakpointValues{i}=fi(tableData.BreakpointValues{i},tableData.BreakpointDataTypes(i));
            breakpointValues{i}.SumMode='SpecifyPrecision';
            breakpointValues{i}.SumWordLength=inputType(i).WordLength+1;
            breakpointValues{i}.SumFractionLength=max(tableData.BreakpointDataTypes(i).FractionLength,inputType(i).FractionLength);
            breakpointValues{i}.ProductMode='SpecifyPrecision';
            breakpointValues{i}.ProductWordLength=breakpointValues{i}.SumWordLength+breakpointValues{i}.SumWordLength;
            breakpointValues{i}.ProductFractionLength=breakpointValues{i}.SumWordLength-1;
        elseif tableData.BreakpointDataTypes(i).ishalf
            breakpointValues{i}=half(tableData.BreakpointValues{i});
        else
            breakpointValues{i}=fi(tableData.BreakpointValues{i},tableData.BreakpointDataTypes(i));
        end
    end
    save(filename,'tableValues','breakpointValues');
end
