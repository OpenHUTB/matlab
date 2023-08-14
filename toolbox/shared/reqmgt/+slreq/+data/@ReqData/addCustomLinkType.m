function mfLinkType=addCustomLinkType(this,typeName,superTypeNameOrEnum,forwardName,backwardName,description)




    if~isvarname(typeName)
        error(message('Slvnv:slreq:InvalidTypeNameSpecified',typeName));
    end

    if isenum(superTypeNameOrEnum)&&isa(superTypeNameOrEnum,'slreq.custom.LinkType')

        superTypeNameOrEnum=char(superTypeNameOrEnum);
    end

    mfSuperType=this.repository.linkTypes{superTypeNameOrEnum};
    if isempty(mfSuperType)
        error(message('Slvnv:slreq:InvalidSuperTypeNameNotFound',superTypeNameOrEnum));
    elseif slreq.app.LinkTypeManager.isUnresolved(mfSuperType)
        error(message('Slvnv:slreq:InvalidSuperTypeUnresolved',superTypeNameOrEnum))
    end

    allExistingTypes=this.repository.linkTypes.toArray;
    for n=1:length(allExistingTypes)

        thisType=allExistingTypes(n);
        if strcmp(thisType.forwardName,forwardName)
            error(message('Slvnv:slreq:InvalidTypeNameConflict','forwardName',forwardName));
        elseif strcmp(thisType.backwardName,backwardName)
            error(message('Slvnv:slreq:InvalidTypeNameConflict','backwardName',backwardName));
        end
    end

    existingLinkType=this.repository.linkTypes{typeName};
    if~isempty(existingLinkType)
        if slreq.app.LinkTypeManager.isUnresolved(existingLinkType)



            mfLinkType=existingLinkType;
        else
            error(message('Slvnv:slreq:SpecifiedTypeExists',typeName));
        end
    else
        mfLinkType=slreq.datamodel.LinkType(this.model);
        mfLinkType.typeName=typeName;
        this.repository.linkTypes.add(mfLinkType);
    end

    mfLinkType.isBuiltin=false;
    mfLinkType.forwardName=forwardName;
    mfLinkType.backwardName=backwardName;

    mfLinkType.description=description;


    mfLinkType.superType=mfSuperType;
end