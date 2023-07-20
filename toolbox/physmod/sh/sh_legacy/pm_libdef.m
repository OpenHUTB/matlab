function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/sh/sh_legacy');
    lib.Object.package.name='sh_legacy';
    lib.Name='sh_legacy';
    lib.Product='SimHydraulics';
    lib.Protect=true;
    icon=PmSli.Icon;
    lib.Icon=icon;
    lib.Descriptor=sprintf('Hydraulic Legacy Components');
    entry(1)=NetworkEngine.LibraryEntry(lib,'internal');
end
