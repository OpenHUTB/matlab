function val=getFullName(this)




    mdlObj=this.getParent;

    if isempty(mdlObj.name)
        val=['<model>/Code'];
    else
        val=[mdlObj.name,'/Design Verifier results'];
    end



