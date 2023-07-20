function hdlcode=emit(this)







    gConnOld=hdlconnectivity.genConnectivity(0);


    if~isempty(PersistentHDLResource)
        this.getResource;
    end




    hdlcode=this.baseEmit;





    if gConnOld,
        this.compGenConnectivity;
    end

    hdlconnectivity.genConnectivity(gConnOld);

