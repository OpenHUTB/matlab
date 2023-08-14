function lib(libInfo)

    libName=pm_message('sm:library:bodyElements:flexibleBodies:platesShells:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=sprintf('%s',[libName,' Library']);
    libInfo.DVGIconKey='SMLibrary.plates_shells_lib';
