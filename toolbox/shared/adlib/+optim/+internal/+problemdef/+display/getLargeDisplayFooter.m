function str=getLargeDisplayFooter(type)









    switch type
    case 'expression'
        footer=iCreateFooter('optim.problemdef.OptimizationExpression',...
        'shared_adlib:printForCommandWindow:ExpressionFooter');
    case 'constraint'
        footer=iCreateFooter('optim.problemdef.OptimizationConstraint',...
        'shared_adlib:printForCommandWindow:ConstraintFooter');
    case 'equation'
        footer=iCreateFooter('optim.problemdef.OptimizationEquality',...
        'shared_adlib:printForCommandWindow:EquationFooter');
    case 'equality'
        footer=iCreateFooter('optim.problemdef.OptimizationEquality',...
        'shared_adlib:printForCommandWindow:EqualityFooter');
    end

    str=sprintf('\n\n  %s',footer);

    function footer=iCreateFooter(className,msgId)

        showHelp=[className,'/show'];
        [startTagShow,endTagShow]=optim.internal.problemdef.createHotlinks(...
        'helpPopup',showHelp);
        writeHelp=[className,'/write'];
        [startTagWrite,endTagWrite]=optim.internal.problemdef.createHotlinks(...
        'helpPopup',writeHelp);
        footer=getString(message(msgId,startTagShow,endTagShow,...
        startTagWrite,endTagWrite));