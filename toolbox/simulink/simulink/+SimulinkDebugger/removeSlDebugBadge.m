function removeSlDebugBadge(blkHandle)






    debugBadge=diagram.badges.get(['slDebugBadge',num2str(blkHandle)],'BlockSouthWest');
    debugBadge.remove;
end
