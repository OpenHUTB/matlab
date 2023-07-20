function ret=getSupportedImportersForFile(this,fname)
    ret=string.empty;

    try

        fullFilename=this.verifyFileAndFindParser(fname);
        [~,~,ext]=fileparts(fullFilename);


        if this.CustomParsers.isKey(ext)
            importers=this.CustomParsers.getDataByKey(ext);
            for idx=1:numel(importers)
                if importers{idx}.supportsFile(fullFilename)
                    ret(end+1)=string(class(importers{idx}));%#ok<AGROW>
                end
            end
        end
    catch me %#ok<NASGU>


        [~,~,ext]=fileparts(fname);
    end


    this.createPendingParsers();
    if this.CreatedParsers.isKey(ext)
        ret(end+1)="built-in";
    end

end
