function[hParentNet,hNInst]=getParentNetwork(hN)




    hNInsts=hN.instances;
    if length(hNInsts)==1
        hNInst=hNInsts(1);
        hParentNet=hNInst.Owner;
    else

        hParentNet=[];
        hNInst=[];
    end

end