function libraries=getSupportedLibraries(this)






    if isempty(this.LibraryDB)
        error(message('hdlcoder:engine:invalidDatabase','getSupportedLibraries'));
    end

    libraries=this.LibraryDB;


    libraries=libraries(~strcmpi(libraries(:),'discoverylib'));


