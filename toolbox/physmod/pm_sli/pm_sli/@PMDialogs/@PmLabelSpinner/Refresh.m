function retStatus=Refresh(hThis)







    retStatus=true;

    try

        hThis.setEnableStatus();
    catch
        retStatus=false;
    end

end

