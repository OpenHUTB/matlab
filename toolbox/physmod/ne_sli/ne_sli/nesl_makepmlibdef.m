function entry=nesl_makepmlibdef(lib,varargin)








    narginchk(1,2);

    entry=NetworkEngine.LibraryEntry(lib,varargin{:});

end


