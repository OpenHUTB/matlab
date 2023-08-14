function[licenseFound,errorStruct]=ssc_checklicense(verboseMode)











    narginchk(0,1);

    if(nargin<1)
        verboseMode=false;
    end




    product=pmsl_defaultproduct;
    licenseFound=pmsl_checklicense(product);
    errorStruct=[];
    if~licenseFound
        errorStruct=pm_errorstruct('physmod:simscape:simscape:ssc_checklicense:InvalidLicense',product);
        if verboseMode
            beep;
            errordlg(errorStruct.message,'License Error');
        end
    end

end


