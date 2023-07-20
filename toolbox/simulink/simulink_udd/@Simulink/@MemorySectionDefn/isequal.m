function r=isequal(obj,other)



    r=false;
    if~isa(other,'Simulink.MemorySectionDefn')
        return;
    end


    assert(strcmp(class(obj),'Simulink.MemorySectionDefn'));%#ok
    assert(strcmp(class(other),'Simulink.MemorySectionDefn'));%#ok


    h=classhandle(obj);
    assert(length(h.Properties)==13);


    props_string={...
    'Name',...
    'OwnerPackage',...
    'Comment',...
    'PragmaPerVar',...
    'PrePragma',...
    'PostPragma',...
...
...
...
...
    'IsConst',...
    'IsVolatile',...
    'Qualifier'};

    for k=1:length(props_string)
        if~isequal(obj.(props_string{k}),other.(props_string{k}))
            return;
        end
    end


    if((obj.DataUsage.IsParameter~=other.DataUsage.IsParameter)||...
        (obj.DataUsage.IsSignal~=other.DataUsage.IsSignal))
        return;
    end

    r=true;


