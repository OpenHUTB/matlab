


function setFieldsFromFilterJSON(obj,filterJSON)
    if isstruct(filterJSON)

        obj.setSummary('');
        obj.setDescription('');
        obj.setTimeStamp(datetime('now','InputFormat','dd-MMM-yyyy HH:mm:ss',...
        'Locale','en_US','Format','dd-MMM-yyyy HH:mm:ss'));
        obj.setUser('');
        obj.fJustification.codeLines='';
        obj.fJustification.usingSuggestedTraceability=false;
        if~isempty(filterJSON)
            inParser=inputParser;
            addParameter(inParser,'id','');
            addParameter(inParser,'description','');
            addParameter(inParser,'timeStamp','');
            addParameter(inParser,'user','');
            addParameter(inParser,'codeLines','');
            addParameter(inParser,'deleted','');
            parse(inParser,filterJSON);
            obj.setDescription(inParser.Results.description);
            obj.setTimeStamp(datetime(inParser.Results.timeStamp,'InputFormat',...
            'dd-MMM-yyyy HH:mm:ss','Locale','en_US','Format','dd-MMM-yyyy HH:mm:ss'));
            obj.setUser(inParser.Results.user);
            obj.fJustification.codeLines=inParser.Results.codeLines;
        end


        for i=1:numel(filterJSON)
            setFieldsFromFilterJSONHelper(obj,filterJSON);
        end
    end
end
