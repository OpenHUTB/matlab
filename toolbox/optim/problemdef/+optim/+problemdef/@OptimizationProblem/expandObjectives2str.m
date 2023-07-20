function objectiveStr=expandObjectives2str(prob,addBolding,varargin)



















    printHeaders=false;


    if addBolding
        formatSpec='\t<strong>%s %s:</strong>%s';
    else
        formatSpec='\t%s %s:%s';
    end


    objective=prob.Objective;

    if isempty(objective)
        objectiveStr=sprintf(formatSpec,prob.ObjectiveSense,"","");
    elseif isstruct(objective)

        objNames=fieldnames(objective);
        objectiveStr="";
        for i=1:length(objNames)
            thisObj=objective.(objNames{i});
            if~isempty(thisObj)

                objStr=optim.internal.problemdef.display.showDisplay(thisObj,...
                printHeaders,'objective',varargin{:});
                objStr=optim.internal.problemdef.display.indent(objStr);

                if isstruct(prob.ObjectiveSense)
                    thisSense=prob.ObjectiveSense.(objNames{i});
                else
                    thisSense=prob.ObjectiveSense;
                end
                objStr=sprintf(formatSpec,thisSense,objNames{i},objStr);
                objectiveStr=objectiveStr+objStr+newline;
            end
        end
    else

        objStr=optim.internal.problemdef.display.showDisplay(objective,...
        printHeaders,'objective',varargin{:});
        objStr=optim.internal.problemdef.display.indent(objStr);


        objectiveName="";
        objectiveStr=sprintf(formatSpec,prob.ObjectiveSense,objectiveName,...
        objStr);

    end


end