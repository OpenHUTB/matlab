function config(bd,option)




    switch(option)
    case 'Convert'
        Simulink.SoftwareTarget.concurrentExecution(bd,...
        'ConvertForConcurrentExecution');
    case 'Add'
        configSet=Simulink.SoftwareTarget.concurrentExecution(bd,...
        'AddConfigurationForConcurrentExecution');
        configSet.activate;
    case 'OpenDialog'
        Simulink.SoftwareTarget.concurrentExecution(bd,'OpenDialog');
    otherwise
        DAStudio.error('Simulink:mds:InvalidArg2_config');
    end

end