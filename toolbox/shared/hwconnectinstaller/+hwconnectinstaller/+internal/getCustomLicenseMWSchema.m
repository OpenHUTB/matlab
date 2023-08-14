function dlgstruct=getCustomLicenseMWSchema(hStep,dlgstruct)





    hSetup=hStep.getSetup();
    pkgName=hSetup.PackageInfo(hSetup.SelectedPackage).Name;
    sp=hSetup.Installer.getSpPkgObject(pkgName,hSetup.WebSpPkg);























































    ListSites.Text=hwconnectinstaller.util.getMathWorksUSRPLicense;
    ListSites.Type='textbrowser';
    ListSites.RowSpan=[1,7];
    ListSites.ColSpan=[1,5];
    ListSites.Graphical=true;
    ListSites.BackgroundColor=[0,0,0];
    ListSites.ForegroundColor=[237,237,237];
    ListSites.Tag=[hStep.ID,'_Step_ListOfSites'];

    dlgstruct.Items{4}.Name=DAStudio.message('hwconnectinstaller:setup:Accept');
    dlgstruct.Items{6}.Name=DAStudio.message('hwconnectinstaller:setup:Decline');

    dlgstruct.DialogTitle=DAStudio.message('hwconnectinstaller:setup:USRP_MathWorks_title');

    dlgstruct.Items{end+1}=ListSites;


