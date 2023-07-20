function w=getWidgetData(obj,name)



    w=[];
    param=obj.widgetToParam(name);
    if~isempty(param)
        wList=obj.getWidgetDataList(param);
        for i=1:length(wList)
            if strcmp(wList{i}.Name,name)
                w=wList{i};
                return;
            end
        end
    end


