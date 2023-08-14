function[ruleStrs,comments]=defaultRuleTranslator(rules)





    ruleStrs=Simulink.DataTypePrmWidget.udtMessages(rules);
    comments=cell(size(ruleStrs));
    for i=1:length(comments);
        comments{i}='';
    end
