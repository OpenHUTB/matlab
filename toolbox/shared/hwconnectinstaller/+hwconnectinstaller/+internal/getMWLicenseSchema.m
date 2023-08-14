function dlgstruct=getMWLicenseSchema(hStep,dlgstruct)





    hSetup=hStep.getSetup();
    allWebSps={hSetup.WebSpPkg.Name};
    selectedPkgs={hSetup.PackageInfo(hSetup.SelectedPackage).Name};
    selectedWebSps=hSetup.WebSpPkg(ismember(allWebSps,selectedPkgs));






    [License.Text,~,dialogTitle]=hwconnectinstaller.util.getLicenseAndDialogTitle(selectedWebSps(1));

    License.Type='textbrowser';
    License.RowSpan=[1,6];
    License.ColSpan=[1,5];
    License.Graphical=true;
    License.BackgroundColor=[0,0,0];
    License.ForegroundColor=[237,237,237];
    License.Tag=[hStep.ID,'_Step_ListOfSites'];

    AcceptSelection.Type='checkbox';
    AcceptSelection.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:MathWorks_license_accept'));
    AcceptSelection.RowSpan=[7,7];
    AcceptSelection.ColSpan=[1,5];
    AcceptSelection.Tag=[hStep.ID,'_Step_Accept'];
    AcceptSelection.MatlabMethod='dialogCallback';
    AcceptSelection.MatlabArgs={hStep,'EnableNext','%tag','%value','%dialog'};
    AcceptSelection.Value=hStep.EnableNextButton;

    dlgstruct.DialogTitle=dialogTitle;
    dlgstruct.Items{end+1}=License;
    dlgstruct.Items{end+1}=AcceptSelection;

    dlgstruct.Items{4}.Enabled=hStep.EnableNextButton;

    dlgstruct.RowStretch=[0,0,0,0,0,1,0,0];

