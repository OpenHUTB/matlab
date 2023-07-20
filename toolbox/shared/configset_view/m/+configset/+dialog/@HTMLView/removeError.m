function removeError(obj,param,widget)








    adp=obj.Source;
    if isempty(param)
        names={widget};
    else
        names={param};
        mcs=configset.internal.getConfigSetStaticData;
        data=adp.getParamData(param,mcs,adp.Source);
        if~isempty(data)
            if~isempty(data.WidgetList)
                for i=1:length(data.WidgetList)
                    w=data.WidgetList{i};
                    names{i}=w.Name;
                end
            end
        end
    end


    for i=1:length(names)
        name=names{i};
        if obj.errorMap.isKey(name)
            error=obj.errorMap(name);
            obj.updateError(error,false);
            obj.errorMap.remove(name);
        end
    end
