function dlgstruct=getDialogSchema(this,name)%#ok<INUSD>





    dlgstruct.DialogTag=this.ID;
    if this.InLibrary
        dlgstruct.DialogTitle=DAStudio.message('Simulink:tools:MACBTitle');
    else
        dlgstruct.DialogTitle=DAStudio.message('Simulink:tools:MACETitle');
    end
    dlgstruct.LayoutGrid=[6,10];
    dlgstruct.RowStretch=[0,0,0,0,0,1];
    dlgstruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];




    if isempty(this.HelpMethod)
        if~isempty(this.CSHParameters)&&isfield(this.CSHParameters,'MapKey')&&...
            isfield(this.CSHParameters,'TopicID')
            mapkey=['mapkey:',this.CSHParameters.MapKey];
            topicid=this.CSHParameters.TopicID;
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={mapkey,topicid,'CSHelpWindow'};
        else
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={[docroot,'/slcheck/helptargets.map'],'model_advisor_configuration_editor_window'};
        end
    else
        dlgstruct.HelpMethod=this.HelpMethod;
        dlgstruct.HelpArgs=this.HelpArgs;
    end
    if isempty(this.ParentObj)
        if this.InLibrary
            [addonStruct]=loc_createDialogForLibraryRoot(this);
        else
            [addonStruct]=loc_createDialogForRoot(this);
        end
    elseif strcmp(this.Type,'Task')
        if this.MACIndex>0
            [addonStruct]=loc_createDialogForTask(this);
            dlgstruct.LayoutGrid=addonStruct.LayoutGrid;
            dlgstruct.RowStretch=addonStruct.RowStretch;
            dlgstruct.ColStretch=addonStruct.ColStretch;
        else
            [addonStruct]=loc_createDialogForStubNode(this);
        end
    else
        [addonStruct]=loc_createDialogForGroup(this);
    end
    dlgstruct.Items=addonStruct.Items(1:end);
    dlgstruct.EmbeddedButtonSet={'Help','Apply'};
    dlgstruct.SmartApply=true;




    function[addonStruct]=loc_createDialogForTask(this)


        addonStruct=[];
        if isempty(this.MAObj)
            return
        end

        hmdlAdvCheck=this.MAObj.CheckCellArray{this.MACIndex};


        groupRowIndex=1;


        AnalysisGroup.Type='group';
        AnalysisGroup.Name=this.DisplayName;
        if(this.SupportsEditTime)
            AnalysisGroup.Name=[AnalysisGroup.Name,' ',DAStudio.message('ModelAdvisor:engine:EditTimeSupportedCheck')];
        end


        if~strcmp(hmdlAdvCheck.CallbackContext,'None')
            AnalysisGroup.Name=[AnalysisGroup.Name,' (',DAStudio.message('Simulink:tools:PrefixForCompileCheck'),'',DAStudio.message('Simulink:tools:MATriggerUpdateDiagram'),') '];
        end
        AnalysisGroup.RowSpan=[groupRowIndex,groupRowIndex];
        AnalysisGroup.ColSpan=[1,10];

        row_ind=1;
        AnalyzeItems={};


        DisplayNameMsg.Name=[DAStudio.message('Simulink:tools:MADisplayName'),': '];
        DisplayNameMsg.Type='text';
        DisplayNameMsg.Tag='text_DisplayNameMsg';
        DisplayNameMsg.WordWrap=true;
        DisplayNameMsg.RowSpan=[row_ind,row_ind];
        DisplayNameMsg.ColSpan=[1,2];
        AnalyzeItems{end+1}=DisplayNameMsg;
        DisplayName.Type='edit';
        DisplayName.Tag='edit_DisplayName';
        DisplayName.Alignment=0;
        DisplayName.RowSpan=[row_ind,row_ind];
        DisplayName.ColSpan=[4,10];



        DisplayName.MatlabMethod='handleCheckEvent';
        DisplayName.MatlabArgs={this,'%tag','%dialog'};


        DisplayName.Value=this.DisplayName;
        AnalyzeItems{end+1}=DisplayName;

        row_ind=row_ind+1;
        emptymsg1.Name='     ';
        emptymsg1.Type='text';
        emptymsg1.Tag='text_emptymsg1';
        emptymsg1.WordWrap=true;
        emptymsg1.RowSpan=[row_ind,row_ind];
        emptymsg1.ColSpan=[1,10];
        AnalyzeItems{end+1}=emptymsg1;


        row_ind=row_ind+1;
        WfDesMsg.Name=[DAStudio.message('ModelAdvisor:engine:CheckInstanceID'),': '];
        WfDesMsg.Type='text';
        WfDesMsg.Tag='text_CheckInstanceID';
        WfDesMsg.WordWrap=true;
        WfDesMsg.RowSpan=[row_ind,row_ind];
        WfDesMsg.ColSpan=[1,2];
        AnalyzeItems{end+1}=WfDesMsg;
        WfDes.Type='text';
        WfDes.Name=this.ID;
        WfDes.WordWrap=true;
        WfDes.RowSpan=[row_ind,row_ind];
        WfDes.ColSpan=[4,10];
        AnalyzeItems{end+1}=WfDes;

        row_ind=row_ind+1;
        emptymsg2.Name='     ';
        emptymsg2.Type='text';
        emptymsg2.Tag='text_emptymsg1.1';
        emptymsg2.WordWrap=true;
        emptymsg2.RowSpan=[row_ind,row_ind];
        emptymsg2.ColSpan=[1,10];
        AnalyzeItems{end+1}=emptymsg2;


        row_ind=row_ind+1;
        WfDesMsg.Name=[DAStudio.message('Simulink:tools:MACheckTitle'),': '];
        WfDesMsg.Type='text';
        WfDesMsg.Tag='text_WfDesMsg';
        WfDesMsg.WordWrap=true;
        WfDesMsg.RowSpan=[row_ind,row_ind];
        WfDesMsg.ColSpan=[1,2];
        AnalyzeItems{end+1}=WfDesMsg;
        WfDes.Type='text';
        WfDes.Name=hmdlAdvCheck.Title;
        WfDes.WordWrap=true;
        WfDes.RowSpan=[row_ind,row_ind];
        WfDes.ColSpan=[4,10];
        AnalyzeItems{end+1}=WfDes;

        row_ind=row_ind+1;
        emptymsg2.Name='     ';
        emptymsg2.Type='text';
        emptymsg2.Tag='text_emptymsg2';
        emptymsg2.WordWrap=true;
        emptymsg2.RowSpan=[row_ind,row_ind];
        emptymsg2.ColSpan=[1,10];
        AnalyzeItems{end+1}=emptymsg2;


        row_ind=row_ind+1;
        checkIDMsg.Name=[DAStudio.message('Simulink:tools:MACheckID'),': '];
        checkIDMsg.Type='text';
        checkIDMsg.Tag='text_checkIDMsg';
        checkIDMsg.WordWrap=true;
        checkIDMsg.RowSpan=[row_ind,row_ind];
        checkIDMsg.ColSpan=[1,2];
        AnalyzeItems{end+1}=checkIDMsg;
        checkID.Type='text';
        checkID.Name=hmdlAdvCheck.ID;
        checkID.WordWrap=true;
        checkID.RowSpan=[row_ind,row_ind];
        checkID.ColSpan=[4,10];
        AnalyzeItems{end+1}=checkID;

        row_ind=row_ind+1;
        emptymsg3.Name='     ';
        emptymsg3.Type='text';
        emptymsg3.Tag='text_emptymsg3';
        emptymsg3.WordWrap=true;
        emptymsg3.RowSpan=[row_ind,row_ind];
        emptymsg3.ColSpan=[1,10];
        AnalyzeItems{end+1}=emptymsg3;


        row_ind=row_ind+1;
        checkTitleTipsMsg.Name=[DAStudio.message('ModelAdvisor:engine:Description'),': '];
        checkTitleTipsMsg.Type='text';
        checkTitleTipsMsg.Tag='text_checkTitleTipsMsg';
        checkTitleTipsMsg.WordWrap=true;
        checkTitleTipsMsg.RowSpan=[row_ind,row_ind];
        checkTitleTipsMsg.ColSpan=[1,2];
        AnalyzeItems{end+1}=checkTitleTipsMsg;
        checkTitleTips.Type='text';
        checkTitleTips.Name=hmdlAdvCheck.TitleTips;
        checkTitleTips.WordWrap=true;
        checkTitleTips.RowSpan=[row_ind,row_ind];
        checkTitleTips.ColSpan=[4,10];
        AnalyzeItems{end+1}=checkTitleTips;

        row_ind=row_ind+1;
        emptymsg4.Name='     ';
        emptymsg4.Type='text';
        emptymsg4.Tag='text_emptymsg4';
        emptymsg4.WordWrap=true;
        emptymsg4.RowSpan=[row_ind,row_ind];
        emptymsg4.ColSpan=[1,10];
        AnalyzeItems{end+1}=emptymsg4;


        row_ind=row_ind+1;
        checkLicenseMsg.Name=[DAStudio.message('Simulink:tools:MAProductAssociation'),': '];
        checkLicenseMsg.Type='text';
        checkLicenseMsg.Tag='text_checkLicenseMsg';
        checkLicenseMsg.WordWrap=true;
        checkLicenseMsg.RowSpan=[row_ind,row_ind];
        checkLicenseMsg.ColSpan=[1,2];
        AnalyzeItems{end+1}=checkLicenseMsg;
        checkLicense.Type='text';
        licenseString='Simulink';
        for i=1:length(hmdlAdvCheck.LicenseName)
            licenseString=[licenseString,'; ',loc_license_to_product(hmdlAdvCheck.LicenseName{i})];%#ok<AGROW>
        end
        checkLicense.Name=licenseString;
        checkLicense.RowSpan=[row_ind,row_ind];
        checkLicense.ColSpan=[4,10];
        AnalyzeItems{end+1}=checkLicense;

        row_ind=row_ind+1;
        emptymsg5.Name='     ';
        emptymsg5.Type='text';
        emptymsg5.Tag='text_emptymsg5';
        emptymsg5.WordWrap=true;
        emptymsg5.RowSpan=[row_ind,row_ind];
        emptymsg5.ColSpan=[1,10];
        AnalyzeItems{end+1}=emptymsg5;

        needInsertStretchTextboxInlieuofBlockType=true;
        if~isempty(this.InputParameters)
            row_ind=row_ind+1;
            InputParamsDlg.Type='group';
            InputParamsDlg.Name=DAStudio.message('Simulink:tools:MAInputParameters');
            InputParamsDlg.Flat=false;
            InputParamsDlg.RowSpan=[row_ind,row_ind];
            InputParamsDlg.ColSpan=[1,10];
            InputParamsDlg.LayoutGrid=hmdlAdvCheck.InputParametersLayoutGrid;
            InputParamsDlg.RowStretch=ones(1,InputParamsDlg.LayoutGrid(1));
            InputParamsDlg.ColStretch=ones(1,InputParamsDlg.LayoutGrid(2));
            InputParamsDlg.Items={};
            for i=1:length(this.InputParameters)

                curParam=this.InputParameters{i};
                curParamItem=[];
                curParamItem.RowSpan=curParam.RowSpan;
                curParamItem.ColSpan=curParam.ColSpan;
                curParamItem.Name=curParam.Name;
                curParamItem.Enabled=curParam.Enable;
                curParamItem.Tag=['InputParameters_',num2str(i)];
                switch(curParam.Type)
                case 'Bool'
                    curParamItem.Type='checkbox';
                    curParamItem.Value=curParam.Value;
                case 'String'
                    curParamItem.Type='edit';
                    curParamItem.Value=curParam.Value;
                case 'Enum'
                    curParamItem.Type='combobox';
                    curParamItem.Value=curParam.Value;
                    curParamItem.Entries=curParam.Entries;
                case 'ComboBox'
                    curParamItem.Type='combobox';
                    curParamItem.Value=curParam.Value;
                    curParamItem.Entries=curParam.Entries;
                    curParamItem.Editable=true;
                case 'RadioButton'
                    curParamItem.Type='radiobutton';
                    curParamItem.Value=curParam.Value;
                    curParamItem.Entries=curParam.Entries;
                case 'PushButton'
                    curParamItem.Name=curParam.Name;
                    curParamItem.Type='pushbutton';
                    curParamItem.Value=curParam.Value;
                    curParamItem.Enabled=false;
                case 'Number'
                    curParamItem.Type='edit';
                    curParamItem.Value=num2str(curParam.Value);
                case 'Table'
                    curParamItem.Type='edit';
                    curParamItem.Value='Editting of table is not supported.';
                    curParamItem.Editable=false;
                case{'BlockType','BlockTypeWithParameter'}
                    needInsertStretchTextboxInlieuofBlockType=false;
                    curParamItem=Advisor.Utils.createDialogSchemaForInputParamBlockTable(this,curParam.Type,'MA',curParamItem,curParam,i);
                case 'BlockConstraint'
                    curParamItem.Type='edit';
                    curParamItem.Value=curParam.Value;
                otherwise
                    DAStudio.error('Simulink:tools:MAUnsupportedInputParamType');
                end
                if ismember(curParam.Type,{'BlockType','BlockTypeWithParameter'})

                else



                    curParamItem.MatlabMethod='handleCheckEvent';
                    curParamItem.MatlabArgs={this,'%tag','%dialog'};
                end
                curParamItem.ToolTip=curParam.Description;
                InputParamsDlg.Items{end+1}=curParamItem;
            end
            AnalyzeItems{end+1}=InputParamsDlg;
        end

        if needInsertStretchTextboxInlieuofBlockType




            row_ind=row_ind+1;
            emptymsg1.Name='     ';
            emptymsg1.Type='text';
            emptymsg1.Tag='text_emptymsg1';
            emptymsg1.WordWrap=true;
            emptymsg1.RowSpan=[row_ind,row_ind];
            emptymsg1.ColSpan=[1,10];
            AnalyzeItems{end+1}=emptymsg1;
        end

        AnalysisGroup.LayoutGrid=[row_ind,10];
        AnalysisGroup.RowStretch=[zeros(1,row_ind-1),1];
        AnalysisGroup.ColStretch=[0,0,0,1,1,1,1,1,1,1];
        AnalysisGroup.Items=AnalyzeItems;

        addonStruct.Items={AnalysisGroup};
        addonStruct.RowStretch=1;
        addonStruct.LayoutGrid=[groupRowIndex,10];
        addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

        addonStruct.DialogTitle=this.DisplayName;



        function[addonStruct]=loc_createDialogForStubNode(this)


            groupRowIndex=1;


            AnalysisGroup.Type='group';
            AnalysisGroup.Name=this.DisplayName;
            AnalysisGroup.RowSpan=[groupRowIndex,groupRowIndex];
            AnalysisGroup.ColSpan=[1,10];

            row_ind=1;
            AnalyzeItems={};


            DisplayNameMsg.Name=[DAStudio.message('Simulink:tools:MADisplayName'),': '];
            DisplayNameMsg.Type='text';
            DisplayNameMsg.Tag='text_DisplayNameMsg';
            DisplayNameMsg.WordWrap=true;
            DisplayNameMsg.RowSpan=[row_ind,row_ind];
            DisplayNameMsg.ColSpan=[1,2];
            AnalyzeItems{end+1}=DisplayNameMsg;
            DisplayName.Type='edit';
            DisplayName.Tag='edit_DisplayName';
            DisplayName.Alignment=0;
            DisplayName.RowSpan=[row_ind,row_ind];
            DisplayName.ColSpan=[4,10];



            DisplayName.MatlabMethod='handleCheckEvent';
            DisplayName.MatlabArgs={this,'%tag','%dialog'};

            DisplayName.Value=this.DisplayName;
            DisplayName.Enabled=false;
            AnalyzeItems{end+1}=DisplayName;

            row_ind=row_ind+1;
            emptymsg1.Name='     ';
            emptymsg1.Type='text';
            emptymsg1.Tag='text_emptymsg1';
            emptymsg1.WordWrap=true;
            emptymsg1.RowSpan=[row_ind,row_ind];
            emptymsg1.ColSpan=[1,10];
            AnalyzeItems{end+1}=emptymsg1;


            row_ind=row_ind+1;
            WfDesMsg.Name=[DAStudio.message('Simulink:tools:MACheckTitle'),': '];
            WfDesMsg.Type='text';
            WfDesMsg.Tag='text_WfDesMsg';
            WfDesMsg.WordWrap=true;
            WfDesMsg.RowSpan=[row_ind,row_ind];
            WfDesMsg.ColSpan=[1,2];
            AnalyzeItems{end+1}=WfDesMsg;
            WfDes.Type='text';
            WfDes.Name=DAStudio.message('Simulink:tools:MAMissCorrespondCheck',this.MAC);
            WfDes.WordWrap=true;
            WfDes.RowSpan=[row_ind,row_ind];
            WfDes.ColSpan=[4,10];
            AnalyzeItems{end+1}=WfDes;

            row_ind=row_ind+1;
            emptymsg2.Name='     ';
            emptymsg2.Type='text';
            emptymsg2.Tag='text_emptymsg2';
            emptymsg2.WordWrap=true;
            emptymsg2.RowSpan=[row_ind,row_ind];
            emptymsg2.ColSpan=[1,10];
            AnalyzeItems{end+1}=emptymsg2;


            row_ind=row_ind+1;
            checkIDMsg.Name=[DAStudio.message('Simulink:tools:MACheckID'),': '];
            checkIDMsg.Type='text';
            checkIDMsg.Tag='text_checkIDMsg';
            checkIDMsg.WordWrap=true;
            checkIDMsg.RowSpan=[row_ind,row_ind];
            checkIDMsg.ColSpan=[1,2];
            AnalyzeItems{end+1}=checkIDMsg;
            checkID.Type='text';
            checkID.Name=this.MAC;
            checkID.WordWrap=true;
            checkID.RowSpan=[row_ind,row_ind];
            checkID.ColSpan=[4,10];
            AnalyzeItems{end+1}=checkID;

            row_ind=row_ind+1;
            emptymsg3.Name='     ';
            emptymsg3.Type='text';
            emptymsg3.Tag='text_emptymsg3';
            emptymsg3.WordWrap=true;
            emptymsg3.RowSpan=[row_ind,row_ind];
            emptymsg3.ColSpan=[1,10];
            AnalyzeItems{end+1}=emptymsg3;


            row_ind=row_ind+1;
            checkTitleTipsMsg.Name=[DAStudio.message('ModelAdvisor:engine:Description'),': '];
            checkTitleTipsMsg.Type='text';
            checkTitleTipsMsg.Tag='text_checkTitleTipsMsg';
            checkTitleTipsMsg.WordWrap=true;
            checkTitleTipsMsg.RowSpan=[row_ind,row_ind];
            checkTitleTipsMsg.ColSpan=[1,2];
            AnalyzeItems{end+1}=checkTitleTipsMsg;
            checkTitleTips.Type='text';
            checkTitleTips.Name=DAStudio.message('Simulink:tools:MAMissCorrespondCheck',this.MAC);
            checkTitleTips.WordWrap=true;
            checkTitleTips.RowSpan=[row_ind,row_ind];
            checkTitleTips.ColSpan=[4,10];
            AnalyzeItems{end+1}=checkTitleTips;

            row_ind=row_ind+1;
            emptymsg4.Name='     ';
            emptymsg4.Type='text';
            emptymsg4.Tag='text_emptymsg4';
            emptymsg4.WordWrap=true;
            emptymsg4.RowSpan=[row_ind,row_ind];
            emptymsg4.ColSpan=[1,10];
            AnalyzeItems{end+1}=emptymsg4;


            row_ind=row_ind+1;
            checkLicenseMsg.Name=[DAStudio.message('Simulink:tools:MAProductAssociation'),': '];
            checkLicenseMsg.Type='text';
            checkLicenseMsg.Tag='text_checkLicenseMsg';
            checkLicenseMsg.WordWrap=true;
            checkLicenseMsg.RowSpan=[row_ind,row_ind];
            checkLicenseMsg.ColSpan=[1,2];
            AnalyzeItems{end+1}=checkLicenseMsg;
            checkLicense.Type='text';
            licenseString=DAStudio.message('Simulink:tools:MAMissCorrespondCheck',this.MAC);
            checkLicense.Name=licenseString;
            checkLicense.RowSpan=[row_ind,row_ind];
            checkLicense.ColSpan=[4,10];
            AnalyzeItems{end+1}=checkLicense;

            row_ind=row_ind+1;
            emptymsg5.Name='     ';
            emptymsg5.Type='text';
            emptymsg5.Tag='text_emptymsg5';
            emptymsg5.WordWrap=true;
            emptymsg5.RowSpan=[row_ind,row_ind];
            emptymsg5.ColSpan=[1,10];
            AnalyzeItems{end+1}=emptymsg5;


            AnalysisGroup.LayoutGrid=[row_ind,10];
            AnalysisGroup.RowStretch=[zeros(1,row_ind-1),1];
            AnalysisGroup.ColStretch=[0,0,0,1,1,1,1,1,1,1];
            AnalysisGroup.Items=AnalyzeItems;

            addonStruct.Items={AnalysisGroup};
            addonStruct.RowStretch=1;
            addonStruct.LayoutGrid=[groupRowIndex,10];
            addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

            addonStruct.DialogTitle=this.DisplayName;




            function[addonStruct]=loc_createDialogForGroup(this)


                groupRowIndex=1;


                AnalysisGroup.Type='group';
                AnalysisGroup.Name=DAStudio.message('Simulink:tools:MAAnalysis');
                AnalysisGroup.Name=this.DisplayName;
                AnalysisGroup.RowSpan=[groupRowIndex,groupRowIndex];
                AnalysisGroup.ColSpan=[1,10];

                row_ind=1;
                AnalyzeItems={};


                DisplayName.Name=[DAStudio.message('Simulink:tools:MADisplayName'),': '];
                DisplayName.Type='edit';
                DisplayName.Tag='edit_DisplayName';
                DisplayName.Alignment=0;
                DisplayName.RowSpan=[row_ind,row_ind];
                DisplayName.ColSpan=[1,10];



                DisplayName.MatlabMethod='handleCheckEvent';
                DisplayName.MatlabArgs={this,'%tag','%dialog'};

                DisplayName.Value=this.DisplayName;
                if this.Protected&&loc_underByPByTFolder(this)
                    DisplayName.Enabled=false;
                    DisplayName.ToolTip=DAStudio.message('Simulink:tools:MACENotRenameFolder');
                end
                AnalyzeItems{end+1}=DisplayName;

                row_ind=row_ind+1;
                emptymsg2.Name='     ';
                emptymsg2.Type='text';
                emptymsg2.Tag='text_emptymsg1.1';
                emptymsg2.WordWrap=true;
                emptymsg2.RowSpan=[row_ind,row_ind];
                emptymsg2.ColSpan=[1,10];
                AnalyzeItems{end+1}=emptymsg2;



                row_ind=row_ind+1;
                WfDesMsg.Name=[DAStudio.message('ModelAdvisor:engine:CheckGroupID'),': '];
                WfDesMsg.Type='text';
                WfDesMsg.Tag='text_CheckGroupID';
                WfDesMsg.WordWrap=true;
                WfDesMsg.RowSpan=[row_ind,row_ind];
                WfDesMsg.ColSpan=[1,2];
                AnalyzeItems{end+1}=WfDesMsg;
                WfDes.Type='text';
                WfDes.Name=this.ID;
                WfDes.WordWrap=true;
                WfDes.RowSpan=[row_ind,row_ind];
                WfDes.ColSpan=[4,10];
                AnalyzeItems{end+1}=WfDes;


                if~isempty(this.InputParameters)
                    row_ind=row_ind+1;
                    InputParamsDlg.Type='group';
                    InputParamsDlg.Name=DAStudio.message('Simulink:tools:MAInputParameters');
                    InputParamsDlg.Flat=false;
                    InputParamsDlg.RowSpan=[row_ind,row_ind];
                    InputParamsDlg.ColSpan=[1,10];
                    InputParamsDlg.LayoutGrid=this.InputParametersLayoutGrid;
                    InputParamsDlg.RowStretch=ones(1,InputParamsDlg.LayoutGrid(1));
                    InputParamsDlg.ColStretch=ones(1,InputParamsDlg.LayoutGrid(2));
                    InputParamsDlg.Items={};
                    for i=1:length(this.InputParameters)

                        curParam=this.InputParameters{i};
                        curParamItem=[];
                        curParamItem.RowSpan=curParam.RowSpan;
                        curParamItem.ColSpan=curParam.ColSpan;
                        curParamItem.Name=curParam.Name;
                        curParamItem.Enabled=curParam.Enable;
                        switch(curParam.Type)
                        case 'Bool'
                            curParamItem.Type='checkbox';
                        case 'String'
                            curParamItem.Type='edit';
                        case 'Enum'
                            curParamItem.Type='combobox';
                            curParamItem.Entries=curParam.Entries;
                        case 'ComboBox'
                            curParamItem.Type='combobox';
                            curParamItem.Entries=curParam.Entries;
                            curParamItem.Editable=true;
                        case 'PushButton'
                            curParamItem.Name=curParam.Name;
                            curParamItem.Type='pushbutton';
                            curParamItem.Enabled=false;
                        otherwise
                            DAStudio.error('Simulink:tools:MAUnsupportedInputParamType');
                        end
                        curParamItem.Tag=['InputParameters_',num2str(i)];



                        curParamItem.MatlabMethod='handleCheckEvent';
                        curParamItem.MatlabArgs={this,'%tag','%dialog'};

                        curParamItem.Value=curParam.Value;

                        curParamItem.ToolTip=curParam.Description;
                        InputParamsDlg.Items{end+1}=curParamItem;
                    end
                    AnalyzeItems{end+1}=InputParamsDlg;
                end


                AnalysisGroup.LayoutGrid=[row_ind,10];
                AnalysisGroup.RowStretch=[zeros(1,row_ind-1),1];
                AnalysisGroup.ColStretch=[0,0,0,1,1,1,1,1,1,1];
                AnalysisGroup.Items=AnalyzeItems;

                addonStruct.Items={AnalysisGroup};
                addonStruct.RowStretch=1;
                addonStruct.LayoutGrid=[groupRowIndex,10];
                addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

                addonStruct.DialogTitle=this.DisplayName;

                function underSystemFolder=loc_underByPByTFolder(this)
                    underSystemFolder=false;
                    itself=this;
                    child=[];
                    while isa(itself,'ModelAdvisor.ConfigUI')&&~isempty(itself.ParentObj)
                        child=itself;
                        itself=itself.ParentObj;
                    end
                    if isa(child,'ModelAdvisor.ConfigUI')
                        newName=child.DisplayName;
                        if strcmp(newName,'By Product')||strcmp(newName,'By Task')||...
                            strcmp(newName,DAStudio.message('Simulink:tools:MAByProduct'))||strcmp(newName,DAStudio.message('Simulink:tools:MAByTask'))
                            underSystemFolder=true;
                        end
                    end


                    function[addonStruct]=loc_createDialogForRoot(this)

                        if(~isempty(this.MAObj.Toolbar)&&isfield(this.MAObj.Toolbar,'viewComboBoxWidget')&&this.MAObj.Toolbar.viewComboBoxWidget.getCurrentItem==1)
                            [addonStruct]=loc_createDialogForRoot_EditTimeView(this);
                            return;
                        end

                        WorkflowGroup.Type='group';
                        WorkflowGroup.Name=DAStudio.message('Simulink:tools:MAWorkflow');
                        WorkflowGroup.RowSpan=[1,1];
                        WorkflowGroup.ColSpan=[1,10];

                        row=1;
                        emptymsg0.Name='     ';
                        emptymsg0.Type='text';
                        emptymsg0.Tag='text_emptymsg0';
                        emptymsg0.WordWrap=true;
                        emptymsg0.RowSpan=[row,row];
                        emptymsg0.ColSpan=[1,10];

                        row=row+1;
                        Line0.Name=DAStudio.message('Simulink:tools:MACERootMsg0');
                        Line0.Type='text';
                        Line0.Tag='text_line0';
                        Line0.WordWrap=true;


                        Line0.RowSpan=[row,row];
                        Line0.ColSpan=[1,10];

                        row=row+1;
                        emptymsg1.Name='     ';
                        emptymsg1.Type='text';
                        emptymsg1.Tag='text_emptymsg1';
                        emptymsg1.WordWrap=true;
                        emptymsg1.RowSpan=[row,row];
                        emptymsg1.ColSpan=[1,10];

                        row=row+1;
                        number1.Name=['1. ',DAStudio.message('Simulink:tools:MACERootMsg1')];
                        number1.Type='text';
                        number1.Tag='text_number1';
                        number1.WordWrap=true;
                        number1.Enabled=false;

                        number1.FontPointSize=13;
                        number1.RowSpan=[row,row];
                        number1.ColSpan=[1,10];

                        row=row+2;
                        emptymsg2.Name='     ';
                        emptymsg2.Type='text';
                        emptymsg2.Tag='text_emptymsg2';
                        emptymsg2.WordWrap=true;
                        emptymsg2.RowSpan=[row,row];
                        emptymsg2.ColSpan=[1,10];

                        row=row+1;
                        number2.Name=['2. ',DAStudio.message('Simulink:tools:MACERootMsg2')];
                        number2.Type='text';
                        number2.Tag='text_number2';
                        number2.WordWrap=true;

                        number2.FontPointSize=13;
                        number2.RowSpan=[row,row];
                        number2.ColSpan=[1,10];

                        row=row+2;
                        emptymsg3.Name='     ';
                        emptymsg3.Type='text';
                        emptymsg3.Tag='text_emptymsg3';
                        emptymsg3.WordWrap=true;
                        emptymsg3.RowSpan=[row,row];
                        emptymsg3.ColSpan=[1,10];

                        row=row+1;
                        number3.Name=['3. ',DAStudio.message('Simulink:tools:MACERootMsg3')];
                        number3.Type='text';
                        number3.Tag='text_number3';
                        number3.WordWrap=true;

                        number3.FontPointSize=13;
                        number3.RowSpan=[row,row];
                        number3.ColSpan=[1,10];

                        row=row+2;
                        emptymsg4.Name='     ';
                        emptymsg4.Type='text';
                        emptymsg4.Tag='text_emptymsg4';
                        emptymsg4.WordWrap=true;
                        emptymsg4.RowSpan=[row,row];
                        emptymsg4.ColSpan=[1,10];

                        row=row+1;
                        number4.Name=['4. ',DAStudio.message('Simulink:tools:MACERootMsg4')];
                        number4.Type='text';
                        number4.Tag='text_number4';
                        number4.WordWrap=true;
                        number4.Enabled=false;

                        number4.FontPointSize=13;
                        number4.RowSpan=[row,row];
                        number4.ColSpan=[1,10];

                        row=row+1;
                        emptymsg5.Name='     ';
                        emptymsg5.Type='text';
                        emptymsg5.Tag='text_emptymsg5';
                        emptymsg5.WordWrap=true;
                        emptymsg5.RowSpan=[row,row];
                        emptymsg5.ColSpan=[1,10];

                        WorkflowGroup.Items={number1,number2,number3,number4,Line0,emptymsg0,emptymsg1,emptymsg2,emptymsg3,emptymsg4,emptymsg5};
                        WorkflowGroup.LayoutGrid=[row+1,10];
                        WorkflowGroup.RowStretch=[zeros(1,row),1];
                        addonStruct.Items={WorkflowGroup};
                        addonStruct.LayoutGrid=[2,10];
                        addonStruct.RowStretch=[0,1];
                        addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

                        function[addonStruct]=loc_createDialogForRoot_EditTimeView(~)

                            EditTimeInstructionsGroup.Type='group';
                            EditTimeInstructionsGroup.Name=DAStudio.message('ModelAdvisor:engine:MACERoot_EditTimeView');
                            EditTimeInstructionsGroup.RowSpan=[1,1];
                            EditTimeInstructionsGroup.ColSpan=[1,10];

                            row=1;
                            emptymsg0.Name=DAStudio.message('ModelAdvisor:engine:MACERoot_EditTimeViewDescription');
                            emptymsg0.Type='text';
                            emptymsg0.Tag='text_emptymsg0';
                            emptymsg0.WordWrap=true;
                            emptymsg0.RowSpan=[row,row];
                            emptymsg0.ColSpan=[1,10];

                            row=row+1;
                            Line0.Name='';
                            Line0.Type='text';
                            Line0.Tag='text_line0';
                            Line0.WordWrap=true;


                            Line0.RowSpan=[row,row];
                            Line0.ColSpan=[1,10];

                            row=row+1;
                            emptymsg1.Name=DAStudio.message('ModelAdvisor:engine:MACERoot_EditTimeViewNote');
                            emptymsg1.Type='text';
                            emptymsg1.Tag='text_emptymsg1';
                            emptymsg1.WordWrap=true;
                            emptymsg1.RowSpan=[row,row];
                            emptymsg1.ColSpan=[1,10];

                            row=row+1;
                            emptymsg2.Name=DAStudio.message('ModelAdvisor:engine:EdittimeView');
                            emptymsg2.Type='hyperlink';
                            emptymsg2.MatlabMethod='helpview';
                            emptymsg2.MatlabArgs={[docroot,'/slcheck/helptargets.map'],'slvnv_edittime'};
                            emptymsg2.Tag='text_emptymsg2';
                            emptymsg2.RowSpan=[row,row];
                            emptymsg2.ColSpan=[1,10];

                            EditTimeInstructionsGroup.Items={Line0,emptymsg0,emptymsg1,emptymsg2};
                            EditTimeInstructionsGroup.LayoutGrid=[row+1,10];
                            EditTimeInstructionsGroup.RowStretch=[zeros(1,row),1];
                            addonStruct.Items={EditTimeInstructionsGroup};
                            addonStruct.LayoutGrid=[2,10];
                            addonStruct.RowStretch=[0,1];
                            addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];


                            function[addonStruct]=loc_createDialogForLibraryRoot(~)

                                row=1;

                                row=row+1;
                                TipsGroup.Type='group';
                                TipsGroup.Name=DAStudio.message('ModelAdvisor:engine:Tips');
                                TipsGroup.RowSpan=[row,row];
                                TipsGroup.ColSpan=[1,10];

                                Line2.Name=DAStudio.message('Simulink:tools:MACELibRootNodeMsgLine1');
                                Line2.Type='text';
                                Line2.Tag='text_line2';
                                Line2.WordWrap=true;
                                Line2.RowSpan=[1,1];
                                Line2.ColSpan=[1,10];
                                TipsGroup.Items{1}=Line2;
                                TipsGroup.LayoutGrid=[1,10];

                                row=row+1;
                                emptymsg3.Name='     ';
                                emptymsg3.Type='text';
                                emptymsg3.Tag='text_emptymsg3';
                                emptymsg3.WordWrap=true;
                                emptymsg3.RowSpan=[row,row];
                                emptymsg3.ColSpan=[1,10];

                                addonStruct.Items={TipsGroup,emptymsg3};
                                addonStruct.LayoutGrid=[row+3,10];
                                addonStruct.RowStretch=[zeros(1,row+1),1,1];
                                addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];


                                function productName=loc_license_to_product(licenseName)
                                    switch lower(licenseName)
                                    case lower('Real-Time_Workshop')
                                        productName='Simulink Coder';
                                    case lower('RTW_Embedded_Coder')
                                        productName='Embedded Coder';
                                    case lower('SL_Verification_Validation')
                                        productName='Simulink Check';
                                    case lower('Fixed_Point_Toolbox')
                                        productName='Fixed-Point Toolbox';
                                    otherwise
                                        productName=licenseName;
                                    end
