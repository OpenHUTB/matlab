function equationsStr=expandObjectives2str(prob,addBolding,varargin)



















    printHeaders=false;


    equations=prob.Equations;
    if isempty(equations)
        equationsStr='';
    else

        if addBolding
            formatSpec='%s\n\t<strong>%s:</strong>%s';
        else
            formatSpec='%s\n %s:%s';
        end
        if isstruct(equations)

            eqnNames=fieldnames(equations);
            equationsStr='';
            for i=1:length(eqnNames)
                thisEqn=equations.(eqnNames{i});
                if~isempty(thisEqn)
                    conStr=optim.internal.problemdef.display.showDisplay(thisEqn,...
                    printHeaders,'equation',varargin{:});
                    conStr=optim.internal.problemdef.display.indent(conStr);
                    equationsStr=sprintf(formatSpec,equationsStr,eqnNames{i},conStr);
                end
            end
        else

            conStr=optim.internal.problemdef.display.showDisplay(equations,...
            printHeaders,'equation',varargin{:});
            conStr=optim.internal.problemdef.display.indent(conStr);
            equationsStr=sprintf('%s',conStr);
        end
    end

end