
function addonStruct=createContainerDialog(this,masterrow)




    struct.Name='tabcontainer';
    struct.Type='tab';
    struct.Tag='tabcontainer_struct';
    struct.LayoutGrid=[1,10];
    struct.RowSpan=[masterrow,masterrow];
    struct.ColSpan=[1,10];


    isHDLWA=false;
    isModelReferenceAdvisor=strcmp(this.ID,'com.mathworks.Simulink.ModelReferenceAdvisor.MainGroup');
    isSLCIAdvisor=strcmp(this.ID,'_SYSTEM_By Product_Simulink Code Inspector');
    isMdlAdv=false;

    if~isempty(this.MAObj.CustomObject)&&~isempty(this.MAObj.CustomObject.GUIReportTabName)
        reportTab.Name=this.MAObj.CustomObject.GUIReportTabName;
    elseif strcmp(this.MAObj.CustomTARootID,'com.mathworks.HDL.WorkflowAdvisor')
        reportTab.Name=DAStudio.message('HDLShared:hdldialog:HDLAdvisor');
        isHDLWA=true;
    elseif strcmp(this.MAObj.CustomTARootID,'com.mathworks.cgo.group')
        reportTab.Name=DAStudio.message('Simulink:tools:CodeGenAdvisorTab');
    elseif strcmp(this.MAObj.CustomTARootID,UpgradeAdvisor.UPGRADE_GROUP_ID)
        reportTab.Name=DAStudio.message('SimulinkUpgradeAdvisor:advisor:title');
    elseif~strcmp(this.MAObj.CustomTARootID,'com.mathworks.FPCA.FixedPointConversionTask')
        reportTab.Name=DAStudio.message('Simulink:tools:MAModelAdvisor');
        isMdlAdv=true;
    else
        reportTab.Name=DAStudio.message('SimulinkFixedPoint:fpca:MSGnameFixedPointConversionAdvisor');
    end
    reportTab.Tag='tab_reportTab';


    row=1;

    AnalysisGroup.Type='group';
    AnalysisGroup.Name=DAStudio.message('Simulink:tools:MAAnalysis');
    AnalysisGroup.ColSpan=[1,10];
    AnalysisGroup.ColStretch=zeros(1,10);
    AnalysisGroup.Items={};

    grouprow=0;

    if~isempty(this.Description)
        grouprow=grouprow+1;
        ContainerDescription.Name=this.Description;
        ContainerDescription.Type='text';
        ContainerDescription.Tag='text_ContainerDescription';
        ContainerDescription.Alignment=0;
        ContainerDescription.WordWrap=true;
        ContainerDescription.RowSpan=[grouprow,grouprow];
        ContainerDescription.ColSpan=[1,10];
    end

    if isa(this,'CodeGenAdvisor.Group')
        ContainerDescription=this.getDescriptionSchema(grouprow);
        grouprow=grouprow+1;
        objSelect=this.getObjSelectPanelSchema(grouprow);
    end


    if~isempty(this.InputParameters)
        grouprow=grouprow+1;
        InputParamsDlg.Type='group';
        InputParamsDlg.Name=DAStudio.message('Simulink:tools:MAInputParameters');
        InputParamsDlg.Flat=false;
        InputParamsDlg.RowSpan=[grouprow,grouprow];
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
                curParamItem.Type='group';
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
                tableItem.Editable=true;
                tableItem.ColumnStretchable=[1,1,1,1];
                tableItem.ValueChangedCallback=@tableChanged;
                tableItem.SelectionBehavior='Row';
                tableItem.RowSpan=[1,5];
                tableItem.ColSpan=[1,3];
                curParamItem.Items{end+1}=tableItem;

                addButton.Name='Add';
                addButton.Type='pushbutton';
                addButton.RowSpan=[4,4];
                addButton.ColSpan=[4,4];
                addButton.MatlabMethod='handleCheckEvent';
                addButton.MatlabArgs={this,'%tag','%dialog'};
                addButton.DialogRefresh=true;
                addButton.Tag=['BlockTypeAddRow_',num2str(i)];
                curParamItem.Items{end+1}=addButton;

                removeButton.Name='Remove';
                removeButton.Type='pushbutton';
                removeButton.RowSpan=[5,5];
                removeButton.ColSpan=[4,4];
                removeButton.Enabled=~isempty(curParam.Value);
                removeButton.MatlabMethod='handleCheckEvent';
                removeButton.MatlabArgs={this,'%tag','%dialog'};
                removeButton.DialogRefresh=true;
                removeButton.Tag=['BlockTypeRemoveRow_',num2str(i)];
                curParamItem.Items{end+1}=removeButton;
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
        AnalysisGroup.Items{end+1}=InputParamsDlg;
    end



    grouprow=grouprow+1;

    analyzebutton.Type='pushbutton';
    analyzebutton.Tag='RunAdvisor';
    analyzebutton.ColSpan=[1,1];
    analyzebutton.Alignment=5;
    analyzebutton.DialogRefresh=true;
    analyzebutton.MethodArgs={};
    analyzebutton.ArgDataTypes={};
    analyzebutton.Enabled=~this.MAObj.isSleeping&&(~isa(this,'CodeGenAdvisor.Group')||~isempty(this.Objectives));

    if isa(this,'ModelAdvisor.Procedure')
        analyzebutton.Name=modeladvisorprivate('getRunToFailureLabel',this.ID);
        analyzebutton.MatlabMethod='runToFail';
        analyzebutton.MatlabArgs={this};
        menuStruct=modeladvisorprivate('modeladvisorutil2','GetSelectMenuForTaskAdvsiorNode',this);
        analyzebutton.Enabled=strcmp(menuStruct.run2failureEnable,'on');
    else
        analyzebutton.Name=DAStudio.message('Simulink:tools:MARunSelectedChecks');
        analyzebutton.MatlabMethod='runTaskAdvisor';
        analyzebutton.MatlabArgs={this};
    end

    if~isempty(this.Description)
        analyzebutton.RowSpan=[1,1];

        analyzeVgrp.Type='group';
        analyzeVgrp.Name='';
        analyzeVgrp.Tag='group_analyzeVgrp';
        analyzeVgrp.Flat=true;
        analyzeVgrp.RowSpan=[grouprow,grouprow];
        analyzeVgrp.ColSpan=[1,10];
        analyzeVgrp.ColStretch=[0,0,1,1,1,1,1,1,1,1];
        analyzeVgrp.LayoutGrid=[1,10];
        analyzeVgrp.Items={analyzebutton};

        AnalysisGroup.Items=[AnalysisGroup.Items,{ContainerDescription,analyzeVgrp}];
    else
        analyzebutton.RowSpan=[grouprow,grouprow];

        AnalysisGroup.Items=[AnalysisGroup.Items,analyzebutton];
    end

    grouprow=grouprow+1;
    launchrptcheckbox.Type='checkbox';
    launchrptcheckbox.Name=DAStudio.message('Simulink:tools:MAShowRptAfterRun');
    launchrptcheckbox.RowSpan=[grouprow,grouprow];
    launchrptcheckbox.ColSpan=[1,1];
    launchrptcheckbox.Enabled=true;
    launchrptcheckbox.Tag='CheckBox_launchReport';
    launchrptcheckbox.MatlabMethod='handleCheckEvent';
    launchrptcheckbox.MatlabArgs={this,'%tag','%dialog'};
    launchrptcheckbox.Value=this.LaunchReport;
    launchrptcheckbox.DialogRefresh=false;

    AnalysisGroup.Items=[AnalysisGroup.Items,launchrptcheckbox];

    if isa(this,'CodeGenAdvisor.Group')
        AnalysisGroup.Items{end+1}=objSelect;
    end

    AnalysisGroup.LayoutGrid=[grouprow,10];
    AnalysisGroup.RowSpan=[row,row+1];
    reportTab.Items{1}=AnalysisGroup;
    row=row+1;



    row=row+1;
    CurrentReportGroup.Type='group';
    CurrentReportGroup.Name=DAStudio.message('Simulink:tools:MAReport');
    CurrentReportGroup.ColSpan=[1,10];
    CurrentReportGroup.ColStretch=zeros(1,10);


    counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',this);

    grouprow=1;
    rptmsg.Name=[DAStudio.message('Simulink:tools:MAReport'),': '];
    rptmsg.Type='text';
    rptmsg.Tag='text_rptmsg';
    rptmsg.WordWrap=true;
    rptmsg.RowSpan=[grouprow,grouprow];
    rptmsg.ColSpan=[1,1];

    [rptPath,rptName,rptExt]=fileparts(modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',...
    this,this.MAObj.AtticData.WorkDir));
    rptLink.Name=['...\',rptName,rptExt];
    rptLink.ToolTip=[rptPath,filesep,rptName,rptExt];
    rptLink.Type='hyperlink';
    rptLink.Tag='hyperlink_rptLink';



    rptLink.MatlabMethod='viewReport';
    rptLink.MatlabArgs={this,''};

    IsModelAdvisor=strcmp(this.MAObj.CustomTARootID,'_modeladvisor_');
    rptLink.RowSpan=[grouprow,grouprow];
    if IsModelAdvisor
        rptLink.ColSpan=[4,5];
    else
        rptLink.ColSpan=[2,3];
    end

    exportbutton.Enabled=1;
    if IsModelAdvisor
        exportbutton.Name=DAStudio.message('ModelAdvisor:engine:GenerateReport');
    else
        exportbutton.Name=DAStudio.message('Simulink:tools:MASaveReport');
    end
    exportbutton.Type='pushbutton';



    exportbutton.MatlabMethod='exportReport';
    exportbutton.MatlabArgs={this};
    exportbutton.Tag='exportReport';
    exportbutton.RowSpan=[1,1];
    if IsModelAdvisor
        exportbutton.ColSpan=[2,3];
    else
        exportbutton.ColSpan=[4,5];
    end
    exportbutton.Alignment=5;
    exportbutton.DialogRefresh=true;


    grouprow=grouprow+1;
    rptDateTitle.Name=[DAStudio.message('Simulink:tools:MADateTime'),': '];
    rptDateTitle.Type='text';
    rptDateTitle.Tag='text_rptDateTitle';
    rptDateTitle.WordWrap=true;
    rptDateTitle.RowSpan=[grouprow,grouprow];
    rptDateTitle.ColSpan=[1,1];

    if counterStructure.generateTime~=0
        rptDateMsg.Name=datestr(counterStructure.generateTime);
    else
        rptDateMsg.Name=DAStudio.message('Simulink:tools:MANotApplicable');
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
    passedCounter.Name=num2str(counterStructure.passCt);
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
    failedCounter.Name=num2str(counterStructure.failCt);
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
    warnCounter.Name=num2str(counterStructure.warnCt);
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
    nrunCounter.Name=num2str(counterStructure.nrunCt);
    nrunCounter.Name=[DAStudio.message('Simulink:tools:MANotRunMsg'),': ',nrunCounter.Name];
    nrunCounter.Type='text';
    nrunCounter.Tag='text_nrunCounter';
    nrunCounter.WordWrap=true;
    nrunCounter.RowSpan=[grouprow,grouprow];
    nrunCounter.ColSpan=[9,9];

    CurrentReportGroup.LayoutGrid=[grouprow,10];
    CurrentReportGroup.RowSpan=[row,row+2];
    row=row+2;
    CurrentReportGroup.Items={rptmsg,rptLink,exportbutton,rptDateTitle,rptDateMsg,summarymsg,passedIcon,passedCounter,failedIcon,failedCounter,warnIcon,warnCounter,nrunIcon,nrunCounter};
    reportTab.Items{end+1}=CurrentReportGroup;


    showMAAdviceOnContainerNode2=false;
    if isa(this,'ModelAdvisor.Procedure')
        row=row+1;
        emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
        reportTab.Items{end+1}=emptymsg;
        row=row+1;
        genrptmsg1.Name=DAStudio.message('Simulink:tools:MAAdviceOnprocedure1',['"',DAStudio.message('Simulink:tools:MARunToFailure'),'"']);
        row=row+1;
        emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
        reportTab.Items{end+1}=emptymsg;
        row=row+1;
        if~isModelReferenceAdvisor
            row=row+1;
            emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
            reportTab.Items{end+1}=emptymsg;
            row=row+1;

            if isHDLWA
                msgId='Simulink:tools:MAAdviceOnprocedure1HDLWA';
            else
                msgId='Simulink:tools:MAAdviceOnprocedure1';
            end
            menuLabel=modeladvisorprivate('getRunToFailureLabel',this.ID);
            genrptmsg1.Name=DAStudio.message(msgId,['"',menuLabel,'"']);

            genrptmsg1.Name=[' ',genrptmsg1.Name];
            genrptmsg1.Type='text';
            genrptmsg1.Tag='text_genrptmsg1';
            genrptmsg1.WordWrap=true;
            genrptmsg1.RowSpan=[row,row];
            genrptmsg1.ColSpan=[1,10];
            reportTab.Items{end+1}=genrptmsg1;
        end

        if~isHDLWA&&~isModelReferenceAdvisor

            row=row+1;
            emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
            reportTab.Items{end+1}=emptymsg;
            row=row+1;
            genrptmsg2.Name=DAStudio.message('Simulink:tools:MAAdviceOnprocedure2',['"',DAStudio.message('Simulink:tools:MARunThisTask'),'"'],['"',DAStudio.message('Simulink:tools:MARunThisTask'),'"']);
            genrptmsg2.Name=[' ',genrptmsg2.Name];
            genrptmsg2.Type='text';
            genrptmsg2.Tag='text_genrptmsg2';
            genrptmsg2.WordWrap=true;
            genrptmsg2.RowSpan=[row,row];
            genrptmsg2.ColSpan=[1,10];
            reportTab.Items{end+1}=genrptmsg2;
        end

        if~isModelReferenceAdvisor
            row=row+1;
            emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
            reportTab.Items{end+1}=emptymsg;
            row=row+1;
            genrptmsg3.Name=DAStudio.message('Simulink:tools:MAAdviceOnprocedure3',['"',DAStudio.message('Simulink:tools:MAShowRptAfterRun'),'"']);
            genrptmsg3.Name=[' ',genrptmsg3.Name];
            genrptmsg3.Type='text';
            genrptmsg3.Tag='text_genrptmsg3';
            genrptmsg3.WordWrap=true;
            genrptmsg3.RowSpan=[row,row];
            genrptmsg3.ColSpan=[1,10];
            reportTab.Items{end+1}=genrptmsg3;

            row=row+1;
            emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
            reportTab.Items{end+1}=emptymsg;
            row=row+1;
            genrptmsg4.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode5');
            genrptmsg4.Name=[' ',genrptmsg4.Name];
            genrptmsg4.Type='text';
            genrptmsg4.Tag='text_genrptmsg4';
            genrptmsg4.WordWrap=true;
            genrptmsg4.RowSpan=[row,row];
            genrptmsg4.ColSpan=[1,10];
            reportTab.Items{end+1}=genrptmsg4;

            row=row+1;
            emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
            reportTab.Items{end+1}=emptymsg;
            row=row+1;
            genrptmsg5.Name=DAStudio.message('Simulink:tools:MAAdviceOnprocedure5',['"',DAStudio.message('Simulink:tools:MAWhatsThis'),'"']);
            genrptmsg5.Name=[' ',genrptmsg5.Name];
            genrptmsg5.Type='text';
            genrptmsg5.Tag='text_genrptmsg5';
            genrptmsg5.WordWrap=true;
            genrptmsg5.RowSpan=[row,row];
            genrptmsg5.ColSpan=[1,10];
            reportTab.Items{end+1}=genrptmsg5;

            row=row+1;
            emptymsg.Name=' ';emptymsg.Type='text';emptymsg.WordWrap=true;emptymsg.RowSpan=[row,row];emptymsg.ColSpan=[1,10];
            reportTab.Items{end+1}=emptymsg;
            row=row+1;
            genrptmsg6.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode6');
            genrptmsg6.Name=[' ',genrptmsg6.Name];
            genrptmsg6.Type='text';
            genrptmsg6.Tag='text_genrptmsg6';
            genrptmsg6.WordWrap=true;
            genrptmsg6.RowSpan=[row,row];
            genrptmsg6.ColSpan=[1,10];
            reportTab.Items{end+1}=genrptmsg6;
        end

    else
        row=row+1;
        TipsGroup.Type='group';
        TipsGroup.Name=DAStudio.message('ModelAdvisor:engine:Tips');
        TipsGroup.RowSpan=[row,row];
        TipsGroup.ColSpan=[1,10];




        srow=1;
        genrptmsg1.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode1',['"',DAStudio.message('Simulink:tools:MARunSelectedChecks'),'"']);
        genrptmsg1.Name=[' ',genrptmsg1.Name];
        genrptmsg1.Type='text';
        genrptmsg1.Tag='text_genrptmsg1';
        genrptmsg1.WordWrap=true;
        genrptmsg1.RowSpan=[srow,srow];
        genrptmsg1.ColSpan=[1,10];
        TipsGroup.Items{1}=genrptmsg1;




        if~isempty(this.ChildrenObj(cellfun(@(x)isa(x,'ModelAdvisor.Procedure'),this.ChildrenObj)))
            showMAAdviceOnContainerNode2=true;
        end
        if showMAAdviceOnContainerNode2



            srow=srow+1;
            genrptmsg2.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode2',['"',DAStudio.message('Simulink:tools:MARunSelectedChecks'),'"']);
            genrptmsg2.Name=[' ',genrptmsg2.Name];
            genrptmsg2.Type='text';
            genrptmsg2.Tag='text_genrptmsg2';
            genrptmsg2.WordWrap=true;
            genrptmsg2.RowSpan=[srow,srow];
            genrptmsg2.ColSpan=[1,10];
            TipsGroup.Items{end+1}=genrptmsg2;
        end




        srow=srow+1;
        genrptmsg3.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode3');
        genrptmsg3.Name=[' ',genrptmsg3.Name];
        genrptmsg3.Type='text';
        genrptmsg3.Tag='text_genrptmsg3';
        genrptmsg3.WordWrap=true;
        genrptmsg3.RowSpan=[srow,srow];
        genrptmsg3.ColSpan=[1,10];
        TipsGroup.Items{end+1}=genrptmsg3;




        srow=srow+1;
        genrptmsg4.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode4',['"',DAStudio.message('Simulink:tools:MAShowRptAfterRun'),'"']);
        genrptmsg4.Name=[' ',genrptmsg4.Name];
        genrptmsg4.Type='text';
        genrptmsg4.Tag='text_genrptmsg4';
        genrptmsg4.WordWrap=true;
        genrptmsg4.RowSpan=[srow,srow];
        genrptmsg4.ColSpan=[1,10];
        TipsGroup.Items{end+1}=genrptmsg4;




        srow=srow+1;
        genrptmsg5.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode5');
        genrptmsg5.Name=[' ',genrptmsg5.Name];
        genrptmsg5.Type='text';
        genrptmsg5.Tag='text_genrptmsg5';
        genrptmsg5.WordWrap=true;
        genrptmsg5.RowSpan=[srow,srow];
        genrptmsg5.ColSpan=[1,10];
        TipsGroup.Items{end+1}=genrptmsg5;




        srow=srow+1;
        genrptmsg6.Name=DAStudio.message('Simulink:tools:MAAdviceOnContainerNode6');
        genrptmsg6.Name=[' ',genrptmsg6.Name];
        genrptmsg6.Type='text';
        genrptmsg6.Tag='text_genrptmsg6';
        genrptmsg6.WordWrap=true;
        genrptmsg6.RowSpan=[srow,srow];
        genrptmsg6.ColSpan=[1,10];
        TipsGroup.Items{end+1}=genrptmsg6;

        if~isSLCIAdvisor
            srow=srow+1;
            genrptmsg7.Name=DAStudio.message('ModelAdvisor:engine:RootNodeMsgLine7');
            genrptmsg7.Name=[' ',genrptmsg7.Name];
            genrptmsg7.Type='text';
            genrptmsg7.Tag='text_genrptmsg7';
            genrptmsg7.WordWrap=true;
            genrptmsg7.RowSpan=[srow,srow];
            genrptmsg7.ColSpan=[1,10];
            TipsGroup.Items{end+1}=genrptmsg7;

            srow=srow+1;
            genrptmsg8.Name=DAStudio.message('ModelAdvisor:engine:RootNodeMsgLine8');
            genrptmsg8.Name=[' ',genrptmsg8.Name];
            genrptmsg8.Type='text';
            genrptmsg8.Tag='text_genrptmsg8';
            genrptmsg8.WordWrap=true;
            genrptmsg8.RowSpan=[srow,srow];
            genrptmsg8.ColSpan=[1,10];
            TipsGroup.Items{end+1}=genrptmsg8;
        end

        TipsGroup.LayoutGrid=[srow,10];
        reportTab.Items{end+1}=TipsGroup;

    end












    if~isModelReferenceAdvisor
        row=row+1;
        LegendGroup.Type='group';
        LegendGroup.Name=DAStudio.message('Simulink:tools:MALegend');
        LegendGroup.RowSpan=[row,row];
        LegendGroup.ColSpan=[1,10];
        if~this.MAObj.IsLibrary||modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
            CompileCheck.Name=[' ',DAStudio.message('Simulink:tools:PrefixForCompileCheck'),'    ',DAStudio.message('Simulink:tools:MARequiresCompileShort'),newline...
            ,' ',DAStudio.message('ModelAdvisor:engine:PrefixForExtensiveCheck'),'  ',DAStudio.message('ModelAdvisor:engine:MAExtensiveAnalysisShort')];
        else
            CompileCheck.Name=[' ',DAStudio.message('ModelAdvisor:engine:PrefixForNSupportLibCheck'),' ',DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary')];
        end
        CompileCheck.Type='text';
        CompileCheck.Tag='text_CompileCheck';
        CompileCheck.WordWrap=true;
        CompileCheck.RowSpan=[1,1];
        CompileCheck.ColSpan=[1,1];
        LegendGroup.Items{1}=CompileCheck;
        LegendGroup.LayoutGrid=[1,2];
        reportTab.Items{end+1}=LegendGroup;
    end


    row=row+1;
    emptymsg.Name='     ';
    emptymsg.Type='text';
    emptymsg.Tag='text_emptymsg';
    emptymsg.WordWrap=true;
    emptymsg.RowSpan=[row,row];
    emptymsg.ColSpan=[1,10];
    reportTab.Items{end+1}=emptymsg;

    reportTab.LayoutGrid=[row,10];
    reportTab.RowStretch=[zeros(1,row-1),1];
    struct.Tabs={reportTab};


    if strcmp(this.MAObj.TaskAdvisorRoot.ID,'SysRoot')&&this.MAObj.ShowExclusionTab
        exclusionTab.Name=DAStudio.message('ModelAdvisor:engine:Exclusions');
        exclusionTab.Tag='tab_exclusionTab';
        exclusionTab.LayoutGrid=[2,10];
        srcText.Type='textbrowser';
        srcText.Text='';
        srcText.Tag='browser_srcText';
        srcText.RowSpan=[1,2];
        srcText.ColSpan=[1,10];
        exclusionTab.RowStretch=[0,1];
        exclusionTab.Items={srcText};
        struct.Tabs=[struct.Tabs,exclusionTab];
    end
    addonStruct.Items={struct};
    addonStruct.LayoutGrid=[1,10];
    addonStruct.RowStretch=1;
    addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];


    function tableChanged(dlg,ridx,cidx,value)
        ConfigUIObj=Advisor.Utils.convertMCOS(dlg.getSource);


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
