function gotIt=utSlLicenseCheck


    gotIt=false;

    if(license('test','SIMULINK'))
        try
            gotIt=(0~=license('checkout','SIMULINK'));
        catch
            gotIt=false;
        end
    end
