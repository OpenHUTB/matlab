function visualizeInput(id,varargin)




    if isa(id,'sltest.testmanager.TestInput')
        testInput=id;
        tcpID=0;
        sheets=arrayfun(@(x)x.Sheet,testInput.ExcelSpecifications,'UniformOutput',false);
        ranges=arrayfun(@(x)x.Range,testInput.ExcelSpecifications,'UniformOutput',false);

        model='';
        if(nargin>1)
            model=varargin{1};
        end
    else
        if(ischar(id)~=0)
            id=str2double(id);
        end
        testInput=sltest.internal.Helper.getTestInput(id);
        [sheets,ranges,model,tcpID]=stm.internal.getSheetRangeInfo(id,int32(stm.internal.SourceSelectionTypes.Input));
    end

    if isvalid(testInput)
        stm.internal.util.visualizeFile(testInput.FilePath,testInput.Name,...
        sheets,ranges,xls.internal.SourceTypes.Input,model,tcpID);
    end
end
