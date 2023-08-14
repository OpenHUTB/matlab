function hf=updateOutputInfo(this,hf,hC,arith)%#ok<INUSL>









    if strcmpi(arith,'double')
        hf.outputsltype='double';
    else
        if isa(hC,'hdlcoder.sysobj_comp')
            sysObjHandle=hC.getSysObjImpl;
            hf.outputsltype=getBlockParam(sysObjHandle,'OutDataTypeName');
        else
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            hf.outputsltype=block.OutDataTypeName;
        end
    end

