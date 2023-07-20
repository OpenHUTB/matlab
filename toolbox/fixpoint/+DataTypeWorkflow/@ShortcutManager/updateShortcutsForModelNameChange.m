function updateShortcutsForModelNameChange(this,mdlObj,oldName)




    shortcutNames=this.getCustomShortcutNames;
    customMap=this.getCustomShortcutMapForModel;

    if customMap.getCount>0
        for i=1:length(shortcutNames)

            if customMap.isKey(shortcutNames{i})
                settingsMap=customMap.getDataByKey(shortcutNames{i});
                if settingsMap.isKey('SystemSettingMap')
                    blksettingsMap=settingsMap.getDataByKey('SystemSettingMap');
                    mapCount=blksettingsMap.getCount;
                    keys(1:mapCount)={''};
                    for p=1:mapCount
                        keys{p}=blksettingsMap.getKeyByIndex(p);
                        dataArray(p)=blksettingsMap.getDataByIndex(p);%#ok<*AGROW>
                    end
                    for k=1:mapCount
                        key=keys{k};
                        data=dataArray(k);
                        if strcmpi(Simulink.ID.getModel(key),oldName)
                            idx=regexp(key,':','start');
                            if isempty(idx)
                                newKey=Simulink.ID.getSID(mdlObj);
                            else
                                newKey=[Simulink.ID.getSID(mdlObj),key(idx:end)];
                            end
                            blksettingsMap.insert(newKey,data);
                            blksettingsMap.deleteDataByKey(key);
                        end
                    end
                end
            end
        end
    end


