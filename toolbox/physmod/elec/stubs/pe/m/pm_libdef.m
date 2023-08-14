function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/elec/stubs/pe/m');
    lib.Object.package.name='pe';
    lib.Name='pe';
    lib.Product='Power_System_Blocks';
    lib.Protect=true;
    icon=PmSli.Icon;
    icon.setImage('pe.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Power Systems Stubs');
    entry(1)=NetworkEngine.LibraryEntry(lib,'no_context');
end
