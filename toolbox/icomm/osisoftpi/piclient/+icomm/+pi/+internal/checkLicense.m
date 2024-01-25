function checkLicense()

    try

        matlab.internal.licensing.checkoutProductLicense("OT");
    catch

        error(message('icomm_osisoftpi:messages:NotLicensed'));
    end

end
