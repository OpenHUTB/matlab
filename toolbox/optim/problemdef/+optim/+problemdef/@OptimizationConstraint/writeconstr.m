function writeconstr(con,varargin)




















    narginchk(1,2);


    defaultFilename=inputname(1);
    if isempty(defaultFilename)
        defaultFilename='WriteConstrOutput';
    end


    writeDisplay2File(con,defaultFilename,varargin{:});
