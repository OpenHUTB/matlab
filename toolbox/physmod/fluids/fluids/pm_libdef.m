function entry=pm_libdef

    lib.Object.package.path=fullfile(matlabroot,'toolbox/physmod/fluids/fluids');
    lib.Object.package.name='fluids';
    lib.Name='SimscapeFluids';
    lib.Product='SimHydraulics';
    lib.Protect=true;
    icon=PmSli.Icon;
    icon.setImage('fluids.jpg');
    lib.Icon=icon;
    lib.Descriptor=sprintf('Fluids');
    entry(1)=NetworkEngine.LibraryEntry(lib,'simscape');
    entry(1).DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn('hydro/index.html','hydro/ref');
    entry(1)=fluids.internal.customLibDef(entry(1));
end
