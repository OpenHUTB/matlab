function dlgstruct=variantconfigurationddg(h,name)









    descTxt.Name=DAStudio.message('Simulink:dialog:VariantConfigurationDataObject');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name='Simulink.VariantConfigurationData';
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,2];






    buttonToLaunchVariantManager.Name=DAStudio.message('Simulink:dialog:Edit');
    buttonToLaunchVariantManager.Type='pushbutton';
    buttonToLaunchVariantManager.Enabled=true;
    buttonToLaunchVariantManager.RowSpan=[2,2];
    buttonToLaunchVariantManager.ColSpan=[1,1];
    buttonToLaunchVariantManager.Tag='EditButton';
    buttonToLaunchVariantManager.MatlabMethod='variantmanager';
    buttonToLaunchVariantManager.MatlabArgs={'EditVarConfigDataObj',name,h};

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[3,3];
    spacer.ColSpan=[1,2];




    dlgstruct.DialogTitle=[class(h),': ',name];
    dlgstruct.Items={descGrp,buttonToLaunchVariantManager,spacer};
    dlgstruct.LayoutGrid=[3,2];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_variantconfiguration_type'};
    dlgstruct.RowStretch=[0,0,1];
    dlgstruct.ColStretch=[0,1];
