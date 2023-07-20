function r=isequal(obj,other)



    r=false;
    if~isa(other,'Simulink.MemorySectionRefDefn')
        return;
    end


    assert(strcmp(class(obj),'Simulink.MemorySectionRefDefn'));%#ok
    assert(strcmp(class(other),'Simulink.MemorySectionRefDefn'));%#ok


    h=classhandle(obj);
    assert(length(h.Properties)==16);


    props_string={...
    'Name',...
    'OwnerPackage',...
    'RefPackageName',...
    'RefDefnName'};

    for k=1:length(props_string)
        if~isequal(obj.(props_string{k}),other.(props_string{k}))
            return;
        end
    end
    r=true;


