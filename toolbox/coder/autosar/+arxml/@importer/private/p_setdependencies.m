function p_setdependencies(this,aDependencies)





    if iscellstr(aDependencies)||isstring(aDependencies)

        aDependencies=RTW.unique(aDependencies);


        aDependencies(strcmp(this.file.filename,aDependencies))=[];

        nbDep=numel(aDependencies);

        this.dependencies=[];
        for ii=1:nbDep
            this.dependencies=[this.dependencies;arxml.reader(aDependencies{ii})];
        end

    elseif ischar(aDependencies)||isStringScalar(aDependencies)
        this.dependencies=arxml.reader(aDependencies);

    elseif isempty(aDependencies)
        this.dependencies=[];

    else

    end


    this.needReadUpdate=true;
