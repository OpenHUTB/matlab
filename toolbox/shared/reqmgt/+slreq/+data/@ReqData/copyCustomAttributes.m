function copyCustomAttributes(this,src,dst,actionType)







    srcAttrs=src.attributeItems.toArray();
    dstRegistry=dst.requirementSet.attributeRegistry;

    for n=1:length(srcAttrs)
        srcAttr=srcAttrs(n);
        thisAttrReg=dstRegistry.getByKey(srcAttr.name);
        if isempty(thisAttrReg)
            if strcmp(actionType,'paste')



                continue;
            else



                switch class(srcAttr)
                case 'slreq.datamodel.StrAttrItem'
                    thisAttrReg=slreq.datamodel.StrAttrReg(this.model);
                case 'slreq.datamodel.BoolAttrItem'
                    thisAttrReg=slreq.datamodel.BoolAttrReg(this.model);
                    thisAttrReg.default=srcAttr.registry.default;
                case 'slreq.datamodel.IntAttrItem'
                    thisAttrReg=slreq.datamodel.IntAttrReg(this.model);
                    thisAttrReg.default=srcAttr.registry.default;
                case 'slreq.datamodel.EnumAttrItem'
                    thisAttrReg=slreq.datamodel.EnumAttrReg(this.model);
                    entries=srcAttr.registry.entries;
                    for i=1:entries.Size
                        entry=entries.at(i);
                        thisAttrReg.entries.add(entry);
                    end
                case 'slreq.datamodel.DateTimeAttrItem'
                    thisAttrReg=slreq.datamodel.DateTimeAttrReg(this.model);
                end
                thisAttrReg.name=srcAttr.name;
                thisAttrReg.typeName=srcAttr.registry.typeName;
                dst.requirementSet.attributeRegistry.add(thisAttrReg);
            end
        end

        thisAttrItem=[];



        tNotPasteOp=~strcmp(actionType,'paste');
        switch class(srcAttr)
        case 'slreq.datamodel.StrAttrItem'
            tCopyOver=tNotPasteOp||...
            thisAttrReg.typeName==slreq.datamodel.AttributeRegType.Edit;
            if tCopyOver
                thisAttrItem=slreq.datamodel.StrAttrItem(this.model);
                thisAttrItem.value=srcAttr.value;
            end
        case 'slreq.datamodel.BoolAttrItem'
            tCopyOver=tNotPasteOp||...
            thisAttrReg.typeName==slreq.datamodel.AttributeRegType.Checkbox;
            if tCopyOver
                thisAttrItem=slreq.datamodel.BoolAttrItem(this.model);
                thisAttrItem.value=srcAttr.value;
            end
        case 'slreq.datamodel.IntAttrItem'

            tCopyOver=tNotPasteOp||...
            thisAttrReg.typeName==slreq.datamodel.AttributeRegType.Edit;
            if tCopyOver
                thisAttrItem=slreq.datamodel.IntAttrItem(this.model);
                thisAttrItem.value=srcAttr.value;
            end




        case 'slreq.datamodel.EnumAttrItem'
            if thisAttrReg.typeName==slreq.datamodel.AttributeRegType.Combobox

                tSameEnumDef=srcAttr.registry.entries.Size==thisAttrReg.entries.Size&&...
                all(strcmp(srcAttr.registry.entries.toArray,thisAttrReg.entries.toArray));
            else
                tSameEnumDef=false;
            end
            tCopyOver=tNotPasteOp||tSameEnumDef;
            if tCopyOver
                thisAttrItem=slreq.datamodel.EnumAttrItem(this.model);
                thisAttrItem.index=srcAttr.index;
            end







        case 'slreq.datamodel.DateTimeAttrItem'
            tCopyOver=tNotPasteOp||...
            thisAttrReg.typeName==slreq.datamodel.AttributeRegType.DateTime;
            if tCopyOver
                thisAttrItem=slreq.datamodel.DateTimeAttrItem(this.model);
                thisAttrItem.value=srcAttr.value;
            end
        end
        if~isempty(thisAttrItem)
            thisAttrItem.name=srcAttr.name;
            thisAttrItem.registry=thisAttrReg;
            dst.attributeItems.add(thisAttrItem);
        end
    end
end
