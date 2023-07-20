function supercheckoutfdtbxlicense(this)%#ok<INUSD>




    if~isdeployed
        if~license('checkout','Signal_Blocks')
            error(message('signal:fdesign:abstracttype:supercheckoutfdtbxlicense:LicenseRequired'));
        end
    end


