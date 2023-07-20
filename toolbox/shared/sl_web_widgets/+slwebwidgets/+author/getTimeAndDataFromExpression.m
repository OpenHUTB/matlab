function[timeToUse,dataToUse]=getTimeAndDataFromExpression(timeString,dataString,varargin)





    try
        timeToUse=eval(timeString);
    catch ME_TIME

        try
            timeToUse=evalin('base',timeString);
        catch ME_TIME_WS

            if~isempty(varargin)
                timeToUse=slwebwidgets.tableeditor.evalinSimulink(varargin{1},timeString);
            end
        end
    end

    timeToUse=slwebwidgets.AuthorUtility.formatTimeValues(timeToUse);

    try
        dataToUse=eval(dataString);
    catch ME_DATA
        try
            dataToUse=evalin('base',dataString);
        catch ME_DATA_WS
            if~isempty(varargin)
                dataToUse=slwebwidgets.tableeditor.evalinSimulink(varargin{1},dataString);
            end
        end
    end

    dataToUse=slwebwidgets.AuthorUtility.formatDataValues(dataToUse);
