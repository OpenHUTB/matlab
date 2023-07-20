





function status=isValidAnalysisRoot(sysObj)
    status=false;


    if~isa(sysObj,'DAStudio.Object')&&~isa(sysObj,'Simulink.DABaseObject')
        return;
    end


    [sysObj,~]=...
    Advisor.component.internal.Object2ComponentID.resolveObject(sysObj);

    if Advisor.component.internal.Object2ComponentID.isComponent(sysObj)
        status=true;
    end
end
