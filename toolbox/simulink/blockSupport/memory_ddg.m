function dlgStruct=memory_ddg(source,h)






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
    dlgStruct.DialogTag='Memory';

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
        maxCol=4;

        InitCondition=create_widget(source,h,'InitialCondition',rowIdx,2,2);
        InitCondition.NameLocation=2;
        InitCondition.RowSpan=[rowIdx,rowIdx+1];
        InitCondition.ColSpan=[1,maxCol];
        rowIdx=rowIdx+2;

        InheritSampleTime=create_widget(source,h,'InheritSampleTime',rowIdx,2,2);
        InheritSampleTime.RowSpan=[rowIdx,rowIdx];
        InheritSampleTime.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        LinearizeMemory=create_widget(source,h,'LinearizeMemory',rowIdx,2,2);
        LinearizeMemory.RowSpan=[rowIdx,rowIdx];
        LinearizeMemory.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        LinearizeAsDelay=create_widget(source,h,'LinearizeAsDelay',rowIdx,2,2);
        LinearizeAsDelay.RowSpan=[rowIdx,rowIdx];
        LinearizeAsDelay.ColSpan=[1,maxCol];
        rowIdx=rowIdx+1;

        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
        spacer.ColSpan=[1,maxCol+1];

        thisTab.Name=DAStudio.message('Simulink:dialog:Main');
        thisTab.Items={InitCondition,InheritSampleTime,...
        LinearizeMemory,LinearizeAsDelay,spacer};

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
