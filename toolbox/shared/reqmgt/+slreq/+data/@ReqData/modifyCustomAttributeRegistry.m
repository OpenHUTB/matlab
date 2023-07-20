function modifyCustomAttributeRegistry(this,dataSet,prevName,name,typeName,description,defaultValOrEnumList)







    mfSet=this.getModelObj(dataSet);
    [tf,invalidChars]=slreq.internal.isValidCustomAttributeName(name);
    if~tf
        invalidListStr=strrep(strjoin(invalidChars),' ','');
        error(message('Slvnv:slreq:AttributeNameIsInvalid',invalidListStr));
    end

    allRegistries=mfSet.attributeRegistry;
    thisAttrReg=allRegistries.getByKey(prevName);

    if isempty(thisAttrReg)
        error(message('Slvnv:slreq:AttributeNoSuchAttribute',prevName))
    end


    if slreq.custom.AttributeHandler.isReservedName(name)

        error(message('Slvnv:slreq:AttributeNameIsReserved',name))
    end

    if typeName==slreq.datamodel.AttributeRegType.Checkbox...
        &&~isempty(defaultValOrEnumList)...
        &&isa(thisAttrReg,'slreq.datamodel.BoolAttrReg')...
        &&~isequal(thisAttrReg.default,defaultValOrEnumList)
        error(message('Slvnv:slreq:AttributeDefaultValCannotBeModified'))
    end

    if thisAttrReg.isReadOnly&&~strcmp(name,prevName)
        error(message('Slvnv:slreq:AttributeReadOnlyCannotBeModified'))
    end

    if~strcmp(prevName,name)
        thisAttrReg.name=name;


        attributeItems=thisAttrReg.items.toArray;
        for n=1:length(attributeItems)
            attributeItems(n).name=name;
        end
    end

    if~strcmp(thisAttrReg.description,description)
        thisAttrReg.description=description;
    end

    if typeName==slreq.datamodel.AttributeRegType.Combobox&&~isempty(defaultValOrEnumList)
        applyComboboxListChange(thisAttrReg,defaultValOrEnumList);
    end

    if~mfSet.dirty

        dataSet.setDirty(true);
    end


    modInfo.prevName=prevName;
    modInfo.newName=name;
    if isa(dataSet,'slreq.data.Requirement')
        this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('CustomAttributeModified',modInfo));
    else
        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('CustomAttributeModified',modInfo));
    end

    function applyComboboxListChange(thisAttrReg,enumList)



        prevEnums=thisAttrReg.entries.toArray;
        if isempty(enumList)||~strcmp(enumList{1},'Unset')
            error(message('Slvnv:slreq:AttributeComboboxName1stElementMustBeUnset'));
        end

        if~isequal(prevEnums,enumList)



            thisAttrReg.entries.clear();

            for j=1:length(enumList)

                thisAttrReg.entries.add(enumList{j});
            end

            if slreq.custom.AttributeHandler.hasOnlyNameChange(prevEnums,enumList)


                return;
            end

            attrItems=thisAttrReg.items.toArray;
            if~isempty(attrItems)
                origEnumIdx=[];
                newEnumIdx=[];





                removed=setdiff(prevEnums,enumList);
                if~isempty(removed)



                    for j=1:length(removed)
                        origEnumIdx(j)=find(strcmp(removed{j},prevEnums));%#ok<AGROW>

                        newEnumIdx(j)=1;%#ok<AGROW>
                    end
                end

                unionEntries=union(prevEnums,enumList);
                if~isempty(unionEntries)
                    for j=1:length(unionEntries)



                        prevIndex=find(strcmp(unionEntries{j},prevEnums));
                        newIndex=find(strcmp(unionEntries{j},enumList));
                        if prevIndex~=newIndex
                            origEnumIdx(end+1)=prevIndex;%#ok<AGROW>
                            newEnumIdx(end+1)=newIndex;%#ok<AGROW>
                        end
                    end
                end

                if~isempty(origEnumIdx)
                    for j=1:length(attrItems)
                        thisMapIdx=find(attrItems(j).index==origEnumIdx);
                        if~isempty(thisMapIdx)

                            attrItems(j).index=newEnumIdx(thisMapIdx);
                        end
                    end
                end
            end
        end
    end
end
