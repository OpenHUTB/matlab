function fullpath=resolvePath(fname)





    try
        fullpath=builtin('_canonicalizepath',fname);
    catch
        fp=matlab.depfun.internal.which.callWhich(fname);
        if isempty(fp)
            comparisons.internal.message('error','comparisons:comparisons:FileNotFound',fname);
        else

            try
                fullpath=builtin('_canonicalizepath',fp);
            catch
                comparisons.internal.message('error','comparisons:comparisons:FileNotFound',fname);
            end
        end
    end

end

