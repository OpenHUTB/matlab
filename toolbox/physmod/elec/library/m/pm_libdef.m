function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/elec/library/m');
    lib.Object.package.name='ee';
    lib.Name='ee';
    lib.Product='Power_System_Blocks';
    lib.Protect=true;
    icon=PmSli.Icon;
    icon.setImage('ee.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Electrical');
    entry(1)=NetworkEngine.LibraryEntry(lib,'simscape');
    entry(1)=ee_customizelibdef(entry(1));
end
