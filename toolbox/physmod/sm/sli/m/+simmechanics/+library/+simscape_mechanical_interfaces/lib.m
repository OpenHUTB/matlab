function lib(libInfo)



    libName=pm_message('sm:library:simscape_mechanical_interfaces:Name');
    libInfo.SLBlockProperties.Name=libName;
    libInfo.Annotation=[libName,' Library'];
    libInfo.DVGIconKey='SMLibrary.simscape_mechanical_interfaces_lib';

    libInfo.SLBlockProperties.OpenFcn=...
    'simmechanics.library.helper.load_open_subsystem(''fl_lib'',''fl_lib/Mechanical/Multibody Interfaces'');';
