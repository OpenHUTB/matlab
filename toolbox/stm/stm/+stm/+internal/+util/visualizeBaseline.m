function visualizeBaseline(id,varargin)




    if isa(id,'sltest.testmanager.BaselineCriteria')
        baseline=id;
        tcpID=0;
        sheets=arrayfun(@(x)x.Sheet,baseline.ExcelSpecifications,'UniformOutput',false);
        ranges=arrayfun(@(x)x.Range,baseline.ExcelSpecifications,'UniformOutput',false);

        model='';
        if(nargin>1)
            model=varargin{1};
        end
    else
        if ischar(id)
            id=str2double(id);
        end
        baseline=sltest.internal.Helper.getBaselineCriteria(id);
        [sheets,ranges,model,tcpID]=stm.internal.getSheetRangeInfo(id,int32(stm.internal.SourceSelectionTypes.Baseline));
    end

    if isvalid(baseline)
        stm.internal.util.visualizeFile(baseline.FilePath,baseline.Name,...
        sheets,ranges,xls.internal.SourceTypes.Output,model,tcpID);
    end
end
