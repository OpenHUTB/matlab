function hObj=LibraryEntry(lib,varargin)









    narginchk(1,2);
    name=[lib.Name,'_lib'];
    hObj=NetworkEngine.LibraryEntry;
    hObj.initialize(name,lib.Product,varargin{:});

    hObj.Object=lib.Object;
    hObj.Icon=lib.Icon;
    hObj.Protect=lib.Protect;
    hObj.Descriptor=lib.Descriptor;
    hObj.EditingModeFcn='ne_editingmodecallback';
end
