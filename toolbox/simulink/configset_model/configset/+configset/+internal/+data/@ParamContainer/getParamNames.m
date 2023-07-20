function out=getParamNames(obj)



    n=length(obj.ParamList);
    out=cell(n,1);
    j=1;
    for i=1:n
        if obj.ParamList{i}.isFeatureActive
            out{j}=obj.ParamList{i}.Name;
            j=j+1;
        end
    end

    out=out(1:j-1);