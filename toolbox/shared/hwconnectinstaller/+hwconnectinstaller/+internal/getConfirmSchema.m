function dlgstruct=getConfirmSchema(hStep,dlgstruct)



    hSetup=hStep.getSetup();
    spPkgInfo=hSetup.PackageInfo(hSetup.SelectedPackage);

    if hSetup.InstallerWorkflow.isDownload
        listOfSites='<html><table HEIGHT="100%" WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=2><tbody>';
        for k=1:numel(spPkgInfo)
            SPline=['<tr><td>'...
            ,spPkgInfo(k).FullName...
            ,'</td><td>'...
            ,spPkgInfo(k).Url...
            ,'</td></tr>'];
            listOfSites=[listOfSites,SPline];
            try
                for i=1:numel(spPkgInfo(k).TpPkgInfo)

                    line=['<tr><td>'...
                    ,spPkgInfo(k).TpPkgInfo(i).Name...
                    ,'</td><td>'...
                    ,spPkgInfo(k).TpPkgInfo(i).Url];
                    listOfSites=[listOfSites,line,char(10)];%#ok<AGROW>
                end
            catch ex
                warning(ex.identifier,ex.message);
            end
        end

        listOfSites=[listOfSites,'</tbody></table></html>'];


        Intro.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Introduction'));
        Intro.Type='text';
        Intro.RowSpan=[5,5];
        Intro.ColSpan=[1,6];
        Intro.Tag=[hStep.ID,'_Step_Intro'];

        ListSites.Text=listOfSites;
        ListSites.Type='textbrowser';
        ListSites.RowSpan=[6,6];
        ListSites.ColSpan=[1,6];
        ListSites.Graphical=true;
        ListSites.MaximumSize=[10000,15*(numel(spPkgInfo(1).TpPkgInfo)+5)];
        ListSites.BackgroundColor=[0,0,0];
        ListSites.ForegroundColor=[237,237,237];
        ListSites.Tag=[hStep.ID,'_Step_ListOfSites'];

        dlgstruct.Items{end+1}=Intro;
        dlgstruct.Items{end+1}=ListSites;
        folderValue=hSetup.DownloadDir;
        actionText=lower(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Next_Download')));
        adjText=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_In'));
    elseif hSetup.InstallerWorkflow.isUninstall
        folderValue=hSetup.InstallDir;
        actionText=lower(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Next_Uninstall')));
        adjText=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_From'));
    else
        if isempty(hSetup.InstallDir)

            pkgInfo=hSetup.Installer.getSpPkgInfo(spPkgInfo(1).Name,struct('missingInfoAction','error'));
            folderValue=pkgInfo.InstallDir;
        else
            folderValue=hSetup.InstallDir;
        end
        actionText=lower(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Next_Install')));
        adjText=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_In'));
    end
    descIndex=hStep.findDialogWidget(dlgstruct,'Description');


    nameList='';
    newLineString=sprintf('\n');
    for i=1:numel(spPkgInfo)
        nameList=[nameList,newLineString,spPkgInfo(i).FullName];
    end
    nameText=[actionText,newLineString,nameList,newLineString,newLineString,adjText];
    nameText=[nameText,' ',folderValue];
    dlgstruct.Items{descIndex}.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Description'),...
    nameText);

    nextIndex=hStep.findDialogWidget(dlgstruct,'Next');

    if hSetup.InstallerWorkflow.isDownload
        dlgstruct.Items{nextIndex}.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Next_Download'));
        dlgstruct.DialogTitle=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Label_Download'));
    elseif hSetup.InstallerWorkflow.isUninstall
        dlgstruct.Items{nextIndex}.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Next_Uninstall'));
        dlgstruct.DialogTitle=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Label_Uninstall'));
    else
        dlgstruct.Items{nextIndex}.Name=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Next_Install'));
        dlgstruct.DialogTitle=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Confirm_Label_Install'));
    end
    hMWDownloadManager=hwconnectinstaller.util.download.MWDownloadManager.getInstance();

    if hMWDownloadManager.isDownloading
        backBtnIndex=hStep.findDialogWidget(dlgstruct,'Back');
        dlgstruct.Items{nextIndex}.Enabled=false;
        dlgstruct.Items{backBtnIndex}.Enabled=false;
    end


