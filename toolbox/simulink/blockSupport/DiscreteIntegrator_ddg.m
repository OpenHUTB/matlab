function dlgStruct=DiscreteIntegrator_ddg(source,h)







    mlock;
    persistent sigObjCache;

    if isempty(sigObjCache)
        sigObjCache=Simulink.SigpropDDGCache;
    end


    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;

    paramGrp.Tabs={};
    [paramGrp.Tabs{end+1},scalingTags]=get_main_tab(source,h);
    paramGrp.Tabs{end+1}=get_signal_attributes_tab(source,h,scalingTags);
    paramGrp.Tabs{end+1}=get_state_attributes_tab(source,h,sigObjCache);





    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,newline,' ')));
    dlgStruct.DialogTag='DiscreteIntegrator';

    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyCallback='cg_widgets_ddg_cb';
    dlgStruct.PreApplyArgs={h.Handle,'preapply_cb',sigObjCache,'%dialog'};
    dlgStruct.PostApplyCallback='cg_widgets_ddg_cb';
    dlgStruct.PostApplyArgs={h.Handle,'postapply_cb'};
    dlgStruct.CloseCallback='cg_widgets_ddg_cb';
    dlgStruct.CloseArgs={h.Handle,'close_cb','%closeaction',sigObjCache,'%dialog'};


    dlgStruct.PostRevertCallback='cg_widgets_ddg_cb';
    dlgStruct.PostRevertArgs={h.Handle,'postrevert_cb',sigObjCache};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end


    function[thisTab,scalingTags]=get_main_tab(source,h)


        rowIdx=1;
        maxCol=4;

        IntegratorMethod=create_widget(source,h,'IntegratorMethod',rowIdx,2,2);
        IntegratorMethod.RowSpan=[rowIdx,rowIdx];
        IntegratorMethod.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        GainValue=create_widget(source,h,'gainval',rowIdx,2,2);
        GainValue.NameLocation=2;
        GainValue.RowSpan=[rowIdx,rowIdx+1];
        GainValue.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        ExternalReset=create_widget(source,h,'ExternalReset',rowIdx,2,2);
        ExternalReset.RowSpan=[rowIdx,rowIdx];
        ExternalReset.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        InitialConditionSource=create_widget(source,h,'InitialConditionSource',rowIdx,2,2);
        InitialConditionSource.RowSpan=[rowIdx,rowIdx];
        InitialConditionSource.ColSpan=[1,maxCol];
        InitialConditionSource.DialogRefresh=true;
        rowIdx=rowIdx+1;

        InitialCondition=create_widget(source,h,'InitialCondition',rowIdx,2,2);
        InitialCondition.NameLocation=2;
        InitialCondition.RowSpan=[rowIdx,rowIdx+1];
        InitialCondition.ColSpan=[1,maxCol];
        InitialCondition.Enabled=isequal(h.InitialConditionSource,'internal');
        scalingTags.initValTag=InitialCondition.Tag;
        rowIdx=rowIdx+2;

        InitialConditionSetting=create_widget(source,h,'InitialConditionSetting',rowIdx,2,2);
        InitialConditionSetting.RowSpan=[rowIdx,rowIdx];
        InitialConditionSetting.ColSpan=[1,maxCol];
        showICMode=true;
        InitialConditionSetting.Enabled=showICMode;
        InitialConditionSetting.Visible=showICMode;
        InitialConditionSetting.DialogRefresh=true;
        rowIdx=rowIdx+1;

        SampleTime=Simulink.SampleTimeWidget.getCustomDdgWidget(...
        source,h,'SampleTime','SampleTimeType',rowIdx,2,2,true,...
        Simulink.SampleTimeWidget.getSampleTimeMask('InheritedPeriodic'));

        if slfeature('EnableAdvancedSampleTimeWidget')==0
            SampleTime.NameLocation=2;
        end
        SampleTime.RowSpan=[rowIdx,rowIdx+1];
        SampleTime.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        LimitOutput=create_widget(source,h,'LimitOutput',rowIdx,2,2);
        LimitOutput.RowSpan=[rowIdx,rowIdx];
        LimitOutput.ColSpan=[1,maxCol];
        LimitOutput.DialogRefresh=true;
        rowIdx=rowIdx+1;

        UpperSaturationLimit=create_widget(source,h,'UpperSaturationLimit',rowIdx,2,2);
        UpperSaturationLimit.NameLocation=2;
        UpperSaturationLimit.RowSpan=[rowIdx,rowIdx+1];
        UpperSaturationLimit.ColSpan=[1,maxCol];
        UpperSaturationLimit.Enabled=isequal(h.LimitOutput,'on');
        scalingTags.UpperLimitTag=UpperSaturationLimit.Tag;
        rowIdx=rowIdx+2;

        LowerSaturationLimit=create_widget(source,h,'LowerSaturationLimit',rowIdx,2,2);
        LowerSaturationLimit.NameLocation=2;
        LowerSaturationLimit.RowSpan=[rowIdx,rowIdx+1];
        LowerSaturationLimit.ColSpan=[1,maxCol];
        LowerSaturationLimit.Enabled=isequal(h.LimitOutput,'on');
        scalingTags.LowerLimitTag=LowerSaturationLimit.Tag;
        rowIdx=rowIdx+2;

        ShowSaturationPort=create_widget(source,h,'ShowSaturationPort',rowIdx,2,2);
        ShowSaturationPort.RowSpan=[rowIdx,rowIdx];
        ShowSaturationPort.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        ShowStatePort=create_widget(source,h,'ShowStatePort',rowIdx,2,2);
        ShowStatePort.RowSpan=[rowIdx,rowIdx];
        ShowStatePort.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        IgnoreLimit=create_widget(source,h,'IgnoreLimit',rowIdx,2,2);
        IgnoreLimit.RowSpan=[rowIdx,rowIdx];
        IgnoreLimit.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
        spacer.ColSpan=[1,maxCol+1];

        thisTab.Name=DAStudio.message('Simulink:dialog:Main');

        thisTab.Items={IntegratorMethod,GainValue,ExternalReset,...
        InitialConditionSource,InitialCondition,InitialConditionSetting,...
        SampleTime,LimitOutput,UpperSaturationLimit,LowerSaturationLimit,...
        ShowSaturationPort,ShowStatePort,IgnoreLimit,spacer};

        thisTab.LayoutGrid=[rowIdx,maxCol+1];
        thisTab.ColStretch=[ones(1,maxCol),0];
        thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];


        function thisTab=get_signal_attributes_tab(source,h,scalingTags)


            rowIdx=1;
            maxCol=2;

            OutMin=create_widget(source,h,'OutMin',rowIdx,2,2);
            OutMin.NameLocation=2;
            OutMin.RowSpan=[rowIdx,rowIdx+1];
            OutMin.ColSpan=[1,1];
            OutMin.Enabled=~source.isHierarchySimulating;

            OutMin.MatlabMethod='slDDGUtil';
            OutMin.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

            OutMax=create_widget(source,h,'OutMax',rowIdx,2,2);
            OutMax.NameLocation=2;
            OutMax.RowSpan=[rowIdx,rowIdx+1];
            OutMax.ColSpan=[2,maxCol];
            OutMax.Enabled=~source.isHierarchySimulating;

            OutMax.MatlabMethod='slDDGUtil';
            OutMax.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};
            rowIdx=rowIdx+2;





            DataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
            DataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
            DataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('IR_BP');
            DataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('Num');


            DataTypeItems.scalingMinTag={OutMin.Tag};
            DataTypeItems.scalingMaxTag={OutMax.Tag};
            DataTypeItems.scalingValueTags={scalingTags.UpperLimitTag,...
            scalingTags.initValTag,scalingTags.LowerLimitTag};


            DataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
            'OutDataTypeStr',...
            DAStudio.message('Simulink:dialog:DataDataTypePrompt'),'OutDataTypeStr',...
            h.OutDataTypeStr,DataTypeItems,false);
            DataTypeGroup.RowSpan=[rowIdx,rowIdx];
            DataTypeGroup.ColSpan=[1,2];
            DataTypeGroup.Enabled=~source.isHierarchySimulating;

            rowIdx=rowIdx+1;

            lockOutScale=create_widget(source,h,'LockScale',rowIdx,2,2);
            lockOutScale.RowSpan=[rowIdx,rowIdx];
            lockOutScale.ColSpan=[1,maxCol];
            rowIdx=rowIdx+1;

            RndMeth=create_widget(source,h,'RndMeth',rowIdx,2,2);
            RndMeth.RowSpan=[rowIdx,rowIdx];
            RndMeth.ColSpan=[1,maxCol];
            rowIdx=rowIdx+1;

            SaturateOnIntegerOverflow=create_widget(source,h,'SaturateOnIntegerOverflow',rowIdx,2,2);
            SaturateOnIntegerOverflow.RowSpan=[rowIdx,rowIdx];
            SaturateOnIntegerOverflow.ColSpan=[1,maxCol];
            rowIdx=rowIdx+1;

            spacer.Name='';
            spacer.Type='text';
            spacer.RowSpan=[rowIdx,rowIdx];
            spacer.ColSpan=[1,maxCol+1];

            thisTab.Name=DAStudio.message('Simulink:dialog:SignalAttributes');
            thisTab.Items={OutMin,OutMax,DataTypeGroup,lockOutScale,...
            RndMeth,SaturateOnIntegerOverflow,spacer};

            thisTab.LayoutGrid=[rowIdx,maxCol+1];
            thisTab.ColStretch=[ones(1,maxCol),0];
            thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];


            function thisTab=get_state_attributes_tab(source,h,sigObjCache)



                options.StateNamePrm='StateName';
                options.StorageClassPrm='RTWStateStorageClass';
                options.TypeQualifierPrm='RTWStateStorageTypeQualifier';
                options.NeedSpacer=true;
                options.IgnoreNameWidget=false;
                thisTab=populateCodeGenWidgets(source,h,sigObjCache,options);
                thisTab.Items=sldialogs('align_names',thisTab.Items);
                thisTab.Name=DAStudio.message('Simulink:dialog:StateAttributes');

