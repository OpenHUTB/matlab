function uncompileAllModels(this)



    list=this.CompiledModelList;
    it=list.iterator;
    while it.hasNext()
        model=it.next;
        rptgen_sl.uncompileModel(model);
    end
    list.clear();