function h=getHandleFromObject(Object)
    if isa(Object,'Simulink.Object')
        h=Object.Handle;
    elseif isa(Object,'Stateflow.LinkChart')
        h=sfprivate('chart2block',Object.Id);
    else
        h=Object.Id;
    end
end