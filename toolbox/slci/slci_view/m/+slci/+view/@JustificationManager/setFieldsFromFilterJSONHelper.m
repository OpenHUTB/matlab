


function setFieldsFromFilterJSONHelper(obj,filterJSON)
    if isstruct(filterJSON)
        comment=advisor.filter.Metadata(obj.fMfModel);
        if isfield(filterJSON,'summary')
            comment.summary=(filterJSON.summary);
        else
            comment.summary=('');
        end
        if isfield(filterJSON,'description')
            comment.description=(filterJSON.description);
        else
            comment.description=('');
        end
        if isfield(filterJSON,'timeStamp')
            comment.timeStamp=datetime(filterJSON.timeStamp,'InputFormat',...
            'dd-MMM-yyyy HH:mm:ss','Locale','en_US','Format','dd-MMM-yyyy HH:mm:ss');
        else
            comment.timeStamp=(datetime('now','InputFormat','dd-MMM-yyyy HH:mm:ss',...
            'Locale','en_US','Format','dd-MMM-yyyy HH:mm:ss'));
        end
        if isfield(filterJSON,'user')
            comment.user=(filterJSON.user);
        else
            comment.user=('');
        end
        obj.addComment(comment);
    end
end
