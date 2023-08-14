function[constMatrix,sharingFactor,useRAM]=getBlockInfo(this,slbh)



    constMatrix=hdlslResolve('constMatrix',slbh);



    sharingFactor=1;
    sharingFactorImpl=this.getImplParams('SharingFactor');
    useRAM='off';
    useRamImpl=this.getImplParams('UseRAM');

    if~isempty(sharingFactorImpl)

        sharingFactor=sharingFactorImpl;
    end

    if~isempty(useRamImpl)

        useRAM=useRamImpl;
    end

end