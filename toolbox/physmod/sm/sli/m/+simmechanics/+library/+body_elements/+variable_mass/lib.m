function lib(libInfo)

    libName=pm_message('sm:library:bodyElements:variableMass:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[libName,' Library'];
    libInfo.DVGIconKey='SMLibrary.variable_mass_lib';
