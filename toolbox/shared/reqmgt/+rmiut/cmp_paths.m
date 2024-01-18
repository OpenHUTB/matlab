function result=cmp_paths(first,second)

    if ispc
        result=strcmp(unify_path(first),unify_path(second));
    else
        result=strcmp(first,second);
    end
end


function unified=unify_path(myPath)
    unified=strrep(lower(myPath),'\','/');
end
