function fHandle=function_handle(func)






    if ischar(func)

        [fpath,fname]=fileparts(func);
        if isempty(fpath)
            fHandle=str2func(fname);
        else


            fullfunc=which(func);
            if isempty(fullfunc)
                fullfunc=func;
            end
            fHandle=pm_pathtofunctionhandle(fullfunc);
        end
    elseif isa(func,'function_handle')
        fHandle=func;
    else
        pm_error('physmod:common:foundation:mli:util:function:InvalidFunction');
    end
