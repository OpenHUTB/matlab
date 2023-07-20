function dlgstruct=getDialogSchema(this,type)







    packagenamedescLbl.Name=DAStudio.message('RTW:tfldesigner:PackageNameText');
    packagenamedescLbl.Type='text';
    packagenamedescLbl.RowSpan=[1,1];
    packagenamedescLbl.ColSpan=[1,1];

    packagenamedesc.Type='edit';
    packagenamedesc.RowSpan=[1,1];
    packagenamedesc.ColSpan=[2,8];
    packagenamedesc.Tag='Tfldesigner_PackageName';
    packagenamedescLbl.Buddy=packagenamedesc.Tag;

    entryclassdescLbl.Name=DAStudio.message('RTW:tfldesigner:CustomClassNameText');
    entryclassdescLbl.Type='text';
    entryclassdescLbl.RowSpan=[2,2];
    entryclassdescLbl.ColSpan=[1,1];

    entryclassdesc.Type='edit';
    entryclassdesc.RowSpan=[2,2];
    entryclassdesc.ColSpan=[2,8];
    entryclassdesc.Tag='Tfldesigner_EntryClass';
    entryclassdescLbl.Buddy=entryclassdesc.Tag;

    switch type
    case 'new'

        baseentryclassdescLbl.Name=DAStudio.message('RTW:tfldesigner:BaseEntryTypeText');
        baseentryclassdescLbl.Type='text';
        baseentryclassdescLbl.RowSpan=[3,3];
        baseentryclassdescLbl.ColSpan=[1,1];

        baseentryclassdesc.Type='combobox';
        baseentryclassdesc.RowSpan=[3,3];
        baseentryclassdesc.ColSpan=[2,8];
        baseentryclassdesc.Tag='Tfldesigner_BaseEntryClass';
        baseentryclassdesc.Entries={'RTW.TflCOperationEntryML',...
        'RTW.TflCFunctionEntryML'};
        baseentryclassdescLbl.Buddy=baseentryclassdesc.Tag;

        locationdescLbl.Name=DAStudio.message('RTW:tfldesigner:SaveLocationText');
        locationdescLbl.Type='text';
        locationdescLbl.RowSpan=[4,4];
        locationdescLbl.ColSpan=[1,1];

        locationdesc.Type='edit';
        locationdesc.RowSpan=[4,4];
        locationdesc.ColSpan=[2,7];
        locationdesc.Tag='Tfldesigner_NewLocationCType';
        locationdesc.Value=this.customfilepath;
        locationdescLbl.Buddy=locationdesc.Tag;

        locbutton.Name=DAStudio.message('RTW:tfldesigner:BrowseButtonLabel');
        locbutton.Type='pushbutton';
        locbutton.RowSpan=[4,4];
        locbutton.ColSpan=[8,8];
        locbutton.Tag='Tfldesigner_NewLocationButton';
        locbutton.ObjectMethod='customlocation';
        locbutton.MethodArgs={'%dialog',locbutton.Tag};
        locbutton.ArgDataTypes={'handle','string'};
        locbutton.DialogRefresh=true;

        containgroups.Type='panel';
        containgroups.LayoutGrid=[4,8];
        containgroups.RowSpan=[1,4];
        containgroups.ColSpan=[1,8];
        containgroups.RowStretch=zeros(1,4);
        containgroups.ColStretch=zeros(1,8);
        containgroups.Items={packagenamedescLbl,packagenamedesc,entryclassdescLbl,entryclassdesc,...
        baseentryclassdescLbl,baseentryclassdesc,locationdescLbl,locationdesc,locbutton};

        dlgstruct.DialogTitle=DAStudio.message('RTW:tfldesigner:NewCustomClassDialogTitle');
        dlgstruct.Sticky=true;
        dlgstruct.PreApplyMethod='applyproperties';
        dlgstruct.PreApplyArgsDT={'handle','string'};
        dlgstruct.PreApplyArgs={'%dialog','new'};
        dlgstruct.StandaloneButtonSet={'OK','Cancel'};
        dlgstruct.MinMaxButtons=false;
        dlgstruct.Items={containgroups};

    case 'open'

        locationdescLbl.Name=DAStudio.message('RTW:tfldesigner:LocationText');
        locationdescLbl.Type='text';
        locationdescLbl.RowSpan=[3,3];
        locationdescLbl.ColSpan=[1,1];

        locationdesc.Type='edit';
        locationdesc.RowSpan=[3,3];
        locationdesc.ColSpan=[2,7];
        locationdesc.Tag='Tfldesigner_OpenLocationCType';
        locationdesc.Value=this.customfilepath;
        locationdescLbl.Buddy=locationdesc.Tag;

        locbutton.Name=DAStudio.message('RTW:tfldesigner:BrowseButtonLabel');
        locbutton.Type='pushbutton';
        locbutton.RowSpan=[3,3];
        locbutton.ColSpan=[8,8];
        locbutton.Tag='Tfldesigner_OpenLocationButton';
        locbutton.ObjectMethod='customlocation';
        locbutton.MethodArgs={'%dialog',locbutton.Tag};
        locbutton.ArgDataTypes={'handle','string'};
        locbutton.DialogRefresh=true;

        containgroups.Type='panel';
        containgroups.LayoutGrid=[3,8];
        containgroups.RowSpan=[1,3];
        containgroups.ColSpan=[1,8];
        containgroups.RowStretch=zeros(1,3);
        containgroups.ColStretch=zeros(1,8);
        containgroups.Items={packagenamedescLbl,packagenamedesc,entryclassdescLbl,entryclassdesc,...
        locationdescLbl,locationdesc,locbutton};

        dlgstruct.DialogTitle=DAStudio.message('RTW:tfldesigner:OpenCustomClassDialogTitle');
        dlgstruct.Sticky=true;
        dlgstruct.PreApplyMethod='applyproperties';
        dlgstruct.PreApplyArgsDT={'handle','string'};
        dlgstruct.PreApplyArgs={'%dialog','open'};
        dlgstruct.StandaloneButtonSet={'OK','Cancel'};
        dlgstruct.MinMaxButtons=false;
        dlgstruct.Items={containgroups};
    end



