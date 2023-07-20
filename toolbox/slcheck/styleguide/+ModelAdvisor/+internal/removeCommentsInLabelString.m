
function result=removeCommentsInLabelString(labelstr,getJoinedStr)







    label_split=regexp(labelstr,'\n','split');









    expressionComment='^%.*|/\*.*?\*/|(\/\/)+.*';
    comment_filtered=cellfun(@(x)regexprep(x,expressionComment,''),label_split,'UniformOutput',false);


    comment_filtered=comment_filtered(cellfun(@(x)~isempty(x),comment_filtered));
    if getJoinedStr
        result=strjoin(comment_filtered,'\n');
    else
        result=comment_filtered;
    end
