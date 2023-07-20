function loadCustomComponent(obj)




    comps=obj.registerComponent;
    for i=1:length(comps)
        comp=comps{i};
        componentPath=obj.registerComponent(comp);
        obj.loadComponent(comp,componentPath);
    end

