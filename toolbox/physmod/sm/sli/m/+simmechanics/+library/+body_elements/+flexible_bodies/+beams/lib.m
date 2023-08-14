function lib(libInfo)

    libName=pm_message('sm:library:bodyElements:flexibleBodies:beams:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=sprintf('%s',[libName,' Library']);
    libInfo.DVGIconKey='SMLibrary.beams_lib';
