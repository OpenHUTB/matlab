function decomposition=getDecomposition(this)








    decomposition=1;

    controlFileParam=this.getImplParams('SerialPartition');

    if~isempty(controlFileParam)
        decomposition=controlFileParam;
    end
