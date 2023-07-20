function out=genConfigCheckReportComments(modelName)







    out='';
    try
        checkResult=coder.internal.configCheckReportHelper('readModelAdvisorCheckReport',modelName);

        if length(checkResult.op)==1
            objectiveText='Code generation objective: ';
        else
            objectiveText='Code generation objectives: ';
        end
        validateText='Validation result: ';
        if isempty(checkResult.op)
            out=sprintf('%sUnspecified\n%s%s\n',objectiveText,validateText,checkResult.result);
            return;
        end
        out=objectiveText;
        if(length(checkResult.op)>1)
            for i=1:length(checkResult.op)
                out=sprintf('%s\n   %d. %s',out,i,checkResult.op{i});
            end
        else
            out=sprintf('%s%s',out,checkResult.op{1});
        end

        out=sprintf('%s\n%s%s\n',out,validateText,checkResult.result);
    catch me
        if rtwprivate('rtwinbat')
            rethrow(me);
        else
            disp(me.message);
        end
        out=me.message;
    end
