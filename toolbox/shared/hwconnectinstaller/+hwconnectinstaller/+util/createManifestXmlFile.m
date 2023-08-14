function xmlfile=createManifestXmlFile(SupportPkg,outputdir)






    if exist(fullfile(outputdir,SupportPkg.XmlFile),'file')==2
        delete(fullfile(outputdir,SupportPkg.XmlFile));
    end

    fid=fopen(fullfile(outputdir,SupportPkg.XmlFile),'w');
    if(fid<0)
        error(message('hwconnectinstaller:installapi:FileOpenError',SupportPkg.XmlFile));
    end
    c=onCleanup(@()fclose(fid));


    fprintf(fid,'<?xml version="1.0"?>\n');
    fprintf(fid,'<!--Copyright %s The MathWorks, Inc. -->\n',date);
    fprintf(fid,'<PackageRepository>\n');
    fprintf(fid,'    <MatlabRelease name="%s">\n',SupportPkg.Release);
    fprintf(fid,'        <SupportPackage\n');
    fprintf(fid,'            name="%s"\n',SupportPkg.Name);
    fprintf(fid,'            version="%s"\n',SupportPkg.Version);
    fprintf(fid,'            platform="%s"\n',SupportPkg.PlatformStr);
    fprintf(fid,'            visible="%d"\n',SupportPkg.Visible);
    fprintf(fid,'            enable="%d"\n',SupportPkg.Enable);
    fprintf(fid,'            url="%s"\n',SupportPkg.Url);
    fprintf(fid,'            baseproduct="%s"\n',SupportPkg.BaseProduct);
    fprintf(fid,'            basecode="%s"\n',SupportPkg.BaseCode);
    fprintf(fid,'            supporttypequalifier="%s"\n',SupportPkg.SupportTypeQualifier);
    fprintf(fid,'            custommwlicensefiles="%s"\n',SupportPkg.CustomMWLicenseFiles);
    if SupportPkg.AllowDownloadWithoutInstall
        fprintf(fid,'            allowdownloadwithoutinstall="yes"\n');
    else
        fprintf(fid,'            allowdownloadwithoutinstall="no"\n');
    end
    fprintf(fid,'            fullname="%s"\n',SupportPkg.FullName);
    fprintf(fid,'            displayname="%s"\n',SupportPkg.DisplayName);
    fprintf(fid,'            supportcategory="%s"\n',SupportPkg.SupportCategory);
    fprintf(fid,'            customlicense="%s"\n',SupportPkg.CustomLicense);
    fprintf(fid,'            customlicensenotes="%s"\n',SupportPkg.CustomLicenseNotes);
    fprintf(fid,'            infohyperlink="%s"\n',SupportPkg.InfoUrl);
    fprintf(fid,'            infotext="%s"\n',SupportPkg.InfoText);

    if SupportPkg.ShowSPLicense
        fprintf(fid,'            showsplicense="yes"\n');
    else
        fprintf(fid,'            showsplicense="no"\n');
    end
    fprintf(fid,'            downloadurl="%s"\n',SupportPkg.DownloadUrl);
    fprintf(fid,'            licenseurl="%s"\n',SupportPkg.LicenseUrl);
    fprintf(fid,'            folder="%s">\n',SupportPkg.Folder);

    for i=1:length(SupportPkg.Children)
        fprintf(fid,'        <DependsOn name="%s" version="%s"></DependsOn>\n',...
        SupportPkg.Children(i).Name,...
        SupportPkg.Children(i).Version);
    end


    for i=1:length(SupportPkg.TpPkg)
        fprintf(fid,'            <ThirdPartyPackage name="%s" platforms="%s" url="%s" licenseurl="%s"></ThirdPartyPackage>\n',...
        SupportPkg.TpPkg(i).Name,...
        SupportPkg.TpPkg(i).PlatformStr,...
        SupportPkg.TpPkg(i).Url,...
        SupportPkg.TpPkg(i).LicenseUrl);
    end
    fprintf(fid,'        </SupportPackage>\n');
    fprintf(fid,'    </MatlabRelease>\n');
    fprintf(fid,'</PackageRepository>\n');


    xmlfile=fullfile(outputdir,SupportPkg.XmlFile);
end
