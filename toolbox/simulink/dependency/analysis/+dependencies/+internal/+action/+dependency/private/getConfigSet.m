function[cs,modelName]=getConfigSet(dependency)







    [~,modelName,~]=fileparts(dependency.UpstreamNode.Location{1});

    types=dependency.Type.Parts;

    cs=get_param(modelName,'ConfigurationSets');


    if length(types)>1
        cs=find(cs,'-depth',0,'Name',types(2));
    else

        cs=getActiveConfigSet(modelName);
    end
end
