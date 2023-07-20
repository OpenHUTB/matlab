function paramList=loadParameterOverridesMatFile(fileName)






    data=load(fileName);

    paramNames=fields(data);
    paramList=struct(...
    'Name',paramNames,...
    'ClassName',getClassNames(data),...
    'CanShow',false,...
    'DerivedDisplayValue',''...
    );

    for idx=1:length(paramNames)
        [paramList(idx).CanShow,paramList(idx).DerivedDisplayValue]=...
        stm.internal.util.getDisplayValue(data.(paramNames{idx}));
    end
end

function classNames=getClassNames(data)
    classNames=...
    struct2cell(structfun(@(field)class(field),data,'Uniform',false));
end
