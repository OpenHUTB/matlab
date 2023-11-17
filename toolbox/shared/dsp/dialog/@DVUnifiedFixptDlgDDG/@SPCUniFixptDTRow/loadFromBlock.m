function loadFromBlock(this)

    prefixStr=this.Prefix;
    udtPrmStr=strcat(prefixStr,'DataTypeStr');
    minPrmStr=strcat(prefixStr,'Min');
    maxPrmStr=strcat(prefixStr,'Max');

    this.DataTypeStr=this.Block.(udtPrmStr);

    if isprop(this.Block,minPrmStr)

        this.DesignMin=this.Block.(minPrmStr);
        this.DesignMax=this.Block.(maxPrmStr);
    else
        this.DesignMin='';
        this.DesignMax='';
    end


