classdef(Hidden=true)DictionarySpecificationCallBack





    properties
    end

    methods(Static)

        function selectDD(ddgDialogObj,dialogH)
            modelddg_cb(dialogH,'doSelectDD','DataDictionary');
            Simulink.DictionarySpecificationCallBack.updateDictionary(ddgDialogObj,dialogH,dialogH.getWidgetValue('DataDictionary'));
        end

        function newDD(ddgDialogObj,dialogH)
            modelddg_cb(dialogH,'doNewDD','DataDictionary');
            Simulink.DictionarySpecificationCallBack.updateDictionary(ddgDialogObj,dialogH,dialogH.getWidgetValue('DataDictionary'));
        end

        function openDD(ddgDialogObj,dialogH)%#ok
            modelddg_cb(dialogH,'doOpenDD','DataDictionary');
        end

        function selectDataSource(ddgDialogObj,dialogH)
            if slfeature('SLModelAllowedBaseWorkspaceAccess')==0


                modelddg_cb(dialogH,'doSelectDataSource');
            end

            status=true;
            bdH=ddgDialogObj.source;
            dataSelectorState=dialogH.getWidgetValue('DataSourceSelect');
            if dataSelectorState==0
                if~isempty(get_param(bdH.name,'DataDictionary'))&&...
                    bdH.isHierarchySimulating
                    status=false;
                    errordlg(DAStudio.message('SLDD:sldd:NoChangeWhileRunning'),...
                    DAStudio.message('Simulink:dialog:DataDictDialogTitle'));
                end
                dataDict='';


                if status&&(~isequal(get_param(bdH.name,'DataDictionary'),dataDict))
                    hWait=waitbar(0,DAStudio.message('SLDD:sldd:WaitMigrationStart'));
                    Simulink.dd.launchDictionaryMigration(bdH,dataDict,hWait,dialogH);
                    dialogH.setWidgetValue('DataDictionary',dataDict);
                    dialogH.clearWidgetDirtyFlag('DataDictionary');

                    try
                        close(hWait);
                    catch
                    end
                end
            end
        end

        function btnDataMigrate(ddgDialogObj,dialogH)
            status=true;
            dataDict=dialogH.getWidgetValue('DataDictionary');
            dlgSrc=dialogH.getDialogSource;
            bdH=dlgSrc.source;
            if isempty(dataDict)
                dialogH.setUserData('DataDictionary',get_param(bdH.name,'DataDictionary'));
            else
                try
                    dd=Simulink.dd.open(dataDict);
                    dialogH.setUserData('DataDictionary',dataDict);
                    dd.close();
                catch E
                    status=false;
                    uiwait(errordlg(E.message,DAStudio.message('Simulink:dialog:DataDictDialogTitle')));
                end
            end
            if status
                hWait=waitbar(0,DAStudio.message('SLDD:sldd:WaitMigrationStart'));
                status=Simulink.dd.launchDictionaryMigration(bdH,dataDict,hWait,dialogH,'migrateBtn');
                try
                    close(hWait);
                catch
                end
            end
        end

        function updateDictionary(ddgDialogObj,dialogH,dictName)
            if slfeature('SLModelAllowedBaseWorkspaceAccess')<2

                dialogH.clearWidgetDirtyFlag('DataDictionary');
            end

            selectorState=dialogH.getWidgetValue('DataSourceSelect');
            if(~selectorState)
                return;
            end

            status=true;
            bdH=ddgDialogObj.source;

            dataDict=strtrim(dictName);
            if~isempty(dataDict)
                [~,~,ext]=fileparts(dataDict);

                if(isempty(ext))
                    dataDict=[dataDict,'.sldd'];
                elseif~isequal(ext,'.sldd')&&slfeature('SLModelAllowedBaseWorkspaceAccess')<2
                    status=false;

                    msg=DAStudio.message('SLDD:sldd:DictionaryExtensionNotValid',...
                    dataDict,'.sldd');
                    errordlg(msg,DAStudio.message('Simulink:dialog:DataDictDialogTitle'));
                end


                if status&&~isequal(get_param(bdH.name,'DataDictionary'),dataDict)
                    dialogH.setWidgetValue('DataDictionary',dataDict);
                    if isempty(which(dataDict))
                        msg=[DAStudio.message('SLDD:sldd:DictionaryNotFound',dataDict),' ',DAStudio.message('SLDD:sldd:DictionaryCreateNow')];
                        title=DAStudio.message('Simulink:dialog:DataDictDialogTitle');
                        rsp=questdlg(msg,title,DAStudio.message('Simulink:editor:DialogOK'),...
                        DAStudio.message('Simulink:editor:DialogCancel'),...
                        DAStudio.message('Simulink:editor:DialogCancel'));

                        status=false;
                        if strcmp(rsp,DAStudio.message('Simulink:editor:DialogOK'))
                            modelddg_cb(dialogH,'doNewDD','DataDictionary');


                            dataDict=dialogH.getWidgetValue('DataDictionary');
                            if~isempty(which(dataDict))
                                status=true;
                            end
                        end
                    end
                end
            end

            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1

                accessToBWSFromMdl=dialogH.getWidgetValue('EnableAccessToBaseWorkspace');
                modelddg_cb(dialogH,'doSetEnableBWS',accessToBWSFromMdl);
                error=false;
                if isempty(dialogH.getWidgetValue('DataDictionary'))&&~accessToBWSFromMdl
                    error=true;
                end

                if error||slfeature('SLDataDictionaryMigrateUI')<1

                    defaultModelPropCB_ddg(dialogH,ddgDialogObj.source,'DataDictionary',dataDict);
                    return
                end
            end

            if status&&slfeature('SLDataDictionaryMigrateUI')<1
                status=false;
            end

            if status

                if~isequal(get_param(bdH.name,'DataDictionary'),dataDict)
                    if isempty(dataDict)
                        dialogH.setUserData('DataDict',get_param(bdH.name,'DataDictionary'));
                    else
                        try
                            dd=Simulink.dd.open(dataDict);
                            dialogH.setUserData('DataDict',dataDict);
                            dd.close();
                        catch E
                            status=false;
                            uiwait(errordlg(E.message,DAStudio.message('Simulink:dialog:DataDictDialogTitle')));
                        end
                    end
                    if status
                        hWait=waitbar(0,DAStudio.message('SLDD:sldd:WaitMigrationStart'));
                        if slfeature('SLDataDictionaryMigrateUI')>0
                            ddFunction='link';
                        else
                            ddFunction='auto';
                        end

                        status=Simulink.dd.launchDictionaryMigration(bdH,dataDict,hWait,dialogH,ddFunction);
                        try
                            close(hWait);
                        catch
                        end
                    end
                end
            end

            if~status
                defaultModelPropCB_ddg(dialogH,ddgDialogObj.source,'DataDictionary',bdH.DataDictionary);
            end

        end



    end

end


