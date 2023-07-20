function lib(libInfo)

    libName=pm_message('sm:library:gearsAndCouplings:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[strrep(libName,newline,' '),' Library'];
    libInfo.DVGIconKey='SMLibrary.gears_couplings_drives_lib';
