function constraintsStr=expandConstraints2str(prob,addBolding,varargin)



















    printHeaders=false;


    constraints=prob.Constraints;
    if isempty(constraints)
        constraintsStr='';
    else

        if addBolding
            formatSpec='%s\n\t<strong>subject to %s:</strong>%s';
        else
            formatSpec='%s\n\tsubject to %s:%s';
        end
        if isstruct(constraints)

            conNames=fieldnames(constraints);
            constraintsStr='';
            for i=1:length(conNames)
                thisCon=constraints.(conNames{i});
                if~isempty(thisCon)

                    conStr=optim.internal.problemdef.display.showDisplay(thisCon,...
                    printHeaders,'constraint',varargin{:});
                    conStr=optim.internal.problemdef.display.indent(conStr);
                    constraintsStr=sprintf(formatSpec,constraintsStr,conNames{i},conStr);
                end
            end
        else

            conStr=optim.internal.problemdef.display.showDisplay(constraints,...
            printHeaders,'constraint',varargin{:});
            conStr=optim.internal.problemdef.display.indent(conStr);
            constraintsStr=sprintf(formatSpec,'','',conStr);
        end
    end

end