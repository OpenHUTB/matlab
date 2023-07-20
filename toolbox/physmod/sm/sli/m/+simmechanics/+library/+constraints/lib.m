function lib(libInfo)

    libName=pm_message('sm:library:constraints:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[libName,' Library'];
    libInfo.DVGIconKey='SMLibrary.constraints_lib';