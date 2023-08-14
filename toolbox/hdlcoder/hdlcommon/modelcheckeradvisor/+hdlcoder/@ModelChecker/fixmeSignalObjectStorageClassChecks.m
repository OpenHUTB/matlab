function ResultDescription=fixmeSignalObjectStorageClassChecks(mdlTaskObj)










    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runSignalObjectStorageClassChecks');

    List=ModelAdvisor.List;
    List.setType('bulleted');

    [candidateSignals]=hdlcoder.ModelChecker.getInvalidSignalObjectStorageClass(checker.m_DUT);


    for ii=1:numel(candidateSignals)
        sigH=candidateSignals(ii);
        if slfeature('AutoMigrationIM')>0
            modelMapping=Simulink.CodeMapping.getCurrentMapping(bdroot);
            if~isempty(modelMapping)
                signalMapping=modelMapping.Signals.findobj('PortHandle',sigH);
                if~isempty(signalMapping)
                    signalMapping.unmap;
                end
            end
        else
            set_param(sigH,'StorageClass','Auto');
        end
        if ishandle(sigH)
            path=get_param(sigH,'Parent');
            addtoList(path);
        end
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:signal_storage_class_error')),List];

    function addtoList(path)
        txtObjAndLink=ModelAdvisor.Text(path);
        as_numeric_string=['char([',num2str(path+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
end
