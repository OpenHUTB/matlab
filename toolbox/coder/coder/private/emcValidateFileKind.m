





function val=emcValidateFileKind(ext)



    switch ext
    case{'.c','.C','.cc','.cxx','.cpp','.cu'}
        val=1;
    case{'.h','.H','.hh','.hpp','.hxx','.cuh'}
        val=2;
    case{'.a','.so','.dylib','.lib','.o','.obj'}
        val=3;
    case{'.m','.p','.mlx'}
        val=4;
    otherwise
        val=-1;
    end
