function lib(libInfo)

    libName=pm_message('sm:library:curvesSurfaces:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[libName,' Library'];
    libInfo.DVGIconKey='SMLibrary.curves_surfaces_lib';
