function hC=findComponentUnderNetwork(this,hNet,slhandle)





    hC=hNet.findComponent('sl_handle',slhandle);
    if~isempty(hC)
        return;
    end

    hComps=hNet.Components;
    for ii=1:length(hComps)
        hComp=hComps(ii);
        if isa(hComp,'hdlcoder.ntwk_instance_comp')
            hLowerNet=hComp.ReferenceNetwork;
            hC=this.findComponentUnderNetwork(hLowerNet,slhandle);
            if~isempty(hC)
                return;
            end
        end
    end

end

