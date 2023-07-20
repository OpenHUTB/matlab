function onFilteredClassListChange(this,value)




    if(this.filteredPropHash.isKey(value))
        this.filteredProps=this.filteredPropHash(value);

    else
        this.filteredProps={};

    end


    try
        this.acceptedProps=fields(eval(value));
    catch %#ok<CTCH>
        this.acceptedProps={};
    end

    this.acceptedProps=setdiff(this.acceptedProps,this.filteredProps);
    this.currFilterClass=value;
