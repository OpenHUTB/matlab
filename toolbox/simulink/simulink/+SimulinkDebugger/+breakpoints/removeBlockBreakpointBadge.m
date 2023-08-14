function removeBlockBreakpointBadge(blockPath)




    try
        blockPath=strrep(blockPath,'''','');
        badgeName=['slDebugBlockBreakpointBadge-',blockPath];
        debugBadge=diagram.badges.get(badgeName,'BlockSouthWest');


        debugBadge.remove;
    catch

    end
end