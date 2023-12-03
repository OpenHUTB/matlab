function result=extractTraceComments(str)

    result.openingComment='';
    result.closingComment='';
    result.content=regexprep(str,'/\*@[><\[\]][0-9a-f]*\*/','');
    comments=regexp(str,'/\*@[><\[\]][0-9a-f]*\*/','match');
    for i=1:length(comments)
        if~isempty(regexp(comments{i},'^/\*@\[','once'))
            result.openingComment=[result.openingComment,comments{i}];
        elseif~isempty(regexp(comments{i},'^/\*@\]','once'))
            result.closingComment=[result.closingComment,comments{i}];
        elseif~isempty(regexp(comments{i},'^/\*@[><]','once'))
            comments{i}=regexprep(comments{i},'^/\*@[><]','/\*@\[');
            result.openingComment=[result.openingComment,comments{i}];
            result.closingComment=[result.closingComment,'/*@]*/'];
        end
    end
