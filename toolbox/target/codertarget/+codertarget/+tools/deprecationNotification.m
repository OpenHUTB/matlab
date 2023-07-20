function deprecationNotification(modelName)





    h=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
    if ismethod(h,'getDeprecationInfo')
        cs=getActiveConfigSet(modelName);
        adaptorName='AdaptorName';

        if cs.isValidParam(adaptorName)
            depInfoObj=h.getDeprecationInfo(get_param(cs,adaptorName));
            if~isempty(depInfoObj)
                UpgradeAdvisor.AlertManager.createAlert(modelName,'codertarget:setup:deprecatedRealtimeTarget',...
                DAStudio.message('codertarget:setup:UARealtime2CoderTarget_modelNotCompliant'));
            end
        end
    end
end
