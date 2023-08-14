


function[status,message]=modelddg_data_cb(dialogH,action,varargin)

    status=true;
    message='';

    if isequal(action,'preapply')
        bdH=varargin{1};
        ddFunction=varargin{2};
        [status,message]=preapply(dialogH,bdH,ddFunction);
    elseif isequal(action,'postapply')
        bdH=varargin{1};
        [status,message]=postapply(dialogH,bdH);
    end
end


function[status,message]=postapply(dialogH,bdH)
    status=true;
    message='';


end

function[status,errMsg]=preapply(dialogH,bdH,ddFunction)

    status=true;
    errMsg='';

    if dialogH.isWidgetValid('DataSourceSelect')||...
        (slfeature('SLModelAllowedBaseWorkspaceAccess')>1&&...
        dialogH.isWidgetValid('DataDictionary'))
        if bdH.isLibrary&&slfeature('SLLibrarySLDD')>0||...
            (bdIsSubsystem(bdH.Handle)&&slfeature('SLSubsystemSLDD')>0)
            dataSelectorState=1;
        elseif slfeature('SLModelAllowedBaseWorkspaceAccess')>1


            dataSelectorState=1;


            if~dialogH.getWidgetValue('EnableBWSAccess')&&...
                isempty(dialogH.getWidgetValue('DataDictionary'))
                status=false;
                errordlg(DAStudio.message('Simulink:Data:NeedAccessToBaseWSOrDD'));
                return;
            end
        else
            dataSelectorState=dialogH.getWidgetValue('DataSourceSelect');
        end
        switch dataSelectorState
        case 0
            if~isempty(get_param(bdH.name,'DataDictionary'))&&...
                bdH.isHierarchySimulating
                status=false;
                errordlg(DAStudio.message('SLDD:sldd:NoChangeWhileRunning'),...
                DAStudio.message('Simulink:dialog:DataDictDialogTitle'));
            end
            dataDict='';

        case 1
            dataDict=dialogH.getWidgetValue('DataDictionary');
            dataDict=strtrim(dataDict);
            [~,~,ext]=fileparts(dataDict);
            if isempty(dataDict)
                if slfeature('SLModelAllowedBaseWorkspaceAccess')<2
                    errordlg(DAStudio.message('SLDD:sldd:EmptyDictionaryFilespec'),DAStudio.message('Simulink:dialog:DataDictDialogTitle'));
                    status=false;
                end
            elseif bdH.isHierarchySimulating&&...
                ~isequal(get_param(bdH.name,'DataDictionary'),...
                dialogH.getWidgetValue('DataDictionary'))

                status=false;
                errordlg(DAStudio.message('SLDD:sldd:NoChangeWhileRunning'),...
                DAStudio.message('Simulink:dialog:DataDictDialogTitle'));
            else
                if(isempty(ext))
                    dataDict=[dataDict,'.sldd'];
                elseif~isequal(ext,'.sldd')
                    status=false;

                    msg=DAStudio.message('SLDD:sldd:DictionaryExtensionNotValid',...
                    dataDict,'.sldd');
                    errordlg(msg,DAStudio.message('Simulink:dialog:DataDictDialogTitle'));
                end
                if status&&...
                    ~isequal(get_param(bdH.name,'DataDictionary'),...
                    dialogH.getWidgetValue('DataDictionary'))
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
        end

        if status

            if~isequal(get_param(bdH.name,'DataDictionary'),dataDict)||...
                isequal(ddFunction,'migrateBtn')
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
                if status&&~((bdH.isLibrary&&slfeature('SLLibrarySLDD')>0)||...
                    (bdIsSubsystem(bdH.Handle)&&slfeature('SLSubsystemSLDD')>0))
                    hWait=waitbar(0,DAStudio.message('SLDD:sldd:WaitMigrationStart'));
                    status=Simulink.dd.launchDictionaryMigration(bdH,dataDict,hWait,dialogH,ddFunction);
                    try
                        close(hWait);
                    catch
                    end
                elseif status
                    try
                        set_param(bdH.Name,'DataDictionary',dataDict);
                    catch E
                        status=false;
                        errMsg=E.message;
                    end
                end



                if~strcmp(ddFunction,'auto')&&~(bdH.isLibrary||bdIsSubsystem(bdH.Handle))
                    if strcmp(get_param(bdH.name,'EnableAccessToBaseWorkspace'),'on')&&...
                        ~dialogH.getWidgetValue('EnableBWSAccess')||...
                        strcmp(get_param(bdH.name,'EnableAccessToBaseWorkspace'),'off')&&...
                        dialogH.getWidgetValue('EnableBWSAccess')
                        set_param(bdH.Name,'DataDictionary',dialogH.getWidgetValue('DataDictionary'));
                        set_param(bdH.name,'EnableAccessToBaseWorkspace',...
                        int8(dialogH.getWidgetValue('EnableBWSAccess')));
                    end
                end
            elseif slfeature('SLModelAllowedBaseWorkspaceAccess')>1&&...
                ~((bdH.isLibrary&&slfeature('SLLibrarySLDD')>0)||...
                (bdIsSubsystem(bdH.Handle)&&slfeature('SLSubsystemSLDD')>0))

                wBWS=warning('off','Simulink:dialog:BWSAccessViaDD');
                try
                    set_param(bdH.name,'EnableAccessToBaseWorkspace',...
                    int8(dialogH.getWidgetValue('EnableBWSAccess')))
                catch E
                    status=false;
                    errordlg(E.message,DAStudio.message('Simulink:dialog:ModelDialogTitle'));
                end
                warning(wBWS);
            end
            if~bdH.isLibrary&&slfeature('SlDataEnableDataConsistencyCheck')>1


                if strcmp(get_param(bdH.name,'EnforceDataConsistency'),'on')&&...
                    ~dialogH.getWidgetValue('EnforceDataConsistency')||...
                    strcmp(get_param(bdH.name,'EnforceDataConsistency'),'off')&&...
                    dialogH.getWidgetValue('EnforceDataConsistency')
                    set_param(bdH.name,'EnforceDataConsistency',...
                    int8(dialogH.getWidgetValue('EnforceDataConsistency')));
                end
            end
        end
    end

end


