function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/simscape/library/m');
    lib.Object.package.name='foundation';
    lib.Name='fl';
    lib.Product='Simscape';
    lib.Protect=false;
    icon=PmSli.Icon;
    icon.setImage('foundation.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Foundation\nLibrary');
    entry(1)=NetworkEngine.LibraryEntry(lib,'simscape');
end
