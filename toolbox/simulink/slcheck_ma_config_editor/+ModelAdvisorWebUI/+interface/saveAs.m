function resultJSON=saveAs(jsonString)

    try
        if ismac
            h=figure('OuterPosition',[1,1,3,3]);
            drawnow;
            h.delete;
        end
        [filename,pathname]=uiputfile({'*.json','JSON-files (*.json)'},DAStudio.message('Simulink:tools:MASaveAs'));
        if~isequal(filename,0)&&~isequal(pathname,0)
            filePath=fullfile(pathname,filename);
            [~,~,ext]=fileparts(filePath);
            if~strcmp(ext,'.json')
                filePath=[filePath,'.json'];
            end


            fid=fopen(filePath,'wt','n','UTF-8');
            fwrite(fid,jsonString,'char');
            fclose(fid);

            success=true;
        else

            result=struct('success',true,'message',jsonencode(struct('title','cancel','content','cancel')),'warning',false,'filepath','','value',jsonencode('cancel'));
            resultJSON=jsonencode(result);

            t=ModelAdvisorWebUI.interface.MACEUI.getInstance;
            t.bringToFront;
            return
        end

        title=DAStudio.message('ModelAdvisor:engine:MACEConfigSavingmsg');
        msg=DAStudio.message('ModelAdvisor:engine:MACEConfigSaveSuccess');
        if success

            defaultConfigFile=ModelAdvisor.getDefaultConfiguration;
            if~strcmp(defaultConfigFile,filePath)
                choice=questdlg(DAStudio.message('ModelAdvisor:engine:MACESetAsDefaultQuestion'),...
                DAStudio.message('ModelAdvisor:engine:MACEMarkAsDefault'),'Yes','No','No');
                if strcmp(choice,'Yes')
                    ModelAdvisor.setDefaultConfiguration(filePath);
                    warnDlgHandle=findall(0,'type','figure','Tag','MASetDefaultConfig');
                    if isempty(warnDlgHandle)
                        warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MASetDefaultConfig',filePath));
                        set(warndlgHandle,'Tag','MASetDefaultConfig');
                    end
                end
            else

                ModelAdvisor.setDefaultConfiguration(filePath);
            end
        else
            msg=DAStudio.message('ModelAdvisor:engine:MACENotSavedmsg');
        end
    catch E
        success=false;
        title=DAStudio.message('ModelAdvisor:engine:MACEError');
        msg=E.message;
        filePath='';
    end
    result=struct('success',success,'message',jsonencode(struct('title',title,'content',msg)),'warning',false,'filepath',filePath,'value',jsonencode('saveAs'));
    resultJSON=jsonencode(result);
    if success&&strcmp(ext,'.json')

        editControl=edittimecheck.EditTimeEngine.getInstance();
        editControl.refreshModelConfigurationFile(filename);
        modeladvisorprivate('modeladvisorutil2','refreshAdvisorConfigurationForEditTime');
    end
    t=ModelAdvisorWebUI.interface.MACEUI.getInstance;
    t.bringToFront;
end