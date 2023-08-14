function oldValue=setMATLABDriveExplorerIntegrationSetting(setting,newValue,persistSetting)










    narginchk(1,3);
    s=getOrCreateSettingNode(setting);
    try
        oldValue=s.ActiveValue;
    catch


        oldValue=[];
    end

    if nargin>1
        if nargin==2
            persistSetting=false;
        end

        if persistSetting
            s.PersonalValue=newValue;
        else
            s.TemporaryValue=newValue;
        end
    end
end

function s=getOrCreateSettingNode(setting)
    S=settings;
    if~hasGroup(S,'mldrivedesktop')
        g=addGroup(S,'mldrivedesktop');
    else
        g=S.mldrivedesktop;
    end
    if~hasSetting(g,setting)
        s=addSetting(g,setting);
    else
        s=g.(setting);
    end
end
