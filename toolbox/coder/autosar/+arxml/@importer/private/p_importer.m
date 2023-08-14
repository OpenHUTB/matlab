function p_importer(this,filename)





    if iscellstr(filename)||isstring(filename)
        mainfile=filename{1};
        this.file=arxml.reader(mainfile);

        if length(filename)>1
            dependencyFiles=filename(2:end);
            p_setdependencies(this,dependencyFiles);
        end
    else
        this.file=arxml.reader(filename);
    end


    if nargin==2
        this.needReadUpdate=true;
    end
