function dialogCB(this,hDlg,action,varargin)



    enablecodeProver=pslink.util.Helper.isProverAvailable();

    switch lower(action)
    case 'convertonoffvalue'
        imd=DAStudio.imDialog.getIMWidgets(hDlg);
        val=find(imd,'WidgetId',varargin{1});
        this.(varargin{2})=val.checked;

    case 'verifmode'
        val=hDlg.getWidgetValue(varargin{1});
        theEnum=findtype('PSEnumVerificationMode');
        this.PSVerificationMode=theEnum.Strings{val+1};

    case 'verifsettings'
        val=hDlg.getWidgetValue(varargin{1});
        theEnum=findtype('PSEnumVerificationSettings');
        if~isempty(this.PSSystemToAnalyze)
            systemName=this.PSSystemToAnalyze;
            if~isempty(systemName)&&pslink.verifier.sfcn.isVerifiableSFcn(systemName)
                theEnum=findtype('PSEnumSfcnVerificationSettings');
            end
        end
        this.PSVerificationSettings=theEnum.Strings{val+1};

    case 'cxxverifsettings'
        val=hDlg.getWidgetValue(varargin{1});
        theEnum=findtype('PSEnumCxxVerificationSettings');
        this.PSCxxVerificationSettings=theEnum.Strings{val+1};

    case 'inputrangemode'
        val=hDlg.getWidgetValue(varargin{1});
        if val==0
            this.PSInputRangeMode='DesignMinMax';
        else
            this.PSInputRangeMode='FullRange';
        end

    case 'outputrangemode'
        val=hDlg.getWidgetValue(varargin{1});
        if val==0
            this.PSOutputRangeMode='DesignMinMax';
        else
            this.PSOutputRangeMode='None';
        end

    case 'paramrangemode'
        val=hDlg.getWidgetValue(varargin{1});
        if val==0
            this.PSParamRangeMode='DesignMinMax';
        else
            this.PSParamRangeMode='None';
        end

    case 'selecttplfile'
        [psprjFilename,filePath]=uigetfile({'*.psprj','Polyspace Project (*.psprj)';...
        '*.cfg','Polyspace Project (*.cfg)'},...
        DAStudio.message('polyspace:gui:pslink:configSelectorTitle'),'MultiSelect','off');

        if~isempty(psprjFilename)&&~isequal(psprjFilename,0)
            psprjFile=fullfile(filePath,psprjFilename);
            pslink.verifier.ConfigFile.checkValidProjectFile(psprjFile);

            this.PSPrjConfigFile=psprjFile;
            hDlg.refresh();
            hDlg.getDialogSource.enableApplyButton(true);
            dirtyWidget(ConfigSet.DDGWrapper(hDlg),'PSPrjConfigFile',true);

            if slfeature('ConfigsetDDUX')==1
                if(isa(hDlg,'DAStudio.Dialog'))
                    htmlView=hDlg.getDialogSource;
                    data=struct;
                    data.paramName='selecttplfile';
                    data.paramValue=psprjFile;
                    data.widgetType='browse';
                    htmlView.publish('sendToDDUX',data);
                end
            end
        end

    case 'validatetplfile'

        imd=DAStudio.imDialog.getIMWidgets(hDlg);
        val=find(imd,'WidgetId',varargin{1});
        psprjFile=val.text;
        if~isempty(psprjFile)
            pslink.verifier.ConfigFile.checkValidProjectFile(psprjFile);

            this.PSPrjConfigFile=psprjFile;
            hDlg.refresh();
        end

    case 'additionalfiles'


        fileList=this.PSAdditionalFileList;
        if isempty(fileList)
            fileName=fullfile(pwd,'polyspace_additional_file_list.txt');
            fileList=pssharedprivate('readAdditionalSourceListFile',fileName);
        end

        fileSelector=pslink.FileListSelector(this,fileList);
        fileSelector.pslinkccDlg=hDlg;
        DAStudio.Dialog(fileSelector,'','DLG_STANDALONE');

    case 'checklevelmode'
        val=hDlg.getWidgetValue(varargin{1});
        if val==0
            this.PSCheckConfigBeforeAnalysis='Off';
        elseif val==1
            this.PSCheckConfigBeforeAnalysis='OnWarn';
        else
            this.PSCheckConfigBeforeAnalysis='OnHalt';
        end

    case 'checkoptions'
        if exist('pslinkprivate')==0 %#ok<EXIST>
            diag=MException(message('polyspace:gui:pslink:badSetup'));
            sldiagviewer.reportError(diag);
            return
        end

        if~isempty(this.PSSystemToAnalyze)
            systemName=this.PSSystemToAnalyze;
        else
            systemName=get_param(bdroot,'Name');
        end
        polyspace_check_config_stage=Simulink.output.Stage(message('polyspace:gui:pslink:checkConfigurationStageName').getString(),...
        'ModelName',systemName,'UIMode',true);%#ok<NASGU>

        currConfigSet=getActiveConfigSet(bdroot(systemName));
        commitBuild=slprivate('checkSimPrm',currConfigSet);

        if~commitBuild||~isa(hDlg,'DAStudio.Dialog')
            return
        end

        try
            coderID=varargin{1};
            [resultDescription,resultDetails,resultType,~,resultId]=...
            pslinkprivate('checkOptions',coderID,systemName);


            pslinkprivate('reportCheckOptionsResults',...
            systemName,resultDescription,resultDetails,resultType,resultId);
        catch Me
            sldiagviewer.reportError(Me);
        end
    case 'runverification'
        if~isempty(this.PSSystemToAnalyze)
            systemName=this.PSSystemToAnalyze;
        else
            systemName=get_param(bdroot,'Name');
        end
        currConfigSet=getActiveConfigSet(bdroot(systemName));
        if~enablecodeProver
            set_param(currConfigSet,'PSVerificationMode','BugFinder');
        end
        commitBuild=slprivate('checkSimPrm',currConfigSet);

        if~commitBuild||~isa(hDlg,'DAStudio.Dialog')
            return
        end

        coderId=varargin{1};
        isForSFcn=strcmp(coderId,pslink.verifier.sfcn.Coder.CODER_ID);
        isForSlcc=strcmp(coderId,pslink.verifier.slcc.Coder.CODER_ID);
        coderName=pssharedprivate('getCoderName',coderId);
        compName=sprintf('Polyspace Verifier for %s',coderName);

        try
            if isForSFcn
                sfcnPath=systemName;
                systemName=bdroot(sfcnPath);

                meObj=pssharedprivate('checkSystemValidity',sfcnPath,true);
                if~isempty(meObj)
                    throwAsCaller(meObj);
                end
                pslinkprivate('launchSFunctionVerification',sfcnPath);
            elseif isForSlcc
                blockPath=systemName;
                systemName=bdroot(blockPath);
                meObj=pssharedprivate('checkSystemValidity',blockPath,true);
                if~isempty(meObj)
                    throwAsCaller(meObj);
                end
                pslinkprivate('launchSlccVerification',blockPath);
            else
                pslinkprivate('launchCodeVerification',systemName,[],[],false,true);
            end
        catch Me
            pslinkprivate('pslinkExceptionMessage',Me,systemName,compName);
        end

    case 'advancedoptions'
        if exist('pslinkprivate')==0 %#ok<EXIST>
            diag=MException(message('polyspace:gui:pslink:badSetup'));
            sldiagviewer.reportError(diag);
            return
        end

        coderID=varargin{1};


        msgS=pslink.util.MessageStream.instance();
        msgR=pslink.util.MessageReporter(true);
        msgR.clear(true);
        msgS.setReporter(msgR);
        msgS.setQueued(true);

        if~isempty(this.PSSystemToAnalyze)
            systemName=this.PSSystemToAnalyze;
        else
            systemName=get_param(bdroot,'Name');
        end

        currConfigSet=getActiveConfigSet(bdroot(systemName));
        commitBuild=slprivate('checkSimPrm',currConfigSet);

        if~commitBuild||~isa(hDlg,'DAStudio.Dialog')
            return
        end

        try

            pslinkOptions=pslink.Options(systemName);
            pslinkOptions=pslinkOptions.deepCopy();

            cfgFileName=pslinkprivate('getOrCreateConfigFile',systemName,coderID,pslinkOptions);

            src=hDlg.getDialogSource;
            if isa(src,'configset.dialog.HTMLView')

                web=ConfigSet.DDGWrapper(hDlg);
                web.disableDialog();
            else



                widGetsList={...
                '_pslink_ConfigComp_verification_mode_widgetid',...
                '_pslink_ConfigComp_verification_settings_widgetid',...
                '_pslink_ConfigComp_cxx_verification_settings_widgetid',...
                '_pslink_ConfigComp_configure_widgetid',...
                '_pslink_ConfigComp_input_range_mode_widgetid',...
                '_pslink_ConfigComp_param_range_mode_widgetid',...
                '_pslink_ConfigComp_output_range_mode_widgetid',...
                '_pslink_ConfigComp_model_ref_verif_depth_widgetid',...
                '_pslink_ConfigComp_result_dir_widgetid',...
                '_pslink_ConfigComp_check_configuration_widgetid',...
                '_pslink_ConfigComp_enable_additional_file_list_widgetid',...
                '_pslink_ConfigComp_stub_lookup_tables_widgetid',...
                '_pslink_ConfigComp_model_by_model_widgetid',...
                '_pslink_ConfigComp_add_suffix_to_result_dir_widgetid',...
                '_pslink_ConfigComp_add_to_simulink_project_widgetid',...
                '_pslink_ConfigComp_open_project_manager_widgetid',...
                '_pslink_ConfigComp_check_conf_label_widgetid',...
                '_pslink_ConfigComp_bug_finder_DRS_widgetid',...
                '_pslink_ConfigComp_enable_custom_project_file_widgetid',...
                '_pslink_ConfigComp_PSPrjConfigFile_widgetid',...
                '_pslink_ConfigComp_PSPrjConfigFile_push_widgetid',...
                '_pslink_ConfigComp_sfcn_all_instances_widgetid',...
'_pslink_ConfigComp_run_verification_widgetid'...
                };

                hDlg.disableWidgets(widGetsList);
            end

            pslinkprivate('openPolyspaceConfig',coderID,cfgFileName,true);

            if isa(src,'configset.dialog.HTMLView')

                web.enableDialog();
            else

                hDlg.restoreFromSchema();
            end

            if~isa(hDlg,'DAStudio.Dialog')
                return
            end

        catch Me
            msgS.createError('',Me.message,systemName,'Polyspace Configuration');
            msgS.flush();
            return
        end

    otherwise


    end






