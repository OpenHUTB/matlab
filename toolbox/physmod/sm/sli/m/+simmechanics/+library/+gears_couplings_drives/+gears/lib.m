function lib(libInfo)

    libName=pm_message('sm:library:gearsAndCouplings:gears:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[libName,' Library'];
    libInfo.DVGIconKey='SMLibrary.gears_lib';
