



function[value,msg]=isSimscapeLicensed(~)
    value=pm.sli.internal.isDefaultProductInstalled();
    msg='';
end