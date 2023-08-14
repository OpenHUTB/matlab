function fileLogImport(varargin)





























    try
        narginchk(0,3);

        switch nargin
        case 0
            runTable=slrealtime.fileLogList('ShowHostDir',true);
            request=runTable;
        case 1
            runTable=slrealtime.fileLogList('ShowHostDir',true);
            request=varargin{1};
        case 2
            runTable=slrealtime.fileLogList(varargin{:},'ShowHostDir',true);
            request=runTable;
        case 3
            runTable=slrealtime.fileLogList(varargin{2:3},'ShowHostDir',true);
            request=varargin{1};
        otherwise
            assert(0);
        end

    catch ME
        rethrow(ME);
    end


    try
        runTable=slrealtime.internal.logging.legitimizeRequest(request,'LocalRunTable',runTable);
        localImporter=slrealtime.internal.logging.Importer;
        localImporter.importLocal(runTable);
    catch ME
        error(message('slrealtime:logging:CannotImport',ME.message));
    end

end
