function[status,errstr]=postApply(this)




    if this.hasUnappliedChanges

        this.hasUnappliedChanges=false;
        this.lastFilterElement={};

        try
            this.save(this.fileName);
        catch Mexp
            status=false;
            errstr=getString(message(Mexp.identifier));
            return;
        end

        fn=get_param(this.modelName,this.getModelParamName);
        if~strcmpi(fn,this.fileName)&&this.saveToModel
            set_param(this.modelName,this.getModelParamName,this.fileName);
        elseif~this.saveToModel
            set_param(this.modelName,this.getModelParamName,'');
        end

        if this.attachToData
            this.applyFilter;
        end
    end

    status=true;
    errstr='';



