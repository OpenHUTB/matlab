function props=find_reduced_set_of_properties(h,simulink_class_name)
















    persistent baseClassProps;


    if~isfield(baseClassProps,simulink_class_name)
        fullBaseClassName=['Simulink.',simulink_class_name];
        assert(isa(h,fullBaseClassName));
        basicObj=eval(fullBaseClassName);
        baseClassProps.(simulink_class_name)=Simulink.data.getPropList(basicObj,'GetAccess','public');
    end
    basicProps=baseClassProps.(simulink_class_name);

    allProps=Simulink.data.getPropList(h,'GetAccess','public');


    if(length(basicProps)==length(allProps))
        props=[];
        return;
    end;


    j=1;
    for i=1:length(allProps)
        if~ismember(allProps(i),basicProps)
            props(j)=allProps(i);%#ok
            j=j+1;
        end;
    end
end

