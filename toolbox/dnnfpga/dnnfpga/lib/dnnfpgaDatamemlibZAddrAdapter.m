function[zAddrOut,zSelOut]=dnnfpgaDatamemlibZAddrAdapter(zAddrIn,active,zAddrLimit,addrW,binSize)
%#codegen

    coder.allowpcode('plain');

    zAddrOutT=fi(zeros(binSize,1),0,addrW+1,0);
    zSelOutT=fi(zeros(binSize,1),0,1,0);
    if(active)
        zAddrLimitT=zAddrLimit;
        for ibx=1:binSize
            ibz=zAddrIn(ibx);
            if(ibz>=zAddrLimitT)
                zAddrOutT(ibx)=fi(zAddrIn(ibx)-zAddrLimitT,0,addrW+1,0);
                zSelOutT(ibx)=1;
            else
                zAddrOutT(ibx)=zAddrIn(ibx);
                zSelOutT(ibx)=0;
            end
        end
    else
        zAddrOutT=zAddrIn;
        zSelOutT=fi(zeros(binSize,1),0,1,0);
    end
    zAddrOut=reshape(zAddrOutT,[binSize,1]);
    zSelOut=reshape(zSelOutT,[binSize,1]);
end
