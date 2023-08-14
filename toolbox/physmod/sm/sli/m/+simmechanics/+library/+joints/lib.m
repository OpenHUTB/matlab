function lib(libInfo)

    libName=pm_message('sm:library:joints:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[libName,' Library'];
    libInfo.DVGIconKey='SMLibrary.joints_lib';