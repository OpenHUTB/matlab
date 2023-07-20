function retVal=refreshChildren(hThis)










    retVal=true;
    items=hThis.Items;
    nItems=length(items);
    for idx=1:nItems
        retVal=Refresh(items(idx));
        if(retVal==false)
            idStr=sprintf('%s.refreshChildren',class(hThis));
            error(idStr,'Failed to Refresh item(%d): ''%s''',idx,class(hThis.Items(idx)));
        end
    end
