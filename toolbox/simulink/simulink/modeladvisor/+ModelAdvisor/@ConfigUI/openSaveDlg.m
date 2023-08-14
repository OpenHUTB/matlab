function openSaveDlg






    MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

    if isa(MAObj,'Simulink.ModelAdvisor')
        configisempty=modeladvisorprivate('modeladvisorutil2','CheckNonEmptyConfig',MAObj);
        if configisempty
            return
        end
        if~isempty(MAObj.ConfigFilePath)
            MAObj.saveConfiguration(MAObj.ConfigFilePath);
        else
            [filename,pathname]=uiputfile('*.mat',DAStudio.message('Simulink:tools:MASaveAs'));
            if~isequal(filename,0)&&~isequal(pathname,0)
                configFilePath=fullfile(pathname,filename);
                MAObj.saveConfiguration(configFilePath);
            end
        end
    end
    ModelAdvisor.ConfigUI.setEditTimeCheckingBehavior(MAObj.ConfigFilePath);
