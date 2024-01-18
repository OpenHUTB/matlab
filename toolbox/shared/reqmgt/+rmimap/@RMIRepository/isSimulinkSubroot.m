function yesno=isSimulinkSubroot(ndData)
    sourceType=ndData.getValue('source');
    if strcmp(sourceType,'linktype_rmi_matlab')
        yesno=true;
    elseif strcmp(sourceType,'linktype_rmi_simulink')
        yesno=(ndData.names.size>1);
    else
        yesno=false;
    end
end
