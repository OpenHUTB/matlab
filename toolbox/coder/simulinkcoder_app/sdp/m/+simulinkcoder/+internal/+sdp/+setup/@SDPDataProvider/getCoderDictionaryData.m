function[data,meta]=getCoderDictionaryData(obj,id,role)


    data=mdom.Data;
    if role>0
        value=obj.dataModel.getCoderDictionary(id);
        data.setProp('label',value);
    end

    iscsref=obj.dataModel.isConfigSetRef(id);

    meta=mdom.MetaData;
    if role==1&&~iscsref
        meta.setProp('editor','DefaultEditor');
    else
        meta.setProp('enabled',false);
    end

