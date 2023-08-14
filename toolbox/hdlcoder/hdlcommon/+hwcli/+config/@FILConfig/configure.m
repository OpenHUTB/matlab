function configure(obj,hDI)





    configure@hwcli.base.FILBase(obj,hDI);
    configure@hwcli.base.DeployBase(obj,hDI);


    if(obj.RunTaskGenerateRTLCodeAndTestbench)
        hDI.GenerateRTLCode=obj.GenerateRTLCode;
        hDI.GenerateTestbench=obj.GenerateTestbench;
        hDI.GenerateValidationModel=obj.GenerateValidationModel;
    end

    if(obj.RunTaskVerifyWithHDLCosimulation)
        hDI.SkipVerifyCosim=false;
    else
        hDI.SkipVerifyCosim=true;
    end

end
