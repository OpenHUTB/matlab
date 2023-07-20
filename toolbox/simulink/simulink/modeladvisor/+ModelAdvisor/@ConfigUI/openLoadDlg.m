function configFileIsValid=openLoadDlg




    configFileIsValid=false;

    MAObj=Simulink.ModelAdvisor.getFocusModelAdvisorObj;
    if isempty(MAObj)
        MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    end
    mp=ModelAdvisor.Preferences;
    mp.ModelAdvisorWebUI;
    if isa(MAObj,'Simulink.ModelAdvisor')


        if~isa(MAObj.ConfigUIWindow,'DAStudio.Explorer')&&~mp.ModelAdvisorWebUI
            warnmsg=DAStudio.message('Simulink:tools:MAWarnLoadConfigUI');
            response=questdlg(warnmsg,DAStudio.message('Simulink:tools:MAWarning'),...
            DAStudio.message('Simulink:tools:MALoad'),...
            DAStudio.message('Simulink:tools:MACancel'),...
            DAStudio.message('Simulink:tools:MACancel'));
            if~strcmp(response,DAStudio.message('Simulink:tools:MALoad'))
                return;
            end
        else
            if MAObj.ConfigUIDirty
                warnmsg=DAStudio.message('Simulink:tools:MAWarnLoadConfigUIWhenDirty');
                response=questdlg(warnmsg,DAStudio.message('Simulink:tools:MAWarning'),...
                DAStudio.message('Simulink:tools:MAContinue'),...
                DAStudio.message('Simulink:tools:MACancel'),...
                DAStudio.message('Simulink:tools:MACancel'));
                if~strcmp(response,DAStudio.message('Simulink:tools:MAContinue'))
                    return;
                end
            end
        end

        [filename,pathname]=uigetfile({'*.json; *.mat','JSON-files (*.json) and MAT-files (*.mat)';},DAStudio.message('Simulink:tools:MAOpen'));
        if~isequal(filename,0)&&~isequal(pathname,0)
            configFilePath=fullfile(pathname,filename);
            [~,~,ext]=fileparts(configFilePath);
            configFileIsValid=false;



















            needGenerateConfigUIJSON=false;
            if strcmp(ext,'.mat')
                configVar=load(configFilePath);
                if isfield(configVar,'jsonString')

                    MAObj.ConfigUIJSON=configVar.jsonString;
                    MAObj.isUserLoaded=true;
                    configFileIsValid=true;
                else
                    if isfield(configVar,'configuration')&&...
                        isfield(configVar.configuration,'ConfigUIRoot')&&...
                        isfield(configVar.configuration,'ConfigUICellArray')

                        configFileIsValid=true;
                        MAObj.isUserLoaded=true;
                        needGenerateConfigUIJSON=true;
                    end
                end
            elseif strcmp(ext,'.json')
                jsonString=fileread(configFilePath);
                MAObj.ConfigUIJSON=jsonString;
                MAObj.isUserLoaded=true;
                configFileIsValid=true;
            end

            if configFileIsValid


                if~isa(MAObj.ConfigUIWindow,'DAStudio.Explorer')
                    MAObj.activateConfiguration(configFilePath);
                else
                    MAObj.loadConfiguration(configFilePath);
                end
                if needGenerateConfigUIJSON
                    MAObj.ConfigUIJSON=Advisor.Utils.exportJSON(MAObj,'MACE');
                end
            else
                warndlgHandle=errordlg(DAStudio.message('Simulink:tools:MAInvalidConfigFile',configFilePath));
                set(warndlgHandle,'Tag','MAInvalidConfigFile');
                MAObj.DialogCellArray{end+1}=warndlgHandle;
            end
        end
    end

