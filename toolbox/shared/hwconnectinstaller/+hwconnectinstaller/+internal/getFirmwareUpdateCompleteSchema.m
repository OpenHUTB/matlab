function dlgstruct=getFirmwareUpdateCompleteSchema(hStep,dlgstruct)





    CheckBox.Name=hStep.StepData.Labels.DemoCheckbox;
    CheckBox.Type='checkbox';
    CheckBox.RowSpan=[4,4];
    CheckBox.ColSpan=[1,3];
    CheckBox.Tag=[hStep.ID,'_Step_CheckBox'];
    CheckBox.MatlabMethod='dialogCallback';
    CheckBox.MatlabArgs={hStep,'CheckBox','%tag','%value'};

    CheckBox.Value=hStep.StepData.Checkbox;
    hSetup=hStep.getSetup();
    fwUdpater=hSetup.FwUpdater;





    try
        spRoot=matlabshared.supportpkg.internal.getSupportPackageRootNoCreate();
    catch
        spRoot='';
    end
    if isdir(spRoot)&&~isempty(matlabshared.supportpkg.internal.ssi.getBaseCodesHavingExamples(...
        cellstr(fwUdpater.BaseCodeForSelectedSpPkg),spRoot))
        CheckBox.Visible=true;
    else
        CheckBox.Visible=false;
    end

    CheckBox.DialogRefresh=true;


    dlgstruct.Items{3}.Visible=false;
    dlgstruct.Items{6}.Visible=false;
    dlgstruct.Items{end+1}=CheckBox;
