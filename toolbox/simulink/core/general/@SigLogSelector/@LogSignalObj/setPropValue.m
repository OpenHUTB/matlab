function setPropValue(h,prop,val)







    type=h.getPropDataType(prop);
    switch(type)
    case{'string'}
        sigPropVal=val;%#ok<NASGU>
    case{'enum'}
        assert(strcmp(prop,'NameMode'));
        trueStr=...
        DAStudio.message('Simulink:Logging:SigLogDlgNameModeTrue');
        sigPropVal=strcmpi(val,trueStr);%#ok<NASGU>
    otherwise
        sigPropVal=str2double(val);%#ok<NASGU>
    end


    try
        eval(['h.signalInfo.LoggingInfo.',prop,' = sigPropVal;']);
    catch me
        SigLogSelector.displayWarningDlg(me.identifier,me.message);
        return;
    end


    h.signalInfo.signalName_=h.signalInfo.getSignalNameFromPort(...
    false,...
    true);


    mi=h.hParent.getModelLoggingInfo;
    mi=mi.setSettingsForSignal(h.signalInfo);
    h.hParent.setModelLoggingInfo(mi);


    h.firePropertyChange;



    if strcmp(prop,'DataLogging')
        node=h.hParent.getBdOrTopMdlRefNode;
        node.firePropertyChange;
    end
end
