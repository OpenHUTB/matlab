function ensureRegisteredAttributes(reqSet,attributeData,docType,doProxy)




    reqData=slreq.data.ReqData.getInstance();
    attrRegistries=reqData.getCustomAttributeRegistries(reqSet);
    for i=1:length(attributeData)
        attrInfo=attributeData{i};
        if ischar(attrInfo)

            attrName=attrInfo;
            attrType='Edit';
            attrValues='';
        else

            attrName=attrInfo.name;
            attrType=attrInfo.type;
            if strcmp(attrType,'Combobox')
                attrValues=attrInfo.values;
            else

                attrValues=attrInfo.default;
            end
        end
        attrReg=attrRegistries.getByKey(attrName);
        if isempty(attrReg)

            reqData.addCustomAttributeRegistry(reqSet,attrName,attrType,...
            ['value from ',docType],attrValues,doProxy);
        else
            if~strcmp(attrReg.typeName,attrType)

                error(message('Slvnv:slreq:AttributeTypeErrorForImport',attrName));
            end



            if~attrReg.isReadOnly&&doProxy
                attrReg.isReadOnly=doProxy;
            end
        end
    end
end

