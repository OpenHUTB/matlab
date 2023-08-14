function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/battery/library/m');
    lib.Object.package.name='batt';
    lib.Name='batt';
    lib.Product='simscape_battery';
    lib.Protect=true;
    icon=PmSli.Icon;
    icon.setImage('batt.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Battery');
    entry(1)=NetworkEngine.LibraryEntry(lib,'simscape');
    entry(1)=batt_customizelibdef(entry(1));
end
