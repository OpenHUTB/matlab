function hNew=addNfpAcoshComp(hN,hC,slRate,isSingle)




    if transformnfp.getLatencyStrategy==3
        blkNameSuffix='0';
    else
        blkNameSuffix='';
    end

    if isSingle
        hNew=transformnfp.getSingleAcoshComp(hN,hC,slRate,blkNameSuffix);
    else
        hNew=transformnfp.getDoubleAcoshComp(hN,hC,slRate,blkNameSuffix);
    end
end