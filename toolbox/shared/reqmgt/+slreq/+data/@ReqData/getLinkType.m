function mfLinkType=getLinkType(this,typeNameOrEnum)





    if isa(typeNameOrEnum,'slreq.custom.LinkType')&&isenum(typeNameOrEnum)

        typeName=typeNameOrEnum.getTypeName;
    elseif ischar(typeNameOrEnum)
        typeName=typeNameOrEnum;
    else
        assert(false,'Invalid input specified')
    end

    mfLinkType=this.repository.linkTypes{typeName};
    if isempty(mfLinkType)
        error(message('Slvnv:slreq:InvalidLinkTypeName',typeName));
    end
end
