












function rc=ParallelAnchorDirManager(action,varargin)



    persistent ParallelCacheFolder;
    persistent ParallelCodeGenFolder;

    rc=[];

    switch action
    case 'set'
        ParallelCacheFolder=varargin{1};
        ParallelCodeGenFolder=varargin{2};
    case 'get'
        if strcmp(varargin{1},'SIM')
            if isempty(ParallelCacheFolder)
                ParallelCacheFolder='';
            end
            rc=ParallelCacheFolder;
        elseif strcmp(varargin{1},'RTW')
            if isempty(ParallelCodeGenFolder)
                ParallelCodeGenFolder='';
            end
            rc=ParallelCodeGenFolder;
        else

            rc='';
        end
    end
    return;
end

