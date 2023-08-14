function[ptx,ptxCallInfo]=ptxFactory(expansionkey,internalState,ftree,fcnInfoStruct,varargin)
















































































    errorMechanism=internalState;


    parallel.internal.gpu.Symbols.checkInputTypes(internalState,varargin);


    iR=parallel.internal.gpu.IR(fcnInfoStruct,ftree,errorMechanism);
    boundFcnLabel=getBoundFcnLabel(iR);
    boundFcnName=getBoundFcnName(iR);

    errorIfBoundFcnWrongNumberOfArgs(iR,errorMechanism,varargin);

    emitter=parallel.internal.ptx.ptxEmitter(getBoundFcnName(iR),fcnInfoStruct.type);



    if containsNonStaticLoop(iR)
        allocateJumpCountReg(internalState);
        allocateErrorCheckCountReg(internalState);
    end

    needsRand=isRandCalled(iR);
    if needsRand
        allocateRandState(internalState,emitter);
    end


    setCompilationNode(internalState,getFcnBeginNode(iR,boundFcnLabel));
    setCurrentContext(internalState,getFcnContext(iR,boundFcnLabel));


    boundFcnInputs=getFcnInputs(iR,boundFcnLabel);
    symbols=parallel.internal.gpu.Symbols(internalState,boundFcnInputs,varargin);








    [offsetPtx,offsetMachine,offset32]=calculateOffset(emitter,internalState);


    sizecheckPtx=arraySizeCheck(emitter,internalState,offset32);


    names=getFcnInputs(iR,boundFcnLabel);
    fetchInputsPtx=loadSymbols(emitter,internalState,symbols,names,expansionkey,offsetMachine,offset32);



    if strcmp(getRuleset(internalState),'singleton')
        scalarizeSymbols(symbols,boundFcnInputs);
    end


    fetchImplicitInputs=loadImplicitSymbols(emitter,internalState,boundFcnLabel,iR);




    [ptxasm,internalState,symbols]=compileFcnTree(emitter,internalState,symbols,boundFcnLabel,iR);





    checkBlockErrorPtx='';
    if bodyThrowsError(internalState)
        checkBlockErrorPtx=checkBlockError(emitter,internalState);
        acknowledgeError(internalState);
    end


    assignOutputsPtx=storeSymbols(emitter,internalState,symbols,boundFcnLabel,iR,offsetMachine);


    [PFS,prototype,types,complexities,entryname,entry]=mangleCprotoEntry(emitter,internalState,symbols,boundFcnLabel,iR,expansionkey);



    needsInterrupt=true;
    ptx=[...
    moduleHeader(emitter,internalState,boundFcnName,needsInterrupt)...
    ,makePrologue(emitter,internalState,entry,offsetPtx,offset32)...
    ,sizecheckPtx...
    ,fetchInputsPtx...
    ,fetchImplicitInputs...
    ,ptxasm...
    ,beginEpilogue(emitter)...
    ,checkBlockErrorPtx...
    ,assignOutputsPtx...
    ,endEpilogue(emitter)...
    ];


    ptx=regexprep(ptx,emitter.Pfs,PFS);
    entryname=regexprep(entryname,emitter.Pfs,PFS);

    neededUplevels=getMATLABUplevelVariables(iR);
    theWarnings=getCellArrayOfWarnings(internalState);

    ptxCallInfo=parallel.internal.datastructs.CallInfo(...
    prototype,...
    entryname,...
    numel(boundFcnInputs),...
    {types},...
    complexities,...
    {neededUplevels},...
    {getContextFcnCallsMap(iR)},...
    needsRand,...
    {theWarnings}...
    );

end
