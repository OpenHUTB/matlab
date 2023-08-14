function runMATLABScriptDuringStartup(varargin)




    try
        matlab.internal.project.util.runMATLABCodeInBase(varargin{:});
    catch exception
        stack=dbstack;
        if numel(stack)>1


            report=exception.getReport;
            report=strrep(report,"\","\\");
            warning('MATLAB:project:StartupFileError',report);
        end
        rethrow(exception)
    end

end