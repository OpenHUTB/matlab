function dlgstruct=getInstallCompleteSchema(hStep,dlgstruct)



    hSetup=hStep.getSetup();

    spNameText=[];
    for i=1:numel(hSetup.SelectedPackage)
        spNameText=[spNameText,hSetup.PackageInfo(hSetup.SelectedPackage(i)).FullName,sprintf('\n')];%#ok<*AGROW>
    end
    isMultiplePackage=(numel(hSetup.SelectedPackage)>1);

    if hSetup.InstallerWorkflow.isDownload

        hStep.StepData.DemoCheckbox=false;
        hStep.StepData.ExtraInfoCheckbox=false;
        dlgstruct.DialogTitle=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Label_Download'));
        descIndex=hStep.findDialogWidget(dlgstruct,'Description');
        finalDownloadDir=hSetup.Installer.getMostRecentDownloadOnlyDirectory();
        finalDownloadDirMultiple='';
        if isMultiplePackage
            pkgNames={hSetup.PackageInfo(hSetup.SelectedPackage).Name};
            for i=1:numel(pkgNames)
                pkgtag=hwconnectinstaller.SupportPackage.getPkgTag(pkgNames{i});
                finalDownloadDirMultiple=[finalDownloadDirMultiple,char(10),fullfile(fileparts(finalDownloadDir),[pkgtag,'_download'])];
            end
            msgString=message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description_Download_Multiple'),spNameText,finalDownloadDirMultiple).getString();
        else
            msgString=message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description_Download'),spNameText,finalDownloadDir).getString();
        end
        dlgstruct.Items{descIndex}.Name=msgString;

        backIndex=hStep.findDialogWidget(dlgstruct,'Back');
        dlgstruct.Items{backIndex}.Visible=false;
        nextIndex=hStep.findDialogWidget(dlgstruct,'Next');
        dlgstruct.Items{nextIndex}.Visible=false;
        finishIndex=hStep.findDialogWidget(dlgstruct,'Finish');
        dlgstruct.Items{finishIndex}.Visible=true;
        cancelIndex=hStep.findDialogWidget(dlgstruct,'Cancel');
        dlgstruct.Items{cancelIndex}.Visible=false;
    elseif hSetup.InstallerWorkflow.isUninstall

        hStep.StepData.DemoCheckbox=false;
        hStep.StepData.ExtraInfoCheckbox=false;
        dlgstruct.DialogTitle=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Label_Uninstall'));
        descIndex=hStep.findDialogWidget(dlgstruct,'Description');
        if isMultiplePackage
            dlgstruct.Items{descIndex}.Name=sprintf(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description_Uninstall_Multiple'),spNameText));
        else
            dlgstruct.Items{descIndex}.Name=sprintf(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description_Uninstall'),spNameText));
        end
        backIndex=hStep.findDialogWidget(dlgstruct,'Back');
        dlgstruct.Items{backIndex}.Visible=false;
        nextIndex=hStep.findDialogWidget(dlgstruct,'Next');
        dlgstruct.Items{nextIndex}.Visible=false;
        finishIndex=hStep.findDialogWidget(dlgstruct,'Finish');
        dlgstruct.Items{finishIndex}.Visible=true;
        cancelIndex=hStep.findDialogWidget(dlgstruct,'Cancel');
        dlgstruct.Items{cancelIndex}.Visible=false;
    else


        needDemoCheckbox=false;
        needExtrainfoCheckbox=false;
        extrainfoText='';

        hInstaller=hSetup.getInstaller();
        for i=1:numel(hSetup.SelectedPackage)
            try
                pkgName=hSetup.PackageInfo(hSetup.SelectedPackage(i)).Name;
                sp=hInstaller.getSpPkgInfo(pkgName,struct('missingInfoAction','error'));
                needFirmwareUpdate=hwconnectinstaller.util.isFirmwareUpdateAvailable(sp);
                if~isempty(sp.DemoXml)
                    needDemoCheckbox=true;
                end
                if~isempty(sp.ExtraInfoCheckBoxCmd)
                    needExtrainfoCheckbox=true;
                end
                if~isempty(sp.ExtraInfoCheckBoxDescription)
                    newLineString=sprintf('');
                    extrainfoText=[extrainfoText,newLineString,sp.ExtraInfoCheckBoxDescription];
                end
            catch ex
                sp=hwconnectinstaller.SupportPackage();%#ok<*NASGU>
                warning(ex.identifier,ex.message);
            end
        end



        if needFirmwareUpdate
            LongDescription.Name=hStep.StepData.Labels.LongDescription;
            LongDescription.Type='text';
            LongDescription.RowSpan=[3,4];
            LongDescription.ColSpan=[1,4];

            if isMultiplePackage
                dlgstruct.Items{1}.Name=sprintf(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description_Multiple'),spNameText));
            else
                dlgstruct.Items{1}.Name=sprintf(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description'),spNameText));
            end
            dlgstruct.Items{4}.Name=hStep.StepData.Labels.Continue;
            dlgstruct.Items{6}.Name=hStep.StepData.Labels.Close;
            dlgstruct.Items{end+1}=LongDescription;
            dlgstruct.Items{3}.Visible=false;
        else

            if isMultiplePackage
                dlgstruct.Items{1}.Name=sprintf(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description_Multiple'),spNameText));
            else
                dlgstruct.Items{1}.Name=sprintf(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:InstallComplete_Description'),spNameText));
            end
            dlgstruct.Items{3}.Visible=false;
            dlgstruct.Items{4}.Visible=false;
            dlgstruct.Items{5}.Visible=true;
            dlgstruct.Items{6}.Visible=false;


            CheckBox.Name=hStep.StepData.Labels.DemoCheckbox;
            CheckBox.Type='checkbox';
            CheckBox.RowSpan=[4,4];
            CheckBox.ColSpan=[1,3];
            CheckBox.Tag=[hStep.ID,'_Step_DemoCheckBox'];
            CheckBox.MatlabMethod='dialogCallback';
            CheckBox.MatlabArgs={hStep,'DemoCheckBox','%tag','%value'};

            if~needDemoCheckbox
                CheckBox.Value=false;
                CheckBox.Visible=false;
                hStep.StepData.DemoCheckbox=false;
            else
                CheckBox.Value=hStep.StepData.DemoCheckbox;
                CheckBox.Visible=true;
            end

            dlgstruct.Items{end+1}=CheckBox;


            if isempty(extrainfoText)
                CheckBox.Name=hStep.StepData.Labels.ExtraInfoCheckbox;
            else
                CheckBox.Name=extrainfoText;
            end

            CheckBox.Type='checkbox';
            CheckBox.RowSpan=[6,6];
            CheckBox.ColSpan=[1,3];
            CheckBox.Tag=[hStep.ID,'_Step_ExtraInfoCheckBox'];
            CheckBox.MatlabMethod='dialogCallback';
            CheckBox.MatlabArgs={hStep,'ExtraInfoCheckBox','%tag','%value'};

            if~needExtrainfoCheckbox
                CheckBox.Value=false;
                CheckBox.Visible=false;
                hStep.StepData.ExtraInfoCheckbox=false;
            else
                CheckBox.Value=hStep.StepData.ExtraInfoCheckbox;
                CheckBox.Visible=true;
            end

            CheckBox.DialogRefresh=true;
            dlgstruct.Items{end+1}=CheckBox;
        end
    end

