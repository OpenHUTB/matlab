function hNew=addNfpAsinhComp(hN,hC,slRate,isSingle)




    if transformnfp.getLatencyStrategy==3
        blkNameSuffix='0';
    else
        blkNameSuffix='';
    end

    if isSingle
        hNew=transformnfp.getSingleAsinhComp(hN,hC,slRate,blkNameSuffix);
    else
        hNew=transformnfp.getDoubleAsinhComp(hN,hC,slRate,blkNameSuffix);
    end
end