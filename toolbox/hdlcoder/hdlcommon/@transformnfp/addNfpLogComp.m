function hNew=addNfpLogComp(hN,latency,slRate,isSingle,isHalf)




    denormal=transformnfp.handleDenormal();
    if isSingle
        if strcmpi(hdlfeature('NFPLogApprxImpl'),'on')
            hNew=transformnfp.getSingleLogPolyApproxComp(hN,slRate,denormal);
        else
            hNew=transformnfp.getSingleLogComp(hN,latency,slRate,denormal);
        end
    elseif isHalf
        hNew=transformnfp.getHalfLogComp(hN,latency,slRate,denormal);
    else
        hNew=transformnfp.getDoubleLogComp(hN,latency,slRate,denormal);
    end
end
