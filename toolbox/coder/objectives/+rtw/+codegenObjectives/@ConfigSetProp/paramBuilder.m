function paramBuilder(obj)


    obj.ParamHash=coder.advisor.internal.HashMap;
    csdm=configset.internal.getConfigSetStaticData;
    params=parameterList(obj);
    paramIdx=length(params);

    for i=1:paramIdx
        params(i).inDAG=0;
        params(i).ancestor=0;
        paramDM=csdm.getParam(params(i).name);
        if iscell(paramDM)
            params(i).DAGOrder=0;
        else
            params(i).DAGOrder=paramDM.Order;
        end
    end

    idx=length(params);
    prop=loc_getParamList(csdm);
    paramHash=obj.ParamHash;

    for i=1:length(prop)
        if isempty(prop{i})||~isempty(paramHash.get(prop{i}))
            continue;
        end

        idx=idx+1;
        params(idx).name=prop{i};
        params(idx).id=idx;
        params(idx).default='off';
        params(idx).defaultComplementary='on';
        params(idx).reversed='N';
        params(idx).inDAG=0;
        params(idx).ancestor=0;

        paramDM=csdm.getParam(prop{i});
        if iscell(paramDM)
            params(idx).DAGOrder=0;
        else
            params(idx).DAGOrder=paramDM.Order;
        end
        paramHash.put(params(idx).name,idx);
    end

    obj.ParamHash=paramHash;
    obj.Parameters=params;


    function prop=loc_getParamList(csdm)
        components=csdm.ComponentList;
        component_params={};
        for i=1:length(components)
            if any(strcmp(components{i}.Type,{'Base','Target'}))
                component_params{end+1}=components{i}.getParamNames';%#ok<AGROW>
            end
        end
        prop=[component_params{:}];






