function success=setTemporaryAccessibleRoots(varargin)




    success=true;
    if~iscellstr(varargin)
        connector.internal.Logger.doWarning('accessible_roots_m',...
        'Expected cell string array input');
        success=false;
    else
        s=settings;
        displayedRoots=s.matlab.desktop.displayedroots;


        for rootGroupName=string(properties(displayedRoots)')
            try
                if hasGroup(displayedRoots,rootGroupName)
                    rootGroup=displayedRoots.(rootGroupName);
                    if rootGroup.hasSetting('IsTemporaryAccessibleRoot')&&...
                        rootGroup.IsTemporaryAccessibleRoot.ActiveValue
                        displayedRoots.removeGroup(rootGroupName);
                    end
                end
            catch err
                connector.internal.Logger.doWarning('accesible_roots_m',...
                'Error purging previous temporary accessible roots',...
                rootGroupName,err.message);
            end
        end

        for folder=varargin



            rootSettingNameIncrement=1;
            rootSettingName=sprintf("TemporaryRoot%d",int64(rootSettingNameIncrement));
            while displayedRoots.hasGroup(rootSettingName)
                rootSettingNameIncrement=rootSettingNameIncrement+1;
                rootSettingName=sprintf("TemporaryRoot%d",int64(rootSettingNameIncrement));
            end

            newDisplayedRoot=displayedRoots.addGroup(rootSettingName);
            newDisplayedRoot.addSetting('Path');
            newDisplayedRoot.Path.TemporaryValue=char(folder);
            newDisplayedRoot.addSetting('IsEnabled');
            newDisplayedRoot.IsEnabled.TemporaryValue=true;
            newDisplayedRoot.addSetting('IsTemporaryAccessibleRoot',PersonalValue=true);






            httpPathSanitizedString=replace(folder,[" ","/","\","|",":",";",'#','%','+','{}','()','~','&','^','.','_'],'-');



            connector.addStaticContentOnPath(char(strcat(httpPathSanitizedString,datestr(datetime('now'),'dd-mmm-yyyy-HH-MM-SS-FFF'))),char(folder));
        end
    end
end
