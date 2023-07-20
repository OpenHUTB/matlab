function addParams(obj,paramList)



    n=length(obj.ParamList);
    obj.ParamList=[obj.ParamList,paramList];


    for i=1:length(paramList)
        p=paramList{i};
        p.ID=n+i;
        p.Order=n+p.Order;
        name=p.Name;
        fullName=p.FullName;
        alias=p.Alias;
        for j=1:length(alias)
            obj.ParamMap(alias{j})=p;
            obj.ParamMap([p.Component,':',alias{j}])=p;
        end
        loc_addWidgetsToMap(obj,p);

        q=obj.getParamAllFeatures(name);
        if isempty(q)
            a=p;
        elseif iscell(q)
            a=[q,{p}];
        else
            a={q,p};
        end
        obj.ParamMap(name)=a;

        q=obj.getParamAllFeatures(fullName);
        if isempty(q)
            a=p;
        elseif isempty(p.Feature)
            assert(~obj.ParamMap.isKey(fullName),...
            ['duplicate parameter: ',fullName]);
        else
            if~iscell(q)
                q={q};
            end
            for j=1:length(q)
                assert(~isequal(q{j}.Feature,p.Feature),...
                ['duplicate parameter name: ''',fullName,''' with feature ''',p.Feature.Name,'''']);
            end
            a=[q,{p}];
        end
        obj.ParamMap(fullName)=a;
    end


    for i=1:length(paramList)
        p=paramList{i};
        obj.param.(p.Name)=obj.ParamMap(p.Name);
    end

end

function loc_addWidgetsToMap(obj,param)
    if~param.Hidden
        if isempty(param.WidgetList)
            obj.WidgetNameMap(param.Name)=param.Name;
            obj.WidgetNameMap(param.FullName)=param.FullName;
        else
            for w=1:length(param.WidgetList)
                obj.WidgetNameMap(param.WidgetList{w}.Name)=param.Name;
                obj.WidgetNameMap([param.Component,':',param.WidgetList{w}.Name])=param.FullName;
            end
        end
    end
end

