function registerCustomImporter(this,obj,ext)

    validateattributes(obj,{'io.reader'},{'scalar'});



    this.unregisterCustomImporter(obj,ext);


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

        if~isKey(this.CustomParsers,curExt)
            insert(this.CustomParsers,curExt,{obj});
        else
            importers=getDataByKey(this.CustomParsers,curExt);
            importers{end+1}=obj;%#ok<AGROW>
            insert(this.CustomParsers,curExt,importers);
        end
    end
end
