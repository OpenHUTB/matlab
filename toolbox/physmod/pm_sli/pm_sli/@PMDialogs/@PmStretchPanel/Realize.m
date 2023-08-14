function retStatus=Realize(hThis)







    retStatus=true;

    try
        hThis.realizeChildren();
    catch
        retStatus=false;
    end
