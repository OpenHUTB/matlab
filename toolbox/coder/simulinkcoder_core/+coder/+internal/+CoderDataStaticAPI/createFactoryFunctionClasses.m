function createFactoryFunctionClasses(sourceDD)












    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    sourceDD=hlp.openDD(sourceDD);


    fcEntry=hlp.createEntry(sourceDD,'FunctionClass','ModelFunction');
    hlp.setProp(fcEntry,'FunctionName','$R$N');
    hlp.setProp(fcEntry,'Description','Entry point function owned by model');

    fcEntry=hlp.createEntry(sourceDD,'FunctionClass','UtilityFunction');
    hlp.setProp(fcEntry,'FunctionName','$N$C');
    hlp.setProp(fcEntry,'Description','Shared utility function');

end
