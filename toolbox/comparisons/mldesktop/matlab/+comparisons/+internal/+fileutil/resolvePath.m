function fullpath=resolvePath(fname)

    try
        fullpath=builtin('_canonicalizepath',fname);
    catch
        fp=matlab.depfun.internal.which.callWhich(fname);
        if isempty(fp)
            error(message('comparisons:mldesktop:FileNotFound',fname))
        else
            try
                fullpath=builtin('_canonicalizepath',fp);
            catch
                error(message('comparisons:mldesktop:FileNotFound',fname))
            end
        end
    end

end
