function savedStruct=saveobj(this)


    savedStruct=struct();

    savedStruct.class=class(this);
    savedStruct.ResultDir=this.pslinkcc.PSResultDir;
    savedStruct.VerificationSettings=this.pslinkcc.PSVerificationSettings;
    savedStruct.CxxVerificationSettings=this.pslinkcc.PSCxxVerificationSettings;
    savedStruct.OpenProjectManager=this.pslinkcc.PSOpenProjectManager;
    savedStruct.AddSuffixToResultDir=this.pslinkcc.PSAddSuffixToResultDir;
    savedStruct.EnableAdditionalFileList=this.pslinkcc.PSEnableAdditionalFileList;
    savedStruct.AdditionalFileList=this.pslinkcc.PSAdditionalFileList;
    savedStruct.ModelRefVerifDepth=this.pslinkcc.PSModelRefVerifDepth;
    savedStruct.ModelRefByModelRefVerif=this.pslinkcc.PSModelRefByModelRefVerif;
    savedStruct.AutoStubLUT=this.pslinkcc.PSAutoStubLUT;
    savedStruct.InputRangeMode=this.pslinkcc.PSInputRangeMode;
    savedStruct.ParamRangeMode=this.pslinkcc.PSParamRangeMode;
    savedStruct.OutputRangeMode=this.pslinkcc.PSOutputRangeMode;
    savedStruct.VerificationMode=this.pslinkcc.PSVerificationMode;
    savedStruct.CheckConfigBeforeAnalysis=this.pslinkcc.PSCheckConfigBeforeAnalysis;
    savedStruct.EnablePrjConfigFile=this.pslinkcc.PSEnablePrjConfigFile;
    savedStruct.PrjConfigFile=this.pslinkcc.PSPrjConfigFile;
    savedStruct.AddToSimulinkProject=this.pslinkcc.PSAddToSimulinkProject;
    savedStruct.VerifAllSFcnInstances=this.pslinkcc.PSVerifAllSFcnInstances;


