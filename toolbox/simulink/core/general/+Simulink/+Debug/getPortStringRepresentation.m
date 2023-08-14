function str=getPortStringRepresentation(portHandle)




    str=DAStudio.message(...
    'Simulink:studio:ConditionalPauseBlockPort',...
    get_param(portHandle,'Parent'),...
    num2str(get_param(portHandle,'PortNumber')));
end