

function fout=getFunctionType(fin,fname,mdl,isTopMdl)




    if strcmp(fin,'output')...
        &&strcmp(get_param(mdl,'CombineOutputUpdateFcns'),'on')
        if isTopMdl...
            &&~isempty(strfind(fname,mdl))
            fout='step';
        else
            fout='output and update';
        end
    else
        fout=fin;
    end



end
