function genResults(this)




    res=this.getDataResult;
    if~isempty(res)
        genCovResults(this,res)
    end
end
