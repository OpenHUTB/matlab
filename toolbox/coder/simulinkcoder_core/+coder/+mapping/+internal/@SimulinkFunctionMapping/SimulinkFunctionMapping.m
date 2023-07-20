



classdef SimulinkFunctionMapping


    methods(Static,Access=public)


        out=isValidIdentifier(str);
        validatePublicFunction(model,fcnName,varargin);
        varargout=validateFunctionPrototype(...
        model,fcnBlock,fcnPrototype,returnCImpl);
        validate(model,fcnName);
        validateAll(model);
        compileTimeChecks(model,varargin);
        doEditTimeModelChecks(model);


        previewStr=getFunctionPreview(model,fcnName);


        out=hasCoderDictMapping(mdl);
        out=hasModelMapping(mdl);
        modelmapping=getOrCreateCoderDictMapping(mdl);
        out=createDefaultFunctionPrototypeFromBlock(blkHandle,varargin);
        out=getField(model,fcnName,field);
        out=get(model,fcnName);
        set(model,fcnName,varargin);
        [out,configsetSymbol]=getFcnName(blk,fcnName,codeName);
        namingRule=getNamingRuleFromMappingDefaults(mdlH);
        [codeInArgs,codeOutArgs]=getCodeInputOutputArguments(blk,fcnPrototype);
        cImpl=validateAndConstructCImplementation(...
        model,fcnBlock,fcnPrototype);


        flattenedStr=validateAndReturnArgName(...
        modelName,designArgName,codeArgName,inOut);
        flattenedStr=validateAndReturnFcnName(modelName,fcnName,codeFcnName);
        out=getCodeFunctionName(fcnPrototype);
        newPrototype=setCodeFunctionName(oldPrototype,newFcnName);
        matched=arePrototypesConsistentForModelReference(fcnProto,callerProto);
        byValue=canArgBePassedByValue(arg);


        out=isPublicFcn(blk,fcnName);
        isModel=isSimulinkModel(modelName);
        fcnBlock=getSimulinkFunctionOrCallerBlock(model,fcnName);
        [inArgs,outArgs,fcnName]=getSLFcnInOutArgs(blk);
        [inArgsProp,outArgsProp,ScalarOutReturnAsDefaultIdx]=getArgInAndArgOutProperties(blk);
    end

    methods(Static,Access=private)


        validateUseOfRenaming(model,func,fcnName);


        out=getOptionalMultiInstanceIdentifier();
        out=getMultiInstanceIdentifier();


        out=getFunctionObj(cTargetMapping,fcnName);
        out=getTargetMapping(model,fcnName);
        out=getDefaultStruct(model,fcnName);
        funcObj=getOrCreateFunctionPrototypeObj(fcnName,coderDictMapping);
        funcObj=setPrototype(model,fcnName,coderDictMapping,fcnPrototype,funcObj);


        func=getParsedFunction(fcnPrototype);
        checkFlattenedStr(flattenedStr,symbol);
        tf=isaSupportedVoidPtrArg(arg,conceptualIOType);


        fcnName=getSlFunctionName(blk);
        isSLFcn=isSimulinkFunction(blk);
        slFcnBlock=getSimulinkFunctionBlock(model,fcnName);
        callerBlock=getFunctionCallerBlock(model,fcnName);
    end
end
