function err=checkValidVarNameStringExtended(s)





    err=slvariants.internal.config.utils.checkValidVarNameString(s);
    if isempty(err)
        return;
    end


    err=[];

    warnstate=warning;
    warning('off','MATLAB:namelengthmaxexceeded');
    try






        eval(strcat(s,'=0;'));

        if contains(s,'%')
            ok=false;
        else

            s=strtrim(s);


            var=strsplit(s,{'.','(',')','{','}'});
            ok=isvarname(var{1});

        end

    catch ex %#ok<NASGU>


        ok=false;
    end
    warning(warnstate);
    if~ok
        err=MException(message('Simulink:Variants:InvalidVariableName'));
    end
end
