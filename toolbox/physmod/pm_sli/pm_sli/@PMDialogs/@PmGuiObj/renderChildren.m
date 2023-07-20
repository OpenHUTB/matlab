function[retStatus,schema]=renderChildren(hThis,~)













    retStatus=true;


    items=hThis.Items;
    nItems=numel(items);
    childItems=cell(1,nItems);


    for idx=1:nItems
        newSchema=[];
        [status,newSchema]=Render(items(idx),newSchema);
        if(status)
            childItems{idx}=newSchema;
        else
            retStatus=false;
            idStr=sprintf('%s.renderChildren',class(hThis));
            error(idStr,'Failed to render schema for item(%d): ''%s''',idx,class(hThis.Items(idx)));
        end
    end
    schema=childItems;
