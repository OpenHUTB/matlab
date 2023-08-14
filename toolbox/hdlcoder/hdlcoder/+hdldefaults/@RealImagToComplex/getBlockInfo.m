function[inputMode,cval]=getBlockInfo(this,hC)



    slbh=hC.SimulinkHandle;

    inputMode=get_param(slbh,'Input');

    if~strcmpi(inputMode,'real and imag')


        slbh=hC.SimulinkHandle;
        rto=get_param(slbh,'RuntimeObject');
        constprm=0;
        for n=1:rto.NumRuntimePrms
            if strcmp(rto.RuntimePrm(n).Name,'ConstantPart')
                constprm=n;
                break;
            end
        end
        if constprm==0
            error(message('hdlcoder:validate:constantvaluenotfound'));
        end

        cval=rto.RuntimePrm(constprm).Data;
    else
        cval=0;
    end
