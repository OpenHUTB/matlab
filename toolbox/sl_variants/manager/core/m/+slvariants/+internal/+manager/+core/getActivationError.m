function err=getActivationError(excep)







    err=struct('Message',Simulink.variant.utils.i_convertMExceptionHierarchyToMessage(excep),...
    'MessageID',excep.identifier);
end
