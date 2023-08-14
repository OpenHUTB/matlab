function lib(libInfo)



    libName=pm_message('sm:library:beltsCables:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[libName,' Library'];
    libInfo.DVGIconKey='SMLibrary.belts_cables_lib';
