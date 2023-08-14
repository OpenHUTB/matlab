function supportedParams=assignHardwareIDs(supportedParams,cStr,hexStr,defaultStr)




    if~isempty(supportedParams.productid)
        supportedParams.productid=assignIDs(supportedParams.productid,cStr,hexStr);
    else
        supportedParams.productid=defaultStr;
    end

    if~isempty(supportedParams.vendorid)
        supportedParams.vendorid=assignIDs(supportedParams.vendorid,cStr,hexStr);
    else
        supportedParams.vendorid=defaultStr;
    end

end

function hardwareID=assignIDs(hardwareID,cStr,hexStr)
    h=hardwareID;
    if~any(any(~((h>='0'&h<='9')|(h>='A'&h<='F')|(h>='a'&h<='f'))))
        idVal=hex2dec(hardwareID);
        idVal=[hexStr,dec2hex(idVal,4)];
        idVal=lower(idVal);
    else

        idVal=hardwareID;
    end
    hardwareID=[cStr,idVal,cStr];
end