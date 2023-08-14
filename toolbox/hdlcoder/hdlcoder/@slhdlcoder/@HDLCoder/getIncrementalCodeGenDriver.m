function incrementalCodeGenDriver=getIncrementalCodeGenDriver(this)





    if isempty(this.IncrementalCodeGenDriver)
        this.IncrementalCodeGenDriver=incrementalcodegen.IncrementalCodeGenDriver(this);
    end

    incrementalCodeGenDriver=this.IncrementalCodeGenDriver;
