function hf=updateProdInfo(this,hf,hC,arith)%#ok<INUSL>







    if strcmpi(arith,'double')
        hf.productsltype=hf.inputsltype;
        return;
    else
        if isa(hC,'hdlcoder.sysobj_comp')
            sysObjHandle=hC.getSysObjImpl;
            hf.productsltype=getBlockParam(sysObjHandle,'ProductDataTypeName');
        else
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');

            hf.productsltype=block.ProductDataTypeName;
        end
    end
