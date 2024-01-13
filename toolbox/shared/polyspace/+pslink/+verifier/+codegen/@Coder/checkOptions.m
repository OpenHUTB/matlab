function[resultDescription,resultDetails,resultType,hasError,resultId]=checkOptions(codeGenFolder,opts)

    if nargin<2
        opts=struct();
    end

    disableWarnings=false;
    haltOnWarn=false;
    if isfield(opts,'CheckConfigBeforeAnalysis')
        disableWarnings=strcmpi(opts.CheckConfigBeforeAnalysis,'Off');
        haltOnWarn=strcmpi(opts.CheckConfigBeforeAnalysis,'OnHalt');
    end

    resultDescription={};
    resultDetails={};
    resultType={};
    resultId={};
    hasError=false;
    hasWarning=false;
    codeInfoFile=fullfile(codeGenFolder,'codeInfo.mat');

    resultDescription{end+1}=DAStudio.message('polyspace:gui:pslink:chkOptsDescGenCodeFolder');
    resultDetails{end+1}={};
    resultType{end+1}={};
    resultId{end+1}={};

    if~disableWarnings

        resultDescription{end+1}=DAStudio.message('polyspace:gui:pslink:chkOptsDescCodeGenOptim');
        resultDetails{end+1}={};
        resultType{end+1}={};
        resultId{end+1}={};

        configInfo=[];
        codeDescriptor=coder.internal.getCodeDescriptorInternal(codeInfoFile,247362);
        if~isempty(codeDescriptor)
            configInfo=codeDescriptor.getConfigInfo();
        end

        if~isempty(configInfo)&&configInfo.InitFltsAndDblsToZero==0
            resultId{end}{end+1}='polyspace:gui:pslink:codegenChkOptsDetailsInitFltsAndDblsToZero';
            resultDetails{end}{end+1}=message(resultId{end}{end}).getString();
            resultType{end}{end+1}='Warning';
            hasWarning=true;
        end
    end

    if haltOnWarn&&hasWarning
        hasError=true;
    end
