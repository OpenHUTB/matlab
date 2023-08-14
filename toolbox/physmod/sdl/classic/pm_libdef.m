function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/sdl/classic');
    lib.Object.package.name='sdl_classic';
    lib.Name='sdl_classic';
    lib.Product='SimDriveline';
    lib.Protect=true;
    icon=PmSli.Icon;
    lib.Icon=icon;
    lib.Descriptor=sprintf('SimDriveline Classic');
    entry(1)=NetworkEngine.LibraryEntry(lib,'internal');
end
