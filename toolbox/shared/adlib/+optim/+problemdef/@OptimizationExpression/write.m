function write(expr,varargin)

















    narginchk(1,2);

    defaultFilename=inputname(1);
    if isempty(defaultFilename)
        defaultFilename='WriteOutput';
    end


    writeDisplay2File(expr,defaultFilename,varargin{:});
