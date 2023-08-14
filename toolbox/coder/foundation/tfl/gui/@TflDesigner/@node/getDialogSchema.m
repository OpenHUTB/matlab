function dlgstruct=getDialogSchema(this,name)%#ok<INUSD>






    switch(this.Type)

    case 'TflTable'

        tablenameEdit.Name=DAStudio.message('RTW:tfldesigner:NodeNameText');
        tablenameEdit.Type='edit';
        tablenameEdit.RowSpan=[1,1];
        tablenameEdit.ColSpan=[1,4];
        tablenameEdit.Value=this.getPropValue('Tfldesigner_Name');
        tablenameEdit.Tag='Tfldesigner_Name';
        tablenameEdit.ObjectMethod='setproperties';
        tablenameEdit.MethodArgs={'%dialog','%tag'};
        tablenameEdit.ArgDataTypes={'handle','string'};

        versionLbl.Name=DAStudio.message('RTW:tfldesigner:VersionText');
        versionLbl.Type='text';
        versionLbl.RowSpan=[2,2];
        versionLbl.ColSpan=[1,2];
        versionLbl.Tag='Tfldesigner_VersionLbl';

        version.Name=this.getPropValue('Tfldesigner_Version');
        version.Type='text';
        version.RowSpan=[2,2];
        version.ColSpan=[3,4];
        version.Tag='Tfldesigner_Version';

        totalEntriesLbl.Name=DAStudio.message('RTW:tfldesigner:NumEntriesText');
        totalEntriesLbl.Type='text';
        totalEntriesLbl.RowSpan=[3,3];
        totalEntriesLbl.ColSpan=[1,2];
        totalEntriesLbl.Tag='Tfldesigner_TotalEntriesLbl';

        totalEntries.Name=num2str(length(this.children));
        totalEntries.Type='text';
        totalEntries.RowSpan=[3,3];
        totalEntries.ColSpan=[3,4];
        totalEntries.Tag='Tfldesigner_TotalEntries';

        panelProp.Type='panel';
        panelProp.LayoutGrid=[3,4];
        panelProp.RowSpan=[1,1];
        panelProp.ColSpan=[1,4];
        panelProp.RowStretch=zeros(1,3);
        panelProp.ColStretch=zeros(1,4);
        panelProp.Items={tablenameEdit,versionLbl,version,...
        totalEntriesLbl,totalEntries};

        Inst.Text=DAStudio.message('RTW:tfldesigner:TableInstrucText');
        Inst.Type='textbrowser';
        Inst.RowSpan=[1,5];
        Inst.ColSpan=[1,4];
        Inst.Tag='Tfldesigner_TableDescription';

        Instpanel.Type='panel';
        Instpanel.LayoutGrid=[5,4];
        Instpanel.RowSpan=[2,8];
        Instpanel.ColSpan=[1,4];
        Instpanel.RowStretch=ones(1,5);
        Instpanel.ColStretch=zeros(1,4);
        Instpanel.Items={Inst};

        grpProp.Type='group';
        grpProp.Name=DAStudio.message('RTW:tfldesigner:PropertiesText');
        grpProp.LayoutGrid=[8,4];
        grpProp.RowStretch=ones(1,8);
        grpProp.ColStretch=zeros(1,4);
        grpProp.Items={panelProp,Instpanel};

        if~isempty(strfind(this.Name,'.mat'))...
            ||strcmpi(this.Name,'HitCache')...
            ||strcmpi(this.Name,'MissCache')...
            ||strcmpi(this.Name,'TLCCallList')...
            ||~isempty(strfind(this.Name,'.p'))
            grpProp.Enabled=false;
        end



        dlgstruct.DialogTitle=this.name;
        dlgstruct.Source=this;
        dlgstruct.EmbeddedButtonSet={'Help','Apply'};
        dlgstruct.Items={grpProp};
        dlgstruct.PreApplyMethod='applyproperties';
        dlgstruct.PreApplyArgsDT={'handle'};
        dlgstruct.PreApplyArgs={'%dialog'};
        dlgstruct.HelpMethod='helpview';
        dlgstruct.HelpArgs=...
        {[docroot,'/toolbox/ecoder/helptargets.map'],'tfl_base'};

    case 'TflRegistry'

        tr=RTW.TargetRegistry.get;

        lineN=1;
        NameLbl.Name=DAStudio.message('RTW:tfldesigner:NodeNameText');
        NameLbl.Type='text';
        NameLbl.RowSpan=[lineN,lineN];
        NameLbl.ColSpan=[1,2];
        Name.Name=this.object.Name;
        Name.Type='text';
        Name.RowSpan=[lineN,lineN];
        Name.ColSpan=[4,5];

        lineN=lineN+1;
        DscLbl.Name=DAStudio.message('RTW:tfldesigner:DescriptionText');
        DscLbl.Type='text';
        DscLbl.RowSpan=[lineN,lineN];
        DscLbl.ColSpan=[1,2];
        Dsc.Name=this.object.Description;
        Dsc.Type='text';
        Dsc.RowSpan=[lineN,lineN];
        Dsc.ColSpan=[4,5];

        lineN=lineN+1;
        BaseTflLbl.Name=DAStudio.message('RTW:tfldesigner:BaseTFLText');
        BaseTflLbl.Type='text';
        BaseTflLbl.RowSpan=[lineN,lineN];
        BaseTflLbl.ColSpan=[1,2];
        try
            BaseTfl.Name=coder.internal.getTfl(tr,this.object.BaseTfl).Name;
        catch %#ok<CTCH>
            BaseTfl.Name='';
        end
        BaseTfl.Type='text';
        BaseTfl.RowSpan=[lineN,lineN];
        BaseTfl.ColSpan=[4,5];

        lineN=lineN+1;
        NumEnLbl.Name=DAStudio.message('RTW:tfldesigner:NumTablesText');
        NumEnLbl.Type='text';
        NumEnLbl.RowSpan=[lineN,lineN];
        NumEnLbl.ColSpan=[1,2];
        NumEn.Name=num2str(length(this.children));
        NumEn.Type='text';
        NumEn.RowSpan=[lineN,lineN];
        NumEn.ColSpan=[4,5];

        SpcLbl.Name='     ';
        SpcLbl.Type='text';
        SpcLbl.RowSpan=[lineN,lineN];
        SpcLbl.ColSpan=[3,3];

        grpSummary.Type='group';
        grpSummary.Name=DAStudio.message('RTW:tfldesigner:SummaryText');
        grpSummary.LayoutGrid=[lineN,5];
        grpSummary.ColStretch=[0,0,0,1,1];
        grpSummary.RowSpan=[1,2];
        grpSummary.ColSpan=[1,5];
        grpSummary.Items={...
        DscLbl,Dsc,...
        NameLbl,Name,...
        BaseTflLbl,BaseTfl,...
        NumEnLbl,NumEn,...
        SpcLbl};


        txt1=DAStudio.message('RTW:tfldesigner:RegistryText');
        tableList=coder.internal.getTflTableList(tr,this.object.Name);
        [dummyList,Ia]=setdiff(tableList,{'private_ansi_tfl_table_tmw.mat','private_iso_tfl_table_tmw.mat'});
        if~isempty(dummyList)
            tableList=tableList(sort(Ia));
        end
        if~isempty(tableList)
            txt2=[DAStudio.message('RTW:tfldesigner:RegistryTableListText')...
            ,sprintf(' %s <br>',tableList{:})];
        else
            txt2=DAStudio.message('RTW:tfldesigner:RegistryEmptyListText');
        end
        Inst.Text=[txt1,txt2];
        Inst.Type='textbrowser';
        Inst.RowSpan=[3,5];
        Inst.ColSpan=[1,5];


        dlgstruct.DialogTitle=this.object.Name;
        dlgstruct.LayoutGrid=[5,5];
        dlgstruct.RowStretch=[0,0,1,1,1];
        dlgstruct.EmbeddedButtonSet={''};
        dlgstruct.Items={grpSummary,Inst};

    end

    me=TflDesigner.getexplorer;
    if~isempty(me)
        me.imme.selectListViewNode(this);
    end




