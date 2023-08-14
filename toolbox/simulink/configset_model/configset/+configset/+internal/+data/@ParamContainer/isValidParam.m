function out=isValidParam(obj,name)


    out=obj.ParamMap.isKey(name);
    if out
        list=obj.ParamMap(name);
        if iscell(list)
            out=false;
            for i=1:length(list)
                if list{i}.isFeatureActive
                    out=true;
                    break;
                end
            end
        else
            out=true;
        end
    end

