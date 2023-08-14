function res=hasTransitionAction(transition)
    res=false;
    if~isa(transition,'Stateflow.Transition')
        return;
    end
    if isempty(transition.LabelString)
        return;
    end




    label_split=regexp(transition.LabelString,'\n','split');








    expressionComment='^%.*|/\*.*?\*/|(\/\/)+.*';
    comment_filtered=cellfun(@(x)regexprep(x,expressionComment,''),label_split,'UniformOutput',false);


    comment_filtered=comment_filtered(cellfun(@(x)~isempty(x),comment_filtered));



    label_str=strjoin(comment_filtered,'\n');
    label_str=regexprep(label_str,'\s','');




    res=~isempty(regexp(label_str,'^\/.*|.*\]\/.*|.*\}\/.*','once'));
end