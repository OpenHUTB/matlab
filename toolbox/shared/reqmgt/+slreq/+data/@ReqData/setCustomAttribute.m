function setCustomAttribute(this,reqLink,reqLinkSet,name,value)







    if isa(reqLink,'slreq.datamodel.RequirementItem')
        isStereotype=slreq.internal.ProfileReqType.isProfileStereotype(reqLinkSet,name);

        if isStereotype
            this.setStereotypeAttribute(reqLink,name,value);
            return;
        end
    end

    attrRegistries=reqLinkSet.attributeRegistry;

    attributeItems=reqLink.attributeItems;
    custAttrItem=attributeItems.getByKey(name);
    thisAttrReg=attrRegistries.getByKey(name);
    if isempty(custAttrItem)


        if~isempty(thisAttrReg)
            switch class(thisAttrReg)
            case 'slreq.datamodel.StrAttrReg'
                custAttrItem=slreq.datamodel.StrAttrItem(this.model);
            case 'slreq.datamodel.BoolAttrReg'
                custAttrItem=slreq.datamodel.BoolAttrItem(this.model);
            case 'slreq.datamodel.IntAttrReg'
                custAttrItem=slreq.datamodel.IntAttrItem(this.model);




            case 'slreq.datamodel.EnumAttrReg'
                custAttrItem=slreq.datamodel.EnumAttrItem(this.model);



            case 'slreq.datamodel.DateTimeAttrReg'
                custAttrItem=slreq.datamodel.DateTimeAttrItem(this.model);
            end


            custAttrItem.name=name;
            custAttrItem.registry=thisAttrReg;
            attributeItems.add(custAttrItem);
        end
    end

    switch class(thisAttrReg)
    case 'slreq.datamodel.StrAttrReg'
        custAttrItem.value=value;
    case 'slreq.datamodel.IntAttrReg'
        custAttrItem.value=value;
    case 'slreq.datamodel.BoolAttrReg'
        custAttrItem.value=value;




    case 'slreq.datamodel.EnumAttrReg'

        enumList=thisAttrReg.entries.toArray;
        custAttrItem.index=int32(find(strcmp(value,enumList)));








    case 'slreq.datamodel.DateTimeAttrReg'


        custAttrItem.value=slreq.utils.getDateTime(value,'Write');
    end

    reqLinkObj=reqLink.tag;
    if isempty(reqLinkObj)


        return;
    end



    if isa(reqLinkObj,'slreq.data.Link')||isa(reqLinkObj,'slreq.data.LinkSet')
        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Set Prop Update',reqLinkObj));
    elseif isa(reqLinkObj,'slreq.data.Requirement')||isa(reqLinkObj,'slreq.data.RequirementSet')
        this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Set Prop Update',reqLinkObj));
    end
end
