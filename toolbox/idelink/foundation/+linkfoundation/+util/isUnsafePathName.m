function isUnsafe=isUnsafePathName(dirName)




    if~isempty(regexp(dirName,'.*[!@$^&*~?.|[]<>`";#()].*','ONCE'))
        isUnsafe=true;
    else
        isUnsafe=false;
    end
end