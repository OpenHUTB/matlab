function dlgstruct=getVerifyDetailsSchema(hStep,dlgstruct)




    listOfSites='<html><table HEIGHT="100%" WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=2><tbody>';
    listSize=0;
    customLicenseNotes='';
    nameList='';
    newLineString=sprintf('\n');
    try
        hSetup=hStep.getSetup();
        isMultiple=(numel(hSetup.SelectedPackage)>1);
        for k=1:numel(hSetup.SelectedPackage)
            spPkgInfo=hSetup.PackageInfo(hSetup.SelectedPackage(k));
            nameList=[nameList,newLineString,spPkgInfo.FullName];%#ok<AGROW>
            dispWarning=~isequal(spPkgInfo.Action,...
            DAStudio.message('hwconnectinstaller:setup:SelectPackage_Install'));%#ok<*NASGU>
            if isMultiple&&~isempty(spPkgInfo.TpPkgInfo)
                line=['<tr><td>'...
                ,spPkgInfo.FullName...
                ,'</td></tr>'];
                listOfSites=[listOfSites,line,char(10)];%#ok<AGROW>
            end
            for i=1:numel(spPkgInfo.TpPkgInfo)
                if isempty(spPkgInfo.TpPkgInfo(i).LicenseUrl)
                    line=['<tr><td>'...
                    ,spPkgInfo.TpPkgInfo(i).Name...
                    ,'</td><td>'...
                    ,spPkgInfo.TpPkgInfo(i).Url];
                else
                    line=['<tr><td>'...
                    ,spPkgInfo.TpPkgInfo(i).Name...
                    ,'</td><td>'...
                    ,spPkgInfo.TpPkgInfo(i).Url...
                    ,'</td><td><a href="matlab:web('''...
                    ,spPkgInfo.TpPkgInfo(i).LicenseUrl...
                    ,''',''-browser'')">license</a></td></tr>'];
                end
                listOfSites=[listOfSites,line,char(10)];%#ok<AGROW>
                listSize=listSize+1;
            end
            if isMultiple
                line='<tr></tr>';
                listOfSites=[listOfSites,line,char(10)];%#ok<AGROW>
            end
            licenseText=hwconnectinstaller.util.getCustomLicense(spPkgInfo.CustomLicenseNotes);
            customLicenseNotes=[customLicenseNotes,licenseText];%#ok<AGROW>
        end
    catch ex
        warning(ex.identifier,ex.message);
        dispWarning=false;
    end
    listOfSites=[listOfSites,'</tbody></table></html>'];


    Intro.Name=hStep.StepData.Labels.Introduction;
    Intro.Type='text';
    Intro.RowSpan=[2,2];
    Intro.ColSpan=[1,4];

    ListSites.Text=listOfSites;
    ListSites.Type='textbrowser';
    ListSites.RowSpan=[3,4];
    ListSites.ColSpan=[1,5];
    ListSites.Graphical=true;
    ListSites.MaximumSize=[10000,15*(listSize+5)];
    ListSites.BackgroundColor=[0,0,0];
    ListSites.ForegroundColor=[237,237,237];
    ListSites.Tag=[hStep.ID,'_Step_ListOfSites'];

    if~isempty(customLicenseNotes)
        note=sprintf(customLicenseNotes);
    else
        note=['<html><body><table HEIGHT="100%" WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0><tbody><tr><td>'...
        ,strrep(hStep.StepData.Labels.LicenseNote,char(10),'</td></tr><tr><td>')...
        ,'</td></tr></tbody></table></body></html>'];
    end
    LicenseNote.Text=note;
    LicenseNote.Type='textbrowser';
    LicenseNote.RowSpan=[5,5];
    LicenseNote.ColSpan=[1,5];


    WarningIcon.FilePath=hStep.StepData.Icon;
    WarningIcon.Type='image';
    WarningIcon.RowSpan=[6,6];
    WarningIcon.ColSpan=[1,1];
    WarningIcon.Visible=false;

    WarningMessage.Name=hStep.StepData.Labels.Warning;
    WarningMessage.Type='text';
    WarningMessage.RowSpan=[6,6];
    WarningMessage.ColSpan=[2,4];
    WarningMessage.Visible=false;

    descIndex=hStep.findDialogWidget(dlgstruct,'Description');
    dlgstruct.Items{descIndex}.Name=DAStudio.message('hwconnectinstaller:setup:VerifyDetails_Description',nameList);
    dlgstruct.Items{end+1}=Intro;
    dlgstruct.Items{end+1}=ListSites;
    dlgstruct.Items{end+1}=LicenseNote;
    dlgstruct.Items{end+1}=WarningIcon;
    dlgstruct.Items{end+1}=WarningMessage;




