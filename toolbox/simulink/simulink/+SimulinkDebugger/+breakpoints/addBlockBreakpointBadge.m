function addBlockBreakpointBadge(blockPath)




    try
        badgeName=['slDebugBlockBreakpointBadge-',blockPath];
        debugBadge=diagram.badges.create(badgeName,'BlockSouthWest');
        imgPath=['toolbox',filesep,'shared',filesep,'dastudio',filesep...
        ,'resources',filesep,'indicators',filesep,'EnabledBreakpoint.svg'];
        debugBadge.Image=fullfile((matlabroot),imgPath);


        do=diagram.resolver.resolve(blockPath);
        debugBadge.setVisible(do,true);
    catch

    end

end


