function varargout=getCommentStrings(function_name,commentsToAdd)







    if isa(function_name,'cfit')
        varargout{1}=['%This code is an approximation for ',type(function_name),' fit',newline,'%'];
    else
        varargout{1}=['%This code is an approximation for ',function_name,newline,'%'];
    end

    for i=1:length(commentsToAdd)
        commentsToAdd{i,:}=['%',commentsToAdd{i},newline];
    end
    varargout{2}=commentsToAdd;
end
