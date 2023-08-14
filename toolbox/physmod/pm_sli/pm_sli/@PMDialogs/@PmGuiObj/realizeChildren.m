function retVal=realizeChildren(hThis)









    retVal=true;
    items=hThis.Items;
    nItems=length(items);
    for idx=1:nItems
        retVal=Realize(items(idx));
        if(retVal==false)
            idStr=sprintf('%s.realizeChildren',class(hThis));
            error(idStr,'Failed to Realize item(%d): ''%s''',idx,class(hThis.Items(idx)));
        end
    end
