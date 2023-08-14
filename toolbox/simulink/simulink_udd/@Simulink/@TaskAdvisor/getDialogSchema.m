function dlgstruct=getDialogSchema(this,name)%#ok<INUSD>



    row=1;

    if~isempty(this.CustomDialogSchema)
        [addonStruct]=this.CustomDialogSchema;

    elseif strncmp(this.ID,'com.mathworks.FPCA.',19)&&strcmp(this.Type,'Container')
        [addonStruct]=loc_createFPCAContainerNode(this);
    elseif strcmp(this.ID,'SysRoot')
        [addonStruct]=loc_createDialogForRoot(this);




    elseif strcmp(this.Type,'Container')
        [addonStruct]=loc_createTopNodeDialog(this,row);
    elseif this.MACIndex~=0

        [addonStruct]=loc_createDialogForMACheck(this);
    else
        addonStruct.Items={};
    end


    dlgstruct.DialogTitle=[this.DisplayName];
    dlgstruct.LayoutGrid=[6,10];
    dlgstruct.RowStretch=[0,0,0,0,0,1];
    dlgstruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];
    if isempty(this.HelpMethod)
        dlgstruct.HelpMethod='helpview';
        dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'model_advisor'};
    else
        dlgstruct.HelpMethod=this.HelpMethod;
        dlgstruct.HelpArgs=this.HelpArgs;
    end
    dlgstruct.Items={addonStruct.Items{1:end}};
    if strcmp(this.Type,'Task')
        dlgstruct.EmbeddedButtonSet={'Help','Apply'};
    else
        dlgstruct.EmbeddedButtonSet={'Help'};
    end
    dlgstruct.SmartApply=true;
    addOnFields=fieldnames(addonStruct);
    for i=1:length(addOnFields)
        if~strcmp(addOnFields{i},'Items')
            dlgstruct.(addOnFields{i})=addonStruct.(addOnFields{i});
        end
    end



    function[addonStruct]=loc_createDialogForRoot(this)

        row=1;
        emptymsg1.Name='     ';
        emptymsg1.Type='text';
        emptymsg1.Tag='text_emptymsg1';
        emptymsg1.WordWrap=true;
        emptymsg1.RowSpan=[row,row];
        emptymsg1.ColSpan=[1,10];

        row=row+1;
        Line1.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine1');
        Line1.Tag='text_line1';
        Line1.Type='text';
        Line1.WordWrap=true;
        Line1.RowSpan=[row,row];
        Line1.ColSpan=[1,10];

        row=row+1;
        emptymsg2.Name='     ';
        emptymsg2.Type='text';
        emptymsg2.Tag='text_emptymsg2';
        emptymsg2.WordWrap=true;
        emptymsg2.RowSpan=[row,row];
        emptymsg2.ColSpan=[1,10];

        row=row+1;
        Line2.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine2');
        Line2.Type='text';
        Line2.Tag='text_line2';
        Line2.WordWrap=true;
        Line2.RowSpan=[row,row];
        Line2.ColSpan=[1,10];

        row=row+1;
        emptymsg3.Name='     ';
        emptymsg3.Type='text';
        emptymsg3.Tag='text_emptymsg3';
        emptymsg3.WordWrap=true;
        emptymsg3.RowSpan=[row,row];
        emptymsg3.ColSpan=[1,10];

        row=row+1;
        Line3.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine3');
        Line3.Type='text';
        Line3.Tag='text_line3';
        Line3.WordWrap=true;
        Line3.RowSpan=[row,row];
        Line3.ColSpan=[1,10];

        row=row+1;
        emptymsg4.Name='     ';
        emptymsg4.Type='text';
        emptymsg4.Tag='text_emptymsg4';
        emptymsg4.WordWrap=true;
        emptymsg4.RowSpan=[row,row];
        emptymsg4.ColSpan=[1,10];

        row=row+1;
        Line4.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine4');
        Line4.Type='text';
        Line4.Tag='text_line4';
        Line4.WordWrap=true;
        Line4.RowSpan=[row,row];
        Line4.ColSpan=[1,10];

        row=row+1;
        emptymsg5.Name='     ';
        emptymsg5.Type='text';
        emptymsg5.Tag='text_emptymsg5';
        emptymsg5.WordWrap=true;
        emptymsg5.RowSpan=[row,row];
        emptymsg5.ColSpan=[1,10];

        row=row+1;
        Line5.Name=DAStudio.message('Simulink:tools:MARootNodeMsgLine5');
        Line5.Type='text';
        Line5.Tag='text_line5';
        Line5.WordWrap=true;
        Line5.RowSpan=[row,row];
        Line5.ColSpan=[1,10];

        row=row+1;
        emptymsg6.Name='     ';
        emptymsg6.Type='text';
        emptymsg6.Tag='text_emptymsg6';
        emptymsg6.WordWrap=true;
        emptymsg6.RowSpan=[row,row];
        emptymsg6.ColSpan=[1,10];

        row=row+1;
        LegendGroup.Type='group';
        LegendGroup.Name=DAStudio.message('Simulink:tools:MALegend');
        LegendGroup.RowSpan=[row,row+1];
        LegendGroup.ColSpan=[1,6];
        LegendGroup.LayoutGrid=[5,2];

        SelectedCheck.Name=DAStudio.message('Simulink:tools:MANotRunMsg');
        SelectedCheck.Type='text';
        SelectedCheck.Tag='text_SelectedCheck';
        SelectedCheck.WordWrap=true;
        SelectedCheck.RowSpan=[1,1];
        SelectedCheck.ColSpan=[2,2];
        LegendGroup.Items={SelectedCheck};
        selectedIcon.Type='image';
        selectedIcon.Tag='image_selectedIcon';
        selectedIcon.RowSpan=[1,1];
        selectedIcon.ColSpan=[1,1];
        imagepath=fullfile(matlabroot,'toolbox/simulink/simulink/modeladvisor/private/');
        selectedIcon.FilePath=fullfile(imagepath,'icon_task.png');
        LegendGroup.Items{end+1}=selectedIcon;

        PassedCheck.Name=DAStudio.message('Simulink:tools:MAPassedMsg');
        PassedCheck.Type='text';
        PassedCheck.Tag='text_PassedCheck';
        PassedCheck.WordWrap=true;
        PassedCheck.RowSpan=[2,2];
        PassedCheck.ColSpan=[2,2];
        LegendGroup.Items{end+1}=PassedCheck;
        passedIcon.Type='image';
        passedIcon.Tag='image_passedIcon';
        passedIcon.RowSpan=[2,2];
        passedIcon.ColSpan=[1,1];
        passedIcon.FilePath=fullfile(imagepath,'task_passed.png');
        LegendGroup.Items{end+1}=passedIcon;

        FailedCheck.Name=DAStudio.message('Simulink:tools:MAFailedMsg');
        FailedCheck.Type='text';
        FailedCheck.Tag='text_FailedCheck';
        FailedCheck.WordWrap=true;
        FailedCheck.RowSpan=[3,3];
        FailedCheck.ColSpan=[2,2];
        LegendGroup.Items{end+1}=FailedCheck;
        failedIcon.Type='image';
        failedIcon.Tag='image_failedIcon';
        failedIcon.RowSpan=[3,3];
        failedIcon.ColSpan=[1,1];
        failedIcon.FilePath=fullfile(imagepath,'task_failed.png');
        LegendGroup.Items{end+1}=failedIcon;

        WarnCheck.Name=DAStudio.message('Simulink:tools:MAWarning');
        WarnCheck.Type='text';
        WarnCheck.Tag='text_WarnCheck';
        WarnCheck.WordWrap=true;
        WarnCheck.RowSpan=[4,4];
        WarnCheck.ColSpan=[2,2];
        LegendGroup.Items{end+1}=WarnCheck;
        WarnIcon.Type='image';
        WarnIcon.Tag='image_WarnIcon';
        WarnIcon.RowSpan=[4,4];
        WarnIcon.ColSpan=[1,1];
        WarnIcon.FilePath=fullfile(imagepath,'task_warning.png');
        LegendGroup.Items{end+1}=WarnIcon;

        CompileCheck.Name=DAStudio.message('Simulink:tools:MARequiresCompileShort');
        CompileCheck.Type='text';
        CompileCheck.Tag='text_CompileCheck';
        CompileCheck.WordWrap=true;
        CompileCheck.RowSpan=[5,5];
        CompileCheck.ColSpan=[2,2];
        LegendGroup.Items{end+1}=CompileCheck;
        CompileFlag.Name=' ^ ';
        CompileFlag.Bold=1;
        CompileFlag.Type='text';
        CompileFlag.WordWrap=true;
        CompileFlag.RowSpan=[5,5];
        CompileFlag.ColSpan=[1,1];
        LegendGroup.Items{end+1}=CompileFlag;

        addonStruct.Items={Line1,Line2,Line3,Line4,Line5,emptymsg1,emptymsg2,emptymsg3,emptymsg4,emptymsg5,emptymsg6,LegendGroup};
        addonStruct.LayoutGrid=[row+3,10];
        addonStruct.RowStretch=[zeros(1,row+1),1,1];
        addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];



        function[addonStruct]=loc_createDialogForMACheck(this)

            hmdlAdvCheck=this.MAObj.CheckCellArray{this.MACIndex};


            groupRowIndex=1;


            AnalysisGroup.Type='group';
            AnalysisGroup.Name=DAStudio.message('Simulink:tools:MAAnalysis');
            if strcmp(hmdlAdvCheck.CallbackContext,'PostCompile')
                AnalysisGroup.Name=[AnalysisGroup.Name,' (^',DAStudio.message('Simulink:tools:MATriggerUpdateDiagram'),') '];
            end
            AnalysisGroup.RowSpan=[groupRowIndex,groupRowIndex];
            AnalysisGroup.ColSpan=[1,10];

            row_ind=1;
            AnalyzeItems={};


            if~isempty(hmdlAdvCheck)&&isprop(hmdlAdvCheck,'TitleTips')&&~isempty(hmdlAdvCheck.TitleTips)
                WfDes.Name=hmdlAdvCheck.TitleTips;
            else
                WfDes.Name=this.Help;
            end
            WfDes.Type='text';
            WfDes.Alignment=0;
            WfDes.WordWrap=true;
            WfDes.RowSpan=[row_ind,row_ind];
            WfDes.ColSpan=[1,10];
            AnalyzeItems{end+1}=WfDes;


            row_ind=row_ind+1;
            analyze.Name=DAStudio.message('Simulink:tools:MARunThisCheck');
            analyze.Tag='RunAdvisor';
            analyze.Type='pushbutton';
            analyze.RowSpan=[1,1];
            analyze.ColSpan=[1,2];
            analyze.Alignment=5;
            analyze.Enabled=this.Selected;
            analyze.DialogRefresh=true;
            analyze.ObjectMethod='runTaskAdvisor';
            analyze.MethodArgs={};
            analyze.ArgDataTypes={};
            analyzeVgrp.Type='group';
            analyzeVgrp.Name='';
            analyzeVgrp.Flat=true;
            analyzeVgrp.RowSpan=[row_ind,row_ind];
            analyzeVgrp.ColSpan=[1,10];
            analyzeVgrp.ColStretch=[0,0,1,1,1,1,1,1,1,1];
            analyzeVgrp.LayoutGrid=[1,10];
            analyzeVgrp.Items={analyze};
            AnalyzeItems{end+1}=analyzeVgrp;













            if~isempty(hmdlAdvCheck.InputParamsDlgCallback)
                row_ind=row_ind+1;

                InputParamsDlg=hmdlAdvCheck.InputParamsDlgCallback(this);
                if~isfield(InputParamsDlg,'RowSpan')
                    InputParamsDlg.RowSpan=[row_ind,row_ind];
                else
                    row_ind=row_ind+InputParamsDlg.RowSpan(2)-InputParamsDlg.RowSpan(1)-1;
                end
                if~isfield(InputParamsDlg,'ColSpan')
                    InputParamsDlg.ColSpan=[1,10];
                end
                AnalyzeItems{end+1}=InputParamsDlg;
            else
                if~isempty(hmdlAdvCheck.InputParameters)
                    row_ind=row_ind+1;
                    InputParamsDlg.Type='group';
                    InputParamsDlg.Name=DAStudio.message('Simulink:tools:MAInputParameters');
                    InputParamsDlg.Flat=false;
                    InputParamsDlg.RowSpan=[row_ind,row_ind];
                    InputParamsDlg.ColSpan=[1,10];
                    InputParamsDlg.LayoutGrid=hmdlAdvCheck.InputParametersLayoutGrid;
                    InputParamsDlg.RowStretch=zeros(1,InputParamsDlg.LayoutGrid(1));
                    InputParamsDlg.ColStretch=zeros(1,InputParamsDlg.LayoutGrid(2));
                    InputParamsDlg.Items={};
                    for i=1:length(hmdlAdvCheck.InputParameters)

                        curParam=hmdlAdvCheck.InputParameters{i};
                        curParamItem=[];
                        curParamItem.RowSpan=curParam.RowSpan;
                        curParamItem.ColSpan=curParam.ColSpan;
                        curParamItem.Name=curParam.Name;
                        switch(curParam.Type)
                        case 'Bool'
                            curParamItem.Type='checkbox';
                        case 'String'
                            curParamItem.Type='edit';
                        case 'Enum'
                            curParamItem.Type='combobox';
                            curParamItem.Entries=curParam.Entries;
                        case 'PushButton'
                            curParamItem.Name=curParam.Name;
                            curParamItem.Type='pushbutton';
                        otherwise
                            DAStudio.error('Simulink:tools:MAUnsupportedInputParamType');
                        end
                        curParamItem.Tag=['InputParameters_',num2str(i)];
                        curParamItem.ObjectMethod='handleCheckEvent';
                        curParamItem.MethodArgs={'%tag','%dialog'};
                        curParamItem.ArgDataTypes={'string','handle'};

                        if isfield(curParam,'Value')
                            curParamItem.Value=curParam.Value;
                        end
                        curParamItem.ToolTip=curParam.ToolTip;
                        InputParamsDlg.Items{end+1}=curParamItem;
                    end
                    AnalyzeItems{end+1}=InputParamsDlg;
                end
            end


            row_ind=row_ind+1;
            ResultMsgPanel.Type='panel';
            ResultMsgPanel.RowSpan=[row_ind,row_ind];
            ResultMsgPanel.ColSpan=[1,3];
            ResultMsgPanel.ColStretch=[0,0,0,0,0,1,1,1,1,1];
            ResultMsgPanel.LayoutGrid=[1,10];

            ResultMsg.Name=[DAStudio.message('Simulink:tools:MAResult'),':  '];
            ResultMsg.Type='text';
            ResultMsg.Alignment=5;
            ResultMsg.Tag='text_ResultMsg';
            ResultMsg.RowSpan=[1,1];
            ResultMsg.ColSpan=[1,1];
            ResultMsgPanel.Items{1}=ResultMsg;







            ResultIcon.Type='image';
            ResultIcon.RowSpan=[1,1];
            ResultIcon.ColSpan=[2,2];
            ResultIcon.Alignment=5;
            ResultIcon.FilePath=fullfile(matlabroot,this.getDisplayIcon);
            ResultMsgPanel.Items{end+1}=ResultIcon;

            switch(this.State)
            case 'None'
                overallstatusString=DAStudio.message('Simulink:tools:MANotRunMsg');
            case 'WaivedPass'
                overallstatusString=DAStudio.message('Simulink:tools:MAWaivedMsg');
            case 'Pass'
                overallstatusString=DAStudio.message('Simulink:tools:MAPassedMsg');
            case 'Fail'
                if hmdlAdvCheck.ErrorSeverity==0
                    overallstatusString=DAStudio.message('Simulink:tools:MAWarning');
                else
                    overallstatusString=DAStudio.message('Simulink:tools:MAFailedMsg');
                end
            otherwise
                overallstatusString='';
            end
            if~strcmp(this.Severity,'Advisory')
                overallstatusString=[overallstatusString,' (',DAStudio.message('Simulink:tools:MARequired'),')'];
            end
            ResultStatusString.Name=overallstatusString;
            ResultStatusString.Type='text';
            ResultStatusString.RowSpan=[1,1];
            ResultStatusString.ColSpan=[3,3];
            ResultMsgPanel.Items{end+1}=ResultStatusString;
            AnalyzeItems{end+1}=ResultMsgPanel;




















            row_ind=row_ind+1;









            if strcmp(this.State,'None')
                if this.Selected
                    summary.Text=DAStudio.message('Simulink:tools:MAPressRunThisCheck');
                else
                    summary.Text=DAStudio.message('Simulink:tools:MASelectThenPressRunThisCheck');
                end
            else
                summary.Text=this.MAObj.CheckCellArray{this.MACIndex}.ResultInHTML;
            end
            summary.Type='textbrowser';
            summary.Tag='ResultBrowser';
            summary.RowSpan=[row_ind,row_ind];
            summary.ColSpan=[1,10];
            summary.MinimumSize=[1,150];

            AnalyzeItems{end+1}=summary;

            AnalysisGroup.LayoutGrid=[row_ind,10];
            AnalysisGroup.RowStretch=[zeros(1,row_ind-1),1];
            AnalysisGroup.ColStretch=[0,0,0,1,1,1,1,1,1,1];
            AnalysisGroup.Items=AnalyzeItems;

            addonStruct.Items={AnalysisGroup};
            addonStruct.RowStretch=[1];


            if~isempty(hmdlAdvCheck.ListViewParameters)
                groupRowIndex=groupRowIndex+1;
                exploreGroup.Type='group';
                exploreGroup.Name=DAStudio.message('Simulink:tools:MAExploreResult');
                exploreGroup.RowSpan=[groupRowIndex,groupRowIndex];
                exploreGroup.ColSpan=[1,10];
                exploreGroup.LayoutGrid=[1,10];
                selectComboBox.Name=[DAStudio.message('Simulink:tools:MASelect'),':'];
                selectComboBox.Tag='ExploreSelectComboBox';
                selectComboBox.RowSpan=[1,1];
                selectComboBox.ColSpan=[1,4];
                selectComboBox.Type='combobox';
                selectComboBox.Entries={};
                for enumIdex=1:length(hmdlAdvCheck.ListViewParameters)
                    selectComboBox.Entries{end+1}=hmdlAdvCheck.ListViewParameters{enumIdex}.Name;
                end
                selectedListViewParamIndex=min(hmdlAdvCheck.SelectedListViewParamIndex,...
                length(hmdlAdvCheck.ListViewParameters));
                selectComboBox.Value=selectComboBox.Entries{selectedListViewParamIndex};
                selectComboBox.ObjectMethod='handleCheckEvent';
                selectComboBox.MethodArgs={'%tag','%dialog'};
                selectComboBox.ArgDataTypes={'string','handle'};

                dummyString1.Name='   ';
                dummyString1.Type='text';
                dummyString1.RowSpan=[1,1];
                dummyString1.ColSpan=[5,5];







                invokeListViewButton.Name=DAStudio.message('Simulink:tools:MAExploreSelection');
                invokeListViewButton.Tag='ListViewButton';
                invokeListViewButton.RowSpan=[1,1];
                invokeListViewButton.ColSpan=[6,7];
                invokeListViewButton.Type='pushbutton';
                invokeListViewButton.ObjectMethod='handleCheckEvent';
                invokeListViewButton.MethodArgs={'%tag','%dialog'};
                invokeListViewButton.ArgDataTypes={'string','handle'};
                if strcmp(this.State,'None')
                    invokeListViewButton.Enabled=false;
                end
                dummyString.Name=' ';
                dummyString.Type='text';
                dummyString.RowSpan=[1,1];
                dummyString.ColSpan=[8,10];


                exploreGroup.Items={selectComboBox,dummyString1,invokeListViewButton,dummyString};
                exploreGroup.RowStretch=[0];
                exploreGroup.ColStretch=[0,0,0,0,0,0,0,1,1,1];
                addonStruct.Items{end+1}=exploreGroup;
                addonStruct.RowStretch=[addonStruct.RowStretch,0];
            end


            if~isempty(hmdlAdvCheck.ActionCallbackHandle)
                groupRowIndex=groupRowIndex+1;
                ActionGroup.Type='group';
                ActionGroup.Name=DAStudio.message('Simulink:tools:MAAction');
                ActionGroup.RowSpan=[groupRowIndex,groupRowIndex];
                ActionGroup.ColSpan=[1,10];
                row_ind=1;


                actionDescriptionText.Name=hmdlAdvCheck.ActionDescription;
                actionDescriptionText.Type='text';
                actionDescriptionText.WordWrap=true;
                actionDescriptionText.RowSpan=[1,1];
                actionDescriptionText.ColSpan=[1,10];
                ActionGroup.Items{1}=actionDescriptionText;


                row_ind=row_ind+1;
                actionButton.Name=hmdlAdvCheck.ActionButtonName;
                actionButton.Tag='ActionButton';
                actionButton.Type='pushbutton';
                actionButton.RowSpan=[1,1];
                actionButton.ColSpan=[1,2];
                actionButton.Enabled=hmdlAdvCheck.ActionEnable;
                actionButton.DialogRefresh=true;
                actionButton.ObjectMethod='runAction';
                actionButton.MethodArgs={};
                actionButton.ArgDataTypes={};
                actVgrp.Type='group';
                actVgrp.Name='';
                actVgrp.Flat=true;
                actVgrp.RowSpan=[row_ind,row_ind];
                actVgrp.ColSpan=[1,10];
                actVgrp.ColStretch=[0,0,1,1,1,1,1,1,1,1];
                actVgrp.LayoutGrid=[1,10];
                actVgrp.Items={actionButton};
                ActionGroup.Items{end+1}=actVgrp;


                row_ind=row_ind+1;
                ActionResultMsg.Name=[DAStudio.message('Simulink:tools:MAResult'),':  '];
                ActionResultMsg.Type='text';
                ActionResultMsg.Alignment=5;
                ActionResultMsg.Tag='text_ActionResultMsg';
                ActionResultMsg.RowSpan=[row_ind,row_ind];
                ActionResultMsg.ColSpan=[1,1];
                ActionGroup.Items{end+1}=ActionResultMsg;


                row_ind=row_ind+1;








                actionResult.Text=this.MAObj.CheckCellArray{this.MACIndex}.ActionResultInHTML;
                actionResult.Type='textbrowser';
                actionResult.Tag='ActionResultBrowser';
                actionResult.RowSpan=[row_ind,row_ind];
                actionResult.ColSpan=[1,10];
                actionResult.MinimumSize=[1,150];

                ActionGroup.Items{end+1}=actionResult;

                ActionGroup.LayoutGrid=[row_ind,10];
                ActionGroup.RowStretch=[zeros(1,row_ind-1),1];

                addonStruct.Items{end+1}=ActionGroup;
                addonStruct.RowStretch=[addonStruct.RowStretch,0];
            end

            addonStruct.LayoutGrid=[groupRowIndex,10];
            addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

            if strcmp(this.DisplayName(1),'^')
                addonStruct.DialogTitle=this.DisplayName(2:end);
            else
                addonStruct.DialogTitle=this.DisplayName;
            end



            function[addonStruct]=loc_createDialogForMAContainer(this)
                currentRow=1;
                addonStruct.Items={};


















                if~strcmp(this.CheckBoxMode,'None')
                    select.Name='Selection';
                    select.Type='group';

                    select.RowSpan=[currentRow,currentRow];
                    select.ColSpan=[1,10];
                    topcheckbox.Type='checkbox';
                    topcheckbox.Name=DAStudio.message('Simulink:tools:MASelectAll');
                    topcheckbox.RowSpan=[1,1];
                    topcheckbox.ColSpan=[1,10];
                    topcheckbox.Enabled=true;
                    topcheckbox.Tag='CheckBox_All';
                    topcheckbox.ObjectMethod='handleCheckEvent';
                    topcheckbox.MethodArgs={'%tag','%dialog'};
                    topcheckbox.ArgDataTypes={'string','handle'};
                    topcheckbox.DialogRefresh=true;
                    [checkboxArray,masterSelectAll,totalRows]=loc_createCheckBoxForAllChildren(this,2);
                    if masterSelectAll
                        topcheckbox.Value=masterSelectAll;
                    end
                    select.LayoutGrid=[totalRows+1,10];
                    select.Items=[{topcheckbox},checkboxArray];
                    currentRow=currentRow+1;
                    addonStruct.Items{end+1}=select;
                end



                analyze.Name=DAStudio.message('Simulink:tools:MARunSelectedChecks');
                analyze.Type='pushbutton';
                analyze.Tag='RunAdvisor';
                analyze.RowSpan=[currentRow,currentRow];
                analyze.ColSpan=[1,4];
                analyze.Enabled=1;
                analyze.DialogRefresh=true;
                analyze.ObjectMethod='runTaskAdvisor';
                analyze.MethodArgs={};
                analyze.ArgDataTypes={};
                currentRow=currentRow+1;%#ok<NASGU>
                addonStruct.Items{end+1}=analyze;






                function addonStruct=loc_createTopNodeDialog(this,row)


                    struct.Name='tabcontainer';
                    struct.Type='tab';
                    struct.Tag='tabcontainer_struct';
                    struct.LayoutGrid=[1,10];
                    struct.RowSpan=[row,row];
                    struct.ColSpan=[1,10];


                    reportTab.Name=DAStudio.message('Simulink:tools:MAModelAdvisor');
                    reportTab.Tag='tab_reportTab';
                    reportTab.RowStretch=[0,1];


                    row=1;
                    genrptmsg1.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode3');
                    genrptmsg1.Type='text';
                    genrptmsg1.Tag='text_genrptmsg1';
                    genrptmsg1.WordWrap=true;
                    genrptmsg1.RowSpan=[row,row];
                    genrptmsg1.ColSpan=[1,10];

                    row=row+1;
                    genrptmsg2.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode3');
                    genrptmsg2.Type='text';
                    genrptmsg2.Tag='text_genrptmsg2';
                    genrptmsg2.WordWrap=true;
                    genrptmsg2.RowSpan=[row,row];
                    genrptmsg2.ColSpan=[1,10];

                    row=row+1;
                    genrptmsg3.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode3');
                    genrptmsg3.Type='text';
                    genrptmsg3.Tag='text_genrptmsg3';
                    genrptmsg3.WordWrap=true;
                    genrptmsg3.RowSpan=[row,row];
                    genrptmsg3.ColSpan=[1,10];

                    row=row+1;
                    genrptmsg4.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode3');
                    genrptmsg4.Type='text';
                    genrptmsg4.Tag='text_genrptmsg4';
                    genrptmsg4.WordWrap=true;
                    genrptmsg4.RowSpan=[row,row];
                    genrptmsg4.ColSpan=[1,10];

                    row=row+1;
                    emptymsg1.Name='     ';
                    emptymsg1.Type='text';
                    emptymsg1.Tag='text_emptymsg1';
                    emptymsg1.WordWrap=true;
                    emptymsg1.RowSpan=[row,row];
                    emptymsg1.ColSpan=[1,10];

                    MsgGroup.Type='group';
                    MsgGroup.Name='';
                    MsgGroup.Flat=true;
                    MsgGroup.RowSpan=[1,row];
                    MsgGroup.ColSpan=[1,10];
                    MsgGroup.LayoutGrid=[row,10];
                    MsgGroup.Items={genrptmsg1,genrptmsg2,genrptmsg3,genrptmsg4,emptymsg1};

                    row=row+1;
                    AnalysisGroup.Type='group';
                    AnalysisGroup.Name=DAStudio.message('Simulink:tools:MAAnalysis');
                    AnalysisGroup.RowSpan=[row,row];
                    AnalysisGroup.ColSpan=[1,10];
                    AnalysisGroup.ColStretch=zeros(1,10);
                    if isempty(this.Help)
                        AnalysisGroup.LayoutGrid=[2,10];
                    else
                        AnalysisGroup.LayoutGrid=[3,10];
                    end

                    grouprow=0;

                    if~isempty(this.Help)
                        grouprow=grouprow+1;
                        ContainerDescription.Name=this.Help;
                        ContainerDescription.Type='text';
                        ContainerDescription.Tag='text_ContainerDescription';
                        ContainerDescription.Alignment=0;
                        ContainerDescription.WordWrap=true;
                        ContainerDescription.RowSpan=[grouprow,grouprow];
                        ContainerDescription.ColSpan=[1,10];
                    end


                    grouprow=grouprow+1;
                    if~isempty(this.Help)
                        analyzebutton.Name=DAStudio.message('Simulink:tools:MARunSelectedChecks');
                        analyzebutton.Type='pushbutton';
                        analyzebutton.Tag='RunAdvisor';
                        analyzebutton.RowSpan=[1,1];
                        analyzebutton.ColSpan=[1,1];
                        analyzebutton.Alignment=5;
                        analyzebutton.Enabled=1;
                        analyzebutton.DialogRefresh=true;
                        analyzebutton.ObjectMethod='runTaskAdvisor';
                        analyzebutton.MethodArgs={};
                        analyzebutton.ArgDataTypes={};
                        analyzeVgrp.Type='group';
                        analyzeVgrp.Name='';
                        analyzeVgrp.Tag='group_analyzeVgrp';
                        analyzeVgrp.Flat=true;
                        analyzeVgrp.RowSpan=[grouprow,grouprow];
                        analyzeVgrp.ColSpan=[1,10];
                        analyzeVgrp.ColStretch=[0,0,1,1,1,1,1,1,1,1];
                        analyzeVgrp.LayoutGrid=[1,10];
                        analyzeVgrp.Items={analyzebutton};
                    else
                        analyzebutton.Name=DAStudio.message('Simulink:tools:MARunSelectedChecks');
                        analyzebutton.Type='pushbutton';
                        analyzebutton.Tag='RunAdvisor';
                        analyzebutton.RowSpan=[grouprow,grouprow];
                        analyzebutton.ColSpan=[1,1];
                        analyzebutton.Alignment=5;
                        analyzebutton.Enabled=1;
                        analyzebutton.DialogRefresh=true;
                        analyzebutton.ObjectMethod='runTaskAdvisor';
                        analyzebutton.MethodArgs={};
                        analyzebutton.ArgDataTypes={};
                    end

                    grouprow=grouprow+1;
                    launchrptcheckbox.Type='checkbox';
                    launchrptcheckbox.Name=DAStudio.message('Simulink:tools:MAShowRptAfterRun');
                    launchrptcheckbox.RowSpan=[grouprow,grouprow];
                    launchrptcheckbox.ColSpan=[1,1];
                    launchrptcheckbox.Enabled=true;
                    launchrptcheckbox.Tag='CheckBox_launchReport';
                    launchrptcheckbox.ObjectMethod='handleCheckEvent';
                    launchrptcheckbox.MethodArgs={'%tag','%dialog'};
                    launchrptcheckbox.ArgDataTypes={'string','handle'};
                    launchrptcheckbox.ObjectProperty='LaunchReport';
                    launchrptcheckbox.DialogRefresh=true;
                    if isempty(this.Help)
                        AnalysisGroup.Items={analyzebutton,launchrptcheckbox};
                    else
                        AnalysisGroup.Items={ContainerDescription,analyzeVgrp,launchrptcheckbox};
                    end

                    row=row+1;
                    emptymsg.Name='     ';
                    emptymsg.Type='text';
                    emptymsg.Tag='text_emptymsg';
                    emptymsg.WordWrap=true;
                    emptymsg.RowSpan=[row,row];
                    emptymsg.ColSpan=[1,10];

                    row=row+1;
                    LastReportGroup.Type='group';
                    LastReportGroup.Name=DAStudio.message('Simulink:tools:MALastReport');
                    LastReportGroup.RowSpan=[row,row];
                    LastReportGroup.ColSpan=[1,10];
                    LastReportGroup.ColStretch=zeros(1,10);

                    grouprow=1;
                    fromnodemsg.Name=[DAStudio.message('Simulink:tools:MAFromNode'),': '];
                    fromnodemsg.Type='text';
                    fromnodemsg.Tag='text_fromnodemsg';
                    fromnodemsg.WordWrap=true;
                    fromnodemsg.RowSpan=[grouprow,grouprow];
                    fromnodemsg.ColSpan=[1,1];

                    generateInfo=modeladvisorprivate('modeladvisorutil2','LoadGenerateInfo',this.MAObj);
                    if isfield(generateInfo,'fromTaskAdvisorNode')
                        nodenamemsg.Name=generateInfo.fromTaskAdvisorNode;
                    else
                        nodenamemsg.Name=DAStudio.message('Simulink:tools:MANotApplicable');
                    end
                    nodenamemsg.Type='text';
                    nodenamemsg.Tag='text_nodenamemsg';
                    nodenamemsg.WordWrap=true;
                    nodenamemsg.RowSpan=[grouprow,grouprow];
                    nodenamemsg.ColSpan=[2,10];

                    grouprow=grouprow+1;
                    rptmsg.Name=[DAStudio.message('Simulink:tools:MAReport'),': '];
                    rptmsg.Type='text';
                    rptmsg.Tag='text_rptmsg';
                    rptmsg.WordWrap=true;
                    rptmsg.RowSpan=[grouprow,grouprow];
                    rptmsg.ColSpan=[1,1];

                    rptLink.Name=this.MAObj.AtticData.DiagnoseRightFrame;
                    rptLink.Type='hyperlink';
                    rptLink.Tag='hyperlink_rptLink';
                    rptLink.ObjectMethod='viewReport';
                    rptLink.RowSpan=[grouprow,grouprow];
                    rptLink.ColSpan=[2,10];
                    rptLink.MethodArgs={};
                    rptLink.ArgDataTypes={};

                    grouprow=grouprow+1;
                    rptDateTitle.Name=[DAStudio.message('Simulink:tools:MADateTime'),': '];
                    rptDateTitle.Type='text';
                    rptDateTitle.Tag='text_rptDateTitle';
                    rptDateTitle.WordWrap=true;
                    rptDateTitle.RowSpan=[grouprow,grouprow];
                    rptDateTitle.ColSpan=[1,1];

                    if isfield(generateInfo,'generateTime')
                        rptDateMsg.Name=datestr(generateInfo.generateTime);
                    else
                        rptDateMsg.Name=DAStudio.message('Simulink:tools:MANotApplicable');;
                    end
                    rptDateMsg.Type='text';
                    rptDateMsg.Tag='text_rptDateMsg';
                    rptDateMsg.WordWrap=true;
                    rptDateMsg.RowSpan=[grouprow,grouprow];
                    rptDateMsg.ColSpan=[2,10];

                    grouprow=grouprow+1;
                    summarymsg.Name=[DAStudio.message('Simulink:tools:MASummary'),': '];
                    summarymsg.Type='text';
                    summarymsg.Tag='text_summarymsg';
                    summarymsg.WordWrap=true;
                    summarymsg.RowSpan=[grouprow,grouprow];
                    summarymsg.ColSpan=[1,1];

                    passedIcon.Type='image';
                    passedIcon.Tag='image_passedIcon';
                    passedIcon.RowSpan=[grouprow,grouprow];
                    passedIcon.ColSpan=[2,2];
                    imagepath=fileparts(fullfile(matlabroot,this.getDisplayIcon));
                    passedIcon.FilePath=fullfile(imagepath,'task_passed.png');
                    if isfield(generateInfo,'passCt')
                        passedCounter.Name=num2str(generateInfo.passCt);
                    else
                        passedCounter.Name=DAStudio.message('Simulink:tools:MANotApplicable');
                    end
                    passedCounter.Name=[DAStudio.message('Simulink:tools:MAPass'),': ',passedCounter.Name];
                    passedCounter.Type='text';
                    passedCounter.Tag='text_passedCounter';
                    passedCounter.WordWrap=true;
                    passedCounter.RowSpan=[grouprow,grouprow];
                    passedCounter.ColSpan=[3,3];

                    failedIcon.Type='image';
                    failedIcon.Tag='image_failedIcon';
                    failedIcon.RowSpan=[grouprow,grouprow];
                    failedIcon.ColSpan=[4,4];
                    failedIcon.FilePath=fullfile(imagepath,'task_failed.png');
                    if isfield(generateInfo,'failCt')
                        failedCounter.Name=num2str(generateInfo.failCt);
                    else
                        failedCounter.Name=DAStudio.message('Simulink:tools:MANotApplicable');
                    end
                    failedCounter.Name=[DAStudio.message('Simulink:tools:MAFail'),': ',failedCounter.Name];
                    failedCounter.Type='text';
                    failedCounter.Tag='text_failedCounter';
                    failedCounter.WordWrap=true;
                    failedCounter.RowSpan=[grouprow,grouprow];
                    failedCounter.ColSpan=[5,5];

                    warnIcon.Type='image';
                    warnIcon.Tag='image_warnIcon';
                    warnIcon.RowSpan=[grouprow,grouprow];
                    warnIcon.ColSpan=[6,6];
                    warnIcon.FilePath=fullfile(imagepath,'task_warning.png');
                    if isfield(generateInfo,'warnCt')
                        warnCounter.Name=num2str(generateInfo.warnCt);
                    else
                        warnCounter.Name=DAStudio.message('Simulink:tools:MANotApplicable');
                    end
                    warnCounter.Name=[DAStudio.message('Simulink:tools:MAWarning'),': ',warnCounter.Name];
                    warnCounter.Type='text';
                    warnCounter.Tag='text_warnCounter';
                    warnCounter.WordWrap=true;
                    warnCounter.RowSpan=[grouprow,grouprow];
                    warnCounter.ColSpan=[7,7];

                    nrunIcon.Type='image';
                    nrunIcon.Tag='image_nrunIcon';
                    nrunIcon.RowSpan=[grouprow,grouprow];
                    nrunIcon.ColSpan=[8,8];
                    nrunIcon.FilePath=fullfile(imagepath,'icon_task.png');
                    if isfield(generateInfo,'nrunCt')
                        nrunCounter.Name=num2str(generateInfo.nrunCt);
                    else
                        nrunCounter.Name=DAStudio.message('Simulink:tools:MANotApplicable');
                    end
                    nrunCounter.Name=[DAStudio.message('Simulink:tools:MANotRunMsg'),': ',nrunCounter.Name];
                    nrunCounter.Type='text';
                    nrunCounter.Tag='text_nrunCounter';
                    nrunCounter.WordWrap=true;
                    nrunCounter.RowSpan=[grouprow,grouprow];
                    nrunCounter.ColSpan=[9,9];


                    grouprow=grouprow+1;
                    warndifferentnodemsg.Name=DAStudio.message('Simulink:tools:MAWarnReportFromDifferentNode');
                    warndifferentnodemsg.Type='text';
                    warndifferentnodemsg.Tag='text_warndifferentnodemsg';
                    warndifferentnodemsg.WordWrap=true;
                    warndifferentnodemsg.RowSpan=[grouprow,grouprow];
                    warndifferentnodemsg.ColSpan=[1,10];

                    LastReportGroup.LayoutGrid=[grouprow,10];
                    LastReportGroup.Items={fromnodemsg,nodenamemsg,rptmsg,rptLink,rptDateTitle,rptDateMsg,summarymsg,passedIcon,passedCounter,failedIcon,failedCounter,warnIcon,warnCounter,nrunIcon,nrunCounter};
                    if~strcmp(nodenamemsg.Name,this.DisplayName)
                        LastReportGroup.Items{end+1}=warndifferentnodemsg;
                    end

                    reportTab.LayoutGrid=[row+5,10];
                    reportTab.RowStretch=[0,0,0,0,0,1,1,1,1,1];
                    reportTab.Items=[{MsgGroup},{AnalysisGroup},{emptymsg},{LastReportGroup}];


                    sourceTab.Name=DAStudio.message('Simulink:tools:MASource');
                    sourceTab.Tag='tab_sourceTab';
                    sourceTab.LayoutGrid=[2,10];
                    daRoot=DAStudio.Root;



                    if 0&&daRoot.hasWebBrowser
                        srcText.Type='webbrowser';
                        srcText.Url=this.MAObj.AtticData.DiagnoseCustomFrame;
                    else
                        srcText.Type='textbrowser';
                        if exist(this.MAObj.AtticData.DiagnoseCustomFrame,'file')
                            srcText.Text=fileread(this.MAObj.AtticData.DiagnoseCustomFrame);
                        else
                            srcText.Text='';
                        end
                    end
                    srcText.Tag='browser_srcText';
                    srcText.RowSpan=[1,2];
                    srcText.ColSpan=[1,10];
                    sourceTab.RowStretch=[0,1];
                    sourceTab.Items={srcText};
                    if this.MAObj.ShowSourceTab
                        struct.Tabs={reportTab,sourceTab};
                    else
                        struct.Tabs={reportTab};
                    end
                    addonStruct.Items={struct};
                    addonStruct.LayoutGrid=[1,10];
                    addonStruct.RowStretch=[1];
                    addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];





                    function[checkboxArray,masterSelectAll,totalRows]=loc_createCheckBoxForAllChildren(this,startRow)

                        checkboxArray={};
                        masterSelectAll=true;
                        totalRows=0;
                        currentRow=startRow;

                        for i=1:length(this.ChildrenObj)
                            curChildren=this.ChildrenObj{i};
                            if strcmp(curChildren.Type,'Container')

                                if strcmp(this.CheckBoxMode,'All')
                                    [childcheckboxArray,childmasterSelectAll,childtotalRows]=loc_createCheckBoxForAllChildren(curChildren,currentRow);
                                elseif strcmp(this.CheckBoxMode,'Direct')
                                    checkbox.Type='checkbox';
                                    checkbox.Name=curChildren.DisplayName;
                                    checkbox.ToolTip=curChildren.Help;
                                    checkbox.RowSpan=[currentRow,currentRow];
                                    checkbox.ColSpan=[2,10];
                                    checkbox.Enabled=curChildren.Enable;
                                    checkbox.Value=curChildren.Selected;
                                    checkbox.Tag=['CheckBox_',num2str(curChildren.Index)];
                                    checkbox.ObjectMethod='handleCheckEvent';
                                    checkbox.MethodArgs={'%tag','%dialog'};
                                    checkbox.ArgDataTypes={'string','handle'};
                                    checkbox.DialogRefresh=true;

                                    childcheckboxArray={checkbox};
                                    childmasterSelectAll=checkbox.Value;
                                    childtotalRows=1;
                                end
                                checkboxArray=[checkboxArray,childcheckboxArray];%#ok<AGROW>
                                masterSelectAll=masterSelectAll&&childmasterSelectAll;
                                currentRow=currentRow+childtotalRows;
                                totalRows=totalRows+childtotalRows;
                            elseif strcmp(curChildren.Type,'Task')
                                checkbox.Type='checkbox';
                                checkbox.Name=curChildren.DisplayName;
                                checkbox.ToolTip=curChildren.Help;
                                checkbox.RowSpan=[currentRow,currentRow];
                                checkbox.ColSpan=[2,10];
                                checkbox.Enabled=curChildren.Enable;
                                checkbox.Value=curChildren.Selected;
                                if~curChildren.Selected
                                    masterSelectAll=false;
                                end
                                checkbox.Tag=['CheckBox_',num2str(curChildren.Index)];
                                checkbox.ObjectMethod='handleCheckEvent';
                                checkbox.MethodArgs={'%tag','%dialog'};
                                checkbox.ArgDataTypes={'string','handle'};
                                checkbox.DialogRefresh=true;
                                checkboxArray{end+1}=checkbox;%#ok<AGROW>
                                currentRow=currentRow+1;
                                totalRows=totalRows+1;
                            end
                        end






                        function addonStruct=loc_createFPCAContainerNode(this)
                            addonStruct.Items={};

                            row=1;
                            SpecificDescription.Name=this.Help;
                            SpecificDescription.Tag='text_SpecificDescription';
                            SpecificDescription.Type='text';
                            SpecificDescription.WordWrap=true;
                            SpecificDescription.RowSpan=[row,row];
                            SpecificDescription.ColSpan=[1,10];
                            addonStruct.Items{end+1}=SpecificDescription;


                            row=row+1;
                            LegendGroup.Type='group';
                            LegendGroup.Name=DAStudio.message('Simulink:tools:MALegend');
                            LegendGroup.RowSpan=[row,row];
                            LegendGroup.ColSpan=[1,6];
                            LegendGroup.LayoutGrid=[5,2];

                            SelectedCheck.Name=DAStudio.message('Simulink:tools:MANotRunMsg');
                            SelectedCheck.Type='text';
                            SelectedCheck.Tag='text_SelectedCheck';
                            SelectedCheck.WordWrap=true;
                            SelectedCheck.RowSpan=[1,1];
                            SelectedCheck.ColSpan=[2,2];
                            LegendGroup.Items={SelectedCheck};
                            selectedIcon.Type='image';
                            selectedIcon.Tag='image_selectedIcon';
                            selectedIcon.RowSpan=[1,1];
                            selectedIcon.ColSpan=[1,1];
                            imagepath=fullfile(matlabroot,'toolbox/simulink/simulink/modeladvisor/private/');
                            selectedIcon.FilePath=fullfile(imagepath,'icon_task.png');
                            LegendGroup.Items{end+1}=selectedIcon;

                            PassedCheck.Name=DAStudio.message('Simulink:tools:MAPassedMsg');
                            PassedCheck.Type='text';
                            PassedCheck.Tag='text_PassedCheck';
                            PassedCheck.WordWrap=true;
                            PassedCheck.RowSpan=[2,2];
                            PassedCheck.ColSpan=[2,2];
                            LegendGroup.Items{end+1}=PassedCheck;
                            passedIcon.Type='image';
                            passedIcon.Tag='image_passedIcon';
                            passedIcon.RowSpan=[2,2];
                            passedIcon.ColSpan=[1,1];
                            passedIcon.FilePath=fullfile(imagepath,'task_passed.png');
                            LegendGroup.Items{end+1}=passedIcon;

                            FailedCheck.Name=DAStudio.message('Simulink:tools:MAFailedMsg');
                            FailedCheck.Type='text';
                            FailedCheck.Tag='text_FailedCheck';
                            FailedCheck.WordWrap=true;
                            FailedCheck.RowSpan=[3,3];
                            FailedCheck.ColSpan=[2,2];
                            LegendGroup.Items{end+1}=FailedCheck;
                            failedIcon.Type='image';
                            failedIcon.Tag='image_failedIcon';
                            failedIcon.RowSpan=[3,3];
                            failedIcon.ColSpan=[1,1];
                            failedIcon.FilePath=fullfile(imagepath,'task_failed.png');
                            LegendGroup.Items{end+1}=failedIcon;

                            WarnCheck.Name=DAStudio.message('Simulink:tools:MAWarning');
                            WarnCheck.Type='text';
                            WarnCheck.Tag='text_WarnCheck';
                            WarnCheck.WordWrap=true;
                            WarnCheck.RowSpan=[4,4];
                            WarnCheck.ColSpan=[2,2];
                            LegendGroup.Items{end+1}=WarnCheck;
                            WarnIcon.Type='image';
                            WarnIcon.Tag='image_WarnIcon';
                            WarnIcon.RowSpan=[4,4];
                            WarnIcon.ColSpan=[1,1];
                            WarnIcon.FilePath=fullfile(imagepath,'task_warning.png');
                            LegendGroup.Items{end+1}=WarnIcon;

                            CompileCheck.Name=DAStudio.message('Simulink:tools:MARequiresCompileShort');
                            CompileCheck.Type='text';
                            CompileCheck.Tag='text_CompileCheck';
                            CompileCheck.WordWrap=true;
                            CompileCheck.RowSpan=[5,5];
                            CompileCheck.ColSpan=[2,2];
                            LegendGroup.Items{end+1}=CompileCheck;
                            CompileFlag.Name=' ^ ';
                            CompileFlag.Bold=1;
                            CompileFlag.Type='text';
                            CompileFlag.WordWrap=true;
                            CompileFlag.RowSpan=[5,5];
                            CompileFlag.ColSpan=[1,1];
                            LegendGroup.Items{end+1}=CompileFlag;
                            addonStruct.Items{end+1}=LegendGroup;


                            txt1=ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg1'),{'bold'});
                            list=ModelAdvisor.List;
                            list.setType('numbered');
                            list.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg2')));
                            list.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg3')));
                            list.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg4')));
                            sublist=ModelAdvisor.List;
                            sublist.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg6')));
                            sublist.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg7')));
                            sublist.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg8')));
                            list.addItem([ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg5')),sublist]);
                            sublist2=ModelAdvisor.List;
                            sublist2.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg10')));
                            sublist2.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg1')));
                            sublist2.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg2')));
                            list.addItem([ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg9')),sublist2]);

                            txt2=ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg3'),{'bold'});
                            txt3=ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg4'));
                            txt4=ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg5'));
                            list2=ModelAdvisor.List;
                            list2.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg16')));
                            list2.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg17')));
                            list2.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg18')));


                            txt5=ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg19'),{'bold'});
                            list3=ModelAdvisor.List;
                            list3.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg20')));
                            list3.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:tools:FPCAContainerMsg21')));

                            table=ModelAdvisor.Table(6,1);
                            table.setBorder(0);
                            table.setEntry(1,1,txt1);
                            table.setEntry(2,1,list);
                            table.setEntry(3,1,[txt2,ModelAdvisor.LineBreak,txt3,ModelAdvisor.LineBreak,txt4]);
                            table.setEntry(4,1,list2);
                            table.setEntry(5,1,txt5);
                            table.setEntry(6,1,list3);
                            doc=ModelAdvisor.Document;
                            doc.addItem({table});

                            row=row+1;
                            GeneralDescription.Text=doc.emitHTML;
                            GeneralDescription.Type='textbrowser';
                            GeneralDescription.Tag='textbrowser_GeneralDescription';
                            GeneralDescription.RowSpan=[row,row];
                            GeneralDescription.ColSpan=[1,10];

                            addonStruct.Items{end+1}=GeneralDescription;

                            addonStruct.LayoutGrid=[row,10];
                            addonStruct.RowStretch=[zeros(1,row-2),0,0];
                            addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

