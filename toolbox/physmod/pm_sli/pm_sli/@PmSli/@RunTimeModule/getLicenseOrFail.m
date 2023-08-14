function getLicenseOrFail(this,block,errorMsg_configId)







    if pm.simscape.internal.isSimscapeComponentDependent(block)
        return
    end
    if any(strncmpi(block.getFullName,'simrfV2',7))
        return
    end

    product={this.determineBlockProduct(block)};

    try

        this.getProductLicenses(product);

    catch

        configData=RunTimeModule_config;
        errorData=configData.Error;
        error_msgid=errorData.(errorMsg_configId);
        productName=pmsl_getproductname(product);
        pm_error(error_msgid,pmsl_sanitizename(block.Name),...
        productName{1});

    end


