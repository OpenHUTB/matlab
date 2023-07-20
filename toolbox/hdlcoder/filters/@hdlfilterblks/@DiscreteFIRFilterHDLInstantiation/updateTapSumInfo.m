function hf=updateTapSumInfo(this,hf,hC,arith)%#ok<INUSL>









    if isFilterSymAsymFIR(hf)

        if strcmpi(arith,'double')
            hf.tapsumsltype=hf.inputsltype;
        else
            if isa(hC,'hdlcoder.sysobj_comp')
                sysObjHandle=hC.getSysObjImpl;
                hf.tapsumsltype=getBlockParam(sysObjHandle,'TapsumDataTypeName');
            else
                bfp=hC.SimulinkHandle;
                block=get_param(bfp,'Object');
                hf.tapsumsltype=block.TapsumDataTypeName;
            end
        end
    end
end


function success=isFilterSymAsymFIR(hf)

    success=strcmpi(class(hf),'hdlfilter.dfsymfir')||...
    strcmpi(class(hf),'hdlfilter.dfasymfir');

end


