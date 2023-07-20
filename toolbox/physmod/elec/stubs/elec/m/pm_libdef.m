function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/elec/stubs/elec/m');
    lib.Object.package.name='elec';
    lib.Name='elec';
    lib.Product='Power_System_Blocks';
    lib.Protect=true;
    icon=PmSli.Icon;
    icon.setImage('elec.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Electronics Stubs');
    entry(1)=NetworkEngine.LibraryEntry(lib,'no_context');
end
