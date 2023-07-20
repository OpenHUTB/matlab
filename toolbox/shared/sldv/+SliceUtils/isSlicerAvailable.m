function yesno=isSlicerAvailable(doCheckOut)




    if nargin==0
        doCheckOut=false;
    end
    if slfeature('UseSlCheckLicenseForSlicer')
        productName='SL_Verification_Validation';
    else
        productName='Simulink_Design_Verifier';
    end

    if doCheckOut
        invalid=builtin('_license_checkout',productName,'quiet');
        yesno=~invalid;
    else
        yesno=license('test',productName);
    end

    yesno=yesno&&...
    exist('slavteng','builtin')==5&&...
    exist('modelslicerprivate','file')==2;
end

