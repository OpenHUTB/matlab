function unregisterCustomImporter(this,obj,ext)



    validateattributes(obj,{'io.reader'},{'scalar'});
    toRemove=class(obj);


    if isstring(ext)
        ext=cellstr(ext);
    elseif ischar(ext)
        ext={ext};
    end


    for idx=1:length(ext)
        curExt=lower(ext{idx});
        if~isempty(curExt)&&curExt(1)~='.'
            curExt=['.',curExt];%#ok<AGROW>
        end

        if isKey(this.CustomParsers,curExt)
            importers=getDataByKey(this.CustomParsers,curExt);
            for idx2=1:numel(importers)
                if isa(importers{idx2},toRemove)
                    importers(idx2)=[];
                    break
                end
            end
            if isempty(importers)
                deleteDataByKey(this.CustomParsers,curExt);
            else
                insert(this.CustomParsers,curExt,importers);
            end
        end
    end
end
