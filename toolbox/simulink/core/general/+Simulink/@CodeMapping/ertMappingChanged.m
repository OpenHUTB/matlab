function ertMappingChanged(dlg,mapObj,mapping)






    val=dlg.getComboBoxText('cmbCoderData');
    if~isempty(mapObj.MappedTo)&&strcmp(val,mapObj.getDecoratedStorageClass())
        return;
    end
    allowedValues=mapping.DefaultsMapping.getAllowedGroupNames('Inports','IndividualLevel');
    if strcmp(val,allowedValues{1})
        mapObj.unmap();
    else
        if strcmp(val,allowedValues{2})
            uuid='';
        else
            uuid=mapping.DefaultsMapping.getGroupUuidFromName(val);
        end
        mapObj.map(uuid);
    end
end
