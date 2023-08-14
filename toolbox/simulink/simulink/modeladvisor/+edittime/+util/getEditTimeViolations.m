





function violations=getEditTimeViolations(model,blkhandle,startWithViolationType)
    diagnosticViolations=edittime.util.getDiagnosticViolations(model,blkhandle);
    advisorViolations=edittime.util.getAdvisorViolations(model,blkhandle);
    violations=reorderViolations([diagnosticViolations,advisorViolations],startWithViolationType);
end


function output=reorderViolations(violations,startWithViolationType)
    v=violations;
    errors=[];warnings=[];
    for i=1:length(v)
        if(v(i).getViolationStatus()==ModelAdvisor.CheckStatus.Failed)
            errors=[errors,v(i)];%#ok<*AGROW>
        end
        if(v(i).getViolationStatus()==ModelAdvisor.CheckStatus.Warning)
            warnings=[warnings,v(i)];
        end
    end


    if(startWithViolationType==ModelAdvisor.CheckStatus.Failed)
        output=[errors,warnings];
    elseif(startWithViolationType==ModelAdvisor.CheckStatus.Warning)
        output=[warnings,errors];
    end
end
