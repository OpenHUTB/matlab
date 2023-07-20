function[tyo,szo,ro,ro2,gasm]=compileAssignExpr(emitter,internalState,symbols,parentFcnLabel,iR)





















    node=getCompilationNode(internalState);

    if parallel.internal.tree.isNodeKindEqualsOrAnon(node)
        node=Right(node);
    end

    if isnull(node)
        tyo=parallel.internal.types.Atomic.Null;
        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();
        ro='';
        ro2='';
        gasm='';
    else
        errorMechanism=internalState;
        setNodeForErrorMechanism(internalState,node);
        gaccum={};
        [tyo,szo,ro,ro2]=ops(node);
        gasm=[gaccum{:}];
    end

    return;





    function[tyo,szo,ro,ro2]=ops(node)

        switch kind(node)

        case{'ID','ANONID'}

            [tyo,szo,ro,ro2]=variableInSymbolTable(node);

        case{'INT','DOUBLE'}

            [tyo,szo,ro,ro2,gac]=makeConstant(node);
            gaccum{end+1}=gac;

        case 'PARENS'

            [tyo,szo,ro,ro2]=ops(Arg(node));

        case{'UPLUS'}

            [tyo,szo,ro,ro2,gac]=uplus(node,parallel.internal.types.opConversionMtreeToMATLAB(kind(node)));
            gaccum{end+1}=gac;

        case{'UMINUS'}

            [tyo,szo,ro,ro2,gac]=uminus(node,parallel.internal.types.opConversionMtreeToMATLAB(kind(node)));
            gaccum{end+1}=gac;

        case{'PLUS','MINUS'}

            [tyo,szo,ro,ro2,gac]=plusMinus(node,parallel.internal.types.opConversionMtreeToMATLAB(kind(node)));
            gaccum{end+1}=gac;
        case{'DOTMUL','DOTDIV','DOTLDIV','MUL','DIV','LDIV'}

            [tyo,szo,ro,ro2,gac]=infix(node,parallel.internal.types.opConversionMtreeToMATLAB(kind(node)));
            gaccum{end+1}=gac;

        case{'LT','LE','GE','GT'}

            [tyo,szo,ro,ro2,gac]=relop(node,lower(kind(node)));
            gaccum{end+1}=gac;

        case{'EQ','NE'}

            [tyo,szo,ro,ro2,gac]=equalityop(node,lower(kind(node)));
            gaccum{end+1}=gac;

        case 'DOTEXP'

            leftInputNode=Left(node);
            rightInputNode=Right(node);
            [tyo,szo,ro,ro2,gac]=power(leftInputNode,rightInputNode,'power');
            gaccum{end+1}=gac;

        case 'EXP'

            leftInputNode=Left(node);
            rightInputNode=Right(node);
            [tyo,szo,ro,ro2,gac]=power(leftInputNode,rightInputNode,'mpower');
            gaccum{end+1}=gac;

        case{'AND','OR'}

            [tyo,szo,ro,ro2,gac]=logicalinfix(node,lower(kind(node)));
            gaccum{end+1}=gac;

        case 'NOT'

            [tyo,szo,ro,ro2,gac]=logicalprefix(node);
            gaccum{end+1}=gac;

        case 'ANDAND'


            [tyo,szo,ro,ro2]=logicalinfixSC(node,'and');

        case 'OROR'


            [tyo,szo,ro,ro2]=logicalinfixSC(node,'or');

        case{'CALL'}

            [tyo,szo,ro,ro2,gac]=call(node);
            gaccum{end+1}=gac;

        case{'SUBSCR'}

            [tyo,szo,ro,ro2,gac]=subsref(node);
            gaccum{end+1}=gac;



        otherwise
            assert(false,'analysis phase is broken.');

        end

    end






    function[tyo,szo,ro,ro2]=variableInSymbolTable(node)
        symbolname=string(node);

        if symbolPresent(symbols,symbolname)

            symbol=getSymbol(symbols,symbolname);
            tyo=symbol.type;
            szo=symbol.shapeinfo;

            ro=symbol.reg;
            ro2='';

            if isComplex(tyo)
                ro2=symbol.reg2;
            end
        else

            fcnHandleInputList=getFcnHandleInputList(iR,parentFcnLabel);
            filterIdx=strcmp(fcnHandleInputList.inputs,symbolname);
            if any(filterIdx)
                symbolname=fcnHandleInputList.handle{filterIdx};
            end

            workspaceSymbols=getFcnWorkspaceSymbols(iR,parentFcnLabel);

            symbol=getSymbol(workspaceSymbols,symbolname);

            tyo=symbol.type;
            szo=symbol.shapeinfo;

            ro=symbol.reg;
            ro2='';

            if isComplexFloatingPoint(tyo)
                ro2=symbol.reg2;
            end


            if(strcmp(getRuleset(internalState),'singleton'))&&(isArray(tyo))
                equalsnode=getCompilationNode(internalState);
                lhsstrings=strings(list(asgvars(equalsnode)));
                if(numel(lhsstrings)>1)
                    lhs=sprintf(': ''%s%s''',sprintf('%s, ',lhsstrings{1:(end-1)}),lhsstrings{end});
                else
                    lhs=[' ''',lhsstrings{1},''''];
                end
                encounteredError(internalState,message('parallel:gpu:compiler:NonUniformOutput',symbolname,lhs));
            end
        end
    end




    function[tyo,szo,ro,ro2,instr]=makeConstant(node)
        value=string(node);
        tyo=parallel.internal.types.Atomic.enumerate(str2double(value));
        [instr,ro,ro2]=constant(emitter,internalState,tyo,value);
        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();
    end


    function[tyo,szo,ro,ro2,instr]=uplus(node,op)
        [tyo,szo,r1,r1i]=ops(Arg(node));
        [tyo,szo,ro,ro2,instr]=uplusImpl(tyo,szo,r1,r1i,op);
    end

    function[tyo,szo,ro,ro2,instr]=uplusImpl(ty1,szo,r1,r1i,op)



        tyo=parallel.internal.types.promoteLogicalToDoubleRule(ty1,op,errorMechanism);


        [cvtinstr,r1,r1i]=castreg(emitter,internalState,tyo,ty1,r1,r1i);


        [cpinstr,ro,ro2]=copyreg(emitter,internalState,tyo,r1,r1i);

        instr=[...
cvtinstr...
        ,cpinstr...
        ];
    end


    function[tyo,szo,ro,ro2,instr]=uminus(node,op)
        [tyo,szo,r1,r1i]=ops(Arg(node));
        [tyo,szo,ro,ro2,instr]=uminusImpl(tyo,szo,r1,r1i,op);
    end

    function[tyo,szo,ro,roi,instr]=uminusImpl(ty1,szo,r1,r1i,op)




        tyo=parallel.internal.types.arithmeticRule(ty1,op,errorMechanism);



        if isUnsignedInteger(tyo)
            [instr,ro,roi]=constant(emitter,internalState,coerceScalar(tyo),'0');
            return
        end


        [cvtinstr,r1,r1i]=castreg(emitter,internalState,tyo,ty1,r1,r1i);


        [ro,roi]=tGet(internalState,tyo);

        if isSignedInteger(tyo)


            [setUpNeg1,regNeg1,~]=constant(emitter,internalState,...
            coerceScalar(tyo),'-1');


            multInstr=saturatedIntegerMultiplication(emitter,internalState,...
            tyo,ro,regNeg1,r1);
            instr=[...
            cvtinstr,...
            setUpNeg1,...
            multInstr,...
            ];
        else
            [negatePtx,ro]=negatereg(emitter,internalState,tyo,r1);

            instr=[...
cvtinstr...
            ,negatePtx...
            ];

            if isComplexFloatingPoint(tyo)
                [negatePtx,roi]=negatereg(emitter,internalState,tyo,r1i);

                instr=[...
instr...
                ,negatePtx...
                ];
            end
        end
    end




    function[tyo,szo,ro,ro2,instr]=logicalprefix(node)

        [ty1,sz1,r1,~]=ops(Arg(node));
        [tyo,szo,ro,ro2,instr]=logicalprefixImpl(ty1,sz1,r1);

    end

    function[tyo,szo,ro,ro2,instr]=logicalprefixImpl(ty1,sz1,r1)

        [instr,tyo,ro]=logicalnotreg(emitter,internalState,ty1,r1);
        ro2='';
        szo=sz1;

    end






    function[tyo,szo,ro,ro2,instr]=infix(node,op)

        [ty1,sz1,r1,r1i]=ops(Left(node));
        [ty2,sz2,r2,r2i]=ops(Right(node));

        [tyo,szo,ro,ro2,instr]=infixImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op);

    end

    function[tyo,szo,ro,ro2,instr]=infixImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op)



        if strcmp(op,'mtimes')
            if isArray(ty1)&&isArray(ty2)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:Mtimes'));
            end

            if isLogical(ty1)&&isLogical(ty2)&&(isArray(ty1)&&isArray(ty2))
                encounteredError(errorMechanism,message('parallel:gpu:compiler:LogicalMatrixTimes'));
            end

        elseif strcmp(op,'ldivide')

            [ty1,ty2]=swap(ty1,ty2);
            [sz1,sz2]=swap(sz1,sz2);
            [r1,r2]=swap(r1,r2);
            [r1i,r2i]=swap(r1i,r2i);

        elseif strcmp(op,'mrdivide')
            if isArray(ty2)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:Mrdivide'));
            end

        elseif strcmp(op,'mldivide')
            if isArray(ty1)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:Mldivide'));
            end

            [ty1,ty2]=swap(ty1,ty2);
            [sz1,sz2]=swap(sz1,sz2);
            [r1,r2]=swap(r1,r2);
            [r1i,r2i]=swap(r1i,r2i);

        end

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,op);

        [cvtPtx,tyo,tyoo,r1,r1i,r2,r2i]=arithmeticTypeCombination(ty1,r1,r1i,ty2,r2,r2i,op);
        [ro,ro2]=tGet(internalState,tyoo);

        opinstr=arithmeticInstruction(emitter,internalState,op,tyoo,ro,ro2,r1,r1i,r2,r2i);


        if isSameBaseType(tyo,tyoo)
            instr=[cvtPtx,opinstr];
        else
            [cvtPtx1,ro,ro2]=castreg(emitter,internalState,tyo,tyoo,ro,ro2);
            instr=[cvtPtx,opinstr,cvtPtx1];
        end

    end













    function[tyo,szo,ro,ro2,instr]=plusMinus(node,op)
        [ty1,sz1,r1,r1i]=ops(Left(node));
        [ty2,sz2,r2,r2i]=ops(Right(node));

        [tyo,szo,ro,ro2,instr]=plusMinusImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op);
    end

    function[tyo,szo,ro,ro2,instr]=plusMinusImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op)
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,op);

        [tyo,tyoo]=parallel.internal.types.arithmeticOperandInDoubleRule(ty1,ty2,op,errorMechanism);
        [cvtPtx,r1,r1i,r2,r2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);

        [ro,ro2]=tGet(internalState,tyoo);

        opinstr=arithmeticInstruction(emitter,internalState,op,tyoo,ro,ro2,r1,r1i,r2,r2i);


        if isSameBaseType(tyo,tyoo)
            instr=[cvtPtx,opinstr];
        else
            [cvtPtx1,ro,ro2]=castreg(emitter,internalState,tyo,tyoo,ro,ro2);
            instr=[cvtPtx,opinstr,cvtPtx1];
        end
    end






    function[tyo,szo,ro,ro2,instr]=relop(node,op)

        [ty1,sz1,r1,r1i]=ops(Left(node));
        [ty2,sz2,r2,r2i]=ops(Right(node));

        [tyo,szo,ro,ro2,instr]=relopImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op);

    end

    function[tyo,szo,ro,ro2,instr]=relopImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op)

        [cvtinstr,tyeq,ro1,ro1i,ro2,ro2i]=relopTypeCombination(ty1,r1,r1i,ty2,r2,r2i,op);
        [opinstr,tyo,ro]=relopInstruction(emitter,internalState,op,tyeq,ro1,ro1i,ro2,ro2i);
        ro2='';

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,op);

        instr=[...
cvtinstr...
        ,opinstr...
        ];

    end



    function[tyo,szo,ro,ro2,instr]=equalityop(node,op)

        [ty1,sz1,r1,r1i]=ops(Left(node));
        [ty2,sz2,r2,r2i]=ops(Right(node));

        [tyo,szo,ro,ro2,instr]=equalityopImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op);

    end

    function[tyo,szo,ro,ro2,instr]=equalityopImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op)

        [cvtinstr,tyeq,ro1,ro1i,ro2,ro2i]=equalityTypeCombination(ty1,r1,r1i,ty2,r2,r2i,op);
        [opinstr,tyo,ro]=relopInstruction(emitter,internalState,op,tyeq,ro1,ro1i,ro2,ro2i);
        ro2='';

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,op);

        instr=[...
cvtinstr...
        ,opinstr...
        ];

    end




    function[tyo,szo,ro,ro2,instr]=logicalinfix(node,op)

        [ty1,sz1,r1,~]=ops(Left(node));
        [ty2,sz2,r2,~]=ops(Right(node));

        [tyo,szo,ro,ro2,instr]=logicalinfixImpl(ty1,sz1,r1,ty2,sz2,r2,op);

    end

    function[tyo,szo,ro,ro2,instr]=logicalinfixImpl(ty1,sz1,r1,ty2,sz2,r2,op)

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,op);
        [instr,tyo,ro]=logicalInstruction(emitter,internalState,op,ty1,r1,ty2,r2);
        ro2='';

    end




    function[tyo,szo,ro,ro2]=logicalinfixSC(node,op)

        endlabel=labelGet(internalState);

        tyo=parallel.internal.types.Atomic.buildAtomic('logical',false);
        [ro,ro2]=tGet(internalState,tyo);


        [ty1,sz1,r1,~]=ops(Left(node));

        if isArray(ty1)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:NonscalarShortcircuit'));
        end

        [cvtinstr,r1]=castreg(emitter,internalState,tyo,ty1,r1,'');
        checkinstr=logicalSCInstruction(emitter,internalState,op,ro,r1,endlabel);

        gaccum{end+1}=[...
cvtinstr...
        ,checkinstr...
        ];


        [ty2,sz2,r2,~]=ops(Right(node));

        if isArray(ty2)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:NonscalarShortcircuit'));
        end

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2);

        [logicalinstr,r2]=castreg(emitter,internalState,tyo,ty2,r2,'');
        [movinstr,ro]=movereg(emitter,internalState,tyo,ro,'',r2,'');

        gaccum{end+1}=[...
logicalinstr...
        ,movinstr...
        ,formatLabel(emitter,'',endlabel)...
        ];

    end




    function[tyo,szo,ro,ro2,instr]=call(node)

        fn=string(Left(node));

        switch fn


        case{'rand','randn'}
            [tyo,szo,ro,ro2,instr]=randImpl(node,fn);

        case{'randi'}
            [tyo,szo,ro,ro2,instr]=randiImpl(node,fn);


        case{'uplus'}
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=uplusImpl(ty1,sz1,r1,r1i,fn);
        case{'uminus'}
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=uminusImpl(ty1,sz1,r1,r1i,fn);
        case 'not'
            [ty1,sz1,r1,~]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=logicalprefixImpl(ty1,sz1,r1);


        case 'abs'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=absImpl(ty1,sz1,r1,r1i,fn);
        case 'angle'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=angleImpl(ty1,sz1,r1,r1i,fn);
        case 'nextpow2'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=nextpow2Impl(ty1,sz1,r1,r1i,fn);


        case 'fix'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=fixImpl(ty1,sz1,r1,r1i,fn);

        case{'ceil','floor'}
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=ceilFloorImpl(ty1,sz1,r1,r1i,fn);

        case 'round'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=roundImpl(ty1,sz1,r1,r1i,fn);

        case 'sign'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=signImpl(ty1,sz1,r1,r1i,fn);

        case 'eps'
            [tyo,szo,ro,ro2,instr]=epsImpl(node,fn);

        case{'realmin','realmax'}
            [tyo,szo,ro,ro2,instr]=realminmaxImpl(node,fn);

        case{'intmin','intmax'}
            [tyo,szo,ro,ro2,instr]=intminmaxImpl(node,fn);

        case{'isinf','isnan','isfinite'}
            [tyo,szo,ro,ro2,instr]=isfiniteImpl(node,fn);

        case{'isfloat','isinteger','islogical','isnumeric','isreal','issparse'}
            [tyo,szo,ro,ro2,instr]=isTypeImpl(node,fn);

        case{'erf','erfc','erfcinv','erfinv','erfcx'...
            ,'gamma','gammaln','reallog','realsqrt'}
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=realFloatOnlyImpl(ty1,sz1,r1,r1i,fn);

        case{'acos','acosd','acosh','acot','acotd','acoth'...
            ,'acsc','acscd','acsch','asec','asecd','asech'...
            ,'asin','asind','asinh','atan','atand','atanh'...
            ,'log','log10','log1p','log2','sqrt','expint'...
            }
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=floatingPointRestrictedDomainImpl(ty1,sz1,r1,r1i,fn);
        case{'cos','cosd','cosh','cot','cotd','coth'...
            ,'csc','cscd','csch','deg2rad','exp','expm1'...
            ,'rad2deg','sec','secd','sech','sin','sind','sinh'...
            ,'tan','tand','tanh'}
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=floatingPointFullDomainImpl(ty1,sz1,r1,r1i,fn);


        case{'double','single'...
            ,'int64','int32','int16','int8'...
            ,'uint64','uint32','uint16','uint8'}
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=explicitCastImpl(ty1,sz1,r1,r1i,fn);

        case 'logical'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=logicalCastImpl(ty1,sz1,r1,r1i,fn);

        case 'cast'
            [tyo,szo,ro,ro2,instr]=castImpl(emitter,node,fn);

        case 'complex'
            [tyo,szo,ro,ro2,instr]=complexImpl(emitter,node,fn);

        case 'real'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=realImpl(ty1,sz1,r1,r1i,fn);

        case 'imag'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=imagImpl(ty1,sz1,r1,r1i,fn);

        case 'conj'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=conjImpl(ty1,sz1,r1,r1i,fn);


        case{'plus','minus'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=plusMinusImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);
        case{'times','rdivide','ldivide','mtimes','mldivide','mrdivide'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=infixImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);
        case{'power','mpower'}



            leftInputNode=parallel.internal.tree.firstArgNode(node);
            rightInputNode=parallel.internal.tree.nextArgNode(leftInputNode);
            [tyo,szo,ro,ro2,instr]=power(leftInputNode,rightInputNode,fn);
        case{'lt','gt','le','ge'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=relopImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'eq','ne'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=equalityopImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'and','or'}
            [ty1,sz1,r1,~,ty2,sz2,r2,~]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=logicalinfixImpl(ty1,sz1,r1,ty2,sz2,r2,fn);

        case{'nthroot'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=nthrootImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case 'hypot'
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=hypotImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'atan2','atan2d','beta','betaln'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=betaAtanImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'psi'}
            [tyo,szo,ro,ro2,instr]=psiImpl(node,fn);

        case{'mod','rem','realpow'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=realOnlyBinaryFcnImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'min','max'}
            [tyo,szo,ro,ro2,instr]=minMaxImpl(node,fn);

        case 'pow2'
            [tyo,szo,ro,ro2,instr]=pow2Impl(node,fn);


        case 'xor'
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=xorImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);


        case 'bitcmp'
            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=bitcmpImpl(ty1,sz1,r1,r1i,fn);

        case{'bitand','bitor','bitxor'}
            [tyo,szo,ro,ro2,instr]=bitLogicImpl(node,fn);

        case 'bitshift'
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=bitshiftImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'bitget'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=bitgetImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'bitset'}
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=bitsetImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn);

        case{'besseli','besselj','besselk','bessely'}
            [tyo,szo,ro,ro2,instr]=besselImpl(node,fn);


        case{'gammainc','gammaincinv'}
            [tyo,szo,ro,ro2,instr]=gammaincImpl(node,fn);
        case{'betainc','betaincinv'}
            [tyo,szo,ro,ro2,instr]=betaincImpl(node,fn);


        case 'true'
            [tyo,szo,ro,ro2,instr]=constantImpl('logical','1');

        case 'false'
            [tyo,szo,ro,ro2,instr]=constantImpl('logical','0');

        case 'pi'
            [tyo,szo,ro,ro2,instr]=constantImpl('double','3.141592653589793');

        case{'Inf','inf'}
            floatOnly=true;
            [tyo,szo,ro,ro2,instr]=buildFcnImpl(node,'Inf','inf',floatOnly);

        case{'NaN','nan'}
            floatOnly=true;
            [tyo,szo,ro,ro2,instr]=buildFcnImpl(node,'NaN','nan',floatOnly);

        case{'ones'}
            floatOnly=false;
            [tyo,szo,ro,ro2,instr]=buildFcnImpl(node,fn,'1.0',floatOnly);

        case{'zeros'}
            floatOnly=false;
            [tyo,szo,ro,ro2,instr]=buildFcnImpl(node,fn,'0.0',floatOnly);

        otherwise


            [tyo,szo,ro,ro2,instr]=customFcnImpl(node,fn);

        end

    end











    function[tyo,szo,ro,ro2,instr]=subsref(node)


        symbolname=string(Left(node));
        fcnHandleInputList=getFcnHandleInputList(iR,parentFcnLabel);
        workspaceSymbols=getFcnWorkspaceSymbols(iR,parentFcnLabel);
        inputToHandleIndex=strcmp(fcnHandleInputList.inputs,symbolname);
        if~isempty(fcnHandleInputList.idx)&&...
            any(inputToHandleIndex)
            symbolname=fcnHandleInputList.handle{inputToHandleIndex};
        end
        symbol=getSymbol(workspaceSymbols,symbolname);



        rdata=symbol.reg;
        rbounds=symbol.reg2;

        tyo=symbol.type;
        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();




        dimensions=symbol.shapeinfo.dims;
        numRealDims=length(dimensions);
        if(prod(dimensions)==1)

            numRealDims=1;
        end


        [ro,ro2]=tGet(internalState,tyo);


        arg=parallel.internal.tree.firstArgNode(node);
        tyargs={};
        rargs={};

        while~isnull(arg)

            [tyarg,~,rarg,~]=ops(arg);


            errorIfIndexIsIllegalType(tyarg);

            tyargs{end+1}=tyarg;%#ok
            rargs{end+1}=rarg;%#ok

            arg=parallel.internal.tree.nextArgNode(arg);

        end

        nargs=numel(tyargs);
        if(1==nargs)


            instr=fetchArrayElementLinearIndexing(emitter,internalState,...
            ro,ro2,tyo,rdata,rbounds,tyarg,rarg,numRealDims);
        elseif(nargs<numRealDims)



            instr=fetchArrayElementFoldIndexing(emitter,internalState,...
            ro,ro2,tyo,rdata,rbounds,tyargs,rargs,numRealDims);
        else


            instr=fetchArrayElementCoordinateIndexing(emitter,internalState,...
            ro,ro2,tyo,rdata,rbounds,tyargs,rargs,numRealDims);
        end

        tyo=coerceScalar(tyo);

    end




    function[tyo,szo,ro,ro2,instr]=power(leftInputNode,rightInputNode,op)

        [ty1,sz1,r1,r1i]=ops(leftInputNode);












        exponent=rightInputNode;
        [value,tooptimize]=determinePowerOptimization(exponent);
        if tooptimize

            avalue=abs(value);
            instr=cell(1,avalue);

            tyt=ty1;
            szt=sz1;
            [instr{1},rt,rti]=copyreg(emitter,internalState,ty1,r1,r1i);

            mulop=parallel.internal.types.opConversionMtreeToMATLAB('DOTMUL');
            for kk=2:avalue
                [tyt,szt,rt,rti,instr{kk}]=infixImpl(tyt,szt,rt,rti,ty1,sz1,r1,r1i,mulop);
            end

            if value>0
                tyo=tyt;
                szo=szt;
                ro=rt;
                ro2=rti;
                instr=[instr{:}];
            else

                divop=parallel.internal.types.opConversionMtreeToMATLAB('DOTDIV');
                tyone=parallel.internal.types.Atomic.buildAtomic('double',false);
                szone=szt;
                [make1instr,rone,ronei]=constant(emitter,internalState,tyone,'1');
                [tyo,szo,ro,ro2,reciporcalinstr]=infixImpl(tyone,szone,rone,ronei,tyt,szt,rt,rti,divop);

                instr=[...
                instr{:}...
                ,make1instr...
                ,reciporcalinstr...
                ];

            end

        else
            [ty2,sz2,r2,r2i]=ops(exponent);
            [tyo,szo,ro,ro2,instr]=powerImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op);
        end

    end

    function[tyo,szo,ro,ro2,instr]=powerImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,op)

        if strcmp(op,'mpower')
            if isArray(ty1)||isArray(ty2)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:MpowerNonscalar'));
            end
        end


        flintCheck='';
        if isInteger(ty1)&&(isDouble(ty2)&&isScalar(ty2))
            regCheck=tGet(internalState,parallel.internal.types.Atomic.buildAtomic('logical',false));
            flintCheck=[...
            unacall(emitter,internalState,ty2,regCheck,'','errorIfNegativeOrNotFlintPower',r2,'')...
            ,exitIfRegisterIsTrue(emitter,internalState,regCheck)...
            ];

        end

        [cvtinstr,tyo,tyoo,r1,r1i,r2,r2i]=arithmeticTypeCombination(ty1,r1,r1i,ty2,r2,r2i,op);

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,op);

        fn='power';
        [ro,ro2]=tGet(internalState,tyoo);

        instr=[...
flintCheck...
        ,cvtinstr...
        ,bincall(emitter,internalState,tyoo,ro,ro2,fn,r1,r1i,r2,r2i)...
        ];


        if~isSameBaseType(tyo,tyoo)
            [cvtinstr,ro,ro2]=castreg(emitter,internalState,tyo,tyoo,ro,ro2);
            instr=[...
instr...
            ,cvtinstr];
        end

    end



    function[tyo,szo,ro,ro2,instr]=buildFcnImpl(node,fn,valueStr,floatOnly)


        firstArg=parallel.internal.tree.firstArgNode(node);

        function iCheckSupportedBuildType(operandType)


            if floatOnly&&~isFloatingPoint(operandType)
                encounteredError(errorMechanism,message(['MATLAB:',fn,':invalidInputClass']));
            end
        end
        allowComplex=true;
        tyo=resolveBuildTypeArgument(firstArg,@iCheckSupportedBuildType,fn,allowComplex);
        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();
        [instr,ro,ro2]=constant(emitter,internalState,tyo,valueStr);
    end

    function[tyo,szo,ro,ro2,instr]=randImpl(node,fn)
        firstArg=parallel.internal.tree.firstArgNode(node);
        function iCheckSupportedRandType(operandType)


            if~isFloatingPoint(operandType)
                encounteredError(errorMechanism,message(['MATLAB:',fn,':invalidPrototype']));
            end
        end
        allowComplex=false;
        tyo=resolveBuildTypeArgument(firstArg,@iCheckSupportedRandType,fn,allowComplex);

        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();

        [instr,ro,ro2]=sampleRandAndAdvance(emitter,internalState,fn,tyo);
    end

    function[tyo,szo,ro,ro2,instr]=randiImpl(node,fn)
        firstArg=parallel.internal.tree.firstArgNode(node);
        secondArg=parallel.internal.tree.nextArgNode(firstArg);



        tycal=parallel.internal.types.Atomic.buildAtomic('double',false);

        [firstElemNode,otherNode]=parallel.internal.tree.resolveArrayEntries(firstArg);
        [ty1,~,rmin,r1i]=ops(firstElemNode);
        iCheckRandiRangeArg(ty1);

        [cvtinstr1,rmin]=castreg(emitter,internalState,tycal,ty1,rmin,r1i);

        if~isnull(otherNode)&&(otherNode~=secondArg)
            secondElemNode=parallel.internal.tree.resolveArrayEntries(otherNode);
            [ty2,~,rmax,r2i]=ops(secondElemNode);
            iCheckRandiRangeArg(ty2);

            [cvtinstr2,rmax]=castreg(emitter,internalState,tycal,ty2,rmax,r2i);

        else



            rmax=rmin;
            [cvtinstr2,rmin,~]=constant(emitter,internalState,tycal,'1');

        end

        instr=[...
cvtinstr1...
        ,cvtinstr2...
        ];

        function iCheckRandiRangeArg(argType)

            if~isScalar(argType)
                encounteredError(errorMechanism,message('MATLAB:RandStream:randi:invalidLimits'));
            end
            if~isReal(argType)
                encounteredError(errorMechanism,message('MATLAB:randi:invalidLimits'));
            end
        end

        function iCheckSupportedRandiType(operandType)


            if~isNumeric(operandType)||is64BitInteger(operandType)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:IllegalType',mType(operandType),fn));
            end
        end
        allowComplex=false;
        tyo=resolveBuildTypeArgument(secondArg,@iCheckSupportedRandiType,fn,allowComplex);

        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();


        [callinstr,ro,ro2]=sampleRandAndAdvance(emitter,internalState,fn,tyo,rmin,rmax);

        instr=[...
instr...
        ,callinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=castImpl(emitter,node,fn)

        firstArg=parallel.internal.tree.firstArgNode(node);
        [ty1,sz1,r1,r1i]=ops(firstArg);
        secondArg=parallel.internal.tree.nextArgNode(firstArg);

        function iCheckSupportedCastType(operandType)


            if~(isNumeric(operandType)||isLogical(operandType))
                encounteredError(errorMechanism,message('parallel:gpu:compiler:IllegalType',mType(operandType),fn));
            end
        end

        allowComplex=true;
        tyo=resolveBuildTypeArgument(secondArg,@iCheckSupportedCastType,fn,allowComplex);

        if isLogical(tyo)&&isComplex(ty1)
            encounteredError(errorMechanism,message("MATLAB:nologicalcomplex"));
        end

        if isReal(tyo)&&isComplex(ty1)
            tyo=coerceComplex(tyo);
        end

        szo=sz1;
        [instr,ro,ro2]=castregisters(emitter,internalState,tyo,ty1,r1,r1i);
    end

    function[tyo,szo,ro,ro2,instr]=complexImpl(emitter,node,fn)

        firstArg=parallel.internal.tree.firstArgNode(node);
        [ty1,sz1,r1,r1i]=ops(firstArg);

        secondArg=parallel.internal.tree.nextArgNode(firstArg);
        if isnull(secondArg)


            tyo=parallel.internal.types.realToComplexRule(ty1,fn,errorMechanism);
            if isComplex(ty1)

                [instr,ro,ro2]=copyreg(emitter,internalState,ty1,r1,r1i);
            else
                [copyinstr,ro]=copyreg(emitter,internalState,ty1,r1,'');
                [zeroload,ro2]=constant(emitter,internalState,coerceScalar(ty1),'0');
                instr=[copyinstr,zeroload];
            end
            szo=sz1;
        else


            [ty2,sz2,r2,r2i]=ops(secondArg);


            szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);


            [tyo,tyoo]=parallel.internal.types.realToComplexRule(ty1,ty2,fn,errorMechanism);

            [instr,ro,~,ro2,~]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
        end
    end

    function[tyo,szo,ro,ro2,instr]=absImpl(ty1,sz1,r1,r1i,fn)



        szo=sz1;
        tyo=parallel.internal.types.arithmeticMapsToRealRule(ty1,fn,errorMechanism);
        cvtinstr='';
        if isLogical(ty1)
            [cvtinstr,r1]=castreg(emitter,internalState,tyo,ty1,r1,r1i);
        end

        if isUnsignedInteger(ty1)
            [opinstr,ro,ro2]=copyreg(emitter,internalState,tyo,r1,r1i);
        elseif isComplexFloatingPoint(ty1)
            [ro,ro2]=tGet(internalState,tyo);
            opinstr=bincall(emitter,internalState,tyo,ro,ro2,'hypot',r1,r1,r1i,r1i);
        else
            [ro,ro2]=tGet(internalState,tyo);
            opinstr=absreg(emitter,internalState,tyo,ro,r1);
        end

        instr=[...
cvtinstr...
        ,opinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=angleImpl(ty1,sz1,r1,r1i,fn)



        szo=sz1;
        tyo=parallel.internal.types.floatingPointMapsToRealRule(ty1,fn,errorMechanism);

        prepinstr='';
        if~isComplexFloatingPoint(ty1)
            [prepinstr,r1i]=constant(emitter,internalState,coerceScalar(ty1),'0');
        end
        [ro,ro2]=tGet(internalState,tyo);
        opinstr=bincall(emitter,internalState,tyo,ro,ro2,'atan2',r1i,'',r1,'');

        instr=[...
prepinstr...
        ,opinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=nextpow2Impl(ty1,sz1,r1,r1i,fn)



        szo=sz1;
        tyo=parallel.internal.types.arithmeticMapsToRealRule(ty1,fn,errorMechanism);

        if isLogical(ty1)

            [prepinstr,r1]=castreg(emitter,internalState,tyo,ty1,r1,r1i);
        elseif isComplexFloatingPoint(ty1)


            [~,~,r1,~,prepinstr]=absImpl(ty1,sz1,r1,r1i,'abs');
        else
            prepinstr='';
        end


        [ro,ro2]=tGet(internalState,tyo);
        opinstr=unacall(emitter,internalState,tyo,ro,ro2,'nextpow2',r1,'');

        instr=[...
prepinstr...
        ,opinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=besselImpl(node,fn)



        if parallel.internal.tree.countNumberOfArgs(node)==3

            [ty_nu,sz_nu,r_nu,ri_nu,...
            ty_z,sz_z,r_z,ri_z,...
            ty_s,sz_s,r_s,ri_s]=preternarycall(node,fn);


            [cvtInInstr,tyo,tyop,r_nu,~,r_z,~,r_s,~]=realFloatOperateInDoubleCombination(fn,...
            ty_nu,r_nu,ri_nu,...
            ty_z,r_z,ri_z,...
            ty_s,r_s,ri_s);


            szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz_nu,sz_z,fn);
            szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,szo,sz_s,fn);
            prepInstr='';
        else

            [ty_nu,sz_nu,r_nu,ri_nu,ty_z,sz_z,r_z,ri_z]=prebinarycall(node,fn);


            [cvtInInstr,tyo,tyop,r_nu,~,r_z,~]=realFloatOperateInDoubleCombination(fn,...
            ty_nu,r_nu,ri_nu,...
            ty_z,r_z,ri_z);
            szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz_nu,sz_z,fn);

            [prepInstr,r_s]=constant(emitter,internalState,coerceScalar(tyop),'0');

        end

        [rop,rop2]=tGet(internalState,tyop);
        callInstr=ternarycall(emitter,internalState,tyop,rop,rop2,fn,r_nu,'',r_z,'',r_s,'');


        [cvtOutInstr,ro,ro2]=castregisters(emitter,internalState,tyo,tyop,rop,rop2);


        instr=[...
cvtInInstr...
        ,prepInstr...
        ,callInstr...
        ,cvtOutInstr...
        ];
    end

    function[tyo,szo,ro,roi,instr]=fixImpl(ty1,szo,r1,r1i,fn)
        tyo=parallel.internal.types.arithmeticRule(ty1,fn,errorMechanism);


        [cvtinstr,rtmp,rtmpi]=castreg(emitter,internalState,tyo,ty1,r1,r1i);



        if isInteger(ty1)||isLogical(ty1)
            [copyinstr,ro,roi]=copyreg(emitter,internalState,tyo,rtmp,rtmpi);
            instr=[...
            cvtinstr,...
            copyinstr,...
            ];
            return
        end


        [ro,roi]=tGet(internalState,tyo);
        realfixinstr=fixreg(emitter,tyo,ro,rtmp);
        instr=[...
        cvtinstr,...
        realfixinstr,...
        ];

        if isComplexFloatingPoint(ty1)
            instr=[...
instr...
            ,fixreg(emitter,tyo,roi,rtmpi)...
            ];
        end
    end

    function[tyo,szo,ro,ro2,instr]=ceilFloorImpl(ty1,szo,r1,r1i,fn)

        tyo=parallel.internal.types.arithmeticRule(ty1,fn,errorMechanism);


        [cvtinstr,rtmp,rtmpi]=castreg(emitter,internalState,tyo,ty1,r1,r1i);



        if isInteger(ty1)||isLogical(ty1)
            [copyinstr,ro,ro2]=copyreg(emitter,internalState,tyo,rtmp,rtmpi);
            instr=[...
            cvtinstr,...
            copyinstr,...
            ];
            return
        end


        [ro,ro2]=tGet(internalState,tyo);
        instr=[...
        cvtinstr,...
        ceilfloorreg(emitter,fn,tyo,ro,r1),...
        ];

        if isComplexFloatingPoint(tyo)
            instr=[...
instr...
            ,ceilfloorreg(emitter,fn,tyo,ro2,r1i)...
            ];
        end
    end

    function[tyo,szo,ro,ro2,instr]=roundImpl(ty1,sz1,r1,r1i,fn)
        tyo=parallel.internal.types.arithmeticRule(ty1,fn,errorMechanism);
        szo=sz1;


        [cvtinstr,rtmp,rtmpi]=castreg(emitter,internalState,tyo,ty1,r1,r1i);



        if isInteger(ty1)||isLogical(ty1)
            [copyinstr,ro,ro2]=copyreg(emitter,internalState,tyo,rtmp,rtmpi);
            instr=[...
            cvtinstr,...
            copyinstr,...
            ];
            return
        end


        [ro,ro2]=tGet(internalState,tyo);
        instr=[...
        cvtinstr,...
        unacall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i),...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=signImpl(ty1,sz1,r1,r1i,fn)
        tyo=parallel.internal.types.arithmeticRule(ty1,fn,errorMechanism);
        szo=sz1;

        [cvtinstr,r1,r1i]=castreg(emitter,internalState,tyo,ty1,r1,r1i);



        [ro,ro2]=tGet(internalState,tyo);
        instr=[cvtinstr,unacall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i)];
    end

    function[tyo,szo,ro,ro2,instr]=epsImpl(node,fn)
        firstArg=parallel.internal.tree.firstArgNode(node);
        if isnull(firstArg)


            tyo=parallel.internal.types.Atomic.buildAtomic('double',false);
            [instr,ro,ro2]=constant(emitter,internalState,tyo,'2.220446049250313e-16');
            szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();

        elseif parallel.internal.tree.isTextLiteral(firstArg)
            ty=parallel.internal.tree.textLiteralContents(firstArg);

            if strcmp(ty,'double')
                epsString='2.220446049250313e-16';
            else
                epsString='1.1920929e-07';
            end

            tyo=parallel.internal.types.Atomic.buildAtomic(ty,false);
            [instr,ro,ro2]=constant(emitter,internalState,tyo,epsString);
            szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();

        else

            [ty1,sz1,r1,r1i]=preunarycall(node,fn);
            szo=sz1;
            tyo=parallel.internal.types.floatingPointMapsToRealRule(ty1,fn,errorMechanism);

            [ro,ro2]=tGet(internalState,tyo);
            if isComplexFloatingPoint(ty1)
                instr=[...
                bincall(emitter,internalState,tyo,ro,ro2,'hypot',r1,r1,r1i,r1i)...
                ,unacall(emitter,internalState,tyo,ro,ro2,fn,ro,ro2)...
                ];
            else
                instr=unacall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i);
            end

        end
    end

    function[tyo,szo,ro,ro2,instr]=realminmaxImpl(node,fn)
        ty=resolveTypeLiteralInput(node,'double',fn);
        tyo=parallel.internal.types.Atomic.buildAtomic(ty,false);
        [instr,ro,ro2]=loadrealminmax(emitter,internalState,tyo,fn);
        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();
    end

    function[tyo,szo,ro,ro2,instr]=intminmaxImpl(node,fn)
        ty=resolveTypeLiteralInput(node,'int32',fn);

        value=sprintf('%i',feval(fn,ty));

        tyo=parallel.internal.types.Atomic.buildAtomic(ty,false);
        [instr,ro,ro2]=constant(emitter,internalState,tyo,value);
        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();

    end

    function[tyo,szo,ro,ro2,instr]=isfiniteImpl(node,fn)

        [ty1,szo,r1,r1i]=preunarycall(node,fn);
        tyo=coerceLogical(ty1);
        ro=rGet(internalState);
        ro2='';

        if isFloatingPoint(ty1)
            instr=unacall(emitter,internalState,ty1,ro,ro2,fn,r1,r1i);
        elseif isLogical(ty1)||isInteger(ty1)

            if strcmp(fn,'isfinite')
                [instr,ro,ro2]=constant(emitter,internalState,coerceScalar(coerceInt32(ty1)),'1');
            else
                [instr,ro,ro2]=constant(emitter,internalState,coerceScalar(coerceInt32(ty1)),'0');
            end

        else
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(ty1)),fn));
        end
    end

    function[tyo,szo,ro,ro2,instr]=isTypeImpl(node,fn)
        [ty1,szo,~,~]=preunarycall(node,fn);
        tyo=coerceLogical(ty1);
        switch(fn)
        case 'isfloat'
            result=isFloatingPoint(ty1);
        case 'isinteger'
            result=isInteger(ty1);
        case 'islogical'
            result=isLogical(ty1);
        case 'isnumeric'
            result=isNumeric(ty1);
        case 'isreal'
            result=isReal(ty1);
        case 'issparse'
            result=isSparse(ty1);
        end
        if result
            [instr,ro,ro2]=constant(emitter,internalState,coerceScalar(coerceInt32(ty1)),'1');
        else
            [instr,ro,ro2]=constant(emitter,internalState,coerceScalar(coerceInt32(ty1)),'0');
        end
    end

    function[tyo,szo,ro,ro2,instr]=realFloatOnlyImpl(tyo,szo,r1,r1i,fn)


        if isRealFloatingPoint(tyo)
            [ro,ro2]=tGet(internalState,tyo);
            instr=unacall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i);
        else
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(tyo)),fn));
        end
    end

    function[tyo,szo,ro,ro2,instr]=floatingPointFullDomainImpl(tyo,szo,r1,r1i,fn)
        tyo=parallel.internal.types.floatingPointFullDomainRule(tyo,fn,errorMechanism);
        [ro,ro2]=tGet(internalState,tyo);
        instr=unacall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i);
    end

    function[tyo,szo,ro,ro2,instr]=floatingPointRestrictedDomainImpl(tyo,szo,r1,r1i,fn)
        tyo=parallel.internal.types.floatingPointRestrictedDomainRule(tyo,fn,errorMechanism);
        [ro,ro2]=tGet(internalState,tyo);
        instr=unacall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i);
    end

    function[tyo,szo,ro,ro2,instr]=explicitCastImpl(ty1,sz1,r1,r1i,fn)
        tyo=parallel.internal.types.Atomic.buildAtomic(fn,isArray(ty1));
        szo=sz1;
        if isComplex(ty1)
            tyo=coerceComplex(tyo);
        end
        [instr,ro,ro2]=castreg(emitter,internalState,tyo,ty1,r1,r1i);
    end

    function[tyo,szo,ro,ro2,instr]=logicalCastImpl(ty1,sz1,r1,r1i,fn)
        tyo=parallel.internal.types.Atomic.buildAtomic(fn,isArray(ty1));
        szo=sz1;
        if isComplex(ty1)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:InvalidConversionComplexLogical'));
        end
        [instr,ro,ro2]=castreg(emitter,internalState,tyo,ty1,r1,r1i);
    end

    function[tyo,szo,ro,ro2,instr]=realImpl(ty1,sz1,r1,~,fn)
        tyo=parallel.internal.types.mapsToRealRule(ty1,fn,errorMechanism);
        ty1=coerceReal(ty1);
        szo=sz1;


        [instr,ro,ro2]=castreg(emitter,internalState,tyo,ty1,r1,'');
    end

    function[tyo,szo,ro,ro2,instr]=imagImpl(ty1,sz1,~,r1i,fn)
        tyo=parallel.internal.types.mapsToRealRule(ty1,fn,errorMechanism);
        szo=sz1;
        if isReal(ty1)

            [instr,ro,ro2]=constant(emitter,internalState,coerceScalar(tyo),'0');
        else

            [instr,ro,ro2]=copyreg(emitter,internalState,tyo,r1i,'');
        end
    end

    function[tyo,szo,ro,ro2,instr]=conjImpl(ty1,sz1,r1,r1i,fn)
        szo=sz1;
        tyo=parallel.internal.types.arithmeticNoLogicalsRule(ty1,fn,errorMechanism);

        if isReal(tyo)

            if tyo==ty1

                [instr,ro,ro2]=copyreg(emitter,internalState,tyo,r1,r1i);
            else

                [instr,ro,ro2]=castreg(emitter,internalState,tyo,ty1,r1,r1i);
            end
        elseif isComplexFloatingPoint(tyo)

            [copyinstr,ro,ro2]=copyreg(emitter,internalState,tyo,r1,r1i);
            [negateinstr,ro2]=negatereg(emitter,internalState,tyo,ro2);

            instr=[...
copyinstr...
            ,negateinstr...
            ];
        else
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(tyo)),fn));
        end
    end

    function[tyo,szo,ro,ro2,instr]=nthrootImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn)
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);
        [cvtinstr,tyo,~,r1,r1i,r2,r2i]=floatingPointAndLogicalArithmeticRuleAndCastInputs(ty1,r1,r1i,ty2,r2,r2i,fn);
        [ro,ro2]=tGet(internalState,tyo);

        instr=[...
cvtinstr...
        ,bincall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i,r2,r2i)...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=hypotImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn)
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);
        [cvtinstr,tyo,tyoo,r1,r1i,r2,r2i]=floatingPointMapsToRealRuleAndCastInputs(ty1,r1,r1i,ty2,r2,r2i,fn);

        [ro,ro2]=tGet(internalState,tyo);


        if isComplex(tyoo)

            [rtmp,rtmp2]=tGet(internalState,tyoo);

            opinstr=[...
            bincall(emitter,internalState,tyo,rtmp,rtmp,fn,r1,r1,r1i,r1i)...
            ,bincall(emitter,internalState,tyo,rtmp2,rtmp2,fn,r2,r2,r2i,r2i)...
            ,bincall(emitter,internalState,tyo,ro,ro2,fn,rtmp,rtmp,rtmp2,rtmp2)...
            ];
        else
            opinstr=bincall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i,r2,r2i);
        end

        instr=[...
cvtinstr...
        ,opinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=betaAtanImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn)
        [cvtinstr,tyo,~,r1,r1i,r2,r2i]=realFloatingPointOnlyCombination(fn,ty1,r1,r1i,ty2,r2,r2i);
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);
        [ro,ro2]=tGet(internalState,tyo);
        instr=[...
cvtinstr...
        ,bincall(emitter,internalState,tyo,ro,ro2,fn,r1,r1i,r2,r2i)...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=psiImpl(node,fn)


        if parallel.internal.tree.countNumberOfArgs(node)==1

            [ty_x,sz_x,r_x,~]=preunarycall(node,fn);


            ty_k=coerceScalar(ty_x);
            [preinstr,r_k]=constant(emitter,internalState,ty_k,'0');
        else

            [ty_k,~,r_k,~,ty_x,sz_x,r_x,~]=prebinarycall(node,fn);
            preinstr='';
        end


        if~isRealFloatingPoint(ty_k)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(ty2)),fn));
        end
        if~isScalar(ty_k)
            encounteredError(errorMechanism,message('MATLAB:psi:kScalar'));
        end


        if~isRealFloatingPoint(ty_x)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(ty2)),fn));
        end


        tyop=parallel.internal.types.Atomic('d');
        [cvtInInstr,r_k,~,r_x,~]=castregisters(emitter,internalState,tyop,ty_k,r_k,'',tyop,ty_x,r_x,'');


        [rop,rop2]=tGet(internalState,tyop);
        callInstr=bincall(emitter,internalState,tyop,rop,rop2,fn,r_k,'',r_x,'');


        tyo=ty_x;
        szo=sz_x;
        [cvtOutInstr,ro,ro2]=castregisters(emitter,internalState,tyo,tyop,rop,rop2);

        instr=[...
preinstr...
        ,cvtInInstr...
        ,callInstr...
        ,cvtOutInstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=gammaincImpl(node,fn)

        [ty_x,sz_x,r_x,ri_x,ty_a,sz_a,r_a,ri_a]=prebinarycall(node,fn);


        [cvtInInstr,tyo,tyop,r_x,~,r_a,~]=realFloatOperateInDoubleCombination(fn,ty_x,r_x,ri_x,ty_a,r_a,ri_a);
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz_x,sz_a,fn);

        thirdArg=...
        parallel.internal.tree.nextArgNode(...
        parallel.internal.tree.nextArgNode(...
        parallel.internal.tree.firstArgNode(node)));
        if isnull(thirdArg)

            suffix='lower';
        else


            suffix=parallel.internal.tree.textLiteralContents(thirdArg);

        end

        callfn=[fn,suffix];
        [rop,rop2]=tGet(internalState,tyop);
        callInstr=bincall(emitter,internalState,tyop,rop,rop2,callfn,r_x,'',r_a,'');

        [cvtOutInstr,ro,ro2]=castregisters(emitter,internalState,tyo,tyop,rop,rop2);

        instr=[...
cvtInInstr...
        ,callInstr...
        ,cvtOutInstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=betaincImpl(node,fn)

        [ty_x,sz_x,r_x,ri_x,ty_z,sz_z,r_z,ri_z,ty_w,sz_w,r_w,ri_w]=preternarycall(node,fn);


        [cvtInInstr,tyo,tyop,r_x,~,r_z,~,r_w,~]=realFloatOperateInDoubleCombination(fn,ty_x,r_x,ri_x,ty_z,r_z,ri_z,ty_w,r_w,ri_w);

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz_x,sz_z,fn);
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,szo,sz_w,fn);

        fourthArg=...
        parallel.internal.tree.nextArgNode(...
        parallel.internal.tree.nextArgNode(...
        parallel.internal.tree.nextArgNode(...
        parallel.internal.tree.firstArgNode(node))));
        if isnull(fourthArg)

            suffix='lower';
        else


            suffix=parallel.internal.tree.textLiteralContents(fourthArg);

        end

        callfn=[fn,suffix];
        [rop,rop2]=tGet(internalState,tyop);
        callInstr=ternarycall(emitter,internalState,tyop,rop,rop2,callfn,r_x,'',r_z,'',r_w,'');

        [cvtOutInstr,ro,ro2]=castregisters(emitter,internalState,tyo,tyop,rop,rop2);

        instr=[...
cvtInInstr...
        ,callInstr...
        ,cvtOutInstr...
        ];

    end

    function[tyo,szo,ro,ro2,instr]=realOnlyBinaryFcnImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn)
        [cvtinstr,tyo,tyoo,r1,r1i,r2,r2i]=realOnlyTypeCombination(fn,ty1,r1,r1i,ty2,r2,r2i);
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);

        [ro,ro2]=tGet(internalState,tyoo);

        instr=[...
cvtinstr...
        ,bincall(emitter,internalState,tyoo,ro,ro2,fn,r1,r1i,r2,r2i)...
        ];

        if~isSameBaseType(tyo,tyoo)
            [cvtinstr,ro,ro2]=castreg(emitter,internalState,tyo,tyoo,ro,ro2);
            instr=[...
instr...
            ,cvtinstr];
        end
    end

    function[tyo,szo,ro,ro2,instr]=minMaxImpl(node,fn)


        nargs=parallel.internal.tree.countNumberOfArgs(node);
        firstArg=parallel.internal.tree.firstArgNode(node);
        secondArg=parallel.internal.tree.nextArgNode(firstArg);


        if(nargs==1)||(nargs>1&&iArgIsSquareEmpty(secondArg))

            [tyo,szo,ro,ro2]=ops(firstArg);
            instr='';
            return
        end


        [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);

        [cvtinstr,tyo,tyoo,r1,r1i,r2,r2i]=arithmeticTypeCombination(ty1,r1,r1i,ty2,r2,r2i,fn);
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);


        thirdArg=parallel.internal.tree.nextArgNode(secondArg);
        if~isnull(thirdArg)


            missingFlag=parallel.internal.tree.textLiteralContents(thirdArg);




            if strncmpi(missingFlag,'includenan',min(length(missingFlag),10))
                fn=[fn,'withnans'];
            end
        end

        [ro,ro2]=tGet(internalState,tyoo);

        instr=[...
cvtinstr...
        ,bincall(emitter,internalState,tyoo,ro,ro2,fn,r1,r1i,r2,r2i)...
        ];

        if isLogical(ty1)&&isLogical(ty2)
            tyo=coerceLogical(tyoo);
        end


        if~isSameBaseType(tyo,tyoo)
            [cvtinstr,ro,ro2]=castreg(emitter,internalState,tyo,tyoo,ro,ro2);
            instr=[...
instr...
            ,cvtinstr];
        end
    end

    function[tyo,szo,ro,ro2,instr]=pow2Impl(node,fn)
        nargs=parallel.internal.tree.countNumberOfArgs(node);
        if(1==nargs)
            [ty2,sz2,r2,r2i]=preunarycall(node,fn);
            [tyo,szo,ro,ro2,instr]=floatingPointRestrictedDomainImpl(ty2,sz2,r2,r2i,fn);
            return;
        else
            [ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn);
            prepinstr='';
            [cvtinstr,tyo,~,r1,r1i,r2,r2i]=floatingPointMapsToRealRuleAndCastInputs(ty1,r1,r1i,ty2,r2,r2i,fn);
            fnToExecute='ldexp';



            if isComplex(ty1)||isComplex(ty2)
                addWarning(internalState,'MATLAB:pow2:ignoredImagPart');
            end
            szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);

            [ro,ro2]=tGet(internalState,tyo);

            instr=[...
prepinstr...
            ,cvtinstr...
            ,bincall(emitter,internalState,tyo,ro,ro2,fnToExecute,r1,r1i,r2,r2i)...
            ];
        end

    end

    function[tyo,szo,ro,ro2,instr]=xorImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn)
        tyo=parallel.internal.types.Atomic.buildAtomic('logical',false);
        [ro,ro2]=tGet(internalState,tyo);

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);


        [cvtinstr1,r1]=castreg(emitter,internalState,tyo,ty1,r1,r1i);
        [cvtinstr2,r2]=castreg(emitter,internalState,tyo,ty2,r2,r2i);

        xorinstr=xorreg(emitter,ro,r1,r2);

        instr=[...
cvtinstr1...
        ,cvtinstr2...
        ,xorinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=bitcmpImpl(ty1,sz1,r1,~,fn)
        tyo=ty1;
        szo=sz1;

        errorIfInputIsComplexOr64BitInteger(ty1,fn);

        if isUnsignedInteger(tyo)
            rotmp=rGet(internalState);
            ro2='';

            [maskinstr,ro]=zerohigherbits(emitter,internalState,tyo,rotmp);

            instr=[...
            bitcmpreg(emitter,rotmp,r1)...
            ,maskinstr...
            ];
        else
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(tyo)),fn));
        end
    end

    function[tyo,szo,r1,r2,chkDoubleValInRangeInstr,cvtDoubleToOutTypeInstr]=enforceBinaryBitOpLimitations(ty1,sz1,r1,ty2,sz2,r2,fn,errorMechanism)
        [tyo,tyoo]=parallel.internal.types.binaryBitFcnRule(ty1,ty2,fn,errorMechanism);











        mtype=mType(coerceScalar(tyo));


        [intMaxInstr,intMaxReg,~]=constant(emitter,internalState,coerceScalar(tyoo),num2str(intmax(mtype)));
        regCheck=tGet(internalState,parallel.internal.types.Atomic.buildAtomic('logical',false));

        if isDouble(ty1)
            checkInstr=bincall(emitter,internalState,ty1,regCheck,'',...
            'errorIfDoubleLargerThanValue',r1,'',intMaxReg,'');
            testInstr=exitIfRegisterIsTrue(emitter,internalState,regCheck);
            chkDoubleValInRangeInstr=[...
intMaxInstr...
            ,checkInstr...
            ,testInstr...
            ];
            [cvtDoubleToOutTypeInstr,r1]=castregWithNonNegativeFlintCheck(emitter,internalState,tyo,ty1,r1);
        elseif isDouble(ty2)
            checkInstr=bincall(emitter,internalState,ty2,regCheck,'',...
            'errorIfDoubleLargerThanValue',r2,'',intMaxReg,'');
            testInstr=exitIfRegisterIsTrue(emitter,internalState,regCheck);
            chkDoubleValInRangeInstr=[...
intMaxInstr...
            ,checkInstr...
            ,testInstr...
            ];
            [cvtDoubleToOutTypeInstr,r2]=castregWithNonNegativeFlintCheck(emitter,internalState,tyo,ty2,r2);
        else


            chkDoubleValInRangeInstr='';
            cvtDoubleToOutTypeInstr='';
        end

        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);
    end

    function[tyo,szo,ro,roi,instr]=bitLogicImpl(node,fn)

        firstArg=parallel.internal.tree.firstArgNode(node);
        [ty1,sz1,r1,~]=ops(firstArg);
        secondArg=parallel.internal.tree.nextArgNode(firstArg);
        [ty2,sz2,r2,~]=ops(secondArg);

        [tyo,szo,r1,r2,chkDoubleValInRangeInstr,cvtDoubleToOutTypeInstr]=enforceBinaryBitOpLimitations(ty1,sz1,r1,ty2,sz2,r2,fn,errorMechanism);

        ro=rGet(internalState);
        roi='';

        instr=[...
chkDoubleValInRangeInstr...
        ,cvtDoubleToOutTypeInstr...
        ,bitopreg(emitter,fn,ro,r1,r2)...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=bitshiftImpl(ty1,sz1,r1,~,ty2,sz2,r2,~,fn)





        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);



        if isUnsignedInteger(ty1)&&isScalar(ty2)&&isDouble(ty2)
            ty22=coerceInt32(ty2);

            [cvtinstr,r2]=castregWithFlintCheck(emitter,internalState,ty22,ty2,r2);
            ty2=ty22;
            tyo=resolveTypes(ty22,ty1);
        elseif isDouble(ty1)&&isScalar(ty1)&&isInteger(ty2)
            ty11=coerceUint32(ty1);


            [cvtinstr,r1]=castregWithNonNegativeFlintCheck(emitter,internalState,ty11,ty1,r1);
            tyo=resolveTypes(ty2,ty11);
        elseif isUnsignedInteger(ty1)&&isInteger(ty2)
            cvtinstr='';
            tyo=resolveTypes(ty2,ty1);
        elseif~isUnsignedInteger(ty1)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(ty1)),fn));
        else
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(ty2)),fn));
        end

        errorIfInputIsComplexOr64BitInteger(ty1,fn);
        errorIfInputIsComplexOr64BitInteger(ty2,fn);

        [opinstr,ro]=bitshiftInstruction(emitter,internalState,r1,ty2,r2);
        ro2='';

        [maskinstr,ro]=zerohigherbits(emitter,internalState,tyo,ro);

        instr=[...
cvtinstr...
        ,opinstr...
        ,maskinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=bitgetImpl(ty1,sz1,r1,~,ty2,sz2,r2,~,fn)
        [tyo,szo,r1o,r2o,chkDoubleValInRangeInstr,cvtDoubleToOutTypeInstr]=enforceBinaryBitOpLimitations(ty1,sz1,r1,ty2,sz2,r2,fn,errorMechanism);
        [opinstr,ro]=bitgetInstruction(emitter,internalState,tyo,r1o,r2o);
        ro2='';

        instr=[...
chkDoubleValInRangeInstr...
        ,cvtDoubleToOutTypeInstr...
        ,opinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=bitsetImpl(ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,fn)
        szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,sz1,sz2,fn);



        [tyo,~]=parallel.internal.types.arithmeticOperatorRule(ty1,ty2,fn,errorMechanism);


        if~isUnsignedInteger(tyo)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(tyo)),fn));
        end

        flintptx='';
        if isDouble(ty1)
            flintptx=checkIfNonNegativeFlint(emitter,internalState,ty1,r1);
        end

        if isDouble(ty2)
            flintptx=[...
flintptx...
            ,checkIfNonNegativeFlint(emitter,internalState,ty2,r2)...
            ];
        end


        nargs=parallel.internal.tree.countNumberOfArgs(node);
        if(nargs==3)

            arg3=...
            parallel.internal.tree.nextArgNode(...
            parallel.internal.tree.nextArgNode(...
            parallel.internal.tree.firstArgNode(node)));
            [ty3,sz3,r3,r3i]=ops(arg3);
            szo=parallel.internal.gpu.Symbols.updateshapeinfo(internalState,szo,sz3,fn);

            [tyo,~]=parallel.internal.types.arithmeticOperatorRule(tyo,ty3,fn,errorMechanism);

            if~isUnsignedInteger(tyo)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(coerceScalar(tyo)),fn));
            end

            if isDouble(ty3)



                logicalType=parallel.internal.types.Atomic.buildAtomic('logical',false);
                [cvtValPtx,r3,r3i]=castreg(emitter,internalState,logicalType,ty3,r3,r3i);
                flintptx=[...
flintptx...
                ,cvtValPtx...
                ];
                ty3=logicalType;
            end

            [cvtinstr,r1o,~,r2o,~,r3o,~]=castregisters(emitter,internalState,tyo,ty1,r1,r1i,tyo,ty2,r2,r2i,tyo,ty3,r3,r3i);

        elseif(nargs==2)
            [cvtinstr,r1o,~,r2o,~]=castregisters(emitter,internalState,tyo,ty1,r1,r1i,tyo,ty2,r2,r2i);
            r3o='';
        else
            assert(false,'analysis phase is broken.');
        end

        [opinstr,ro]=bitsetInstruction(emitter,internalState,tyo,r1o,r2o,r3o);
        ro2='';

        instr=[...
flintptx...
        ,cvtinstr...
        ,opinstr...
        ];
    end

    function[tyo,szo,ro,ro2,instr]=constantImpl(typeStr,valueStr)
        tyo=parallel.internal.types.Atomic.buildAtomic(typeStr,false);
        szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();
        [instr,ro,ro2]=constant(emitter,internalState,tyo,valueStr);
    end







    function[fcnLabel,fcnSymbols,preinstr]=setupExplicitInputsToCustomFunction(node)
        preinstr='';

        fcnLabel=getFcnLabelFromCallNode(iR,parentFcnLabel,indices(node));


        inputs=getFcnInputs(iR,fcnLabel);
        handleInputList=getFcnHandleInputList(iR,fcnLabel);
        inputslist={};

        argpos=1;
        argnode=parallel.internal.tree.firstArgNode(node);

        for kk=1:numel(inputs)

            while argpos<=numel(handleInputList.idx)&&...
                argpos==handleInputList.idx(argpos)
                argnode=parallel.internal.tree.nextArgNode(argnode);
                argpos=argpos+1;
            end
            [type,shapeinfo,reg,reg2]=ops(argnode);



            [copyinstr,reg,reg2]=copyreg(emitter,internalState,type,reg,reg2);

            preinstr=[...
preinstr...
            ,copyinstr...
            ];%#ok<AGROW>

            argsymbol=parallel.internal.gpu.Symbols.makesymbol(inputs{kk},'static',0,type,reg,reg2,shapeinfo);
            inputslist{end+1}=argsymbol;%#ok<AGROW>

            argnode=parallel.internal.tree.nextArgNode(argnode);

        end



        fcnSymbols=parallel.internal.gpu.Symbols({},{},{});
        populateSymbols(fcnSymbols,inputs,inputslist);
    end


    function[ptxfcn,fcnSymbols]=compileCustomFunction(fcnLabel,fcnSymbols,originalCompilationNode)


        originalContext=getCurrentContext(internalState);

        fcnbeginnode=getFcnBeginNode(iR,fcnLabel);
        setCompilationNode(internalState,fcnbeginnode);
        [ptxfcn,internalState,fcnSymbols]=compileFcnTree(emitter,internalState,fcnSymbols,fcnLabel,iR);
        setCompilationNode(internalState,originalCompilationNode);
        setCurrentContext(internalState,originalContext);
        setCurrentContextForErrorMechanism(internalState,originalContext);
    end





    function[calleeImplicitWorkspace,calleeExplicitWorkspace,...
        usedHandleVariables,...
        callerImplicitWorkspace,callerExplicitWorkspace]=setupImplicitInputsToCustomFunction(fcnLabel,calleeExplicitWorkspace)


        usedHandleVariables=getFcnUsedHandleVariables(iR,fcnLabel);



        calleeImplicitWorkspace=getFcnWorkspaceSymbols(iR,fcnLabel);

        if isempty(getFcnScope(iR,fcnLabel))




            callerExplicitWorkspace=parallel.internal.gpu.Symbols({},{},{});
            callerImplicitWorkspace=parallel.internal.gpu.Symbols({},{},{});
        else


            callerExplicitWorkspace=symbols;



            callerImplicitWorkspace=getFcnWorkspaceSymbols(iR,parentFcnLabel);
        end

        for kk=1:numel(usedHandleVariables)
            variableToReference=usedHandleVariables{kk};

            if symbolPresent(callerExplicitWorkspace,variableToReference)

                symbolToPropagate=getSymbol(callerExplicitWorkspace,variableToReference);
            elseif symbolPresent(callerImplicitWorkspace,variableToReference)


                symbolToPropagate=getSymbol(callerImplicitWorkspace,variableToReference);
            else











                symbolToPropagate=parallel.internal.gpu.Symbols.makeNullTypedSymbol(variableToReference,1,1);
            end


            propagateSymbol(calleeImplicitWorkspace,variableToReference,symbolToPropagate);
            propagateSymbol(calleeExplicitWorkspace,variableToReference,symbolToPropagate);
        end
    end



    function[tyo,szo,ro,ro2,postinstr]=propagateExplicitOutputsFromCustomFunction(outputs,fcnSymbols,node,originalCompilationNode)
        postinstr='';
        fcnSymbol=getSymbol(fcnSymbols,outputs{1});

        tyo=fcnSymbol.type;
        szo=fcnSymbol.shapeinfo;
        reg=fcnSymbol.reg;
        reg2=fcnSymbol.reg2;

        [assignPtx,ro,ro2]=copyreg(emitter,internalState,tyo,reg,reg2);


        parentnode=Parent(node);
        while strcmp(kind(parentnode),'PARENS')
            parentnode=Parent(parentnode);
        end

        if strcmp(kind(parentnode),'EQUALS')||strcmp(kind(parentnode),'ANON')



            lifetimes=getFcnLifetimes(iR,parentFcnLabel);
            symbolInfo=lifetimes(indices(Parent(originalCompilationNode)));
            assert(isstruct(symbolInfo),'analysis phase is broken.');



            variablesToUpdate=symbolInfo.declare;
            N=numel(variablesToUpdate);

            for kk=2:N

                variableToUpdate=variablesToUpdate{kk};


                if isempty(variableToUpdate)
                    continue;
                end

                fcnSymbol=getSymbol(fcnSymbols,outputs{kk});

                typeOut=fcnSymbol.type;
                shapeInfo=fcnSymbol.shapeinfo;
                regReal=fcnSymbol.reg;
                regImag=fcnSymbol.reg2;

                [copyinstr,regReal,regImag]=copyreg(emitter,internalState,typeOut,regReal,regImag);

                exprdepth=getDepth(internalState);

                assignPtx=[...
assignPtx...
                ,copyinstr...
                ,updateSymbol(symbols,emitter,internalState,variableToUpdate,typeOut,shapeInfo,regReal,regImag,exprdepth)...
                ];%#ok<AGROW>

            end

        end

        postinstr=[...
postinstr...
        ,assignPtx...
        ];
    end

    function updateImplicitOutputsFromCustomFunction(usedHandleVariables,...
        calleeExplicitWorkspace,calleeImplicitWorkspace,...
        callerExplicitWorkspace,callerImplicitWorkspace)


        for kk=1:numel(usedHandleVariables)

            variableToUpdate=usedHandleVariables{kk};

            if symbolPresent(calleeExplicitWorkspace,variableToUpdate)


                symbolToPropagate=getSymbol(calleeExplicitWorkspace,variableToUpdate);
            elseif symbolPresent(calleeImplicitWorkspace,variableToUpdate)


                symbolToPropagate=getSymbol(calleeImplicitWorkspace,variableToUpdate);
            else
                assert(false,'the solution to reaching equations is off!');
            end


            propagateSymbol(callerImplicitWorkspace,variableToUpdate,symbolToPropagate);
            propagateSymbol(callerExplicitWorkspace,variableToUpdate,symbolToPropagate);
        end
    end

    function[tyo,szo,ro,ro2,instr]=customFcnImpl(node,fn)




        [fcnLabel,calleeExplicitWorkspace,preinstr]=setupExplicitInputsToCustomFunction(node);


        [calleeImplicitWorkspace,calleeExplicitWorkspace,usedHandleVariables,callerImplicitWorkspace,callerExplicitWorkspace]=setupImplicitInputsToCustomFunction(fcnLabel,calleeExplicitWorkspace);


        originalCompilationNode=getCompilationNode(internalState);
        [ptxfcn,calleeExplicitWorkspace]=compileCustomFunction(fcnLabel,calleeExplicitWorkspace,originalCompilationNode);

        postinstr='';

        outputs=getFcnOutputs(iR,fcnLabel);
        if isempty(outputs)




            tyo=parallel.internal.types.Atomic.Null;
            szo=parallel.internal.gpu.Symbols.makescalarshapeinfo();
            ro='';
            ro2='';
        else
            [tyo,szo,ro,ro2,postinstr]=propagateExplicitOutputsFromCustomFunction(outputs,calleeExplicitWorkspace,node,originalCompilationNode);
            updateImplicitOutputsFromCustomFunction(usedHandleVariables,calleeExplicitWorkspace,calleeImplicitWorkspace,callerExplicitWorkspace,callerImplicitWorkspace);
        end


        instr=[...
        formatComment(emitter,['starting call to ''',fn,''' here'])...
        ,preinstr...
        ,ptxfcn...
        ,postinstr...
        ,formatComment(emitter,['finished call to ''',fn,''' here'])...
        ];

    end





    function[cvtinstr,tyo,tyoo,ro1,ro1i,ro2,ro2i]=arithmeticTypeCombination(ty1,r1,r1i,ty2,r2,r2i,op)
        [tyo,tyoo]=parallel.internal.types.arithmeticOperandInDoubleRule(ty1,ty2,op,errorMechanism);
        [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
    end





    function[cvtinstr,tyo,tyoo,ro1,ro1i,ro2,ro2i,ro3,ro3i]=...
        realFloatingPointOnlyCombination(op,ty1,r1,r1i,ty2,r2,r2i,ty3,r3,r3i)
        if nargin>7

            [tyo,tyoo]=parallel.internal.types.realFloatingPointOnlyRule(errorMechanism,op,ty1,ty2,ty3);
            [cvtinstr,ro1,ro1i,ro2,ro2i,ro3,ro3i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i,tyoo,ty3,r3,r3i);
        else

            [tyo,tyoo]=parallel.internal.types.realFloatingPointOnlyRule(errorMechanism,op,ty1,ty2);
            [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
        end
    end







    function[cvtinstr,tyo,tyoo,ro1,ro1i,ro2,ro2i,ro3,ro3i]=...
        realFloatOperateInDoubleCombination(op,ty1,r1,r1i,ty2,r2,r2i,ty3,r3,r3i)

        tyoo=parallel.internal.types.Atomic('d');
        if nargin>7

            tyo=parallel.internal.types.realFloatingPointOnlyRule(errorMechanism,op,ty1,ty2,ty3);
            [cvtinstr,ro1,ro1i,ro2,ro2i,ro3,ro3i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i,tyoo,ty3,r3,r3i);
        else

            tyo=parallel.internal.types.realFloatingPointOnlyRule(errorMechanism,op,ty1,ty2);
            [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
        end
    end





    function[cvtinstr,tyo,tyoo,ro1,ro1i,ro2,ro2i]=...
        realOnlyTypeCombination(op,ty1,r1,r1i,ty2,r2,r2i)
        [tyo,tyoo]=parallel.internal.types.realArithmeticWithLogicalsRule(errorMechanism,op,ty1,ty2);
        [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
    end






    function[cvtinstr,tyoo,ro1,ro1i,ro2,ro2i]=relopTypeCombination(ty1,r1,r1i,ty2,r2,r2i,op)
        [~,tyoo]=parallel.internal.types.relationalOperatorRule(ty1,ty2,op,errorMechanism);
        [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
    end






    function[cvtinstr,tyoo,ro1,ro1i,ro2,ro2i]=equalityTypeCombination(ty1,r1,r1i,ty2,r2,r2i,op)
        [~,tyoo]=parallel.internal.types.equalityOperatorRule(ty1,ty2,op,errorMechanism);
        [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
    end




    function[cvtinstr,tyo,tyoo,ro1,ro1i,ro2,ro2i]=floatingPointMapsToRealRuleAndCastInputs(ty1,r1,r1i,ty2,r2,r2i,op)
        [tyo,tyoo]=parallel.internal.types.floatingPointMapsToRealRule(ty1,ty2,op,errorMechanism);
        [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
    end




    function[cvtinstr,tyo,tyoo,ro1,ro1i,ro2,ro2i]=floatingPointAndLogicalArithmeticRuleAndCastInputs(ty1,r1,r1i,ty2,r2,r2i,op)
        [tyo,tyoo]=parallel.internal.types.floatingPointAndLogicalArithmeticRule(ty1,ty2,op,errorMechanism);
        [cvtinstr,ro1,ro1i,ro2,ro2i]=castregisters(emitter,internalState,tyoo,ty1,r1,r1i,tyoo,ty2,r2,r2i);
    end






    function[b,a]=swap(a,b)
    end



    function[ty1,sz1,r1,r1i]=preunarycall(node,fn)%#ok
        [ty1,sz1,r1,r1i]=ops(parallel.internal.tree.firstArgNode(node));
    end



    function[ty1,sz1,r1,r1i,ty2,sz2,r2,r2i]=prebinarycall(node,fn)%#ok
        arg=parallel.internal.tree.firstArgNode(node);
        [ty1,sz1,r1,r1i]=ops(arg);
        [ty2,sz2,r2,r2i]=ops(parallel.internal.tree.nextArgNode(arg));
    end



    function[ty1,sz1,r1,r1i,ty2,sz2,r2,r2i,ty3,sz3,r3,r3i]=preternarycall(node,fn)%#ok
        arg1=parallel.internal.tree.firstArgNode(node);
        [ty1,sz1,r1,r1i]=ops(arg1);
        arg2=parallel.internal.tree.nextArgNode(arg1);
        [ty2,sz2,r2,r2i]=ops(arg2);
        [ty3,sz3,r3,r3i]=ops(parallel.internal.tree.nextArgNode(arg2));
    end



    function errorIfIndexIsIllegalType(tyarg)

        if isComplex(tyarg)||isLogical(tyarg)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:SubsrefUnsupportedCoordinateIndex'));
        end

        if~isScalar(tyarg)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:SubsrefNonScalarLinearIndex'));
        end
    end




    function errorIfInputIsComplexOr64BitInteger(type,fn)

        if(~isReal(type)||isUint64(type)||isInt64(type))
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',...
            mType(coerceScalar(type)),fn));
        end
    end






    function[value,optimizep]=determinePowerOptimization(node)

        value=nan;
        scale=1;
        if strcmp('UMINUS',kind(node))
            node=Arg(node);
            scale=-1;
        end

        if strcmp('INT',kind(node))
            value=scale.*str2double(string(node));
        end

        optimizep=any(value==[-2,-1,1,2,3]);

    end










    function tyo=resolveBuildTypeArgument(argNode,iCheckSupportedType,fn,allowComplex)
        if isnull(argNode)
            tyo=parallel.internal.types.Atomic.buildAtomic('double',false);
        elseif parallel.internal.tree.isTextLiteral(argNode)
            ty=parallel.internal.tree.textLiteralContents(argNode);

            if strcmp(ty,'like')
                prototypeArg=parallel.internal.tree.nextArgNode(argNode);


                [tyo,~,~,~]=ops(prototypeArg);
                if(~allowComplex&&isComplex(tyo))||isSparse(tyo)
                    encounteredError(errorMechanism,message(['MATLAB:',fn,':complexOrSparsePrototype']));
                end

                iCheckSupportedType(tyo);
            else
                tyo=parallel.internal.types.Atomic.buildAtomic(ty,false);
            end
        else
            assert(false,"analysis phase is broken for build fcn: "+fn);
        end

    end





    function ty=resolveTypeLiteralInput(node,defaultType,fn)
        arg=parallel.internal.tree.firstArgNode(node);
        if isnull(arg)
            ty=defaultType;
        elseif parallel.internal.tree.isTextLiteral(arg)
            ty=parallel.internal.tree.textLiteralContents(arg);
        else


            ty=preunarycall(node,fn);
            encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedType',mType(ty),fn));
        end
    end

end

function tf=iArgIsSquareEmpty(arg)

    tf=false;
    if isequal(kind(arg),'LB')
        row=Arg(arg);

        tf=isnull(Arg(row));
    end
end
