


function cellResult=EvalExpression(obj,expressionString)
    expressionString=regexprep(expressionString,'(gcb)','Obj.BlockHandle');
    expressionString=regexprep(expressionString,'(gcbh)','Obj.BlockHandle');

    for VariablesNameValues=obj.Variables
        try
            if(count(mtfind(mtree(VariablesNameValues.Name),'Kind','ID'))>1)
                VariableNames=strings(mtfind(mtree(VariablesNameValues.Name),'Kind','ID'));
                for i=1:numel(VariableNames)
                    EvalString=[string(VariableNames{i}),'= VariablesNameValues.Value(',string(i),repmat(',:',1,numel(size(VariablesNameValues.Value))-1),');'];
                    EvalString=strjoin(EvalString);
                    eval(char(EvalString));
                end
            else
                EvalString=[string(VariablesNameValues.Name),'= VariablesNameValues.Value;'];
                EvalString=strjoin(EvalString);
                eval(char(EvalString));
            end
        catch
            warning('Adding parameters may have failed.');
        end
    end
    cellResult=eval(['{',char(expressionString),'}']);
end