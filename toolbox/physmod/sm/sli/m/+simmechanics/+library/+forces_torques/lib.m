function lib(libInfo)

    libName=pm_message('sm:library:forcesAndTorques:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[strrep(libName,newline,' '),' Library'];
    libInfo.DVGIconKey='SMLibrary.forces_torques_lib';
