function functionSignatureAndHelpText=generateSignatureAndHelp(prob,...
    extraParams,extraParamsName,inMemory,objValue,gradientValue,...
    equationFcnName,inputVariables,isFinDiff)









    IsEquationProblem=isa(prob,'optim.problemdef.EquationProblem');

    if isFinDiff
        headerMsgId="shared_adlib:codeComments:"+prob.ObjectiveCompileName+"FunctionHeader";
    else
        headerMsgId="shared_adlib:codeComments:"+prob.ObjectiveCompileName+...
        "FunctionHeader"+"With"+prob.DerivativeCompileName;
    end





    helpThreeSpaces="   ";





    if isstrprop(equationFcnName,"lower")
        helpFcnName=upper(equationFcnName);
    else
        helpFcnName=equationFcnName;
    end

    if isempty(extraParams)&&~inMemory





        functionSignature="function ["+objValue+", "+gradientValue+"] = "+...
        equationFcnName+"("+inputVariables+")"+newline;

        if IsEquationProblem
            headerStr=getString(message(headerMsgId));
        else
            headerStr=getString(message(headerMsgId,'gradient'));
        end
        helpText=helpFcnName+" "+headerStr+newline+newline+...
        helpThreeSpaces+upper(objValue)+" = "+helpFcnName+"("+upper(inputVariables)+") "+...
        getString(message("shared_adlib:codeComments:"+prob.ObjectiveCompileName+"FunctionSyntax",...
        upper(objValue),upper(inputVariables)))+newline+...
        newline+...
        helpThreeSpaces+"["+upper(objValue)+", "+upper(gradientValue)+"] = "+...
        helpFcnName+"("+upper(inputVariables)+") ";

    else

        functionSignature="function ["+objValue+", "+gradientValue+"] = "+...
        equationFcnName+"("+inputVariables+", "+extraParamsName+")"+newline;

        if IsEquationProblem
            headerStr=getString(message(headerMsgId));
        else
            headerStr=getString(message(headerMsgId,'gradient'));
        end
        helpText=helpFcnName+" "+headerStr+newline+newline+...
        helpThreeSpaces+upper(objValue)+" = "+helpFcnName+"("+upper(inputVariables)+", "+upper(extraParamsName)+") "+...
        getString(message("shared_adlib:codeComments:"+prob.ObjectiveCompileName+"FunctionSyntaxWithExtraParams",...
        upper(objValue),upper(inputVariables),upper(extraParamsName)))+newline+...
        newline+...
        helpThreeSpaces+"["+upper(objValue)+", "+upper(gradientValue)+"] = "+...
        helpFcnName+"("+upper(inputVariables)+", "+upper(extraParamsName)+") ";
    end


    if IsEquationProblem
        syntaxHelpStr=getString(message("shared_adlib:codeComments:EquationGradientSyntax",...
        upper(gradientValue)));
    else
        syntaxHelpStr=getString(message("shared_adlib:codeComments:ObjectiveGradientSyntax",...
        'gradient',upper(gradientValue)));
    end
    helpText=helpText+syntaxHelpStr+newline+newline+...
    helpThreeSpaces+getString(message('shared_adlib:codeComments:AutoGenerated',datestr(now)));


    helpText=matlab.internal.display.printWrapped(helpText,73);
    helpText(end)=[];


    helpText=strjoin("%"+splitlines(helpText),'\n')+newline+newline;


    functionSignatureAndHelpText=functionSignature+helpText;
end


