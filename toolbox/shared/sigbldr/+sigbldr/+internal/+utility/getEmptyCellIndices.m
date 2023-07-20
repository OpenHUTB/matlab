function[anyEmpty,indices]=getEmptyCellIndices(newcell)



    anyEmpty=false;
    n=length(newcell);
    v=zeros(n,1);
    for i=1:n
        if isnan(newcell{i})
            v(i)=1;
        elseif isempty(newcell{i})
            v(i)=1;
        elseif all(isspace(newcell{i}))
            v(i)=1;
        end
    end

    if any(v)
        anyEmpty=true;
    end
    indices=find(v==1);
end

