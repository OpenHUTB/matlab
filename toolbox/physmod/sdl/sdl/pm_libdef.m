function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/sdl/sdl');
    lib.Object.package.name='sdl';
    lib.Name='sdl';
    lib.Product='SimDriveline';
    lib.Protect=true;
    icon=PmSli.Icon;
    icon.setImage('sdl.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Driveline');
    entry(1)=NetworkEngine.LibraryEntry(lib,'simscape');
    entry(1).DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn('sdl/index.html','sdl/ref');
end
