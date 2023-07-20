function import(obj,xmlFile,params,grt,ert)














    componentParams=obj.ParamMap.keys;

    if contains(xmlFile,'/grt.xml')&&~isempty(grt)
        cp=grt;
    elseif contains(xmlFile,'/ert.xml')&&~isempty(ert)
        cp=ert;
    else
        cp=configset.internal.data.Component;
        cp.parse(xmlFile);
    end


    types=cp.typeMap.keys;
    for k=1:length(types)
        if~obj.typeMap.isKey(types{k})
            obj.typeMap(types{k})=cp.typeMap(types{k});
        end
    end

    if isempty(params)


        paramList=cp.ParamList;
    else

        paramList=cp.ParamList(cellfun(@(p)ismember(p.Name,params),cp.ParamList));
    end


    for k=1:length(paramList)
        param=copy(paramList{k});

        if~ismember(param.Name,componentParams)



            param.FullName=regexprep(param.FullName,['^',cp.FullName,':'],...
            [obj.FullName,':'],'once');
            param.Component=obj.FullName;
            for w=1:length(param.WidgetList)
                param.WidgetList{w}.Component=obj.FullName;
                param.WidgetList{w}.Parameter=param;
            end

            obj.ParamList{end+1}=param;
            if~obj.ParamMap.isKey(param.Name)
                obj.ParamMap(param.Name)=param;
                obj.ParamMap(param.FullName)=param;
            else
                p=obj.ParamMap(param.Name);
                if iscell(p)
                    p=[p,{param}];
                else
                    p={p,param};
                end
                obj.ParamMap(param.Name)=p;
                obj.ParamMap(param.FullName)=p;
            end
        end
    end

