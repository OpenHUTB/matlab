function LoadLinkCharts(system)









    if bdIsLoaded(bdroot(system))&&~strcmpi(get_param(bdroot(system),'Open'),'on')
        Simulink.findBlocks(bdroot(system),Simulink.FindOptions('FollowLinks',true));
    end

end

