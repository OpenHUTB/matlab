function dlgstruct=getCustomLicenseTPSchema(hStep,dlgstruct)





    hSetup=hStep.getSetup();
    pkgName=hSetup.PackageInfo(hSetup.SelectedPackage).Name;
    sp=hSetup.Installer.getSpPkgObject(pkgName,hSetup.WebSpPkg);
    ListSites.Text=DAStudio.message('hwconnectinstaller:setup:USRP_Ettus_license');
    ListSites.Type='textbrowser';
    ListSites.RowSpan=[3,4];
    ListSites.ColSpan=[1,5];
    ListSites.Graphical=true;
    ListSites.MaximumSize=[10000,15*(numel(sp.TpPkg)+5)];
    ListSites.BackgroundColor=[0,0,0];
    ListSites.ForegroundColor=[237,237,237];
    ListSites.Tag=[hStep.ID,'_Step_ListOfSites'];

    LicenseButton.Name=sprintf('\t\t%s\t\t',DAStudio.message('hwconnectinstaller:setup:USRP_Ettus_web'));
    LicenseButton.Type='pushbutton';
    LicenseButton.RowSpan=[5,5];
    LicenseButton.ColSpan=[1,1];
    LicenseButton.MatlabMethod='web(''http://www.ettus.com/license-tmw'')';

    dlgstruct.DialogTitle=DAStudio.message('hwconnectinstaller:setup:USRP_Ettus_title');

    dlgstruct.Items{end+1}=ListSites;
    dlgstruct.Items{end+1}=LicenseButton;



