function hf=updateAccumInfo(this,hf,hC,arith)%#ok<INUSL>






    if strcmpi(arith,'double')
        hf.accumsltype=hf.inputsltype;
    else
        if isa(hC,'hdlcoder.sysobj_comp')
            sysObjHandle=hC.getSysObjImpl;
            hf.Accumsltype=getBlockParam(sysObjHandle,'AccumDataTypeName');
        else
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');

            hf.Accumsltype=block.AccumDataTypeName;
        end
    end
