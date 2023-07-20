function[success,msg]=dlgCallback(~,dlg)









    success=true;
    msg='';

    locSetBuildFolders(dlg,'CacheFolder');
    locSetBuildFolders(dlg,'CodeGenFolder');

    value=dlg.getWidgetValue('CodeGenFolderStructure');
    list=Simulink.filegen.CodeGenFolderStructure.getEnumMemberDisplayList();
    set_param(0,'CodeGenFolderStructure',Simulink.filegen.CodeGenFolderStructure.getEnumStringfromDisplayString(list{value+1}));

    callbacks=dlg.getWidgetValue('CallbackTracing');
    set_param(0,'CallbackTracing',i_onoff(callbacks));

    callbacks=dlg.getWidgetValue('OpenLegendWhenChangingSampleTimeDisplay');
    set_param(0,'OpenLegendWhenChangingSampleTimeDisplay',i_onoff(callbacks));



    printBkMode=dlg.getWidgetValue('PrintBackgroundColorMode');
    if printBkMode==0
        printBkMode='MatchCanvas';
    else
        assert(printBkMode==1);
        printBkMode='White';
    end
    set_param(0,'PrintBackgroundColorMode',printBkMode);



    exportBkMode=dlg.getWidgetValue('ExportBackgroundColorMode');
    if exportBkMode==0
        exportBkMode='MatchCanvas';
    elseif exportBkMode==1
        exportBkMode='White';
    else
        assert(exportBkMode==2);
        exportBkMode='Transparent';
    end
    set_param(0,'ExportBackgroundColorMode',exportBkMode);



    clipboardBkMode=dlg.getWidgetValue('ClipboardBackgroundColorMode');
    if clipboardBkMode==0
        clipboardBkMode='MatchCanvas';
    elseif clipboardBkMode==1
        clipboardBkMode='White';
    else
        assert(clipboardBkMode==2);
        clipboardBkMode='Transparent';
    end
    set_param(0,'ClipboardBackgroundColorMode',clipboardBkMode);

    p=Simulink.Preferences.getInstance;
    p.Save;


    function s=i_onoff(b)

        if b
            s='on';
        else
            s='off';
        end












        function locSetBuildFolders(dlg,folderType)

            newVal=dlg.getWidgetValue(folderType);

            try
                set_param(0,folderType,newVal);
            catch exc

                if strcmp(exc.identifier,'RTW:buildProcess:rootBuildDirDoesNotExist')




                    dlg.setWidgetValue(folderType,get_param(0,folderType));
                    msgID='Simulink:slbuild:BuildFolderDoesNotExist';
                    msg=DAStudio.message(msgID,folderType,newVal);
                    newExc=MException(msgID,'%s',msg);
                    newExc=newExc.addCause(exc);
                    throw(newExc);
                else
                    rethrow(exc);
                end
            end


            return;

