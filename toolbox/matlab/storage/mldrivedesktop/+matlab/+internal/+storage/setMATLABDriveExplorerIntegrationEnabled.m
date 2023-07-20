function oldValue=setMATLABDriveExplorerIntegrationEnabled(newValue,persistSetting)













    setting='ExplorerIntegrationEnabled';
    persistenceLevel='user';

    oldValue=matlab.internal.storage.setMATLABDriveExplorerIntegrationSetting(setting,false,persistenceLevel);
    if isempty(oldValue)
        oldValue=false;
    end

    if nargin>0
        if nargin==1
            persistSetting=false;
        end
        if~persistSetting
            persistenceLevel='session';
        end
        matlab.internal.storage.setMATLABDriveExplorerIntegrationSetting(setting,newValue,persistenceLevel);
    end
end
