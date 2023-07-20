function impl=getDefaultImplementation(this,block)









    table=this.DefaultTable;
    map=table.Sets;
    if map.Count==0
        this.parseDefaultConfigs;
    end

    topSet=table.getImplementationSet(this.ModelName);
    impl=topSet.getImplementation(block,this);
