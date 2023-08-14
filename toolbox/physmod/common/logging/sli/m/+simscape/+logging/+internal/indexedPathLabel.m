function str=indexedPathLabel(indexedPath)




    str='';
    if~isempty(indexedPath)
        str=indexedPath{1};
    end

    for idx=2:numel(indexedPath)
        id=indexedPath{idx};
        if isnumeric(id)
            str=[str,'(',lSubs2Str(id),')'];%#ok<AGROW>
        else
            str=[str,'.',id];%#ok<AGROW>
        end
    end

end

function str=lSubs2Str(subs)







    str=strjoin(arrayfun(@int2str,subs,'UniformOutput',false),', ');

end
