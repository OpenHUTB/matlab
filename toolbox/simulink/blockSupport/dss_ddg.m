function dlgStruct=dss_ddg(source,h)






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
    paramGrp.Tabs{end+1}=get_main_tab(source,h);
    paramGrp.Tabs{end+1}=get_state_attributes_tab(source,h,sigObjCache);





    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,newline,' ')));
    dlgStruct.DialogTag='DSS';

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


    function thisTab=get_main_tab(source,h)


        rowIdx=1;
        maxCol=1;

        A=create_widget(source,h,'A',rowIdx,2,2);
        A.NameLocation=2;
        A.RowSpan=[rowIdx,rowIdx+1];
        A.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        B=create_widget(source,h,'B',rowIdx,2,2);
        B.NameLocation=2;
        B.RowSpan=[rowIdx,rowIdx+1];
        B.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        C=create_widget(source,h,'C',rowIdx,2,2);
        C.NameLocation=2;
        C.RowSpan=[rowIdx,rowIdx+1];
        C.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        D=create_widget(source,h,'D',rowIdx,2,2);
        D.NameLocation=2;
        D.RowSpan=[rowIdx,rowIdx+1];
        D.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        X0=create_widget(source,h,'InitialCondition',rowIdx,2,2);
        X0.NameLocation=2;
        X0.RowSpan=[rowIdx,rowIdx+1];
        X0.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        SampleTime=Simulink.SampleTimeWidget.getCustomDdgWidget(...
        source,h,'SampleTime','',rowIdx,2,2,true);

        if slfeature('EnableAdvancedSampleTimeWidget')==0
            SampleTime.NameLocation=2;
        end
        SampleTime.RowSpan=[rowIdx,rowIdx+1];
        SampleTime.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
        spacer.ColSpan=[1,maxCol+1];

        thisTab.Name=DAStudio.message('Simulink:dialog:Main');
        thisTab.Items={A,B,C,D,X0,SampleTime,spacer};

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
