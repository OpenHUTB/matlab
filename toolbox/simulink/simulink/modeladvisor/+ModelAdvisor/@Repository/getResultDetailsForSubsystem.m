function violationObjs=getResultDetailsForSubsystem(obj,subsystem)
    violationObjs=[];
    allviolationObjs=obj.loadData('resultdetails');
    for i=1:numel(allviolationObjs)
        if~isempty(allviolationObjs(i).Data)
            if(allviolationObjs(i).Type==ModelAdvisor.ResultDetailType.SID)&&strncmp(getfullname(subsystem),Simulink.ID.getFullName(allviolationObjs(i).Data),numel(getfullname(subsystem)))
                if isempty(violationObjs)
                    clear violationObjs;
                    violationObjs(1)=allviolationObjs(i);
                else
                    violationObjs(end+1)=allviolationObjs(i);%#ok<AGROW>
                end
            end
        end
    end
end