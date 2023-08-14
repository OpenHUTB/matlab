function dlgstruct=getDialogSchema(this,name)%#ok





    ResourcePath=fullfile(fileparts(mfilename('fullpath')),'..','resources');

    namedescLbl.Name=DAStudio.message('RTW:tfldesigner:SLNameText');
    namedescLbl.Type='text';
    namedescLbl.RowSpan=[1,1];
    namedescLbl.ColSpan=[1,1];
    namedescLbl.ToolTip=DAStudio.message('RTW:tfldesigner:RegistryNameTooltip');

    namedesc.Type='edit';
    namedesc.RowSpan=[1,1];
    namedesc.ColSpan=[2,8];
    namedesc.Tag='Tfldesigner_RegistryName';
    namedesc.ToolTip=DAStudio.message('RTW:tfldesigner:RegistryNameTooltip');
    namedescLbl.Buddy=namedesc.Tag;


    tablelistLbl.Name=DAStudio.message('RTW:tfldesigner:SLTableListText');
    tablelistLbl.Type='text';
    tablelistLbl.RowSpan=[2,2];
    tablelistLbl.ColSpan=[1,1];
    tablelistLbl.ToolTip=DAStudio.message('RTW:tfldesigner:TableListTooltip');

    tablelist.Type='edit';
    tablelist.RowSpan=[2,2];
    tablelist.ColSpan=[2,8];
    tablelist.Tag='Tfldesigner_RegistryTableList';
    tablelist.ToolTip=DAStudio.message('RTW:tfldesigner:TableListTooltip');
    tablelistLbl.Buddy=tablelist.Tag;


    basetflLbl.Name=DAStudio.message('RTW:tfldesigner:SLBaseTflText');
    basetflLbl.Type='text';
    basetflLbl.RowSpan=[3,3];
    basetflLbl.ColSpan=[1,1];
    basetflLbl.ToolTip=DAStudio.message('RTW:tfldesigner:BaseTflTooltip');

    i=RTW.TargetRegistry.get;
    refreshCRL(i);
    n=i.TargetFunctionLibraries;
    for k=1:length(n)
        index(k)=n(k).IsVisible;%#oktogrow
    end
    basetfl.Type='combobox';
    basetfl.Entries=['None',{n(index).Name},'<Custom>'];
    basetfl.Editable=true;
    basetfl.RowSpan=[3,3];
    basetfl.ColSpan=[2,8];
    basetfl.Tag='Tfldesigner_RegistryBaseTfl';
    basetfl.ToolTip=DAStudio.message('RTW:tfldesigner:BaseTflTooltip');
    basetflLbl.Buddy=basetfl.Tag;


    tgthwdeviceLbl.Name=DAStudio.message('RTW:tfldesigner:SLTgtHwDeviceText');
    tgthwdeviceLbl.Type='text';
    tgthwdeviceLbl.RowSpan=[4,4];
    tgthwdeviceLbl.ColSpan=[1,1];
    tgthwdeviceLbl.ToolTip=DAStudio.message('RTW:tfldesigner:HWDeviceTooltip');

    tgthwdevice.Type='edit';
    tgthwdevice.RowSpan=[4,4];
    tgthwdevice.ColSpan=[2,8];
    tgthwdevice.Tag='Tfldesigner_RegistryTargetHWDevice';
    tgthwdevice.ToolTip=DAStudio.message('RTW:tfldesigner:HWDeviceTooltip');
    tgthwdeviceLbl.Buddy=tgthwdevice.Tag;


    descLbl.Name=DAStudio.message('RTW:tfldesigner:SLDescriptionText');
    descLbl.Type='text';
    descLbl.RowSpan=[5,5];
    descLbl.ColSpan=[1,1];
    descLbl.ToolTip=DAStudio.message('RTW:tfldesigner:RegistryDescriptionTooltip');

    desc.Type='edit';
    desc.RowSpan=[5,5];
    desc.ColSpan=[2,8];
    desc.Tag='Tfldesigner_RegistryDescription';
    desc.ToolTip=DAStudio.message('RTW:tfldesigner:RegistryDescriptionTooltip');
    descLbl.Buddy=desc.Tag;

    genalignspec.Name=DAStudio.message('RTW:tfldesigner:GenAlignSpec');
    genalignspec.Tag='Tfldesigner_GenAlignSpec';
    genalignspec.Type='checkbox';
    genalignspec.Source=this;
    genalignspec.Value=this.speccount~=0;
    genalignspec.ObjectMethod='setproperties';
    genalignspec.MethodArgs={'%dialog',{genalignspec.Tag}};
    genalignspec.ArgDataTypes={'handle','mxArray'};
    genalignspec.DialogRefresh=true;
    genalignspec.RowSpan=[7,7];
    genalignspec.ColSpan=[1,8];


    registrypanel.Type='panel';
    registrypanel.LayoutGrid=[7,8];
    registrypanel.RowSpan=[1,1];
    registrypanel.ColSpan=[1,8];
    registrypanel.RowStretch=zeros(1,7);
    registrypanel.ColStretch=ones(1,8);
    registrypanel.Items={namedescLbl,namedesc,tablelistLbl,tablelist,...
    basetflLbl,basetfl,tgthwdeviceLbl,tgthwdevice,...
    descLbl,desc,genalignspec};

    dataalign=[];
    if this.speccount
        row=0;

        dataalign=this.getDataAlignmentDlgGroup(1);
        dataalign.RowSpan=[row+1,row+2];
        dataalign.ColSpan=[1,8];
        row=row+3;

        for i=2:this.speccount
            p=this.getDataAlignmentDlgGroup(i);
            p.RowSpan=[row+1,row+2];
            p.ColSpan=[1,8];
            dataalign(end+1)=p;%#ok
            p=[];%#ok
            row=row+3;
        end

        adddataspecpushbutton.Name='+';
        adddataspecpushbutton.Type='pushbutton';
        adddataspecpushbutton.RowSpan=[row+1,row+1];
        adddataspecpushbutton.ColSpan=[1,1];
        adddataspecpushbutton.Tag='Tfldesigner_AddDataSpecButton';
        adddataspecpushbutton.Enabled=true;
        adddataspecpushbutton.Visible=true;
        adddataspecpushbutton.ObjectMethod='adddataalignspec';
        adddataspecpushbutton.MethodArgs={'%dialog'};
        adddataspecpushbutton.ArgDataTypes={'handle'};
        adddataspecpushbutton.DialogRefresh=true;
        adddataspecpushbutton.ToolTip=DAStudio.message('RTW:tfldesigner:AddSpecButtonToolTip');

        removedataspecpushbutton.Type='pushbutton';
        removedataspecpushbutton.RowSpan=[row+1,row+1];
        removedataspecpushbutton.ColSpan=[2,2];
        removedataspecpushbutton.Tag='Tfldesigner_RemoveDataSpecButton';
        removedataspecpushbutton.Enabled=this.speccount>1;
        removedataspecpushbutton.Visible=true;
        removedataspecpushbutton.ObjectMethod='removedataalignspec';
        removedataspecpushbutton.MethodArgs={'%dialog'};
        removedataspecpushbutton.ArgDataTypes={'handle'};
        removedataspecpushbutton.DialogRefresh=true;
        removedataspecpushbutton.ToolTip=DAStudio.message('RTW:tfldesigner:RemoveButtonToolTip');
        removedataspecpushbutton.FilePath=fullfile(ResourcePath,'delete.png');


        specpanel.Type='panel';
        specpanel.LayoutGrid=[row,8];
        specpanel.RowSpan=[2,2];
        specpanel.ColSpan=[1,8];
        specpanel.RowStretch=ones(1,row);
        specpanel.ColStretch=ones(1,8);
        specpanel.Items={adddataspecpushbutton,removedataspecpushbutton};

        for i=1:length(dataalign)
            specpanel.Items=[specpanel.Items,dataalign(i)];
        end
    end

    registrygroup.Type='group';
    registrygroup.LayoutGrid=[3,1];
    registrygroup.RowStretch=ones(1,3);
    registrygroup.ColStretch=ones(1,1);
    if~isempty(dataalign)
        registrygroup.Items={registrypanel,specpanel};
    else
        registrygroup.Items={registrypanel};
    end




    dlgstruct.DialogTitle=DAStudio.message('RTW:tfldesigner:SLDialogTitleText');
    dlgstruct.Sticky=true;
    dlgstruct.PreApplyMethod='applyproperties';
    dlgstruct.PreApplyArgsDT={'handle'};
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.Items={registrygroup};
    dlgstruct.StandaloneButtonSet={'OK','Cancel'};
    dlgstruct.DefaultOk=false;


