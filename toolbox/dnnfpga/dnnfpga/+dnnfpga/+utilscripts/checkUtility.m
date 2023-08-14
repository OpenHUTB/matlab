function checkUtility(checkout)





    if nargin<1

        checkout=true;
    end

    licenseAvailable=license('checkout','Deep_Learning_HDL_Toolbox');
    if checkout&&~licenseAvailable

        error(message('dnnfpga:workflow:LicenseNotAvailable'));
    end

end
