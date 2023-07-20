function GradientComment=gradComment(numFcnOutputs,codeCommentId,codeCommentHoleCell,gradientType)









    codeCommentId="shared_adlib:codeComments:"+codeCommentId;


    GradientComment=getString(message(codeCommentId,codeCommentHoleCell{:}));
    if numFcnOutputs==2
        SpecifyOption="SpecifyConstraintGradient";
    else
        SpecifyOption="SpecifyObjectiveGradient";
    end
    SpecifyGradientHelp=getString(message("shared_adlib:codeComments:SpecifyGradientHelp",...
    gradientType,SpecifyOption));
    GradientComment=[GradientComment,newline,SpecifyGradientHelp];

    GradientComment=matlab.internal.display.printWrapped(GradientComment,73);

    GradientComment(end)=[];


    GradientComment="%"+strjoin("% "+splitlines(GradientComment),'\n')+newline;
