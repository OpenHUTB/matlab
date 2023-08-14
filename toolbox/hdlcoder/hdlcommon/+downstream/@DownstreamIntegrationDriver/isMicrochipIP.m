function result=isMicrochipIP(obj)




    result=false;
    if obj.isIPWorkflow&&~obj.isBoardEmpty&&obj.isBoardLoaded
        vendor=obj.hTurnkey.hBoard.FPGAVendor;
        result=strcmpi(vendor,'Microchip');
    end
end
