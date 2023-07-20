function result=getUnitTestNames(ssBD)







    inputType=get_param(ssBD,'Type');
    validType=strcmp(inputType,'block_diagram')&&bdIsSubsystem(ssBD);
    if~validType
        error(message('Simulink:SubsystemReference:InputMustBeSSBD'));
    end
    result=get_param(ssBD,'UnitTestNames');
end
