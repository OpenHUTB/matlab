function r=isequal(obj,other)



    r=false;
    if~isa(other,'Simulink.CSCRefDefn')
        return;
    end


    assert(strcmp(class(obj),'Simulink.CSCRefDefn'));%#ok
    assert(strcmp(class(other),'Simulink.CSCRefDefn'));%#ok



    h=classhandle(obj);
    h_other=classhandle(other);
    assert(length(h.Properties)==length(h_other.Properties));


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


