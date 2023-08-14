function hNew=addNfpAtanhComp(hN,hC,slRate,isSingle)




    if transformnfp.getLatencyStrategy==3
        blkNameSuffix='0';
    else
        blkNameSuffix='';
    end

    if isSingle
        hNew=transformnfp.getSingleAtanhComp(hN,hC,slRate,blkNameSuffix);
    else
        hNew=transformnfp.getDoubleAtanhComp(hN,hC,slRate,blkNameSuffix);
    end
end