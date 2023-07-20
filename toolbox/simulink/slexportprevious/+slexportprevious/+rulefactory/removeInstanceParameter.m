function rule=removeInstanceParameter(identifyingRule,parameterName,verObj)



























    p=inputParser;
    p.addRequired('identifyingRule',@ischar);
    p.addRequired('parameterName',@ischarorcellstr);
    p.addRequired('verObj',@isverobj);

    function b=isverobj(obj)
        b=isa(obj,'saveas_version');
    end

    function b=ischarorcellstr(obj)
        b=ischar(obj)||iscellstr(obj);
    end

    p.parse(identifyingRule,parameterName,verObj);

    if iscellstr(parameterName)


        rule=cell(size(parameterName));
        for i=1:numel(parameterName)
            rule{i}=i_rule(identifyingRule,parameterName{i},verObj);
        end
        rule=sprintf('%s\n',rule{:});
    else
        rule=i_rule(identifyingRule,parameterName,verObj);
    end

end

function rule=i_rule(identifyingRule,parameterName,verObj)
    removeRule=slexportprevious.rulefactory.remove(parameterName);

    if~slexportprevious.rulefactory.needsInstanceDataElement(verObj)
        rule=sprintf('<Block<BlockType|Reference>%s%s>',identifyingRule,removeRule);
    else

        rule=sprintf('<Block<BlockType|Reference>%s<InstanceData%s>>',identifyingRule,removeRule);
    end
end

