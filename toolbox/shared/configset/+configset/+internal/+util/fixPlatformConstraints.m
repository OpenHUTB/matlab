function out=fixPlatformConstraints(model)







    out='';
    constraints=configset.internal.util.getPlatformConstraints(...
    get_param(model,'EmbeddedCoderDictionary'),...
    get_param(model,'PlatformDefinition'));
    if~isempty(constraints)
        cs=getActiveConfigSet(model);
        constraints.fix(cs);
    end
