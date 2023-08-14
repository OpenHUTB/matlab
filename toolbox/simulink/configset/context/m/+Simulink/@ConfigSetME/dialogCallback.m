function dialogCallback(hObj,hDlg,tag,schema)




    switch tag
    case 'Tag_ConfigSetME_saveToFile'
        saveFileGrp_Tag='Tag_ConfigSetME_saveFileGroup';
        hDlg.setEnabled(saveFileGrp_Tag,hObj.saveToFile);

    case 'Tag_ConfigSetME_BrowseButton'

        msgTitle=DAStudio.message('Simulink:ConfigSet:ConfigSetMEFileIOWindowTitle');
        [filename,pathname]=uiputfile({'*.mat',DAStudio.message('Simulink:busEditor:MATFiles');...
        '*.m',DAStudio.message('Simulink:busEditor:MATLABFiles')},msgTitle);

        if~ischar(filename)||~ischar(pathname)
            return;
        end

        [~,filenameonly,ext]=fileparts(filename);

        if~isvarname(filenameonly)
            msgbox(DAStudio.message('Simulink:tools:badOutputFileName',filename),...
            DAStudio.message('Simulink:ConfigSet:ConfigSetMEError'),'warn');
            return;
        end

        if strcmpi(ext,'.mat')
            hObj.fileType=1;
        else
            hObj.fileType=2;
        end

        hDlg.setWidgetValue('Tag_ConfigSetME_fileName',fullfile(pathname,filename));

    case 'Tag_ConfigSetME_OKButton'

        if strcmp(schema,'propagateCSRef')
            slprivate('slPropagateCSRefforMdlRef');
            delete(hDlg);
            return;
        end

        tag='Tag_ConfigSetME_';
        sourceName_tag='SourceName';
        csName=hDlg.getWidgetValue([tag,sourceName_tag]);
        csWSName=csName;
        if~isvarname(csWSName)
            errordlg(DAStudio.message('Simulink:ConfigSet:MEContextInvalidIdentifier',csWSName),...
            DAStudio.message('Simulink:ConfigSet:ConfigSetMEError'));
            return;
        end

        model=hObj.node.getModel;
        cs=hObj.node;


        ddFilename=get_param(model,'DataDictionary');
        if~isempty(ddFilename)
            dd=Simulink.dd.open(ddFilename);
            if dd.isOpen
                if dd.entryExists(['Configurations.',csName],false)
                    question=sprintf('%s\n%s',DAStudio.message('Simulink:ConfigSet:ConfigSetMECase2Msg1',csWSName),...
                    DAStudio.message('Simulink:ConfigSet:ConfigSetMECase2Msg2'));
                    answer=questdlg(question,...
                    DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogTitle'),...
                    DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonYes'),...
                    DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonNo'),...
                    DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonNo'));

                    if~strcmpi(answer,DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonYes'))
                        dd.close;
                        return;
                    end

                    cs.Name=csName;
                    dd.setEntry(['Configurations.',csName],cs);

                else
                    cs.Name=csName;
                    dd.insertEntry('Configurations',csName,cs,'Configuration');
                end

                csref=Simulink.ConfigSetRef;
                attachConfigSet(model,csref,true);
                csref.SourceName=csName;
                setActiveConfigSet(model,csref.Name);
                detachConfigSet(model,cs.Name);

                dd.close;
            end

            delete(hDlg);
        else
            saveToFile=hObj.saveToFile;
            fileName=hDlg.getWidgetValue('Tag_ConfigSetME_fileName');

            if saveToFile&&isempty(fileName)
                errordlg(DAStudio.message('Simulink:ConfigSet:ConfigSetMEFileNameEmptyError'),...
                DAStudio.message('Simulink:ConfigSet:ConfigSetMEError'));
                return;
            end

            if saveToFile
                if exist(fileName,'file')
                    [~,message,~]=fileattrib(fileName);

                    if~isempty(message)&&isfield(message,'UserWrite')&&message.UserWrite==0
                        fileattrib(fileName,'+w');
                    end
                end

                [~,filenameonly,ext]=fileparts(fileName);

                if~isvarname(filenameonly)
                    msgbox(DAStudio.message('Simulink:tools:badOutputFileName',fileName),...
                    DAStudio.message('Simulink:ConfigSet:ConfigSetMEError'),'warn');
                    return;
                end

                if isempty(ext)||strcmpi(ext,'.mat')
                    hObj.fileType=1;
                elseif strcmpi(ext,'.m')
                    hObj.fileType=2;
                else
                    errordlg(DAStudio.message('Simulink:tools:badFileNameExtension',ext),...
                    DAStudio.message('Simulink:ConfigSet:ConfigSetMEError'));
                    return;
                end
            end

            fileType=hObj.fileType;

            model=hObj.node.getModel;

            if evalin('base',['exist(''',csWSName,''', ''var'')'])==1
                question=sprintf('%s\n%s',DAStudio.message('Simulink:ConfigSet:ConfigSetMECase2Msg1',csWSName),...
                DAStudio.message('Simulink:ConfigSet:ConfigSetMECase2Msg2'));
                answer=questdlg(question,...
                DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogTitle'),...
                DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonYes'),...
                DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonNo'),...
                DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonNo'));

                if~strcmpi(answer,DAStudio.message('Simulink:ConfigSet:ConfigSetMEDialogButtonYes'))
                    return;
                end
            end

            configset.util.convertToCSRef(model,csWSName,saveToFile,fileName,fileType);
            delete(hDlg);
        end


        selectListItems(daexplr,'Name',csref.getDisplayLabel,true);

    case 'Tag_ConfigSetME_CancelButton'
        delete(hDlg);


    case{'Tag_ConfigSetME_ConvertToCSRef_Help','Tag_ConfigSetME_AddCSRef_Help','Tag_ConfigSetME_propagetCSRef_Help'}
        HelpArgs={[docroot,'/simulink/helptargets.map'],tag};
        helpview(HelpArgs{1},HelpArgs{2});
    end
end



