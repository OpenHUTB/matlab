function[hNIC,failed]=createPIRfromML(fcnName,report,varargin)





    hNIC=[];
    [options,mlc2pirArgs]=parseInputs(varargin{:});


    [fcnInfoRegistry,exprMap,~,createFcnInfoMsgs]=...
    internal.ml2pir.mlhdlc.FunctionInfoRegistryCache.retrieveAndSetCacheValue(fcnName,report);

    if~internal.mtree.Message.containErrorMsgs(createFcnInfoMsgs)
        try
            constrainerArgs=internal.ml2pir.constrainer.PIRConstrainerArgs;
            constrainerArgs.IsNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode;
            constrainerArgs.IntsSaturate=true;
            constrainerArgs.FrameToSampleConversion=options.FrameToSampleConversion;
            constrainerArgs.SamplesPerCycle=options.SamplesPerCycle;


            constrainMsgs=internal.ml2pir.constrainer.runPIRConstrainer(fcnInfoRegistry,exprMap,constrainerArgs);
        catch ex


            internal.mtree.utils.errorWithContext(ex,...
            'ML2PIR constrainer error: ',...
            fullfile('+internal','+ml2pir'))
        end
    else
        constrainMsgs=internal.mtree.Message.empty;
    end

    messages=[createFcnInfoMsgs,constrainMsgs];




    failed=internal.ml2pir.mlhdlc.addValidationChecks(messages);
    if~failed
        hNIC=internal.ml2pir.mlc2pir(fcnName,mlc2pirArgs{:});
    end
end


function[options,mlc2pirArgs]=parseInputs(varargin)

    persistent p;
    if isempty(p)
        p=inputParser;
        p.KeepUnmatched=true;
        p.addParameter('FrameToSampleConversion',false,@islogical);
        p.addParameter('SamplesPerCycle',1,@isnumeric);
    end

    p.parse(varargin{:});

    options=p.Results;
    mlc2pirArgs=namedargs2cell(p.Unmatched);
end

