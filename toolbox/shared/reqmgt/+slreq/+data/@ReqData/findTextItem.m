function result=findTextItem(~,linkset,id)






    items=linkset.textItems.toArray;
    for i=1:length(items)
        if strcmp(items(i).id,id)
            result=items(i);
            return;
        end
    end
    result=[];
end
