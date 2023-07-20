function obj=deepCopy(this)



    obj=pslink.Options();
    constructObject(obj,[]);

    obj.pslinkcc.PSResultDir=this.pslinkcc.PSResultDir;
    obj.pslinkcc.PSVerificationSettings=this.pslinkcc.PSVerificationSettings;
    obj.pslinkcc.PSCxxVerificationSettings=this.pslinkcc.PSCxxVerificationSettings;
    obj.pslinkcc.PSOpenProjectManager=this.pslinkcc.PSOpenProjectManager;
    obj.pslinkcc.PSAddSuffixToResultDir=this.pslinkcc.PSAddSuffixToResultDir;
    obj.pslinkcc.PSEnableAdditionalFileList=this.pslinkcc.PSEnableAdditionalFileList;
    obj.pslinkcc.PSAdditionalFileList=this.pslinkcc.PSAdditionalFileList;
    obj.pslinkcc.PSModelRefVerifDepth=this.pslinkcc.PSModelRefVerifDepth;
    obj.pslinkcc.PSModelRefByModelRefVerif=this.pslinkcc.PSModelRefByModelRefVerif;
    obj.pslinkcc.PSInputRangeMode=this.pslinkcc.PSInputRangeMode;
    obj.pslinkcc.PSParamRangeMode=this.pslinkcc.PSParamRangeMode;
    obj.pslinkcc.PSOutputRangeMode=this.pslinkcc.PSOutputRangeMode;
    obj.pslinkcc.PSAutoStubLUT=this.pslinkcc.PSAutoStubLUT;
    obj.pslinkcc.PSVerificationMode=this.pslinkcc.PSVerificationMode;
    obj.pslinkcc.PSCheckConfigBeforeAnalysis=this.pslinkcc.PSCheckConfigBeforeAnalysis;
    obj.pslinkcc.PSEnablePrjConfigFile=this.pslinkcc.PSEnablePrjConfigFile;
    obj.pslinkcc.PSPrjConfigFile=this.pslinkcc.PSPrjConfigFile;
    obj.pslinkcc.PSAddToSimulinkProject=this.pslinkcc.PSAddToSimulinkProject;
    obj.pslinkcc.PSVerifAllSFcnInstances=this.pslinkcc.PSVerifAllSFcnInstances;

end


