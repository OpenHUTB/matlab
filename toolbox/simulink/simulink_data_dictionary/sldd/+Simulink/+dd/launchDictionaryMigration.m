function rtn=launchDictionaryMigration(hModel,newDataDictName,hWait,dialogH,ddFunction)



    rtn=true;
    hWait=updateWait(hWait,.2);

    if sl.interface.dict.api.isInterfaceDictionary(newDataDictName)&&isequal(ddFunction,'migrateBtn')
        msgGeneral='SLDD:sldd:MigrationError';
        dlg=Simulink.dd.DictionaryMigrationResults(msgGeneral,DAStudio.message('interface_dictionary:migrator:unsupportedMigrateData','Simulink.interface.dictionary.Migrator'));
        DAStudio.Dialog(dlg,'','DLG_STANDALONE');
        closeWait(hWait);
        rtn=false;
        return;
    end

    try


        if isempty(newDataDictName)&&...
            length(find_mdlrefs(hModel.name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false))<2

            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1

                hModel.EnableAccessToBaseWorkspace=dialogH.getWidgetValue('EnableBWSAccess');
            end
            hModel.DataDictionary=newDataDictName;
            cs=getActiveConfigSet(hModel.name);
            if isa(cs,'Simulink.ConfigSetRef')
                cs.refresh;
            end
        end
    catch E
        warning(E.identifier,'%s',E.message);
    end

    hWait=updateWait(hWait,.4);

    if~isequal(hModel.DataDictionary,newDataDictName)||isequal(ddFunction,'migrateBtn')
        action='migrate';
        ddHasBWSAccess=false;
        mdlHasBWSAccess=false;
        if~isempty(newDataDictName)&&~isempty(hModel.DataDictionary)
            if isempty(which(newDataDictName))
                action='';
                rtn=false;
                hWait=closeWait(hWait);
                errordlg(DAStudio.message('SLDD:sldd:DictionaryNotFound',newDataDictName),...
                DAStudio.message('Simulink:dialog:ModelDesignDataGroupName'));
            elseif isempty(which(hModel.DataDictionary))
                rtn=false;
                action='link';
            end

            if rtn&&isequal(ddFunction,'auto')


                question=DAStudio.message('SLDD:sldd:StartComponentize',...
                newDataDictName);
                title=DAStudio.message('Simulink:dialog:ModelDesignDataGroupName');
                btn1=DAStudio.message('SLDD:sldd:StartComponentizeAns1');
                btn2=DAStudio.message('SLDD:sldd:StartComponentizeAns2');
                btnCancel=DAStudio.message('Simulink:editor:DialogCancel');
                hWait=closeWait(hWait);
                button=questdlg(question,title,btn1,btn2,btnCancel,btn1);
                if isequal(button,btn2)
                    hWait=updateWait(hWait,.6);
                    action='migrate';
                elseif isequal(button,btn1)
                    hWait=updateWait(hWait,.6);
                    action='link';
                    try
                        if length(find_mdlrefs(hModel.name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false))<2


                            hModel.DataDictionary=newDataDictName;
                            action='';
                            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1


                                hModel.EnableAccessToBaseWorkspace=...
                                int8(dialogH.getWidgetValue('EnableBWSAccess'));
                            end
                        end
                    catch E
                        warning(E.message);
                    end
                else
                    action='';
                    rtn=false;
                end
            end
        end

        if isequal(ddFunction,'link')

            if(length(find_mdlrefs(hModel.name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false))<2)
                hWait=updateWait(hWait,.8);

                dialogH.clearWidgetDirtyFlag('DataDictionary');

                hModel.DataDictionary=newDataDictName;
                hWait=closeWait(hWait);
            else
                hWait=updateWait(hWait,.8);
                migrationDlgObj=Simulink.dd.DictionaryMigrationDialog(hModel,newDataDictName,'linkv2',dialogH);
                hWait=closeWait(hWait);
                DAStudio.Dialog(migrationDlgObj,'','DLG_STANDALONE');
            end
        elseif isequal(ddFunction,'migrateBtn')
            if~isequal(hModel.DataDictionary,newDataDictName)
                action='linkAndMigrateV2';
            else
                action='migrateV2';
            end

            hWait=updateWait(hWait,.8);
            migrationDlgObj=Simulink.dd.DictionaryMigrationDialog(hModel,newDataDictName,action,dialogH);
            hWait=closeWait(hWait);
            DAStudio.Dialog(migrationDlgObj,'','DLG_STANDALONE');
        else
            if~isempty(newDataDictName)&&isempty(hModel.DataDictionary)
                dictConn=Simulink.dd.open(newDataDictName);
                ddHasBWSAccess=dictConn.HasAccessToBaseWorkspace;
                dictConn.close;
                if slfeature('SLModelAllowedBaseWorkspaceAccess')>1

                    mdlHasBWSAccess=dialogH.getWidgetValue('EnableBWSAccess');
                else
                    mdlHasBWSAccess=ddHasBWSAccess;
                end
            end
            if ddHasBWSAccess||mdlHasBWSAccess




                hWait=updateWait(hWait,.8);
                migrationDlgObj=Simulink.dd.DictionaryMigrationDialog(hModel,newDataDictName,action,dialogH);
                hasHierarchy=migrationDlgObj.isModelRefHierarchy;
                if hasHierarchy
                    if ddHasBWSAccess
                        migrationAction='connectModelHierarchy';
                    else

                        migrationAction='connectModelHierarchyWithoutDDSetting';
                    end
                else
                    if ddHasBWSAccess
                        migrationAction='singleModelConnect';
                    else

                        migrationAction='singleModelConnectWithoutDDSetting';
                    end
                end
                migrationDlgObj.performAction(migrationAction,hWait);
            else

                if~isempty(action)
                    hWait=updateWait(hWait,.8);
                    dlg=Simulink.dd.DictionaryMigrationDialog(hModel,newDataDictName,action,dialogH);
                    hWait=closeWait(hWait);
                    DAStudio.Dialog(dlg,'','DLG_STANDALONE');
                else
                    hWait=closeWait(hWait);
                end
            end
        end
    end

end

function hNew=updateWait(hWait,nAmt)
    try
        waitbar(nAmt,hWait);
        hNew=hWait;
    catch
        hNew=waitbar(nAmt,DAStudio.message('SLDD:sldd:WaitMigrationStart'));
    end

end

function hNew=closeWait(hWait)
    try
        close(hWait);
    catch
    end
    hNew=0;
end
