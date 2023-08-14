function ext=getLibraryExtension(type)



    if ispc
        switch(type)
        case 'import'
            ext='.lib';
        case 'dynamic'
            ext='.dll';
        case 'static'
            ext='.lib';
        end
    elseif ismac
        switch(type)
        case 'import'
            ext='.dylib';
        case 'dynamic'
            ext='.dylib';
        case 'static'
            ext='.a';
        end
    else
        switch(type)
        case 'import'
            ext='.so';
        case 'dynamic'
            ext='.so';
        case 'static'
            ext='.a';
        end
    end


