function footer=getFooter(~)







    [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
    'helpPopup','optim.problemdef.OptimizationExpression/show');


    footer=sprintf('  %s\n',...
    getString(message('shared_adlib:OptimizationExpression:Footer',startTag,endTag)));


    if strcmp(get(0,'FormatSpacing'),'compact')
        footer=sprintf('\n%s',footer);
    end