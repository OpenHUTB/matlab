function newblocklist=resolveInactiveBlocks(~,blocklist)







    newblocklist=zeros(size(blocklist));
    newCount=1;
    for ii=1:numel(blocklist)
        if slfeature('STVariantsInHDL')>0
            [isActive,~]=Simulink.match.startupVariants(blocklist(ii));
        else
            [isActive,~]=Simulink.match.activeVariants(blocklist(ii));
        end
        if~isActive
            continue;
        end


        newblocklist(newCount)=blocklist(ii);
        newCount=newCount+1;
    end
    newblocklist=nonzeros(newblocklist)';
end
