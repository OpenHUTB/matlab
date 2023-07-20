function hdlcoder









    try
        hdlcoder_license_checkout;
        com.mathworks.toolbox.coder.app.CoderApp.runHdlCoder;
    catch me
        me.throwAsCaller();
    end
