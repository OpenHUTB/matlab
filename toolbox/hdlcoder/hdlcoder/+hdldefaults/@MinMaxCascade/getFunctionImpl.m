function impl=getFunctionImpl(this,hC)




    impl=this;
    in=hC.PirInputPorts(1).Signal;
    out=hC.PirOutputPorts(1).Signal;
    isInputValid=targetmapping.isValidDataType(in.Type);
    isOutputValid=targetmapping.isValidDataType(out.Type);

    if(isInputValid||isOutputValid)
        if targetcodegen.targetCodeGenerationUtils.isNFPMode()
            slbh=hC.SimulinkHandle;
            Fname=get_param(slbh,'Function');
            switch Fname
            case{'min','max'}
                impl=hdldefaults.MinMaxTargetLibrary();
            otherwise,impl='';
            end
        end
    end

    if(~isempty(impl))

        impl.implParams=this.implParams;
    end
end
