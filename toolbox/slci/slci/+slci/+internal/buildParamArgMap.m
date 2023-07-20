

function argMap=buildParamArgMap(model)
    str=get_param(model,'ParameterArgumentNames');
    names=strsplit(str,',');
    argMap=containers.Map('KeyType','char','ValueType','any');
    for i=1:numel(names)
        argMap(names{i})=names{i};
    end
end