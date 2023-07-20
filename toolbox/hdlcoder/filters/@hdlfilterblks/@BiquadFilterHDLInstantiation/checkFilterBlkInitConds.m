function pass=checkFilterBlkInitConds(this,hC)%#ok<INUSL>






    if isa(hC,'hdlcoder.sysobj_comp')
        isSysObj=true;
        sysObjHandle=hC.getSysObjImpl;
        iirFilterStructure=sysObjHandle.Structure;
    else
        isSysObj=false;
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        iirFilterStructure=block.IIRFiltStruct;
    end

    switch iirFilterStructure

    case{'Direct form I',...
        'Direct form I transposed'}
        if isSysObj
            initcond_den=sysObjHandle.DenominatorInitialConditions;
            initcond_num=sysObjHandle.NumeratorInitialConditions;
        else
            initcond_den=hdlslResolve('icden',bfp);
            initcond_num=hdlslResolve('icnum',bfp);
        end
        pass=~any(initcond_den)&&~any(initcond_num);
    case{'Direct form II',...
        'Direct form II transposed'}
        if isSysObj
            initconds=sysObjHandle.InitialConditions;
        else
            initconds=hdlslResolve('ic',bfp);
        end
        pass=~any(initconds);
    otherwise
        pass=true;
    end





