function handle=getAutomationFactoryHandle(reg,AdaptorName)




    handle=reg.getAdaptorInfo(AdaptorName).AutomationFactory;

end

