function[status]=postApply(this)




    status=true;
    if~isempty(this.fileName)||this.storeInSLX
        this.save(this.fileName,true);
        this.save(this.defaultExclusionFile,false);
    end
    return;