function sendParams(obj,params)


    errorMap=obj.Source.errorMap;
    n=length(params);
    dataList=cell(n,1);
    for i=1:n
        name=params{i};
        data=obj.getData(name);


        if errorMap.isKey(name)
            err=errorMap(name);
            if~isa(err.data,'configset.internal.data.WidgetStaticData')
                data.error=err.error;
            end
        end

        if isfield(data,'widgets')
            for j=1:length(data.widgets)
                wName=data.widgets{j}.name;
                if errorMap.isKey(wName)
                    err=errorMap(wName);
                    if isa(err.data,'configset.internal.data.WidgetStaticData')
                        data.widgets{j}.error=err.error;
                    end
                end
            end
        end


        dataList{i}=data;
    end

    obj.publish('updateSearch',dataList);
