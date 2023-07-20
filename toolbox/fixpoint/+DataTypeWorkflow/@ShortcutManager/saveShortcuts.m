function saveShortcuts(this)






















    bd=this.ModelObject;
    shortcutNames=this.getCustomShortcutNames;



    originalSettingsShortcut=fxptui.message('lblOriginalSettings');
    shortcutIdx=strcmp(shortcutNames,originalSettingsShortcut);
    shortcutNames(shortcutIdx)=[];

    customMap=this.getCustomShortcutMapForModel;



    buttonConfig=this.getShortcutOptions;
    defaultConfig=this.DefaultShortcutOptions;

    needToSaveBtnConfig=~isequal(buttonConfig,defaultConfig);
    needToSaveCustomShortcuts=customMap.getCount>0;

    if~needToSaveBtnConfig&&~needToSaveCustomShortcuts
        bd.FPTShortcutValueString='';
        return;
    end

    if needToSaveBtnConfig
        btnStr=sprintf('%s','{');
        for i=1:length(buttonConfig)
            switch buttonConfig{i}
            case fxptui.message('lblDblOverride')
                bName=fxptui.message('lblDblOverrideUntranslated');
            case fxptui.message('lblFxptOverride')
                bName=fxptui.message('lblFxptOverrideUntranslated');
            case fxptui.message('lblSglOverride')
                bName=fxptui.message('lblSglOverrideUntranslated');
            case fxptui.message('lblMMOOff')
                bName=fxptui.message('lblMMOOffUntranslated');
            case fxptui.message('lblDTOMMOOff')
                bName=fxptui.message('lblDTOMMOOffUntranslated');
            otherwise
                bName=buttonConfig{i};
            end
            btnStr=sprintf('%s''''%s''''%s',btnStr,bName,',');
        end
        if strcmp(btnStr(end),',')
            btnStr=btnStr(1:end-1);
        end
        btnStr=sprintf('%s%s',btnStr,'}');
    else
        btnStr=sprintf('%s%s%s','{','}');
    end

    valueString=sprintf('%s',btnStr);

    if needToSaveCustomShortcuts
        for i=1:length(shortcutNames)
            tempStr='';
            if customMap.isKey(shortcutNames{i})

                switch shortcutNames{i}
                case fxptui.message('lblDblOverride')
                    sName=fxptui.message('lblDblOverrideUntranslated');
                case fxptui.message('lblFxptOverride')
                    sName=fxptui.message('lblFxptOverrideUntranslated');
                case fxptui.message('lblSglOverride')
                    sName=fxptui.message('lblSglOverrideUntranslated');
                case fxptui.message('lblMMOOff')
                    sName=fxptui.message('lblMMOOffUntranslated');
                case fxptui.message('lblDTOMMOOff')
                    sName=fxptui.message('lblDTOMMOOffUntranslated');
                otherwise
                    sName=shortcutNames{i};
                end

                tempStr=sprintf('%s%s''''%s''''%s',tempStr,'{',sName,',');

                settingsMap=customMap.getDataByKey(shortcutNames{i});





                if settingsMap.isKey('GlobalModelSettings')
                    globalMap=settingsMap.getDataByKey('GlobalModelSettings');
                    for p={'CaptureInstrumentation','CaptureDTO','ModifyDefaultRun','RunName'}
                        param=p{:};
                        switch lower(param)
                        case 'runname'
                            if globalMap.isKey(param)

                                switch globalMap.getDataByKey(param)
                                case fxptui.message('lblDblOverrideRunName')
                                    rName=fxptui.message('lblDblOverrideRunNameUntranslated');
                                case fxptui.message('lblSglOverrideRunName')
                                    rName=fxptui.message('lblSglOverrideRunNameUntranslated');
                                case fxptui.message('lblFxptOverrideRunName')
                                    rName=fxptui.message('lblFxptOverrideRunNameUntranslated');
                                case fxptui.message('lblMMOOffRunName')
                                    rName=fxptui.message('lblMMOOffRunNameUntranslated');
                                otherwise
                                    rName=globalMap.getDataByKey(param);
                                end
                                tempStr=sprintf('%s''''%s''''%s',tempStr,rName,',');
                            else
                                tempStr=sprintf('%s''''%s''''%s',tempStr,'',',');
                            end
                        otherwise
                            if globalMap.isKey(param)
                                tempStr=sprintf('%s%s%s',tempStr,num2str(globalMap.getDataByKey(param)),',');
                            else
                                tempStr=sprintf('%s''''%s''''%s',tempStr,'',',');
                            end
                        end
                    end
                end
                if settingsMap.isKey('SystemSettingMap')
                    blksettingsMap=settingsMap.getDataByKey('SystemSettingMap');
                    for k=1:blksettingsMap.getCount
                        map=blksettingsMap.getDataByIndex(k);

                        if map.getCount>0
                            hasValidBlock=false;
                            if map.isKey('SID')
                                blkSID=map.getDataByKey('SID');
                                hasValidBlock=true;
                            end
                            if~hasValidBlock
                                map.Clear;
                            else
                                if~isempty(blkSID)





                                    indx=regexp(blkSID,':','start');
                                    if~isempty(indx)
                                        blkSID=blkSID(indx:end);
                                    else
                                        blkSID='';
                                    end
                                    tempStr=sprintf('%s''''%s''''%s',tempStr,blkSID,',');
                                    if map.isKey('TopModelTracePath')
                                        tempStr=sprintf('%s%s',tempStr,'{');
                                        tracePath=map.getDataByKey('TopModelTracePath');
                                        for indx=length(tracePath):-1:1
                                            sid=tracePath{indx};

                                            idx=regexp(sid,':','start');
                                            sid=sid(idx:end);
                                            tempStr=sprintf('%s''''%s''''%s',tempStr,sid,',');
                                        end

                                        if strcmpi(tempStr(end),',')
                                            tempStr=tempStr(1:end-1);
                                        end
                                        tempStr=sprintf('%s%s%s',tempStr,'}',',');
                                    else
                                        tempStr=sprintf('%s%s%s%s',tempStr,'{','}',',');
                                    end
                                    for m={'MinMaxOverflowLogging','DataTypeOverride','DataTypeOverrideAppliesTo'}
                                        param=m{:};
                                        if map.isKey(param)
                                            switch param
                                            case 'MinMaxOverflowLogging'
                                                val=map.getDataByKey(param);
                                                switch val
                                                case 'MinMaxAndOverflow'
                                                    str='M';
                                                case 'OverflowOnly'
                                                    str='O';
                                                case 'ForceOff'
                                                    str='F';
                                                otherwise
                                                    str='';
                                                end
                                                tempStr=sprintf('%s''''%s''''%s',tempStr,str,',');
                                            case 'DataTypeOverride'
                                                val=map.getDataByKey(param);
                                                switch val
                                                case{'TrueDoubles','Double'}
                                                    str='D';
                                                case{'TrueSingles','Single'}
                                                    str='S';
                                                case{'ScaledDoubles','ScaledDouble'}
                                                    str='SD';
                                                case{'ForceOff','Off'}
                                                    str='F';
                                                otherwise
                                                    str='';
                                                end
                                                tempStr=sprintf('%s''''%s''''%s',tempStr,str,',');
                                            case 'DataTypeOverrideAppliesTo'
                                                val=map.getDataByKey(param);
                                                switch val
                                                case 'Floating-point'
                                                    str='flt';
                                                case 'Fixed-point'
                                                    str='fix';
                                                otherwise
                                                    str='';
                                                end
                                                tempStr=sprintf('%s''''%s''''%s',tempStr,str,',');
                                            end
                                        else
                                            tempStr=sprintf('%s''''%s''''%s',tempStr,'',',');
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if~isempty(tempStr)
                tempStr=tempStr(1:end-1);
                tempStr=sprintf('%s%s',tempStr,'}');
            end
            if~isempty(valueString)
                valueString=sprintf('%s%s%s',valueString,',',tempStr);
            end
        end
    end

    valueString=sprintf('''%s%s%s''','{',valueString,'}');
    bd.FPTShortcutValueString=valueString;
end

