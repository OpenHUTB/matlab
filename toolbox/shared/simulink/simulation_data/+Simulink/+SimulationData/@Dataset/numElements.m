function nelem=numElements(this)







    this.verifyDatasetIsScalar;

    if~isempty(this.Storage_)
        nelem=this.Storage_.numElements();
    else
        nelem=0;
    end
end
