function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/battery/shared_library/m');
    lib.Object.package.name='batteryecm';
    lib.Name='batteryecm';
    lib.Product='Simscape';
    lib.Protect=true;
    icon=PmSli.Icon;
    lib.Icon=icon;
    lib.Descriptor=sprintf('Equivalent Circuit Battery Components');
    entry(1)=NetworkEngine.LibraryEntry(lib,'internal');
    entry(1)=batteryecmlibdef(entry(1));
end
