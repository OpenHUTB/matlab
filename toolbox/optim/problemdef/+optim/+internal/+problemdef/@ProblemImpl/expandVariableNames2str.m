function variableNamesStr=expandVariableNames2str(prob,addBolding,varargin)





















    vars=prob.Variables;
    variableNames=string(fieldnames(vars));
    variableNamesStr=strjoin(variableNames,', ');
    nVar=numel(variableNames);


    truncate=false;
    type='';


    nIntVar=0;
    integerVariableNamesStr=strings(nVar,1);

    for idxVar=1:nVar
        varNameI=variableNames(idxVar);
        if strcmpi(vars.(varNameI).Type,"integer")
            nIntVar=nIntVar+1;
            integerVariableNamesStr(nIntVar)=varNameI;
        end
    end
    if(nIntVar>0)
        integerVariableNamesStr=join(integerVariableNamesStr(1:nIntVar),', ');
        integerVariableNamesStr=integerVariableNamesStr+" integer";



        integerVariableNamesStr=optim.internal.problemdef.display.printForCommandWindow(integerVariableNamesStr,...
        truncate,type,varargin{:});


        integerVariableNamesStr=newline+"  "+integerVariableNamesStr;
        integerVariableNamesStr=optim.internal.problemdef.display.indent(integerVariableNamesStr);
    end



    variableNamesStr=optim.internal.problemdef.display.printForCommandWindow(variableNamesStr,...
    truncate,type,varargin{:});


    variableNamesStr=newline+"  "+variableNamesStr;
    variableNamesStr=optim.internal.problemdef.display.indent(variableNamesStr);


    if addBolding
        formatSpec='\t<strong>Solve for:</strong>%s\n';
        if(nIntVar>0)
            formatSpec=[formatSpec,'\t<strong>where:</strong>%s\n'];

            variableNamesStr=sprintf(formatSpec,variableNamesStr,integerVariableNamesStr);
        else

            variableNamesStr=sprintf(formatSpec,variableNamesStr);
        end
    else
        formatSpec='\tSolve for:%s\n';
        if(nIntVar>0)
            formatSpec=[formatSpec,'\twhere:%s\n'];

            variableNamesStr=sprintf(formatSpec,variableNamesStr,integerVariableNamesStr);
        else

            variableNamesStr=sprintf(formatSpec,variableNamesStr);
        end
    end

