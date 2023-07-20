
function[addonStruct]=mdlxformertaskSchema(this,~)




    hmdlAdvCheck=this.Check;


    if isempty(hmdlAdvCheck.Callback)
        am=Advisor.Manager.getInstance;
        am.loadCachedFcnHandle(hmdlAdvCheck);
    end


    groupRowIndex=1;


    AnalysisGroup.Type='group';
    AnalysisGroup.Name=DAStudio.message('Simulink:tools:MAAnalysis');
    if(this.check.SupportsEditTime)
        AnalysisGroup.Name=[AnalysisGroup.Name,' ',DAStudio.message('ModelAdvisor:engine:EditTimeSupportedCheck')];
    end
    if~strcmp(hmdlAdvCheck.CallbackContext,'None')
        AnalysisGroup.Name=[AnalysisGroup.Name,' (',DAStudio.message('Simulink:tools:PrefixForCompileCheck'),'',DAStudio.message('Simulink:tools:MATriggerUpdateDiagram'),') '];
    end
    AnalysisGroup.RowSpan=[groupRowIndex,groupRowIndex];
    AnalysisGroup.ColSpan=[1,10];

    row_ind=1;
    AnalyzeItems={};


    if~isempty(this.Description)
        WfDes.Name=this.Description;
    elseif~isempty(hmdlAdvCheck)&&isprop(hmdlAdvCheck,'TitleTips')&&~isempty(hmdlAdvCheck.TitleTips)
        WfDes.Name=hmdlAdvCheck.TitleTips;
    else
        WfDes.Name='';
    end
    WfDes.Type='text';
    WfDes.Tag='text_Description';
    WfDes.Alignment=0;
    WfDes.WordWrap=true;
    WfDes.RowSpan=[row_ind,row_ind];
    WfDes.ColSpan=[1,10];
    AnalyzeItems{end+1}=WfDes;
















    if~isempty(hmdlAdvCheck.InputParameters)
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
        for i=1:length(hmdlAdvCheck.InputParameters)

            curParam=hmdlAdvCheck.InputParameters{i};


            if curParam.Visible==true
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
                case 'PushButton'
                    curParamItem.Name=curParam.Name;
                    curParamItem.Type='pushbutton';
                    curParamItem.Value=curParam.Value;
                case 'Table'
                    curParamItem.Type='table';
                    curParamItem.Value=curParam.Value;
                    curParamItem.Editable=true;
                    curParamItem.Data=curParam.TableSetting.Data;
                    curParamItem.Size=curParam.TableSetting.Size;
                    curParamItem.ColHeader=curParam.TableSetting.ColHeader;
                    curParamItem.ColumnCharacterWidth=curParam.TableSetting.ColumnCharacterWidth;
                    curParamItem.ColumnHeaderHeight=curParam.TableSetting.ColumnHeaderHeight;
                    curParamItem.HeaderVisibility=curParam.TableSetting.HeaderVisibility;
                    curParamItem.ReadOnlyColumns=curParam.TableSetting.ReadOnlyColumns;
                    curParamItem.ValueChangedCallback=curParam.TableSetting.ValueChangedCallback;
                    curParamItem.MinimumSize=curParam.TableSetting.MinimumSize;
                case 'Number'
                    curParamItem.Type='edit';
                    curParamItem.Value=num2str(curParam.Value);
                case 'BlockType'
                    curParamItem.Enabled=true;
                    curParamItem.Type='group';
                    curParamItem.Flat=true;
                    curParamItem.Items={};
                    curParamItem.LayoutGrid=[5,4];
                    curParamItem.ColStretch=[1,1,1,0];

                    tableItem.Name=curParam.Description;
                    tableItem.Type='table';
                    tableItem.Tag=[curParamItem.Tag,'_table'];
                    tableItem.ColHeader={'BlockType','MaskType'};
                    tableItem.Size=size(curParam.Value);
                    tableItem.Data=curParam.Value;
                    tableItem.HeaderVisibility=[0,1];
                    tableItem.Editable=curParam.Enable;
                    tableItem.ColumnStretchable=[1,1,1,1];
                    tableItem.ValueChangedCallback=@tableChanged;
                    tableItem.SelectionBehavior='Row';
                    tableItem.RowSpan=[1,5];
                    tableItem.ColSpan=[1,3];
                    curParamItem.Items{end+1}=tableItem;

                    addButton.Name=DAStudio.message('ModelAdvisor:engine:Add');
                    addButton.Type='pushbutton';
                    addButton.Enabled=curParam.Enable;
                    addButton.RowSpan=[3,3];
                    addButton.ColSpan=[4,4];
                    addButton.MatlabMethod='handleCheckEvent';
                    addButton.MatlabArgs={this,'%tag','%dialog'};
                    addButton.DialogRefresh=true;
                    addButton.Tag=['BlockTypeAddRow_',num2str(i)];
                    curParamItem.Items{end+1}=addButton;

                    removeButton.Name=DAStudio.message('ModelAdvisor:engine:Remove');
                    removeButton.Type='pushbutton';
                    removeButton.RowSpan=[4,4];
                    removeButton.ColSpan=[4,4];
                    removeButton.Enabled=~isempty(curParam.Value)&&curParam.Enable;
                    removeButton.MatlabMethod='handleCheckEvent';
                    removeButton.MatlabArgs={this,'%tag','%dialog'};
                    removeButton.DialogRefresh=true;
                    removeButton.Tag=['BlockTypeRemoveRow_',num2str(i)];
                    curParamItem.Items{end+1}=removeButton;

                    importButton.Name=DAStudio.message('ModelAdvisor:engine:AddFrom');
                    importButton.Type='pushbutton';
                    importButton.Enabled=curParam.Enable;
                    importButton.RowSpan=[5,5];
                    importButton.ColSpan=[4,4];
                    importButton.MatlabMethod='handleCheckEvent';
                    importButton.MatlabArgs={this,'%tag','%dialog'};
                    importButton.DialogRefresh=true;
                    importButton.Tag=['BlockTypeImport_',num2str(i)];
                    curParamItem.Items{end+1}=importButton;
                otherwise
                    DAStudio.error('Simulink:tools:MAUnsupportedInputParamType');
                end
                if strcmp(curParam.Type,'BlockType')

                else



                    curParamItem.MatlabMethod='handleCheckEvent';
                    curParamItem.MatlabArgs={this,'%tag','%dialog'};
                end
                curParamItem.ToolTip=curParam.Description;
                InputParamsDlg.Items{end+1}=curParamItem;
            end
        end


        if~isempty(InputParamsDlg.Items)
            AnalyzeItems{end+1}=InputParamsDlg;
        else
            row_ind=row_ind-1;
        end
    end



    row_ind=row_ind+1;
    if isa(this.ParentObj,'ModelAdvisor.Procedure')
        analyze.Name=DAStudio.message('Simulink:tools:MARunThisTask');
    else
        analyze.Name=DAStudio.message('Simulink:tools:MARunThisCheck');
    end
    analyze.Tag='RunAdvisor';
    analyze.Type='pushbutton';
    analyze.RowSpan=[1,1];
    analyze.ColSpan=[1,2];
    analyze.Alignment=5;
    analyze.Enabled=this.Selected&&~this.MAObj.isSleeping;

    analyze.DialogRefresh=true;
    analyze.MatlabMethod='runTaskAdvisor';
    analyze.MatlabArgs={this};



    menuStruct=modeladvisorprivate('modeladvisorutil2','GetSelectMenuForTaskAdvsiorNode',this);
    continuebtn.Name=DAStudio.message('Simulink:tools:MAContinue');
    continuebtn.Tag='Button_continue';
    continuebtn.Type='pushbutton';
    continuebtn.RowSpan=[1,1];
    continuebtn.ColSpan=[5,6];
    continuebtn.Alignment=5;

    continuebtn.Enabled=true;
    continuebtn.Visible=menuStruct.continueVisible;
    continuebtn.DialogRefresh=true;
    continuebtn.MatlabMethod='ModelAdvisor.Node.continuerun';
    continuebtn.MatlabArgs={};


    if hmdlAdvCheck.ListViewVisible




















        dummyString1.Name='   ';
        dummyString1.Type='text';
        dummyString1.RowSpan=[1,1];
        dummyString1.ColSpan=[3,3];












        dummyString.Name=' ';
        dummyString.Type='text';
        dummyString.RowSpan=[1,1];
        dummyString.ColSpan=[6,6];





    end
    analyzeVgrp.Type='group';
    analyzeVgrp.Name='';
    analyzeVgrp.Flat=true;
    analyzeVgrp.RowSpan=[row_ind,row_ind];
    analyzeVgrp.ColSpan=[1,10];
    analyzeVgrp.ColStretch=[0,0,1,0,0,1,1,1,1,1];
    analyzeVgrp.LayoutGrid=[1,10];

    analyzeVgrp.Items={analyze};
    AnalyzeItems{end+1}=analyzeVgrp;



    row_ind=row_ind+1;
    ResultMsgPanel.Type='panel';
    ResultMsgPanel.RowSpan=[row_ind,row_ind];
    ResultMsgPanel.ColSpan=[1,10];
    ResultMsgPanel.ColStretch=[0,0,0,0,0,1,1,1,1,0];
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

    overallstatusString=ModelAdvisor.CheckStatusUtil.getText(this.State);




    ResultStatusString.Name=overallstatusString;
    ResultStatusString.Type='text';
    ResultStatusString.RowSpan=[1,1];
    ResultStatusString.ColSpan=[3,3];
    ResultMsgPanel.Items{end+1}=ResultStatusString;
    if hmdlAdvCheck.ListViewVisible
        invokeListViewButton.Name=[DAStudio.message('Simulink:tools:MAExploreResult'),'...'];
        invokeListViewButton.Tag='ListViewButton';
        invokeListViewButton.RowSpan=[1,1];
        invokeListViewButton.ColSpan=[10,10];
        invokeListViewButton.Type='pushbutton';



        invokeListViewButton.MatlabMethod='handleCheckEvent';
        invokeListViewButton.MatlabArgs={this,'%tag','%dialog'};




        if(this.State==ModelAdvisor.CheckStatus.NotRun)||this.MAObj.RunTime>this.Runtime||isempty(hmdlAdvCheck.ListViewParameters)||...
            (this.MAObj.RunTime==this.Runtime&&isa(this.ParentObj,'ModelAdvisor.Procedure')&&~strcmp(this.MAObj.LatestRunID,this.ID))
            invokeListViewButton.Enabled=false;
        end
        ResultMsgPanel.Items{end+1}=invokeListViewButton;
    end
    AnalyzeItems{end+1}=ResultMsgPanel;


















    mp=ModelAdvisor.Preferences;

    row_ind=row_ind+1;

    if(this.State==ModelAdvisor.CheckStatus.NotRun)
        if true
            if isa(this.getParent,'ModelAdvisor.Procedure')
                summary.Text=DAStudio.message('Simulink:tools:MAPressRunThisTask');
            else
                summary.Text=DAStudio.message('Simulink:tools:MAPressRunThisCheck');
            end
        else
            if isa(this.getParent,'ModelAdvisor.Procedure')
                summary.Text=DAStudio.message('Simulink:tools:MASelectThenPressRunThisTask');
            else
                summary.Text=DAStudio.message('Simulink:tools:MASelectThenPressRunThisCheck');
            end
        end
        if this.MAObj.IsLibrary&&~hmdlAdvCheck.SupportLibrary&&~modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
            summary.Text=DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary');
        end
    else

        JSfunction=['<script type="text/javascript"> <!--',...
        modeladvisorprivate('modeladvisorutil2','generate_collapsible_JS',this.MAObj),...
        '--></script>'];

        CSS=ModelAdvisor.Element('style',...
        'type','text/css');
        CSS.setContent(modeladvisorprivate('modeladvisorutil2','CSSFormatting'));

        hmdlAdvCheck.ResultInHTML=update_html(this,hmdlAdvCheck.ResultInHTML);
        summary.Text=[CSS.emitHTML,JSfunction,hmdlAdvCheck.ResultInHTML];
    end

    summary.Text=regexprep(summary.Text,['<!-- inputparam_section_start -->','.*','<!-- inputparam_section_finish -->'],'');


    summary.Text=strrep(summary.Text,'<p />','<p>');
    if mp.UseWebkit
        summary.Type='webbrowser';
        summary.WebKit=true;
        summary.HTML=summary.Text;
    else
        summary.Type='textbrowser';
    end
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
    addonStruct.RowStretch=1;


    if isa(hmdlAdvCheck,'ModelAdvisor.Check')&&isa(hmdlAdvCheck.Action,'ModelAdvisor.Action')
        groupRowIndex=groupRowIndex+1;
        ActionGroup.Type='group';
        ActionGroup.Name=DAStudio.message('Simulink:tools:MAAction');
        ActionGroup.RowSpan=[groupRowIndex,groupRowIndex];
        ActionGroup.ColSpan=[1,10];
        row_ind=1;


        actionDescriptionText.Name=hmdlAdvCheck.Action.Description;
        actionDescriptionText.Type='text';
        actionDescriptionText.WordWrap=true;
        actionDescriptionText.RowSpan=[1,1];
        actionDescriptionText.ColSpan=[1,10];
        ActionGroup.Items{1}=actionDescriptionText;


        row_ind=row_ind+1;
        actionButton.Name=hmdlAdvCheck.Action.Name;
        actionButton.Tag='ActionButton';
        actionButton.Type='pushbutton';
        actionButton.RowSpan=[1,1];
        actionButton.ColSpan=[1,2];


        actionButton.Enabled=hmdlAdvCheck.Action.Enable&&(this.State==ModelAdvisor.CheckStatus.Passed)&&strcmp(this.MAObj.LatestRunID,this.ID);





        actionButton.DialogRefresh=true;



        actionButton.MatlabMethod='runAction';
        actionButton.MatlabArgs={this};
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









        JSfunction=['<script type="text/javascript"> ',...
        modeladvisorprivate('modeladvisorutil2','generate_collapsible_JS',this.MAObj),...
        '</script>'];

        CSS=ModelAdvisor.Element('style',...
        'type','text/css');
        CSS.setContent(modeladvisorprivate('modeladvisorutil2','CSSFormatting'));

        actionResult.Text=[CSS.emitHTML,JSfunction,hmdlAdvCheck.Action.ResultInHTML];


        if hmdlAdvCheck.Action.Enable&&(this.State~=ModelAdvisor.CheckStatus.NotRun)&&...
            isa(this.ParentObj,'ModelAdvisor.Procedure')&&~strcmp(this.MAObj.LatestRunID,this.ID)
            actionResult.Text=DAStudio.message('ModelAdvisor:engine:ClickRunThisTaskEnableAction');
        end


        actionResult.Type='webbrowser';
        actionResult.WebKit=true;
        actionResult.HTML=actionResult.Text;

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

    addonStruct.DialogTitle=this.DisplayName;




    function tableChanged(dlg,ridx,cidx,value)
        ConfigUIObj=Advisor.Utils.convertMCOS(dlg.getSource);
        ConfigUIObj=ConfigUIObj.Check;


        for i=1:length(ConfigUIObj.InputParameters)
            if strcmp(ConfigUIObj.InputParameters{i}.Type,'BlockType')
                tableID=['InputParameters_',num2str(i),'_table'];
                if~isempty(dlg.getWidgetSource(tableID))

                    if dlg.getSelectedTableRow(tableID)==ridx
                        ConfigUIObj.InputParameters{i}.Value{ridx+1,cidx+1}=value;
                    end
                end
            end
        end
