function index=searchInListPropByField(obj,nameOfListProp,nameOfField,valueToSearch)







    index=[];
    elements=obj.(nameOfListProp);
    if~isempty(elements)
        index=find(strcmp(string({elements(:).(nameOfField)}),valueToSearch));

        if~isempty(index)
            index=index(1);
        end
    end
end
