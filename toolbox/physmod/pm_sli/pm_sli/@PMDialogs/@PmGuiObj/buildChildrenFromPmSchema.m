function retStatus=buildChildrenFromPmSchema(hThis,pmSchema)













    retStatus=true;

    if(isfield(pmSchema,'Items')==0)
        error('pMDialogs:PmGuiObj:BuildFromSchema:InvalidSchema','Schema structure is missing Items field.');
        retVal=false;
    end

    if(isempty(pmSchema.Items))
        return;
    end

    itemLst=pmSchema.Items;
    nItems=length(itemLst);
    newItems=repmat(PMDialogs.PmGuiObj,nItems,1);
    for idx=1:nItems

        if isstruct(itemLst)
            objSchema=itemLst;
        else
            objSchema=itemLst{idx};
        end


        fullClsName=objSchema.ClassName;
        [pkgName,restOfStr]=strtok(fullClsName,'.');
        [clsName]=strtok(restOfStr,'.');


        hPkg=findpackage(pkgName);


        hClass=findclass(hPkg,clsName);
        if(isempty(hClass))
            error('pMDialogs:PmGuiObj:BuildFromSchema:BadClassName','Unrecognized class name ''%s''',fullClsName);
        end





        newItem=createInstance(hThis,fullClsName);



        retStatus=buildFromPmSchema(newItem,objSchema);


        newItems(idx)=newItem;
    end
    hThis.Items=newItems;
