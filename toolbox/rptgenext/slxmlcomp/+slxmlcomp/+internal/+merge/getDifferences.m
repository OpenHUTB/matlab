function differences=getDifferences(names1,values1,names2,values2)




















    differences={};


    names=union(names1,names2);

    for i=1:length(names)
        value1=i_GetValue(names{i},names1,values1);
        value2=i_GetValue(names{i},names2,values2);

        if~isequal(value1,value2)
            if size(value1,1)==1
                differences=[differences;...
                {names{i},...
                slxmlcomp.internal.convertToString(value1),...
                slxmlcomp.internal.convertToString(value2)}];%#ok<AGROW>
            end
        end
    end

end


function value=i_GetValue(name,names,values)
    index=find(ismember(names,name),1);
    if numel(index)~=1
        value='';
    else
        value=values{index};
    end
end
