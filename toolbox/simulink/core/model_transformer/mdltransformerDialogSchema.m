function addonStruct=mdltransformerDialogSchema(group)




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













    spacer1.Name='     ';
    spacer1.Type='text';
    spacer1.Tag='text_emptymsg';
    spacer1.WordWrap=true;
    spacer1.ColSpan=[1,10];
    spacer1.MaximumSize=[0,5];


    Desc_text=strcat('<b>',DAStudio.message('sl_pir_cpp:creator:TransformDesc'),'<\b>');
    introductionStr4.Name=Desc_text;
    introductionStr4.Type='text';
    introductionStr4.Tag='IntroStr4';
    introductionStr4.WordWrap=true;


    introductionStr5.Name=DAStudio.message('sl_pir_cpp:creator:VariantXform');
    introductionStr5.Type='text';
    introductionStr5.Tag='IntroStr5';
    introductionStr5.WordWrap=true;


    introductionStr6.Name=[char(187),' ',DAStudio.message('sl_pir_cpp:creator:Candidate1'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:Candidate2'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:Candidate3')];
    introductionStr6.Type='text';
    introductionStr6.Tag='IntroStr6';
    introductionStr6.WordWrap=true;

    spacer3.Type='text';
    spacer3.Tag='text_emptymsg';
    spacer3.WordWrap=true;
    spacer3.ColSpan=[1,10];
    spacer3.MaximumSize=[0,5];















    introductionStr9.Name=DAStudio.message('sl_pir_cpp:creator:RunallWarning');
    introductionStr9.Type='text';
    introductionStr9.Tag='IntroStr9';
    introductionStr9.WordWrap=true;

    spacer4.Name='     ';
    spacer4.Type='text';
    spacer4.Tag='text_emptymsg';
    spacer4.WordWrap=true;
    spacer4.ColSpan=[1,10];
    spacer4.MaximumSize=[0,5];
    spacer5.Name='     ';
    spacer5.Type='text';
    spacer5.Tag='text_emptymsg';
    spacer5.WordWrap=true;
    spacer5.ColSpan=[1,10];
    spacer5.MaximumSize=[0,5];

    VariantTaskObj=group.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.Const2Variant');



    IdentifyConstTask=group.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');



    DsmTaskObj=group.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.DSMElim');
    LutTaskObj=group.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.LutXform');
    CsiTaskObj=group.MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform');

    runallButton.Name=DAStudio.message('sl_pir_cpp:creator:Runall');
    runallButton.Type='pushbutton';
    runallButton.MatlabMethod='runToFail';
    runallButton.MatlabArgs={group};
    runallButton.ColSpan=[1,3];
    runallButton.Enabled=(IdentifyConstTask.Selected||DsmTaskObj.Selected||LutTaskObj.Selected||CsiTaskObj.Selected);




    row=1;




    spacer1.RowSpan=[row,row];
    row=row+1;
    introductionStr4.RowSpan=[row,row];
    row=row+1;
    introductionStr5.RowSpan=[row,row];
    row=row+1;
    introductionStr6.RowSpan=[row,row];
    row=row+1;
    spacer3.RowSpan=[row,row];
    row=row+1;




    spacer4.RowSpan=[row,row];
    row=row+1;
    spacer5.RowSpan=[row,row];
    row=row+1;
    introductionStr9.RowSpan=[row,row];
    row=row+1;
    runallButton.RowSpan=[row,row];
    row=row+1;





    introductionStr4.ColSpan=[1,19];
    introductionStr5.ColSpan=[1,19];
    introductionStr6.ColSpan=[1,19];


    introductionStr9.ColSpan=[1,19];

    usingPAGroup.Type='group';

    usingPAGroup.Tag=DAStudio.message('sl_pir_cpp:creator:Introduction');
    usingPAGroup.Flat=false;
    usingPAGroup.RowSpan=[1,1];
    usingPAGroup.ColSpan=[1,20];
    usingPAGroup.ColStretch=zeros(20);
    usingPAGroup.LayoutGrid=[row,200];

    usingPAGroupItems={};
    usingPAGroupItems=[usingPAGroupItems,{introductionStr4,introductionStr5,introductionStr6,spacer3}];
    usingPAGroupItems=[usingPAGroupItems,{spacer4,spacer5,introductionStr9,runallButton}];
    usingPAGroup.Items=usingPAGroupItems;
    reportTab.Items={usingPAGroup};




    grouprow=2;
    row=1;

    counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',group);
    rptmsg.Name=[DAStudio.message('Simulink:tools:MAReport'),': '];
    rptmsg.Type='text';
    rptmsg.Tag='text_rptmsg';
    rptmsg.WordWrap=true;
    rptmsg.RowSpan=[row,row];
    rptmsg.ColSpan=[1,1];



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



