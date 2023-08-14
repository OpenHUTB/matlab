function addSlDebugBadge(blkHandle,currMethodName,currContState,currDiscState)





    debugBadge=diagram.badges.create(['slDebugBadge',num2str(blkHandle)],'BlockSouthWest');
    imgPath=['toolbox',filesep,'shared',filesep,'dastudio',filesep...
    ,'resources',filesep,'indicators',filesep,'EnabledBreakpoint.svg'];
    debugBadge.Image=fullfile((matlabroot),imgPath);


    tooltipStr=sprintf('%s',currMethodName);
    if~isempty(currContState)

        tooltipStr=[tooltipStr,sprintf('\n\n%s',currContState)];
    end
    if~isempty(currDiscState)

        tooltipStr=[tooltipStr,sprintf('\n\n%s',currDiscState)];
    end
    debugBadge.Tooltip=tooltipStr;


    debugBadge.setActionHandler(@onClickBadge);


    do=diagram.resolver.resolve(blkHandle);
    debugBadge.setVisible(do,true);
end

function onClickBadge()

end


