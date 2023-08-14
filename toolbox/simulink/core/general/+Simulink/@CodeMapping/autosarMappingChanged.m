function autosarMappingChanged(dlg,sourceModel,SLPortName,prop)






    mapObj=autosar.api.getSimulinkMapping(sourceModel);
    [ARPortName,ARElementName,ARDataAccessMode]=mapObj.getInport(SLPortName);

    modelMapping=autosar.api.Utils.modelMapping(sourceModel);
    SLPortName=Simulink.CodeMapping.escapeSimulinkName(SLPortName);

    modelName=get_param(sourceModel,'Name');

    SLPort=modelMapping.Inports.findobj('Block',[modelName,'/',SLPortName]);

    switch prop
    case 'DataAccessMode'
        val=dlg.getComboBoxText('cmbDataAccessMode');
        if strcmp(val,DAStudio.message('RTW:autosar:selectERstr'))
            val='';
        end
        if strcmp(val,ARDataAccessMode)
            return;
        end
        prevValueIsMode=any(strcmp(ARDataAccessMode,{'ModeSend','ModeReceive'}));
        newValueIsMode=any(strcmp(val,{'ModeSend','ModeReceive'}));
        if prevValueIsMode&&~newValueIsMode||~prevValueIsMode&&newValueIsMode
            ARPortName='';
            ARElementName='';
        end
        SLPort.mapPortElement(ARPortName,ARElementName,val);
    case 'Port'
        val=dlg.getComboBoxText('cmbPort');
        if strcmp(val,DAStudio.message('RTW:autosar:selectERstr'))
            val='';
        end
        if strcmp(val,ARPortName)
            return;
        end
        ARElementName='';
        SLPort.mapPortElement(val,ARElementName,ARDataAccessMode);
    case 'Element'
        val=dlg.getComboBoxText('cmbElement');
        if strcmp(val,DAStudio.message('RTW:autosar:selectERstr'))
            val='';
        end
        if strcmp(val,ARElementName)
            return;
        end
        SLPort.mapPortElement(ARPortName,val,ARDataAccessMode);
    end
end
