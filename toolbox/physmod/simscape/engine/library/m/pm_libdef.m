function entry=pm_libdef







    entry=PmSli.LibraryEntry('nesl_utility');
    entry.Descriptor=sprintf('Utilities');
    entry.Icon.setImage('nesl_utility.jpg');
    entry.EditingModeFcn='ne_editingmodecallback';
end
