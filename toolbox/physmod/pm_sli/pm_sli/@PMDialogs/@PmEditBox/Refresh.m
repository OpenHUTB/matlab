function retStatus=Refresh(hThis)







    retStatus=true;

    try

        hThis.setEnableStatus();


        retStatus=refreshChildren(hThis);
    catch
        retStatus=false;
    end

end

