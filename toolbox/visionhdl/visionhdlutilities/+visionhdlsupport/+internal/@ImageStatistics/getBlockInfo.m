function blockInfo=getBlockInfo(~,hC)







    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        blockInfo.mean=sysObjHandle.mean;
        blockInfo.variance=sysObjHandle.variance;
        blockInfo.stdDev=sysObjHandle.stdDev;

    else

        bfp=hC.Simulinkhandle;
        blockInfo.mean=get_param(bfp,'mean');
        blockInfo.variance=get_param(bfp,'variance');
        blockInfo.stdDev=get_param(bfp,'stdDev');

        if strcmpi(blockInfo.mean,'on')
            blockInfo.mean=true;
        else
            blockInfo.mean=false;
        end
        if strcmpi(blockInfo.variance,'on')
            blockInfo.variance=true;
        else
            blockInfo.variance=false;
        end
        if strcmpi(blockInfo.stdDev,'on')
            blockInfo.stdDev=true;
        else
            blockInfo.stdDev=false;
        end
    end


end

