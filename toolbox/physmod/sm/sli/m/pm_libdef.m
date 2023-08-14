function entry=pm_libdef




    libName=pm_message('sm:sli:LibraryBrowserDescription');
    entry=PmSli.LibraryEntry('sm_lib',pm_message('sm:local:util:LicenseName'));
    entry.Descriptor=libName;

    iconFile=fullfile(matlabroot,'toolbox','physmod','sm','sli','m',...
    '+simmechanics','+library','lib.jpg');
    entry.Icon.setImage(iconFile);

    smDocRoot='sm';
    entry.DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn(...
    [smDocRoot,'/index.html'],...
    [smDocRoot,'/ref']);

    entry.EditingModeFcn='simmechanics.sli.internal.editingmode_callback';
end


