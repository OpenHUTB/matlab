function hN=getRamNetworkFromMap(this,ramDescriptorwithCtx,RamNet)


    if isempty(this.ExistingRamMap)
        ramInMap=false;
    else
        ramInMap=this.ExistingRamMap.isKey(ramDescriptorwithCtx);
    end

    if~isempty(RamNet)

        hN=RamNet;
    else
        if ramInMap

            hN=this.ExistingRamMap(ramDescriptorwithCtx);


            if~isa(hN,'hdlcoder.network')
                this.ExistingRamMap.remove(ramDescriptorwithCtx);
                hN=[];
            end
        else


            hN=[];
        end
    end
end
