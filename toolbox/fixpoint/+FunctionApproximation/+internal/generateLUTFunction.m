function varargout=generateLUTFunction(solObj,varargin)











    tableData=solObj.tabledata;
    problem=solObj.SourceProblem;
    problem.Options.BreakpointSpecification=solObj.ErrorFunction.Approximation.Data.Spacing;
    defaultFileName=['approximateFunction_',datestr(now,'yyyymmddTHHMMSSFFF'),'.m'];
    defaultLocation='';

    p=inputParser;
    p.CaseSensitive=1;
    addRequired(p,'solObj',@(x)validateattributes(x,{'FunctionApproximation.LUTSolution','FunctionApproximation.internal.ApproximateLUTSolution'},{'size',[1,1]}));
    addParameter(p,'Name',defaultFileName,@ischar);
    addParameter(p,'Path',defaultLocation,@ischar);
    parse(p,solObj,varargin{:});

    FunctionApproximation.internal.DataTypeValidator.validateSupportedDataTypes(problem.InputTypes,problem.OutputType);

    mLUT=FunctionApproximation.internal.GenerateFunction(tableData,problem,p.Results.Name,p.Results.Path);
    if nargout==1
        varargout{1}=mLUT.DocumentObj;
    end
end
