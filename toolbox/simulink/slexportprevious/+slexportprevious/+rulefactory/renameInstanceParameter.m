function rule=renameInstanceParameter(identifyingRule,parameterName,newName,verObj)





























    p=inputParser;
    p.addRequired('sourceBlock',@ischar);
    p.addRequired('parameterName',@ischarorcellstr);
    p.addRequired('newName',@ischarorcellstr);
    p.addRequired('verObj',@isverobj);

    function b=isverobj(obj)
        b=isa(obj,'saveas_version');
    end

    function b=ischarorcellstr(obj)
        b=ischar(obj)||iscellstr(obj);
    end

    p.parse(identifyingRule,parameterName,newName,verObj);

    renameRule=slexportprevious.rulefactory.rename(parameterName,newName);

    if~slexportprevious.rulefactory.needsInstanceDataElement(verObj)
        rule=sprintf('<Block<BlockType|Reference>%s%s>',identifyingRule,renameRule);
    else
        rule=sprintf('<Block<BlockType|Reference>%s<InstanceData%s>>',identifyingRule,renameRule);
    end

end
