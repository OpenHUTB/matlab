function this=loadobj(savedStruct)


    this=pslink.Options();
    constructObject(this,[]);

    this.pslinkcc.PSResultDir=savedStruct.ResultDir;
    this.pslinkcc.PSVerificationSettings=savedStruct.PSVerificationSettings;
    this.pslinkcc.PSCxxVerificationSettings=savedStruct.PSCxxVerificationSettings;
    this.pslinkcc.PSOpenProjectManager=savedStruct.PSOpenProjectManager;
    this.pslinkcc.PSAddSuffixToResultDir=savedStruct.AddSuffixToResultDir;
    this.pslinkcc.PSEnableAdditionalFileList=savedStruct.EnableAdditionalFileList;
    this.pslinkcc.PSAdditionalFileList=savedStruct.AdditionalFileList;
    this.pslinkcc.PSModelRefVerifDepth=savedStruct.ModelRefVerifDepth;
    this.pslinkcc.PSModelRefByModelRefVerif=savedStruct.ModelRefByModelRefVerif;
    if isfield(savedStruct,'AutoStubLUT')
        this.pslinkcc.PSAutoStubLUT=savedStruct.AutoStubLUT;
    end
    this.pslinkcc.PSInputRangeMode=savedStruct.InputRangeMode;
    this.pslinkcc.PSParamRangeMode=savedStruct.ParamRangeMode;
    this.pslinkcc.PSOutputRangeMode=savedStruct.OutputRangeMode;
    this.pslinkcc.PSCheckConfigBeforeAnalysis=savedStruct.CheckConfigBeforeAnalysis;
    this.pslinkcc.PSEnablePrjConfigFile=savedStruct.EnablePrjConfigFile;
    this.pslinkcc.PSPrjConfigFile=savedStruct.PrjConfigFile;
    this.pslinkcc.PSAddToSimulinkProject=savedStruct.AddToSimulinkProject;
    if isfield(savedStruct,'VerifAllSFcnInstances')
        this.pslinkcc.PSVerifAllSFcnInstances=savedStruct.VerifAllSFcnInstances;
    end

    if isfield(savedStruct,'VerificationMode')
        this.pslinkcc.PSVerificationMode=savedStruct.VerificationMode;
    end

