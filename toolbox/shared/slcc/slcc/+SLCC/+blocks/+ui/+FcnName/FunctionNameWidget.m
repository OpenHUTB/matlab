

classdef FunctionNameWidget<handle



    methods(Static)
        function widgetPanel=getWidgetStruct(hDlgSrc,prmIndex,value,tag,fcnList)
            import SLCC.Utils.*
            nameField=struct('Type','combobox');
            nameField.Name=DAStudio.message('Simulink:blkprm_prompts:CustomCodeFcnName');
            nameField.Tag=tag;
            nameField.Entries=sort(fcnList);
            nameField.Value=value;
            nameField.MinimumSize=[150,0];
            nameField.ColSpan=[1,1];
            nameField.RowSpan=[1,1];
            nameField.Editable=1;
            nameField.MatlabMethod='SLCC.blocks.ui.FcnName.FunctionNameWidget.functionNameChanged';
            nameField.MatlabArgs={'%source','%dialog','%tag','%value'};
            nameField.ObjectMethod='handleEditEvent';
            nameField.MethodArgs={'%value',prmIndex,'%dialog'};
            nameField.ArgDataTypes={'mxArray','int32','handle'};
            nameField.Enabled=~(Simulink.harness.internal.isHarnessCUT(get(hDlgSrc.getBlock(),'Handle'))&&...
            ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(get(hDlgSrc.getBlock(),'Handle')));

            gotoFcnDefButtonEnableValue=true;
            if(strcmp(nameField.Value,DAStudio.message('Simulink:CustomCode:CFcnCallerDefaultFunctionName')))
                gotoFcnDefButtonEnableValue=false;
            end

            gotoFcnDefButton=struct('Type','pushbutton',...
            'Enabled',gotoFcnDefButtonEnableValue);
            gotoFcnDefButton.Tag='slcc_functionName_gotoFcnDefButton_tag';
            gotoFcnDefButton.ToolTip=DAStudio.message('Simulink:CustomCode:CFcnCallerGotoFcnDefToolTip');
            gotoFcnDefButton.FilePath=fullfile(matlabroot,'toolbox','shared',...
            'controllib','general','resources','Chevrons_ShowMO_16.png');
            gotoFcnDefButton.ColSpan=[2,2];
            gotoFcnDefButton.RowSpan=[1,1];
            gotoFcnDefButton.MatlabMethod='SLCC.blocks.ui.FcnName.FunctionNameWidget.openFunctionDefinition';
            gotoFcnDefButton.MatlabArgs={'%source','%dialog','%tag'};

            refreshButton=struct('Type','pushbutton');
            refreshButton.Tag='slcc_functionName_refreshButton_tag';
            refreshButton.ToolTip=DAStudio.message('Simulink:CustomCode:CFcnCallerSyncToolTip');
            refreshButton.FilePath=fullfile(matlabroot,'toolbox','shared',...
            'controllib','general','resources','Refresh_16.png');
            refreshButton.ColSpan=[3,3];
            refreshButton.RowSpan=[1,1];
            refreshButton.DialogRefresh=1;
            refreshButton.MatlabMethod='SLCC.blocks.ui.FcnName.FunctionNameWidget.parseCustomCode';
            refreshButton.MatlabArgs={'%source','%dialog','%tag'};


            configSetButton=struct('Type','pushbutton');
            configSetButton.Tag='slcc_functionName_configSetButton_tag';
            configSetButton.ToolTip=DAStudio.message('Simulink:CustomCode:CFcnCallerConfigSetToolTip');
            configSetButton.FilePath=fullfile(matlabroot,'toolbox','shared',...
            'controllib','general','resources','Settings_16.png');
            configSetButton.ColSpan=[4,4];
            configSetButton.RowSpan=[1,1];
            configSetButton.MatlabMethod='SLCC.blocks.ui.FcnName.FunctionNameWidget.openToCustomCodeSettings';
            configSetButton.MatlabArgs={'%source','%dialog','%tag'};


            widgetPanel=struct('Type','panel');
            widgetPanel.Name='';
            widgetPanel.Tag='slcc_functionNamePanel_tag';
            widgetPanel.LayoutGrid=[1,4];
            widgetPanel.ColStretch=[1,0,0,0];
            widgetPanel.Items={nameField,gotoFcnDefButton,refreshButton,configSetButton};
        end

        function openToCustomCodeSettings(hDlgSrc,dl,tag)
            hMdl=bdroot(get(hDlgSrc.getBlock(),'Handle'));
            dl.setEnabled(tag,0);
            if bdIsLibrary(hMdl)
                slCfgPrmDlg(hMdl,'OpenLibSim');
            else
                configset.showParameterGroup(hMdl,{'Simulation Target'});
            end
            dl.setEnabled(tag,1);
        end

        function parseCustomCode(hDlgSrc,dl,tag)
            hBlk=get(hDlgSrc.getBlock(),'Handle');
            hMdl=bdroot(hBlk);
            modelName=get_param(hMdl,'Name');
            dl.setEnabled(tag,0);
            resetDlg=onCleanup(@()dl.setEnabled(tag,1));

            progressbar=DAStudio.WaitBar;
            progressbar.setWindowTitle(DAStudio.message('RTW:configSet:ParsingCustomCodePleaseWait'));
            progressbar.setLabelText(DAStudio.message('Simulink:tools:MAPleaseWait'));
            progressbar.setCancelButtonText(DAStudio.message('Simulink:utility:CloseButton'));
            progressbar.setCircularProgressBar(true);
            progressbar.show();









            dvStage=sldiagviewer.createStage('Simulink','ModelName',modelName);%#ok<NASGU>
            success=slccprivate('parseCustomCode',hMdl,true);
            if~success
                return;
            end

            comboBoxMsg=message('Simulink:blkprm_prompts:CustomCodeFcnName');
            comboBoxTag=comboBoxMsg.string(matlab.internal.i18n.locale('en_US'));
            val=dl.getComboBoxText(comboBoxTag);

            [updateSucceeded,mSLMsg]=updateFunctionAfterParse(hMdl,hBlk,val);

            if updateSucceeded
                diagType='message';
            else
                diagType='warning';
            end
            mSLDiag=MSLException(hBlk,mSLMsg);
            SLCC.Utils.displayOnDiagnosticViewer(modelName,diagType,mSLDiag);
            slmsgviewer.Instance(modelName).show();
        end

        function functionNameChanged(hDlgSrc,dl,tag,val)%#ok<INUSL>
            hBlk=get(hDlgSrc.getBlock(),'Handle');
            try
                slcc('CCallerFunctionNameChanged',hBlk,val);
            catch

            end
        end

        function openFunctionDefinition(hDlgSrc,dl,tag)
            import SLCC.Utils.*
            dl.setEnabled(tag,0);
            blk=hDlgSrc.getBlock();
            value=blk.FunctionName;
            hMdl=bdroot(get(blk,'Handle'));

            [location,status]=slcc('getCustomCodeFunctionLocation',hMdl,value,true);
            if status<=0

                [location,status]=slcc('getCustomCodeFunctionLocation',hMdl,value,false);
            end

            if status>=0
                SLCC.Utils.OpenFileAndHighlight(location.path,...
                location.line,location.column,location.length,hMdl);
            else
                errorId='Simulink:CustomCode:CFcnCallerGotoFcnDefNoFcn';
                errordlg(DAStudio.message(errorId,value),...
                DAStudio.message('Simulink:CustomCode:CFcnCallerGotoFcnDefNoFcnDlgErrTitle'),...
                'modal');
            end
            dl.setEnabled(tag,1);
        end

    end
end

function[updateSucceeded,mSLMsg]=updateFunctionAfterParse(hMdl,hBlk,val)










    mdlName=get_param(hMdl,'Name');
    if isempty(slcc('getModelCustomCodeChecksum',hMdl,false))
        link=['<a href="matlab:SLCC.Utils.OpenConfigureSetAndHighlightParseCC(''',mdlName,''')">',DAStudio.message('RTW:configSet:simParseCustomCodeName'),'</a>'];
        mSLMsg=message('Simulink:CustomCode:EmptyCustomCodeSetting',getfullname(hBlk),link,mdlName);
        updateSucceeded=false;
        return;
    end

    if strcmp(get_param(hMdl,'CustomCodeUndefinedFunction'),'FilterOut')&&...
        isempty(get_param(hBlk,'AvailableFunctions'))
        link=['<a href="matlab:SLCC.Utils.OpenConfigureSetAndHighlightUndefinedFunctionHandling(''',mdlName,''')">',DAStudio.message('RTW:configSet:CustomCodeUndefinedFunctionName'),'</a>'];
        mSLMsg=message('Simulink:CustomCode:NoAvailableFunctionsInFilterOutMode',getfullname(hBlk),link);
        updateSucceeded=false;
        return;
    end

    if strcmp(val,DAStudio.message('Simulink:CustomCode:CFcnCallerDefaultFunctionName'))
        mSLMsg=message('Simulink:CustomCode:CustomCudeParseSuccessful',mdlName);
        updateSucceeded=true;
        return
    end

    try
        structAndEnums=slcc('CCallerFunctionNameChanged',hBlk,val);
    catch mSLMsg
        updateSucceeded=false;
        return;
    end
    if isempty(structAndEnums)
        mSLMsg=message('Simulink:CustomCode:CustomCudeParseSuccessful',mdlName);
    else
        [structAndEnumsList,structAndEnumsCellInput]=getFormattedStructAndEnum(structAndEnums);
        mSLMsg=message('Simulink:CustomCode:CustomCudeParseSuccessfulWithImport',mdlName,val,...
        structAndEnumsList,structAndEnumsCellInput);
    end
    updateSucceeded=true;

end


function[structAndEnumsList,structAndEnumsCellInput]=getFormattedStructAndEnum(structAndEnums)
    structAndEnumsList=sprintf('%s\n',structAndEnums{:});
    structAndEnumsCellInput=sprintf('''%s'',',structAndEnums{:});
    structAndEnumsCellInput(end)=[];
    structAndEnumsCellInput=['{',structAndEnumsCellInput,'}'];
end