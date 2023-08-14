function lib(libInfo)

    libName=pm_message('sm:library:framesAndTransforms:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[strrep(libName,newline,' '),' Library'];
    libInfo.DVGIconKey='SMLibrary.frames_transforms_lib';
