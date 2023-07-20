




function[needsUpdate,allowedValues]=getAllowedValuesForDataElement(ss,portTag,portValue)
    allowedValues={'Select ...'};
    if strcmp(portTag,'Port')
        needsUpdate=true;
        titleView=ss.getTitleView();
        if~isa(titleView,'DAStudio.Dialog')
            return;
        end
        dataViewObj=titleView.getDialogSource;
        modelName=dataViewObj.m_Source.getFullName;
        if~strcmp(portValue,'Select ...')
            dataElements=autosar.mm.Model.findContaineeElementsByPortName(modelName,portValue);
            allowedValues=cat(2,allowedValues,dataElements);
        end
    else
        needsUpdate=false;
    end
end
