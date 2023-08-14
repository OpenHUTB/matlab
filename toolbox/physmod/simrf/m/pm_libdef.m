function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/simrf/m');
    lib.Object.package.name='simrfV2_internal';
    lib.Name='simrfV2_internal';
    lib.Product='Simscape';
    lib.Protect=true;
    icon=PmSli.Icon;
    lib.Icon=icon;
    lib.Descriptor=sprintf('SimRF Internal');
    entry(1)=NetworkEngine.LibraryEntry(lib,'internal');
end
