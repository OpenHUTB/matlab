function[retStat,retItems]=getPmSchemaFromChildren(hThis)











    retStat=true;

    items=hThis.Items;
    nItems=length(items);
    retItems=cell(1,nItems);

    for idx=1:nItems
        newSchema=[];
        [retStat,newSchema]=getPmSchema(items(idx),newSchema);
        if(retStat)
            retItems{idx}=newSchema;
        else
            retStat=false;
            clsSchema=classhandle(hThis);
            originStr=[clsSchema.Package.Name,'.',clsSchema.Name,'::getPmSchema'];
            pm_abort('%s - Failed to add schema object(%d): ''%s''',originStr,idx);
        end
    end
