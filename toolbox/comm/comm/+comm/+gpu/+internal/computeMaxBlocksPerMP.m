function blks=computeMaxBlocksPerMP(numthreads,numregs,sharedbytes,arch,smSize)
























    if~any(arch==[1.3,2.0,2.1,3.0,3.5])
        arch=3.5;
    end

    if nargin<5
        smSize=0;
    end
    smMaxSize=getSharedMaxSize(arch,smSize);



    s=gpuHWData(arch);






    warpsPerBlock=ceilmult(numthreads/s.ThreadsPerWarp,1);

    blocksPerSM_byWarp=min(s.ThreadBlocksPerMultiprocessor,...
    floormult((s.WarpsPerMultiprocessor/warpsPerBlock),1));


    if strcmpi(s.AllocationGranularity,'block')
        regPerBlock=ceilmult(ceilmult(warpsPerBlock,s.WarpAllocationGranularity)*...
        numregs*s.ThreadsPerWarp,getRegAllocUnitSize(arch,numregs));
        regPerSM=s.RegisterFileSize;
    else
        regPerBlock=warpsPerBlock;
        tmp=s.RegisterFileSize/ceilmult(numregs*s.ThreadsPerWarp,getRegAllocUnitSize(arch,numregs));
        regPerSM=floormult(tmp,s.WarpAllocationGranularity);
    end

    if numregs>s.MaxRegistersPerThread
        blocksPerSM_byReg=0;
    else
        if numregs>0
            blocksPerSM_byReg=floormult(regPerSM/regPerBlock,1);
        else
            blocksPerSM_byReg=s.ThreadBlocksPerMultiprocessor;
        end
    end


    sharedPerBlock=ceilmult(sharedbytes,s.SharedMemoryAllocationUnitSize);

    if sharedPerBlock>0
        blocksPerSM_byShared=floormult(smMaxSize/sharedPerBlock,1);
    else
        blocksPerSM_byShared=s.ThreadBlocksPerMultiprocessor;
    end



    blkLimits=[blocksPerSM_byWarp,blocksPerSM_byReg,blocksPerSM_byShared];
    blks=min(blkLimits);

end

function roundedx=ceilmult(x,y)

    tmp=x/y;
    roundedx=ceil(tmp)*y;
end

function flx=floormult(x,y)

    tmp=x/y;
    flx=floor(tmp)*y;
end

function b=getSharedMaxSize(arch,smSize)

    switch(arch)
    case 1.3
        b=16384;

    case{2.0,2.1}
        if any(smSize==[48,16])
            b=smSize*1024;
        else
            b=49152;
        end

    case{3.0,3.5}
        if any(smSize==[48,16,32])
            b=smSize*1024;
        else
            b=49152;
        end
    end
end


function s=getRegAllocUnitSize(arch,numregs)



    switch(arch)
    case 1.3
        s=512;
    case{2.0,2.1}
        if any(numregs==[21,22,29,30,37,38,45,46])
            s=64;
        else
            s=128;
        end
    case 3.0
        s=256;
    case 3.5
        s=256;
    end
end


function st=gpuHWData(arch)
    switch(arch)
    case 1.3
        st=struct(...
        'ThreadsPerWarp',32,...
        'WarpsPerMultiprocessor',32,...
        'ThreadBlocksPerMultiprocessor',8,...
        'RegisterFileSize',16384,...
        'AllocationGranularity','block',...
        'MaxRegistersPerThread',124,...
        'SharedMemoryAllocationUnitSize',512,...
        'WarpAllocationGranularity',2...
        );

    case 2.0
        st=struct(...
        'ThreadsPerWarp',32,...
        'WarpsPerMultiprocessor',48,...
        'ThreadBlocksPerMultiprocessor',8,...
        'RegisterFileSize',32768,...
        'AllocationGranularity','warp',...
        'MaxRegistersPerThread',63,...
        'SharedMemoryAllocationUnitSize',128,...
        'WarpAllocationGranularity',2...
        );

    case 2.1
        st=struct(...
        'ThreadsPerWarp',32,...
        'WarpsPerMultiprocessor',48,...
        'ThreadBlocksPerMultiprocessor',8,...
        'RegisterFileSize',32768,...
        'AllocationGranularity','warp',...
        'MaxRegistersPerThread',63,...
        'SharedMemoryAllocationUnitSize',128,...
        'WarpAllocationGranularity',2...
        );

    case 3.0
        st=struct(...
        'ThreadsPerWarp',32,...
        'WarpsPerMultiprocessor',64,...
        'ThreadBlocksPerMultiprocessor',16,...
        'RegisterFileSize',65536,...
        'AllocationGranularity','warp',...
        'MaxRegistersPerThread',63,...
        'SharedMemoryAllocationUnitSize',256,...
        'WarpAllocationGranularity',4...
        );

    case 3.5
        st=struct(...
        'ThreadsPerWarp',32,...
        'WarpsPerMultiprocessor',64,...
        'ThreadBlocksPerMultiprocessor',16,...
        'RegisterFileSize',65536,...
        'AllocationGranularity','warp',...
        'MaxRegistersPerThread',255,...
        'SharedMemoryAllocationUnitSize',256,...
        'WarpAllocationGranularity',4...
        );
    end
end


