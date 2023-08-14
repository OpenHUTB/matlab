function resp=isInstructionSetExtensionsAvailable(prodHWDeviceVendor,prodHWDeviceType,isERT)



    inParser=inputParser;
    inParser.addRequired('prodHWDeviceVendor',@(x)ischar(x));
    inParser.addRequired('prodHWDeviceType',@(x)ischar(x));
    inParser.parse(prodHWDeviceVendor,prodHWDeviceType);
    params=inParser.Results;

    try
        fullHWName=[params.prodHWDeviceVendor,'->',params.prodHWDeviceType];
        [isAvailable,~]=RTW.getAvailableInstructionSets(fullHWName,isERT);

        resp=isAvailable;
    catch me %#ok<NASGU>
        resp=false;
    end
end