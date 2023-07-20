function altPath=emcAltPathName(path)



    if ispc
        altPath=coder.make.internal.transformPaths(path,'ignoreErrors',true,'pathType','alternate','mapUNCPaths',true);
        if contains(altPath,' ')
            coderprivate.warnBacktraceOff(message('Coder:common:NoShortPathName',altPath))
        end
    else
        altPath=regexprep(strtrim(path),'([^\\]) ','$1\\ ');
    end

