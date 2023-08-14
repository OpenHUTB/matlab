



function[value,msg]=isPolyspaceBugFinderLicensed(~)



    value=pssharedprivate('isPslinkAvailable');
    msg='';
end
