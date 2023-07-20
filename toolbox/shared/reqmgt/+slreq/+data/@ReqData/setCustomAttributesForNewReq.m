function setCustomAttributesForNewReq(this,mfReq,mfReqSet,reqInfo)



    assert(isempty(mfReq.tag),'mfReq should not have dataObject yet');
    assert(isempty(mfReq.requirementSet),'mfReq should not be associated with ReqSet');







    fieldNames=fieldnames(reqInfo);
    registry=mfReqSet.attributeRegistry;

    illegalNames={};
    specifiedCustomAttrNames={};
    for n=1:length(fieldNames)
        fldName=fieldNames{n};
        if~this.builtinReqInfoNameMap.isKey(fldName)
            if~isempty(registry.getByKey(fldName))
                specifiedCustomAttrNames{end+1}=fldName;%#ok<AGROW>
            else
                illegalNames{end+1}=fldName;%#ok<AGROW>
            end
        end
    end

    if~isempty(illegalNames)


        mfReq.destroy;
        ex=MException(message('Slvnv:slreq:Failed'));
        for n=1:length(illegalNames)
            ch=MException(message('Slvnv:slreq:AttributeNoSuchAttribute',illegalNames{n}));
            ex=ex.addCause(ch);
        end
        throwAsCaller(ex);
    end


    try

        for n=1:length(specifiedCustomAttrNames)
            attrName=specifiedCustomAttrNames{n};
            this.setCustomAttribute(mfReq,mfReqSet,attrName,reqInfo.(attrName));
        end
    catch ex



        mfReq.destroy;
        throwAsCaller(ex);
    end
end
