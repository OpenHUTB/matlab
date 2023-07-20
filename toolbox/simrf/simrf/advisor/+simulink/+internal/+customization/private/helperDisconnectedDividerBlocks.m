function varargout=helperDisconnectedDividerBlocks(obj,option)








    switch validatestring(option,{'findblocks','findlines','filterblocks'},2)
    case 'findblocks'







        blks=find_system(obj,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','off','LookInsideSubsystemReference','off',...
        'ReferenceBlock','simrfV2junction1/Divider',...
        'DeviceDivider','Wilkinson power divider');
        if isempty(blks)
            status='passed';
            dcblks=blks;
        elseif~dig.isProductInstalled('RF Blockset')
            status='nolicense';
            dcblks=blks;
        else
            try
                isDisconnected=findBlksWithDisconnectedPort3(blks);
                dcblks=blks(isDisconnected);
                if isempty(dcblks)
                    status='passed';
                else
                    status='failed';
                end
            catch
                status='unknownerror';
                dcblks=blks;
            end
        end
        varargout={status,dcblks};
    case 'findlines'






        varargout{1}=find_system(obj,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','off','LookInsideSubsystemReference','off',...
        'FindAll','on','Type','line','Connected','off');
    case 'filterblocks'





        isDisconnected=findBlksWithDisconnectedPort3(obj);
        fixedBlks=obj(~isDisconnected);
        unfixedBlks=obj(isDisconnected);
        varargout={fixedBlks,unfixedBlks};
    end
end


function isDisconnected=findBlksWithDisconnectedPort3(blks)



    lh=get_param(blks,'LineHandles');
    if numel(lh)==1
        isDisconnected=lh.RConn(2)==-1;
    else
        isDisconnected=cellfun(@(x)x.RConn(2)==-1,lh);
    end
end