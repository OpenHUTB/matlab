function performLicenseChecks(~)




    errMessage=message('shared_dspwebscopes:slspectrumanalyzer:AllLicensesFailed');

    products={'Signal_Blocks','Simscape','RF_Blockset'};


    productNames={'dsp','simscape','rfblks'};

    [success,~]=checkoutFirstAvailableLicense(products,productNames);

    if~success
        error(errMessage);
    end
end

function[success,productName]=checkoutFirstAvailableLicense(productLicenses,productNames)

    success=true;
    productName='';

    for index=1:numel(productLicenses)

        productLicense=productLicenses{index};

        productName=productNames{index};


        if builtin('license','test',productLicense)&&...
            ~isempty(builtin('license','inuse',productLicense))&&...
            ~isempty(ver(productName))


            [avail,~]=builtin('license','checkout',productLicense);
            if avail


                return;
            end
        end
    end

    for index=1:numel(productLicenses)

        productLicense=productLicenses{index};

        productName=productNames{index};

        if builtin('license','test',productLicense)&&~isempty(ver(productName))

            [checkAvail,~]=builtin('license','checkout',productLicense);
            if checkAvail
                return;
            end
        end
    end
    success=false;
end
