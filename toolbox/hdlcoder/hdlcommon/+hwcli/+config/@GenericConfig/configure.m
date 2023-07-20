function configure(obj,hDI)






    configure@hwcli.base.GenericBase(obj,hDI);


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

    if(obj.RunTaskAnnotateModelWithSynthesisResult)
        hDI.CriticalPathSource=obj.CriticalPathSource;
        hDI.CriticalPathNumber=num2str(obj.CriticalPathNumber);
        hDI.ShowAllPaths=obj.ShowAllPaths;
        hDI.ShowUniquePaths=obj.ShowUniquePaths;
        hDI.ShowDelayData=obj.ShowDelayData;
        hDI.ShowEndsOnly=obj.ShowEndsOnly;
    end

end
