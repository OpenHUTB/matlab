function check=isAvailable()





    check=false;


    if~license('test','SL_Verification_Validation')
        return;
    end

    check=true;