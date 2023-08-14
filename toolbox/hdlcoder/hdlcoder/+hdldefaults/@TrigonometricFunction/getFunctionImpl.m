function impl=getFunctionImpl(this,hC)




    slbh=hC.SimulinkHandle;

    Fname=get_param(slbh,'Function');

    if targetmapping.hasFloatingPointPort(hC)
        if targetcodegen.targetCodeGenerationUtils.isAlteraMode()
            switch Fname
            case{'sin','cos'}
                impl=hdldefaults.TrigonometricTargetLibrary();
            otherwise,impl='';
            end
        elseif targetcodegen.targetCodeGenerationUtils.isNFPMode()
            switch Fname
            case{'sin','cos','sincos','atan','atan2','cos + jsin',...
                'asin','acos','tan','sinh','cosh','tanh',...
                'asinh','acosh','atanh'}
                impl=hdldefaults.TrigonometricTargetLibrary();
            otherwise,impl='';
            end
        else
            impl='';
        end
    else
        switch Fname
        case{'sin','cos','sincos','atan2','cos + jsin'}
            impl=hdldefaults.Cordic();
        otherwise
            impl='';
        end
    end

    if~isempty(impl)

        impl.implParams=this.implParams;
    end
end


