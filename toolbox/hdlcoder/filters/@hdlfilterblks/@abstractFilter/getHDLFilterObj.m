function hF=getHDLFilterObj(this,hC)



    if strcmp(hC.ClassName,'filter_comp')
        hF=hC.getFilterObj;
    else
        hF=this.createHDLFilterObj(hC);
    end
