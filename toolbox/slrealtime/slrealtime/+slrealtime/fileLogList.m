function runTable=fileLogList(varargin)
































    parser=inputParser();
    parser.FunctionName="slrealtime.fileLogList";
    parser.addParameter("Directory",[],@(x)validateattributes(x,{'string','char'},{'scalartext'}));
    parser.addParameter("ShowHostDir",false,@islogical);
    parser.parse(varargin{:});


    localDir=parser.Results.Directory;
    if(isempty(localDir))
        localDir=pwd;
    end

    try
        runTable=slrealtime.internal.logging.localLogData(localDir);
    catch ME

        if strcmp(ME.identifier,'slrealtime:logging:InvalidLocalDir')&&isfolder(fullfile(localDir,'applications'))
            localDir=fullfile(localDir,'applications');
            try
                runTable=slrealtime.internal.logging.localLogData(localDir);
            catch ME2
                error([ME.message,newline,ME2.message]);
            end
        else
            rethrow(ME);
        end
    end

    if~isempty(runTable)
        if~parser.Results.ShowHostDir

            runTable=slrealtime.internal.logging.FileLogger.filterHiddenCols(runTable);
        end

        runTable=slrealtime.internal.logging.FileLogger.addRowNames(runTable);
    end

end
