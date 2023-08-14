function[ptxasm,internalState,symbols]=compileFcnTree(emitter,internalState,symbols,fcnLabel,iR)







    lifetimes=getFcnLifetimes(iR,fcnLabel);

    rest=getCompilationNode(internalState);
    returnLabel=labelGet(internalState);

    errorMechanism=internalState;
    setCurrentContextForErrorMechanism(errorMechanism,getFcnContext(iR,fcnLabel));

    ptxasm=[...
    allcompile('','')...
    ,formatLabel(emitter,'return label',returnLabel)...
    ];














    function bodyPtx=allcompile(breaklabel,continuelabel)

        bodyPtx='';

        while~isnull(rest)
            switch kind(rest)
            case{'BREAK'}
                bodyPtx=[bodyPtx,breakcompile(breaklabel)];%#ok<AGROW>
            case{'CONTINUE'}
                bodyPtx=[bodyPtx,continuecompile(continuelabel)];%#ok<AGROW>
            case{'EXPR','PRINT'}
                bodyPtx=[bodyPtx,exprcompile()];%#ok<AGROW>
            case{'FOR'}
                bodyPtx=[bodyPtx,forcompile()];%#ok<AGROW>
            case{'IF'}
                bodyPtx=[bodyPtx,condcompile(breaklabel,continuelabel)];%#ok<AGROW>
            case{'WHILE'}
                bodyPtx=[bodyPtx,whilecompile()];%#ok<AGROW>
            case{'RETURN'}
                bodyPtx=[bodyPtx,returncompile()];%#ok<AGROW>
            case{'FUNCTION'}
                rest=Next(rest);
            otherwise
                assert(false,'analysis phase is broken.');
            end
        end

    end



    function breakPtx=breakcompile(breaklabel)


        if~isempty(breaklabel)
            breakPtx=branchToLabel(emitter,breaklabel);
        else
            setNodeForErrorMechanism(internalState,rest);
            encounteredError(internalState,message('parallel:gpu:compiler:Break'));
        end



        rest=null(rest);

    end



    function continuePtx=continuecompile(continuelabel)


        if~isempty(continuelabel)
            continuePtx=branchToLabel(emitter,continuelabel);
        else
            setNodeForErrorMechanism(internalState,rest);
            encounteredError(internalState,message('parallel:gpu:compiler:Continue'));
        end


        rest=null(rest);

    end





    function exprPtx=exprcompile()

        exprdepth=getDepth(internalState);
        exprPtx='';

        while~isnull(rest)&&(strcmp(kind(rest),'EXPR')||strcmp(kind(rest),'PRINT'))

            node=Arg(rest);
            setCompilationNode(internalState,node);
            [typeOut,shapeInfo,regReal,regImag,rhsPtx]=compileAssignExpr(emitter,internalState,symbols,fcnLabel,iR);

            symbolInfo=lifetimes(indices(rest));
            assert(isstruct(symbolInfo),'analysis phase is broken.');



            fcnHasOutputs=true;
            if strcmp(kind(node),'CALL')







                callSites=getFcnCalls(iR,fcnLabel);
                calledFcnName=string(Left(node));

                if isfield(callSites,calledFcnName)
                    nodeid=indices(node);
                    callnodeids=parallel.internal.gpu.IR.extractCallNodeids(callSites,calledFcnName);
                    idx=(callnodeids(:,1)==nodeid);
                    fcnHasOutputs=(callnodeids(idx,2)>0);
                end

            end


            setNodeForErrorMechanism(internalState,node);
            if numel(symbolInfo.declare)==0&&fcnHasOutputs
                encounteredError(internalState,message('parallel:gpu:compiler:UnsupportedAns'));
            end

            assignPtx='';
            if fcnHasOutputs
                name=symbolInfo.declare{1};
                if~isempty(name)
                    assignPtx=updateSymbol(symbols,emitter,internalState,name,typeOut,shapeInfo,regReal,regImag,exprdepth);
                end
            end

            rest=Next(rest);

            exprPtx=[...
exprPtx...
            ,rhsPtx...
            ,assignPtx...
            ];%#ok<AGROW>

        end

    end



    function forPtx=forcompile()





        typeShadow=parallel.internal.types.Atomic.buildAtomic('double',false);
        noReg='';

        forroot=rest;
        forrootdepth=getDepth(internalState);
        setCompilationNode(internalState,forroot);


        symbolInfo=lifetimes(indices(forroot));
        assert(isstruct(symbolInfo),'analysis phase is broken.');
        makeSymbolsStatic(symbolInfo.declare,forrootdepth);


        testlabel=labelGet(internalState);
        bodylabel=labelGet(internalState);
        endlabel=labelGet(internalState);


        colonroot=Vector(forroot);
        while strcmp(kind(colonroot),'PARENS')
            colonroot=Arg(colonroot);
        end

        if strcmp(kind(colonroot),'COLON')

            lastroot=Right(colonroot);
            beginroot=Left(Left(colonroot));

            if isnull(beginroot)||iskind(Left(colonroot),'CALL')
                beginroot=Left(colonroot);
                steproot=null(colonroot);
            else
                steproot=Right(Left(colonroot));
            end

        else


            beginroot=colonroot;
            steproot=null(colonroot);
            lastroot=null(colonroot);
        end


        setCompilationNode(internalState,beginroot);
        [origTypeBegin,regBegin,beginPtx]=colonnodecompile(typeShadow);


        if isnull(lastroot)


            origTypeLast=typeShadow;
            [lastPtx,regLast,~]=copyreg(emitter,internalState,typeShadow,regBegin,noReg);
        else
            setCompilationNode(internalState,lastroot);
            [origTypeLast,regLast,lastPtx]=colonnodecompile(typeShadow);
        end


        if isnull(steproot)
            origTypeStep=typeShadow;
            [stepPtx,regStep,~]=constant(emitter,internalState,typeShadow,'1');
            implicitStep=true;
        else
            setCompilationNode(internalState,steproot);
            [origTypeStep,regStep,stepPtx]=colonnodecompile(typeShadow);
            implicitStep=false;
        end



        opName='colon';
        [typeIndex,~]=parallel.internal.types.colonOperatorRule(origTypeBegin,origTypeStep,origTypeLast,opName,errorMechanism);



        flintPtx='';

        if isSupportedInteger(typeIndex)

            if origTypeBegin==typeShadow
                flintPtx=checkIfFlint(emitter,internalState,typeShadow,regBegin);
            end

            if(origTypeStep==typeShadow)&&~implicitStep
                flintPtx=[...
flintPtx...
                ,checkIfFlint(emitter,internalState,typeShadow,regStep)...
                ];
            end

            if(origTypeLast==typeShadow)
                flintPtx=[...
flintPtx...
                ,checkIfFlint(emitter,internalState,typeShadow,regLast)...
                ];
            end

        end


        [counterPtx,regShadowCounter,~]=constant(emitter,internalState,typeShadow,'1');
        [lengthPtx,regShadowEnd]=loopLength(emitter,internalState,typeIndex,regBegin,regStep,regLast,typeShadow,endlabel);



        if typeIndex~=typeShadow
            [cvtIndexPtx,regIndex,~]=castreg(emitter,internalState,typeIndex,typeShadow,regBegin,'');
        else
            regIndex=regBegin;
            cvtIndexPtx='';
        end

        indexName=string(Index(forroot));
        shapeInfo=parallel.internal.gpu.Symbols.makescalarshapeinfo();

        assignPtx=updateSymbol(symbols,emitter,internalState,...
        indexName,typeIndex,shapeInfo,regIndex,noReg,forrootdepth);

        indexSymbol=getSymbol(symbols,indexName);
        regIndex=indexSymbol.reg;

        [indexShadowPtx,regShadow,~]=copyreg(emitter,internalState,typeShadow,regBegin,'');

        setupPtx=[...
        formatComment(emitter,'for begin')...
        ,beginPtx...
        ,lastPtx...
        ,stepPtx...
        ,flintPtx...
        ,lengthPtx...
        ,counterPtx...
        ,assignPtx...
        ,indexShadowPtx...
        ,cvtIndexPtx...
        ];


        checkInterruptPtx='';
        if supportsInterrupt(emitter)
            checkInterruptPtx=periodicCheckForInterrupt(emitter,internalState);
        end


        branchreg=pGet(internalState);
        lePtx=setpredicatereg(emitter,'le',branchreg,typeShadow,regShadowCounter,regShadowEnd);
        testPtx=[...
lePtx...
        ,conditionalBranchToLabel(emitter,branchreg,bodylabel)...
        ,branchToLabel(emitter,endlabel)...
        ];


        updatePtx=updateShadowCounter(emitter,typeShadow,regShadowCounter,regShadow,regBegin,regStep);


        [cvtBeginPtx,regCvt,~]=castreg(emitter,internalState,typeIndex,typeShadow,regShadow,noReg);

        rest=Body(forroot);
        incrementDepth(internalState);
        bodyPtx=allcompile(endlabel,testlabel);

        rest=Next(forroot);
        decrementDepth(internalState);


        removeSymbols(symbols,symbolInfo.remove,forrootdepth);
        movePtx=movereg(emitter,internalState,typeIndex,regIndex,'',regCvt,'');


        checkErrorPtx='';
        if bodyThrowsError(internalState)
            checkErrorPtx=periodicCheckForError(emitter,internalState);


        end

        bodyPtx=[...
        formatComment(emitter,'update actual loop counter')...
        ,cvtBeginPtx...
        ,movePtx...
        ,updatePtx...
        ,formatComment(emitter,'start for loop body')...
        ,bodyPtx...
        ,branchToLabel(emitter,testlabel)...
        ];


        forPtx=[...
setupPtx...
        ,formatLabel(emitter,'for test',testlabel)...
        ,checkInterruptPtx...
        ,checkErrorPtx...
        ,testPtx...
        ,formatLabel(emitter,'for body begin',bodylabel)...
        ,bodyPtx...
        ,formatLabel(emitter,'for end',endlabel)...
        ];

    end



    function condPtx=condcompile(breaklabel,continuelabel)

        ifroot=rest;
        ifrootdepth=getDepth(internalState);

        iflabel=labelGet(internalState);
        endlabel=labelGet(internalState);

        condPtx=formatLabel(emitter,'if begin',iflabel);













        symbolInfo=lifetimes(indices(ifroot));
        assert(isstruct(symbolInfo),'analysis phase is broken.');
        makeSymbolsStatic(symbolInfo.declare,ifrootdepth);

        rest=Arg(ifroot);


        symbolBodyInfo=lifetimes(indices(rest));
        assert(isstruct(symbolBodyInfo),'analysis phase is broken.');
        makeSymbolsStatic(symbolBodyInfo.declare,ifrootdepth);

        while~isnull(rest)&&(strcmp(kind(rest),'IFHEAD')||strcmp(kind(rest),'ELSEIF'))

            elseifroot=rest;



            removeSymbols(symbols,symbolBodyInfo.remove,ifrootdepth);


            ifcond=Left(elseifroot);
            bodylabel=labelGet(internalState);
            nextlabel=labelGet(internalState);

            setCompilationNode(internalState,ifcond);
            [checkandbranchPtx,compilebody]=compileCondExpr(emitter,internalState,symbols,fcnLabel,iR,bodylabel,nextlabel);


            rest=Body(elseifroot);

            bodyPtx='';
            if compilebody
                incrementDepth(internalState);
                bodyPtx=allcompile(breaklabel,continuelabel);
                decrementDepth(internalState);
            end

            rest=Next(elseifroot);

            condPtx=[...
condPtx...
            ,checkandbranchPtx...
            ,formatLabel(emitter,'',bodylabel)...
            ,bodyPtx...
            ,branchToLabel(emitter,endlabel)...
            ,formatLabel(emitter,'next branch begin',nextlabel)...
            ];%#ok<AGROW>

            if~isnull(rest)
                symbolBodyInfo=lifetimes(indices(rest));
                assert(isstruct(symbolBodyInfo),'analysis phase is broken.');
            end

        end


        bodyPtx='';

        if~isnull(rest)



            symbolBodyInfo=lifetimes(indices(rest));
            assert(isstruct(symbolBodyInfo),'analysis phase is broken.');
            removeSymbols(symbols,symbolBodyInfo.remove,ifrootdepth);


            rest=Body(rest);
            incrementDepth(internalState);
            bodyPtx=allcompile(breaklabel,continuelabel);
            decrementDepth(internalState);

        end


        removeSymbols(symbols,symbolInfo.remove,ifrootdepth);
        rest=Next(ifroot);


        condPtx=[...
condPtx...
        ,bodyPtx...
        ,formatLabel(emitter,'if end',endlabel)...
        ];

    end



    function whilePtx=whilecompile()

        whileroot=rest;
        whilerootdepth=getDepth(internalState);


        testlabel=labelGet(internalState);
        bodylabel=labelGet(internalState);
        endlabel=labelGet(internalState);



        symbolInfo=lifetimes(indices(whileroot));
        assert(isstruct(symbolInfo),'analysis phase is broken.');
        makeSymbolsStatic(symbolInfo.declare,whilerootdepth);


        checkInterruptPtx='';
        if supportsInterrupt(emitter)
            checkInterruptPtx=periodicCheckForInterrupt(emitter,internalState);
        end


        whiletest=Left(whileroot);
        setCompilationNode(internalState,whiletest);


        checkandbranchPtx=compileCondExpr(emitter,internalState,symbols,fcnLabel,iR,bodylabel,endlabel);


        rest=Body(whileroot);
        incrementDepth(internalState);
        bodyPtx=allcompile(endlabel,testlabel);

        rest=Next(whileroot);
        decrementDepth(internalState);


        removeSymbols(symbols,symbolInfo.remove,whilerootdepth);


        checkErrorPtx='';
        if bodyThrowsError(internalState)
            checkErrorPtx=periodicCheckForError(emitter,internalState);


        end

        whilePtx=[...
        formatLabel(emitter,'while test begin',testlabel)...
        ,formatComment(emitter,'loop test')...
        ,checkInterruptPtx...
        ,checkErrorPtx...
        ,checkandbranchPtx...
        ,formatLabel(emitter,'while body begin',bodylabel)...
        ,bodyPtx...
        ,branchToLabel(emitter,testlabel)...
        ,formatLabel(emitter,'while end',endlabel)...
        ];

    end



    function returnPtx=returncompile()

        symbolInfo=lifetimes(indices(rest));
        assert(isstruct(symbolInfo),'analysis phase is broken.');







        declareSymbolsFixed(symbols,symbolInfo.declare);

        returnPtx=branchToLabel(emitter,returnLabel);
        rest=null(rest);

    end







    function makeSymbolsStatic(symbolsToDeclare,depth)

        if~isempty(fcnLabel.Scope)

            usedHandleVariables=getFcnUsedHandleVariables(iR,fcnLabel);


            explicitVariables=setdiff(symbolsToDeclare,usedHandleVariables);
            declareSymbolsStatic(symbols,explicitVariables,depth);


            fcnWorkspace=getFcnWorkspaceSymbols(iR,fcnLabel);
            implicitVariables=intersect(symbolsToDeclare,usedHandleVariables);
            declareSymbolsStatic(fcnWorkspace,implicitVariables,depth);

        else


            declareSymbolsStatic(symbols,symbolsToDeclare,depth);
        end

    end





    function[typeNode,regNode,nodePtx]=colonnodecompile(typeShadow)

        [typeNode,~,regNode,~,nodePtx]=compileAssignExpr(emitter,internalState,symbols,fcnLabel,iR);




        if isArray(typeNode)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:ForCounterNonscalar'));
        end

        [cvtNodePtx,regNode,~]=castreg(emitter,internalState,typeShadow,typeNode,regNode,'');

        nodePtx=[...
nodePtx...
        ,cvtNodePtx...
        ];

    end

end


