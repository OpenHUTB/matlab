function writeexpr(expr,varargin)




















    narginchk(1,2);

    defaultFilename=inputname(1);
    if isempty(defaultFilename)
        defaultFilename='WriteExprOutput';
    end


    writeDisplay2File(expr,defaultFilename,varargin{:});
