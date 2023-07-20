function out=isequal(obj,other)
    out=true;
    propNames=obj.getAllPropNames;
    propNamesOther=other.getAllPropNames;

    if(length(propNames)~=length(propNamesOther))
        out=false;
        return
    end
    for i=1:length(propNames)

        if~strcmp(propNames{i},propNamesOther{i})
            out=false;
            return
        end

        if~isequal(obj.(propNames{i}),other.(propNames{i}))
            out=false;
            return
        end
    end
end
