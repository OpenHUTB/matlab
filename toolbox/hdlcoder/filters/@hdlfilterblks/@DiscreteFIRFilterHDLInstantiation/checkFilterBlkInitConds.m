function pass=checkFilterBlkInitConds(this,hC)%#ok<INUSL>






    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj
        sysObjHandle=hC.getSysObjImpl;
        initconds=sysObjHandle.InitialConditions;
        pass=~any(initconds);
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        pass=true;

        switch block.FIRFiltStruct
        case{'Direct form',...
            'Direct form symmetric',...
            'Direct form antisymmetric',...
            'Direct form transposed'}
            initconds=hdlslResolve('ic',bfp);
            pass=~any(initconds);
        otherwise

        end
    end


