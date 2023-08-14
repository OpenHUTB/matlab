function dlgStruct=delay_ddg(source,h)






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
    paramGrp.Tabs{end+1}=get_data_and_algorithm_tab(source,h);
    paramGrp.Tabs{end+1}=get_state_attributes_tab(source,h,sigObjCache);





    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag='Delay';

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




    function thisTab=get_data_and_algorithm_tab(source,h)


        dlFromDlg=strcmp(h.DelayLengthSource,'Dialog');
        icFromDlg=strcmp(h.InitialConditionSource,'Dialog');

        titleRowIdx=1;
        DelayRowIdx=2;
        ICRowIdx=3;



        c1=1;
        c2=1;
        c3=1;
        c4=1;









        dataCurCol=1;

        sP.Name='';
        sP.Type='text';
        sP.RowSpan=[titleRowIdx,titleRowIdx];
        sP.ColSpan=[dataCurCol,dataCurCol+c1-1];


        delayPrompt.Name=DAStudio.message('Simulink:dialog:DelayLength');
        delayPrompt.Type='text';
        delayPrompt.RowSpan=[DelayRowIdx,DelayRowIdx];
        delayPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];
        delayPrompt.Tag='DelayLength_Prompt_Tag';
        delayPrompt.Buddy='DelayLength';


        ICPrompt.Name=DAStudio.message('Simulink:dialog:InitialCondition');
        ICPrompt.Type='text';
        ICPrompt.RowSpan=[ICRowIdx,ICRowIdx];
        ICPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];
        ICPrompt.Tag='InitialCondition_Prompt_Tag';
        ICPrompt.Buddy='InitialCondition';

        dataCurCol=dataCurCol+c1;


        srcPrompt.Name=DAStudio.message('Simulink:dialog:Source');
        srcPrompt.Type='text';
        srcPrompt.RowSpan=[titleRowIdx,titleRowIdx];
        srcPrompt.ColSpan=[dataCurCol,dataCurCol+c2-1];


        DelayLengthSource=create_widget(source,h,'DelayLengthSource',DelayRowIdx,2,2);
        DelayLengthSource.Name='';
        DelayLengthSource.RowSpan=[DelayRowIdx,DelayRowIdx];
        DelayLengthSource.ColSpan=[dataCurCol,dataCurCol+c2-1];
        DelayLengthSource.DialogRefresh=true;



        ICSource=create_widget(source,h,'InitialConditionSource',ICRowIdx,2,2);
        ICSource.Name='';
        ICSource.RowSpan=[ICRowIdx,ICRowIdx];
        ICSource.ColSpan=[dataCurCol,dataCurCol+c2-1];
        ICSource.DialogRefresh=true;


        dataCurCol=dataCurCol+c2;


        valuePrompt.Name=DAStudio.message('Simulink:dialog:Value');
        valuePrompt.Type='text';
        valuePrompt.RowSpan=[titleRowIdx,titleRowIdx];
        valuePrompt.ColSpan=[dataCurCol,dataCurCol+c3-1];

        DelayLengthValue=create_widget(source,h,'DelayLength',DelayRowIdx,2,2);
        DelayLengthValue.Name='';
        DelayLengthValue.RowSpan=[DelayRowIdx,DelayRowIdx];
        DelayLengthValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
        if dlFromDlg
            DelayLengthValue.Enabled=true;
            DelayLengthValue.Visible=true;
        else
            DelayLengthValue.Enabled=false;
            DelayLengthValue.Visible=false;
        end

        DelayValueBox.Name='';
        DelayValueBox.Type='edit';
        DelayValueBox.RowSpan=[DelayRowIdx,DelayRowIdx];
        DelayValueBox.ColSpan=[dataCurCol,dataCurCol+c3-1];
        DelayValueBox.Enabled=false;
        if dlFromDlg
            DelayValueBox.Visible=false;
        else
            DelayValueBox.Visible=true;
        end

        ICValue=create_widget(source,h,'InitialCondition',ICRowIdx,2,2);
        ICValue.Name='';
        ICValue.RowSpan=[ICRowIdx,ICRowIdx];
        ICValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
        if icFromDlg
            ICValue.Enabled=true;
            ICValue.Visible=true;
        else
            ICValue.Enabled=false;
            ICValue.Visible=false;

        end


        ICValueBox.Name='';
        ICValueBox.Type='edit';
        ICValueBox.RowSpan=[ICRowIdx,ICRowIdx];
        ICValueBox.ColSpan=[dataCurCol,dataCurCol+c3-1];
        ICValueBox.Enabled=false;
        if icFromDlg
            ICValueBox.Visible=false;
        else
            ICValueBox.Visible=true;
        end


        dataCurCol=dataCurCol+c3;

        isVariableDelay=~dlFromDlg;


        maxDelayPrompt.Name=DAStudio.message('Simulink:dialog:UpperLimit');
        maxDelayPrompt.Type='text';
        maxDelayPrompt.RowSpan=[titleRowIdx,titleRowIdx];
        maxDelayPrompt.ColSpan=[dataCurCol,dataCurCol+c4-1];

        DelayUpLimValue=create_widget(source,h,'DelayLengthUpperLimit',DelayRowIdx,2,2);
        DelayUpLimValue.Name='';
        DelayUpLimValue.RowSpan=[DelayRowIdx,DelayRowIdx];
        DelayUpLimValue.ColSpan=[dataCurCol,dataCurCol+c4-1];
        if isVariableDelay
            DelayUpLimValue.Enabled=~source.isHierarchySimulating;
            DelayUpLimValue.Visible=true;
        else
            DelayUpLimValue.Enabled=false;
            DelayUpLimValue.Visible=false;
        end

        DelayUpLimBox.Name='';
        DelayUpLimBox.Type='edit';
        DelayUpLimBox.RowSpan=[DelayRowIdx,DelayRowIdx];
        DelayUpLimBox.ColSpan=[dataCurCol,dataCurCol+c4-1];
        DelayUpLimBox.Enabled=false;
        if isVariableDelay
            DelayUpLimBox.Visible=false;
        else
            DelayUpLimBox.Visible=true;
        end

        dataCurCol=dataCurCol+c4;
        dataMaxCol=dataCurCol-1;



        algCurCol=dataCurCol;
        rowIdx=ICRowIdx+1;


        [InputProc_Prompt,InputProc_Value]=create_widget(source,h,'InputProcessing',rowIdx,2,2);
        InputProc_Prompt.RowSpan=[rowIdx,rowIdx];
        InputProc_Prompt.ColSpan=[1,1];

        InputProc_Value.RowSpan=[rowIdx,rowIdx];
        InputProc_Value.ColSpan=[2,algCurCol-1];

        rowIdx=rowIdx+1;


        CirBuffer=create_widget(source,h,'UseCircularBuffer',rowIdx,2,2);
        CirBuffer.RowSpan=[rowIdx,rowIdx];
        CirBuffer.ColSpan=[1,algCurCol];
        rowIdx=rowIdx+1;



        DisableDirect=create_widget(source,h,'PreventDirectFeedthrough',rowIdx,2,2);
        DisableDirect.RowSpan=[rowIdx,rowIdx];
        DisableDirect.ColSpan=[1,algCurCol];
        rowIdx=rowIdx+1;
        DisableDirect.Enabled=~source.isHierarchySimulating&&isVariableDelay;
        DisableDirect.Visible=isVariableDelay;


        CheckDelay=create_widget(source,h,'RemoveDelayLengthCheckInGeneratedCode',rowIdx,2,2);
        CheckDelay.RowSpan=[rowIdx,rowIdx];
        CheckDelay.ColSpan=[1,algCurCol];
        if isVariableDelay
            CheckDelay.Enabled=~source.isHierarchySimulating;
            CheckDelay.Visible=true;
        else
            CheckDelay.Enabled=false;
            CheckDelay.Visible=false;
        end

        rowIdx=rowIdx+1;



        Diagnostic=create_widget(source,h,'DiagnosticForDelayLength',rowIdx,2,2);
        Diagnostic.RowSpan=[rowIdx,rowIdx];
        Diagnostic.ColSpan=[1,algCurCol-1];
        if isVariableDelay
            Diagnostic.Enabled=~source.isHierarchySimulating;
            Diagnostic.Visible=true;
        else
            Diagnostic.Enabled=false;
            Diagnostic.Visible=false;
        end

        algMaxCol=algCurCol;



        ctrlCurCol=algCurCol;
        ctrlMaxCol=ctrlCurCol;

        rowIdx=rowIdx+1;


        EnablePort=create_widget(source,h,'ShowEnablePort',rowIdx,2,2);
        EnablePort.RowSpan=[rowIdx,rowIdx];
        EnablePort.ColSpan=[1,ctrlCurCol-1];

        rowIdx=rowIdx+1;


        [ResetPort_Prompt,ResetPort_Value]=create_widget(source,h,'ExternalReset',rowIdx,2,2);
        ResetPort_Prompt.RowSpan=[rowIdx,rowIdx];
        ResetPort_Prompt.ColSpan=[1,1];

        ResetPort_Value.RowSpan=[rowIdx,rowIdx];
        ResetPort_Value.ColSpan=[2,ctrlCurCol-1];

        rowIdx=rowIdx+1;




        dataGroup.Name=DAStudio.message('Simulink:dialog:SigpropGrpDataName');
        dataGroup.Type='group';
        dataGroup.RowSpan=[titleRowIdx,ICRowIdx];
        dataGroup.ColSpan=[1,dataMaxCol];
        dataGroup.LayoutGrid=[...
        dataGroup.RowSpan(2)-dataGroup.RowSpan(1)+1...
        ,dataGroup.ColSpan(2)-dataGroup.ColSpan(1)+1];
        dataGroup.ColStretch=[ones(1,c1),ones(1,c2),6*ones(1,c3),ones(1,c4)];

        dataGroup.Items={sP...
        ,delayPrompt...
        ,ICPrompt...
        ,srcPrompt...
        ,valuePrompt...
        ,DelayLengthSource...
        ,ICSource...
        ,DelayLengthValue...
        ,DelayValueBox...
        ,ICValue...
        ,ICValueBox...
        ,maxDelayPrompt...
        ,DelayUpLimBox...
        ,DelayUpLimValue};


        ctrlGroup.Name=DAStudio.message('Simulink:dialog:GroupControlPort');
        ctrlGroup.Type='group';
        ctrlGroup.RowSpan=[EnablePort.RowSpan(1),ResetPort_Value.RowSpan(2)];
        ctrlGroup.ColSpan=[1,ctrlMaxCol];
        ctrlGroup.LayoutGrid=[...
        ctrlGroup.RowSpan(2)-ctrlGroup.RowSpan(1)+1...
        ,ctrlGroup.ColSpan(2)-ctrlGroup.ColSpan(1)+1];
        ctrlGroup.ColStretch=ones(1,ctrlMaxCol);
        ctrlGroup.Items={EnablePort...
        ,ResetPort_Prompt...
        ,ResetPort_Value};


        algGroup.Name=DAStudio.message('Simulink:dialog:AlgorithmTab');
        algGroup.Type='group';
        algGroup.RowSpan=[InputProc_Prompt.RowSpan(1),Diagnostic.RowSpan(2)];
        algGroup.ColSpan=[1,algMaxCol];
        algGroup.LayoutGrid=[...
        algGroup.RowSpan(2)-algGroup.RowSpan(1)+1...
        ,algGroup.ColSpan(2)-algGroup.ColSpan(1)+1];
        algGroup.ColStretch=ones(1,algMaxCol);

        algGroup.Items={InputProc_Prompt...
        ,InputProc_Value...
        ,CirBuffer...
        ,DisableDirect...
        ,CheckDelay...
        ,Diagnostic};




        ts=Simulink.SampleTimeWidget.getCustomDdgWidget(...
        source,h,'SampleTime','',rowIdx,2,2,true,...
        Simulink.SampleTimeWidget.getSampleTimeMask('InheritedPeriodic'));
        ts.RowSpan=[rowIdx,rowIdx];
        ts.ColSpan=[1,dataMaxCol];
        rowIdx=rowIdx+1;

        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
        spacer.ColSpan=[1,dataMaxCol];

        thisTab.Items={dataGroup...
        ,algGroup...
        ,ctrlGroup...
        ,ts...
        ,spacer};

        thisTab.Name=DAStudio.message('Simulink:dialog:ModelTabOneName');
        thisTab.LayoutGrid=[rowIdx,dataMaxCol];
        thisTab.ColStretch=ones(1,dataMaxCol);
        thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];



        function thisTab=get_state_attributes_tab(source,h,sigObjCache)



            options.StateNamePrm='StateName';
            options.StorageClassPrm='CodeGenStateStorageClass';
            options.TypeQualifierPrm='CodeGenStateStorageTypeQualifier';
            options.NeedSpacer=true;
            options.IgnoreNameWidget=false;
            thisTab=populateCodeGenWidgets(source,h,sigObjCache,options);
            thisTab.Items=sldialogs('align_names',thisTab.Items);
            thisTab.Name=DAStudio.message('Simulink:dialog:StateAttributes');
