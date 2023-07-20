function[group,index]=getWidgetGroup(obj,name,safeMode,checkFeature)




    if nargin<3
        safeMode=true;
    end
    if nargin<4
        checkFeature=true;
    end
    if~safeMode||obj.WidgetGroupMap.isKey(name)
        s=obj.WidgetGroupMap(name);
        group=s.Group;
        index=s.Index;

        if s.Feature&&checkFeature
            idx=arrayfun(@(x)(isempty(x.Feature)||x.isFeatureActive),group);
            group=group(idx);
            index=index(idx);
            if isempty(idx)
                index=0;
            end
        end
    else
        group=[];
        index=0;
    end

