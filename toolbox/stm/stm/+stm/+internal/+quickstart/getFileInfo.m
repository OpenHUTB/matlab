function[sheets,testAttr]=getFileInfo(filePath)








    [~,~,ext]=fileparts(filePath);
    if~any(strcmpi(ext,xls.internal.WriteTable.SpreadsheetExts))
        error(message('stm:QuickStart:DataSource_InvalidFile',filePath));
    end

    sheets=sheetnames(filePath);
    if iscolumn(sheets)
        sheets=sheets';
    end


    T=xls.internal.ReadTable(filePath,'Sheets',sheets);


    testAttr=string.empty;
    if T.readMetadata(xls.internal.SourceTypes.Input).numElements~=0
        testAttr{end+1}=getString(message('stm:QuickStart:SpecsInputsID'));
    end

    if locGetParameterInfo(filePath,sheets)
        testAttr{end+1}=getString(message('stm:QuickStart:SpecsParametersID'));
    end

    if(T.readMetadata(xls.internal.SourceTypes.Output).numElements~=0)
        testAttr{end+1}=getString(message('stm:QuickStart:SpecsComparisonID'));
    end

end

function exists=locGetParameterInfo(filePath,sheets)
    exists=false;
    for sheet=sheets
        T=xls.internal.ReadTable(filePath,'Sheets',sheet);
        if~isempty(T.readParameters())
            exists=true;
            return
        end
    end
end
