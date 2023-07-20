function addComponent(obj,cp)



    if~obj.ComponentMap.isKey(cp.Name)
        obj.ComponentList{end+1}=cp;
        obj.ComponentMap(cp.Name)=cp;
        obj.ComponentMap(cp.Class)=cp;

        obj.addParams(cp.ParamList);
    end


