function impl=getFunctionImpl(this,hC)



    slbh=hC.SimulinkHandle;
    inputsType=get_param(slbh,'Inputs');

    if(strcmpi(inputsType,'*/')||strcmpi(inputsType,'/*')||strcmpi(inputsType,'/')||strcmpi(inputsType,'//'))
        impl=hdldefaults.ShiftAddMathArchitecturesDivRec;
    else
        impl=[];
    end

    if(~isempty(impl))

        impl.implParams=this.implParams;
    end