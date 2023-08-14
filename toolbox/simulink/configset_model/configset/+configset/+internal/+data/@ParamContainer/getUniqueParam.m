function out=getUniqueParam(obj,uName)



    nameSep=strfind(uName,':');
    if length(nameSep)==1
        out=obj.getParamAllFeatures(uName);
    else
        name=uName(1:nameSep(2)-1);
        feature.Name=uName(nameSep(2)+1:nameSep(3)-1);
        feature.Value=str2double(uName(nameSep(3)+1:end));
        if isnan(feature.Value)
            feature.Value=true;
        end
        out=[];
        if~obj.ParamMap.isKey(name)
            error(['Parameter ''',name,''' is not defined']);
        end
        list=obj.ParamMap(name);
        if iscell(list)

            for i=1:length(list)
                if isequal(list{i}.Feature,feature)
                    out=list{i};
                    break;
                end
            end
            if isempty(out)
                error(['Parameter ''',uName,''' is not defined']);
            end
        end
    end



