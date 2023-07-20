function generateCodeMetrics(model,varargin)





























    try
        rtw.report.generateCodeMetrics(model,varargin{:});
    catch me
        throwAsCaller(me);
    end
end


