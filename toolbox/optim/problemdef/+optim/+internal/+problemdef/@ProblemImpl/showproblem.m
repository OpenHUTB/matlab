function showproblem(prob)












    className=prob.className;


    [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
    'helpPopup',className);

    fprintf('\n  %s%s%s : %s',...
    startTag,className,endTag,prob.Description);



    addBolding=~isempty(startTag);
    strBuffer=expand2str(prob,addBolding);

    if~isempty(strBuffer)

        commandWindowSize=matlab.desktop.commandwindow.size;
        commandWindowWidth=commandWindowSize(1);
        strBuffer=matlab.internal.display.printWrapped(strBuffer,commandWindowWidth);
        disp(strBuffer);
    else
        fprintf('\n\n  %s\n',getString(...
        message('optim_problemdef:ProblemImpl:NoProblemDefinedFooter')));
    end
