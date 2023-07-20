function p=getReducerInputParser()







    defaultSuffix='_r';
    defaultValidateSig=true;
    defaultConfig={};
    defaultOutdir='';
    defaultVerbose=false;
    defaultReportFlag=false;
    defaultCompileMode='sim';
    defaultExcludeFiles={};
    defaultFrameHandle=[];
    defaultCalledFromUI=false;


    oldConfigParamName='Configurations';
    outputFolderParamName='OutputFolder';
    preserveSigAttribParamName='PreserveSignalAttributes';
    modelsuffixParamName='ModelSuffix';
    verboseParamName='Verbose';
    namedconfigParamName='NamedConfigurations';
    varconfigParamName='VariableConfigurations';
    gensummParamName='GenerateSummary';
    fullrangeParamName='FullRangeVariables';
    varGroupParamName='VariableGroups';
    compileModeParamName='CompileMode';
    excludeFilesParamName='ExcludeFiles';
    frameHandleParamName='FrameHandle';
    calledFromUI='CalledFromUI';



    p=inputParser;
    p.FunctionName='reduceModel';
    p.StructExpand=false;
    p.PartialMatching=false;
    checkModelName=@(x)validateattributes(x,{'char','string'},{'scalartext'});
    addRequired(p,'ModelName',checkModelName);
    addParameter(p,oldConfigParamName,defaultConfig,...
    @(x)validateattributes(x,{'char','cell','struct'},{}));
    addParameter(p,outputFolderParamName,defaultOutdir,...
    @(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,preserveSigAttribParamName,defaultValidateSig,...
    @(x)validateattributes(x,{'logical','numeric'},{'nonempty','scalar'}));
    addParameter(p,modelsuffixParamName,defaultSuffix,...
    @(x)validateattributes(x,{'char'},{'nonempty','scalartext'}));
    addParameter(p,verboseParamName,defaultVerbose,...
    @(x)validateattributes(x,{'logical','numeric'},{'nonempty','scalar'}));
    addParameter(p,namedconfigParamName,defaultConfig,...
    @(x)validateattributes(x,{'char','cell','string'},{'nonempty','vector'}));
    addParameter(p,varconfigParamName,defaultConfig,...
    @(x)validateattributes(x,{'cell','struct'},{}));
    addParameter(p,gensummParamName,defaultReportFlag,...
    @(x)validateattributes(x,{'logical','numeric'},{'nonempty','scalar'}));
    addParameter(p,fullrangeParamName,defaultConfig,...
    @(x)validateattributes(x,{'cell'},{'nonempty','vector'}));
    addParameter(p,varGroupParamName,defaultConfig,...
    @(x)validateattributes(x,{'cell','struct'},{}));
    addParameter(p,compileModeParamName,defaultCompileMode,...
    @(x)validateattributes(x,{'char'},{'nonempty','scalartext'}));
    addParameter(p,excludeFilesParamName,defaultExcludeFiles,...
    @(x)validateattributes(x,{'cell','char','string'},{}));

    addParameter(p,frameHandleParamName,defaultFrameHandle,...
    @(x)validateattributes(x,{'com.mathworks.toolbox.simulink.variantmanager.VariantManager'},{}));
    addParameter(p,calledFromUI,defaultCalledFromUI,...
    @(x)validateattributes(x,{'logical'},{'nonempty','scalar'}));

end


