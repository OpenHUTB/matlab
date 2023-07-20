function saveRamNetworkToMap(this,ramDescriptor,RamNet)





    if isempty(this.ExistingRamMap)
        this.ExistingRamMap=containers.Map(ramDescriptor,RamNet);
    else
        this.ExistingRamMap(ramDescriptor)=RamNet;
    end
end
