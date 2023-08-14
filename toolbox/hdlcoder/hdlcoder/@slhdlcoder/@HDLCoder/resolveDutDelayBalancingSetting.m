function resolveDutDelayBalancingSetting(this,p)
    if strcmpi(p.getTopNetwork.getDelayBalancing,'inherit')
        if(this.getParameter('balancedelays'))
            db='on';
        else
            db='off';
        end
        p.getTopNetwork.setDelayBalancing(db);
    end
end
