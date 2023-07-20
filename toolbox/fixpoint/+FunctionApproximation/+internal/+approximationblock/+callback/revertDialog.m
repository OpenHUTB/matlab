function[popupDialog,textSection,button1,button2]=revertDialog(variantSystemTag)%#ok<INUSD>







    variantSystemHandle=gcbh;
    variantSystemPath=gcb;
    topModel=bdroot(variantSystemHandle);
    schema=FunctionApproximation.internal.approximationblock.BlockSchema();


    modelLocation=get_param(topModel,'Location');
    X1=modelLocation(1);
    Y1=modelLocation(2);
    X2=modelLocation(3);
    Y2=modelLocation(4);



    f=1/4;
    A=(1+f)/2;
    B=(1-f)/2;
    X1new=A*X1+B*X2;
    Y1new=A*Y1+B*Y2;
    dXnew=300;
    dYnew=200;


    screenPosition=get(0,'ScreenSize');
    xDialog=max(min(X1new,screenPosition(3)-2*dXnew),100);
    yDialog=max(min(screenPosition(4)-Y1new-dYnew,screenPosition(4)-2*dYnew),100);


    dialogPosition=[xDialog,yDialog,dXnew,0.9*dYnew];
    popupDialog=dialog('Position',dialogPosition,'Name',schema.RevertToOriginalPrompt);

    buttonStringForAbort=message('SimulinkFixedPoint:functionApproximation:rfabRevertDialogAbort').getString();
    buttonStringForContinue=message('SimulinkFixedPoint:functionApproximation:rfabRevertDialogContinue').getString();


    part1=message('SimulinkFixedPoint:functionApproximation:rfabRevertDialogPart1').getString();
    part2=message('SimulinkFixedPoint:functionApproximation:rfabRevertDialogPart2').getString();
    part3=message('SimulinkFixedPoint:functionApproximation:rfabRevertDialogPart3',buttonStringForContinue).getString();
    dialogString=sprintf('%s %s %s',part1,part2,part3);
    textSection=uicontrol('Parent',popupDialog,...
    'Style','text',...
    'Position',[10,0.1*dYnew,0.9*dXnew,0.7*dYnew],...
    'String',dialogString,...
    'HorizontalAlignment','left',...
    'FontSize',10);


    button1=uicontrol('Parent',popupDialog,...
    'InnerPosition',[0.05*dXnew,10,0.4*dXnew,0.2*dYnew],...
    'String',buttonStringForContinue,...
    'Callback',schema.getCallbackForRevertDialogWithPath(variantSystemPath));


    button2=uicontrol('Parent',popupDialog,...
    'InnerPosition',[0.55*dXnew,10,0.4*dXnew,0.2*dYnew],...
    'String',buttonStringForAbort,...
    'Callback','delete(gcf)');
end


