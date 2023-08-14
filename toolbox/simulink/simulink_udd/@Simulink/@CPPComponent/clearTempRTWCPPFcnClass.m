function clearTempRTWCPPFcnClass(modelName)



    if bdIsLoaded(modelName)
        fpc=get_param(modelName,'RTWCPPFcnClass');
        if(~isempty(fpc)&&fpc.isTemp)
            isDirty=get_param(modelName,'Dirty');
            cleanupObj=onCleanup(@()set_param(modelName,'Dirty',isDirty));
            set_param(modelName,'RTWCPPFcnClass',get_param(modelName,'cacheRTWCPPFcnClass'));
        end
    end

end


