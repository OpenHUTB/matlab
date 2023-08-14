classdef FromSpreadsheetBlockHandler<dependencies.internal.action.refactor.FileParameterHandler





    properties(Constant)
        ParameterName="FileName";
    end

    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.FromSpreadsheetBlockAnalyzer.FromSpreadsheetBlockType.ID);
    end

end
