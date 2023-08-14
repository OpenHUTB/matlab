function refreshchildrencache(rt,reload)










    global loadedTbl;

    if isempty(loadedTbl)||reload

        loadedTbl=[];

        for idx=1:length(rt.children)
            loadedTbl(end+1).Name=rt.children(idx).Name;%#ok
            loadedTbl(end).hTblTree=rt.children(idx).handle;%#ok
            if strcmpi(rt.children(idx).Type,'TflRegistry')
                library=rt.children(idx);
                for idy=1:length(library.children)
                    loadedTbl(end+1).Name=library.children(idy).Name;%#ok
                    loadedTbl(end).hTblTree=library.children(idy).handle;%#ok
                end
            end
        end
    else

        loadedTbl(end+1).Name=rt.children(end).Name;
        loadedTbl(end).hTblTree=rt.children(end).handle;

    end

