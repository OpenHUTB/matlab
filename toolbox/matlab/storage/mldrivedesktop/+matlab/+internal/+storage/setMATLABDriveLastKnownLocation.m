function oldValue=setMATLABDriveLastKnownLocation(newValue,persistSetting)



    setting='LastKnownMLDriveLocation';
    persistenceLevel='user';
    defaultValue=' ';

    oldValue=matlab.internal.storage.setMATLABDriveExplorerIntegrationSetting(setting,defaultValue,persistenceLevel);
    if isempty(oldValue)
        oldValue=defaultValue;
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
