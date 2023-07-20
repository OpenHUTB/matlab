
function flattenSubsystemBlocks(this)






    arrayfun(@flattenSubsystemsHelper,this.FrontEnd.MaskedSubsystemLibraryBlocks);
    this.FrontEnd.MaskedSubsystemLibraryBlocks=[];




    arrayfun(@flattenBusExpandedSubsystemsHelper,this.FrontEnd.BusExpandedBlocks);
    this.FrontEnd.BusExpandedBlocks=[];
end

function flattenBusExpandedSubsystemsHelper(hNtwk)
    if~ishandle(hNtwk)
        return;
    end


    flattenSubsystemsHelper(hNtwk);

    if~isSafetoFlatten(hNtwk)
        return;
    end


    nicInsts=hNtwk.nicInstances;
    for ii=1:length(nicInsts)
        nic=nicInsts(ii);
        parentNtwk=nic.Owner();
        parentNtwk.flattenNic(nic);
    end
end

function flattenSubsystemsHelper(hNtwk)
    if~ishandle(hNtwk)
        return;
    end

    vComps=hNtwk.Components;
    for jj=1:length(vComps)
        hC=vComps(jj);
        if isa(hC,'hdlcoder.ntwk_instance_comp')&&isSafetoFlatten(hC.ReferenceNetwork)
            flattenSubsystemsHelper(hC.ReferenceNetwork);
            hNtwk.flattenNic(hC);
        end
    end
end

function isSafe=isSafetoFlatten(hN)
    isSafe=true;


    if hN.isSLEnabledSubsys||hN.isSLResettableSubsys||...
        hN.isSLTriggeredSubsys||hN.isPartitionNetwork
        isSafe=false;
    end
end


