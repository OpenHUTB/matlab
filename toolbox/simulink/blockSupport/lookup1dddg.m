function dlgStruct=lookup1dddg(source,h)









    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('BP_In');
    dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('Num');


    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    rowIdx=1;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[rowIdx,rowIdx];
    descGrp.ColSpan=[1,1];


    inputValues=start_property(h,'InputValues');
    inputValues.Type='edit';
    inputValues.RowSpan=[rowIdx,rowIdx];
    inputValues.ColSpan=[1,4];

    inputValues.MatlabMethod='slDDGUtil';
    inputValues.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

    inputValuesEdit.Name=DAStudio.message('Simulink:dialog:Editing');
    inputValuesEdit.Type='pushbutton';
    inputValuesEdit.RowSpan=[rowIdx,rowIdx];
    inputValuesEdit.ColSpan=[5,5];
    inputValuesEdit.MatlabMethod='luteditorddg_cb';
    inputValuesEdit.MatlabArgs={'%dialog',h};


    rowIdx=rowIdx+1;

    outputValues=start_property(h,'Table');
    outputValues.Type='edit';
    outputValues.RowSpan=[rowIdx,rowIdx];
    outputValues.ColSpan=[1,4];

    outputValues.MatlabMethod='slDDGUtil';
    outputValues.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

    rowIdx=rowIdx+1;

    lookup_popup=start_property(h,'LookUpMeth');
    lookup_popup.Type='combobox';
    lookup_popup.Entries=h.getPropAllowedValues('LookUpMeth',true)';
    lookup_popup.RowSpan=[rowIdx,rowIdx];
    lookup_popup.ColSpan=[1,5];
    lookup_popup.DialogRefresh=1;
    lookup_popup.Editable=0;
    lookup_popup.Enabled=~source.isHierarchySimulating;

    lookup_popup.MatlabMethod='slDDGUtil';
    lookup_popup.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    rowIdx=rowIdx+1;

    if slfeature('HideSampleTimeWidgetWithDefaultValue')>0
        ts=Simulink.SampleTimeWidget.getSampleTimeWidget('SampleTime',-1,h.SampleTime,...
        '','',source);
    else
        ts=start_property(h,'SampleTime');
        ts.Type='edit';

        ts.MatlabMethod='slDDGUtil';
        ts.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};
    end
    ts.RowSpan=[rowIdx,rowIdx];
    ts.ColSpan=[1,5];

    rowIdx=rowIdx+1;

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,5];

    mainTab.Name=DAStudio.message('Simulink:dialog:Main');
    mainTab.Items={inputValues,inputValuesEdit,outputValues,lookup_popup,ts,spacer};
    mainTab.LayoutGrid=[rowIdx,rowIdx];
    mainTab.ColStretch=[1,1,1,1,0];
    mainTab.RowStretch=[zeros(1,(rowIdx-1)),1];


    rowIdx=1;

    outMin=start_property(h,'OutMin');
    outMin.Type='edit';
    outMin.RowSpan=[rowIdx,rowIdx];
    outMin.ColSpan=[1,1];
    outMin.Enabled=~source.isHierarchySimulating;

    outMin.MatlabMethod='slDialogUtil';
    outMin.MatlabArgs={source,'sync','%dialog','edit','%tag'};

    outMax=start_property(h,'OutMax');
    outMax.Type='edit';
    outMax.RowSpan=[rowIdx,rowIdx];
    outMax.ColSpan=[2,2];
    outMax.Enabled=~source.isHierarchySimulating;

    outMax.MatlabMethod='slDialogUtil';
    outMax.MatlabArgs={source,'sync','%dialog','edit','%tag'};
    rowIdx=rowIdx+1;


    lockOutScale=start_property(h,'LockScale');


    dataTypeItems.scalingMinTag={outMin.Tag};
    dataTypeItems.scalingMaxTag={outMax.Tag};
    dataTypeItems.scalingValueTags={outputValues.Tag};

    paramName='OutDataTypeStr';




    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
    paramName,...
    DAStudio.message('Simulink:dialog:OutputDataType'),...
    paramName,...
    h.OutDataTypeStr,...
    dataTypeItems,...
    false);

    dataTypeGroup.RowSpan=[rowIdx,rowIdx];
    dataTypeGroup.ColSpan=[1,2];
    dataTypeGroup.Enabled=~source.isHierarchySimulating;

    rowIdx=rowIdx+1;

    lockOutScale.Type='checkbox';
    lockOutScale.DialogRefresh=1;
    lockOutScale.RowSpan=[rowIdx,rowIdx];
    lockOutScale.ColSpan=[1,2];
    lockOutScale.Enabled=~source.isHierarchySimulating;

    lockOutScale.MatlabMethod='slDDGUtil';
    lockOutScale.MatlabArgs={source,'sync','%dialog','checkbox','%tag','%value'};

    rowIdx=rowIdx+1;

    round=start_property(h,'RndMeth');
    round.Type='combobox';
    round.Entries=h.getPropAllowedValues('RndMeth',true)';
    round.RowSpan=[rowIdx,rowIdx];
    round.ColSpan=[1,2];
    round.Editable=0;

    round.DialogRefresh=1;
    round.Enabled=~source.isHierarchySimulating;

    round.MatlabMethod='slDDGUtil';
    round.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    rowIdx=rowIdx+1;

    saturate=start_property(h,'SaturateOnIntegerOverflow');
    saturate.Type='checkbox';
    saturate.RowSpan=[rowIdx,rowIdx];
    saturate.ColSpan=[1,2];
    saturate.Enabled=~source.isHierarchySimulating;

    saturate.MatlabMethod='slDDGUtil';
    saturate.MatlabArgs={source,'sync','%dialog','checkbox','%tag','%value'};


    rowIdx=rowIdx+1;

    spacer=[];
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,2];

    dataTab.Name=DAStudio.message('Simulink:dialog:SignalAttributes');
    dataTab.Items={outMin,outMax,dataTypeGroup,lockOutScale,round,saturate,spacer};

    dataTab.LayoutGrid=[rowIdx,2];
    dataTab.RowStretch=[zeros(1,(rowIdx-1)),1];

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    paramGrp.Tabs={mainTab,dataTab};
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end

function property=start_property(h,propName)



    property.ObjectProperty=propName;
    property.Tag=property.ObjectProperty;

    property.Name=h.IntrinsicDialogParameters.(propName).Prompt;

end



