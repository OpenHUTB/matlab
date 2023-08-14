function addonStruct=VariantTransformDialogSchema(group)


    masterrow=1;

    struct.Name='tabcontainer';
    struct.Type='tab';
    struct.Tag='tabcontainer_struct';
    struct.LayoutGrid=[3,20];
    struct.RowSpan=[masterrow,masterrow];
    struct.ColSpan=[1,10];


    if~isempty(group.MAObj.CustomObject)&&~isempty(group.MAObj.CustomObject.GUIReportTabName)
        reportTab.Name=group.MAObj.CustomObject.GUIReportTabName;
    end
    reportTab.Tag='tab_reportTab';

    introductionStr1.Name=strcat('<b>',DAStudio.message('sl_pir_cpp:creator:Workflow'),'<\b>');
    introductionStr1.Type='text';
    introductionStr1.Tag='IntroStr1';
    introductionStr1.WordWrap=true;






    spacer0.Name='     ';
    spacer0.Type='text';
    spacer0.Tag='text_emptymsg';
    spacer0.WordWrap=true;
    spacer0.ColSpan=[1,10];
    spacer0.MaximumSize=[0,5];

    introductionStr3.Name=strcat('<b>',DAStudio.message('sl_pir_cpp:creator:VariantXform1'),'<\b>');
    introductionStr3.Type='text';
    introductionStr3.Tag='IntroStr3';
    introductionStr3.WordWrap=true;

    introductionStr4.Name=DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyConst');
    introductionStr4.Type='text';
    introductionStr4.Tag='IntroStr4';
    introductionStr4.WordWrap=true;

    introductionStr5.Name=strcat('<b>',DAStudio.message('sl_pir_cpp:creator:VariantXform2'),'<\b>');
    introductionStr5.Type='text';
    introductionStr5.Tag='IntroStr5';
    introductionStr5.WordWrap=true;

    introductionStr6.Name=DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyCandidate');
    introductionStr6.Type='text';
    introductionStr6.Tag='IntroStr6';
    introductionStr6.WordWrap=true;

    introductionStr7.Name=strcat('<b>',DAStudio.message('sl_pir_cpp:creator:VariantXform3'),'<\b>');
    introductionStr7.Type='text';
    introductionStr7.Tag='IntroStr7';
    introductionStr7.WordWrap=true;

    introductionStr8.Name=DAStudio.message('sl_pir_cpp:creator:Tips_ConvertVariant');
    introductionStr8.Type='text';
    introductionStr8.Tag='IntroStr8';
    introductionStr8.WordWrap=true;

    introductionStr9.Name=DAStudio.message('sl_pir_cpp:creator:RunallWarning');
    introductionStr9.Type='text';
    introductionStr9.Tag='IntroStr9';
    introductionStr9.WordWrap=true;


    spacer1.Name='     ';
    spacer1.Type='text';
    spacer1.Tag='text_emptymsg';
    spacer1.WordWrap=true;
    spacer1.ColSpan=[1,10];
    spacer1.MaximumSize=[0,5];

    spacer2.Name='     ';
    spacer2.Type='text';
    spacer2.Tag='text_emptymsg';
    spacer2.WordWrap=true;
    spacer2.ColSpan=[1,10];
    spacer2.MaximumSize=[0,5];

    IdentifyConstTask=group.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');


    runallButton.Name=DAStudio.message('sl_pir_cpp:creator:Runall');
    runallButton.Type='pushbutton';
    runallButton.MatlabMethod='runToFail';
    runallButton.MatlabArgs={group};
    runallButton.ColSpan=[1,3];
    runallButton.Enabled=(IdentifyConstTask.State==ModelAdvisor.CheckStatus.NotRun);




    row=1;
    introductionStr1.RowSpan=[row,row];
    row=row+1;


    spacer0.RowSpan=[row,row];
    row=row+1;
    introductionStr3.RowSpan=[row,row];
    row=row+1;
    introductionStr4.RowSpan=[row,row];
    row=row+1;
    introductionStr5.RowSpan=[row,row];
    row=row+1;
    introductionStr6.RowSpan=[row,row];
    row=row+1;
    introductionStr7.RowSpan=[row,row];
    row=row+1;
    introductionStr8.RowSpan=[row,row];
    row=row+1;
    spacer1.RowSpan=[row,row];
    row=row+1;
    spacer2.RowSpan=[row,row];
    row=row+1;
    introductionStr9.RowSpan=[row,row];
    row=row+1;
    runallButton.RowSpan=[row,row];
    row=row+1;


    introductionStr1.ColSpan=[1,19];

    introductionStr3.ColSpan=[1,19];
    introductionStr4.ColSpan=[1,19];
    introductionStr5.ColSpan=[1,19];
    introductionStr6.ColSpan=[1,19];
    introductionStr7.ColSpan=[1,19];
    introductionStr8.ColSpan=[1,19];
    introductionStr9.ColSpan=[1,19];

    usingPAGroup.Type='group';

    usingPAGroup.Tag='Introduction';
    usingPAGroup.Flat=false;
    usingPAGroup.RowSpan=[1,1];
    usingPAGroup.ColSpan=[1,20];
    usingPAGroup.ColStretch=zeros(20);
    usingPAGroup.LayoutGrid=[row,200];

    usingPAGroupItems={introductionStr1,spacer0};
    usingPAGroupItems=[usingPAGroupItems,{introductionStr3,introductionStr4,introductionStr5,introductionStr6,introductionStr7,introductionStr8,introductionStr8}];
    usingPAGroupItems=[usingPAGroupItems,{spacer1,spacer2,introductionStr9,runallButton}];
    usingPAGroup.Items=usingPAGroupItems;
    reportTab.Items={usingPAGroup};




    grouprow=2;
    row=1;

    counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',group);



    grouprow=grouprow+1;
    emptymsg.Name='     ';
    emptymsg.Type='text';
    emptymsg.Tag='text_emptymsg';
    emptymsg.WordWrap=true;
    emptymsg.RowSpan=[grouprow,grouprow];
    emptymsg.ColSpan=[1,10];
    reportTab.Items{end+1}=emptymsg;

    reportTab.LayoutGrid=[1,20];
    reportTab.RowStretch=[0,0,0,1];

    struct.Tabs={reportTab};

    addonStruct.Items={struct};
    addonStruct.LayoutGrid=[1,10];
    addonStruct.RowStretch=1;
    addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

end

function curParamItem=loc_createInputParamFromDefinition(this,curParam,i)

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
    case 'ComboBox'
        curParamItem.Type='combobox';
        curParamItem.Entries=curParam.Entries;
        curParamItem.Editable=true;
    case 'PushButton'
        curParamItem.Name=curParam.Name;
        curParamItem.Type='pushbutton';
    case 'Table'
        curParamItem.Type='table';
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
    otherwise
        DAStudio.error('Simulink:tools:MAUnsupportedInputParamType');
    end
    curParamItem.Enabled=curParam.Enable;
    curParamItem.Tag=['InputParameters_',num2str(i)];



    curParamItem.MatlabMethod='handleCheckEvent';
    curParamItem.MatlabArgs={this,'%tag','%dialog'};

    curParamItem.Value=curParam.Value;

    curParamItem.ToolTip=curParam.Description;
end



