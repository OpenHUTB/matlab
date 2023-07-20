function output=convertHighlightInput(input,extra)





    name=convertStringsToChars(input);
    if~iscell(name)
        name={name};
    end



    if isa(extra,'Simulink.ConfigSet')
        adp=configset.internal.data.ConfigSetAdapter(extra);
    else
        adp=extra;
    end
    for i=1:length(name)
        id=name{i};
        p=adp.getParamData(id);
        if~isempty(p)
            name{i}=p.Name;
        end
    end

    output=name;
