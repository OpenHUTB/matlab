function action=getcustomtypes(h)


    action=[];
    if~isempty(h.customactions)
        actionItemNames=fields(h.customactions);
        if~isempty(actionItemNames)
            n=length(actionItemNames);
            for i=1:n
                action=[action,{h.customactions.(actionItemNames{i})}];
            end
        end
    end
