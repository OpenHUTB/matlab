function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/simscape/library/m/physical_signal_legacy');
    lib.Object.package.name='foundation';
    lib.Name='fl_ps_legacy';
    lib.Product='Simscape';
    lib.Protect=false;
    icon=PmSli.Icon;
    lib.Icon=icon;
    lib.Descriptor=sprintf('Legacy\nPhysical\nSignals');
    entry(1)=NetworkEngine.LibraryEntry(lib,'internal');
end
