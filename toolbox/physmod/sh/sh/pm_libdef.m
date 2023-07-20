function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/sh/sh');
    lib.Object.package.name='sh';
    lib.Name='sh';
    lib.Product='SimHydraulics';
    lib.Protect=true;
    icon=PmSli.Icon;
    icon.setImage('sh.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Simscape Fluids');
    entry(1)=NetworkEngine.LibraryEntry(lib,'');
    entry(1).DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn('hydro/index.html','hydro/ref');
end
