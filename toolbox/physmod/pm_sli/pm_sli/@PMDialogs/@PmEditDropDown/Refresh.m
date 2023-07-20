function retStatus=Refresh(hThis)







    retStatus=true;

    try

        hThis.setEnableStatus();
    catch %#ok<CTCH>
        retStatus=false;
    end

end

