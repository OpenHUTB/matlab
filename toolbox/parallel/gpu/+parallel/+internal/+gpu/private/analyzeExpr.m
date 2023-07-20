function[neededVars,calledFcns,callsRand]=analyzeExpr(node,handleVariables,errorMechanism,handleInputList)




    neededVars={};
    if nargin<4
        handleInputList=parallel.internal.gpu.IR.makeEmptyHandleInputList;
    end



    calledFcns=struct;

    callsRand=false;

    if parallel.internal.tree.isNodeKindEqualsOrAnon(node)
        node=Right(node);
    end

    if~isnull(node)
        ops(node);
    end

    return;




    function ops(node)

        fn=kind(node);
        switch fn

        case{'ID','ANONID'}






            theString=string(node);


            isFiltered=strcmp(theString,handleInputList.inputs);
            if any(isFiltered)
                theString=handleInputList.handle{isFiltered};
            end























            if~strcmpi(theString,'false')
                neededVars{end+1}=theString;
            end
        case{'INT','DOUBLE'}



        case 'PARENS'

            ops(Arg(node));

        case{'UMINUS','UPLUS','NOT'}

            ops(Arg(node));

        case{'PLUS','MINUS','DOTMUL','DOTDIV'...
            ,'DOTLDIV','MUL','DIV','LDIV','EQ','NE','LT','LE'...
            ,'GE','GT','DOTEXP','EXP','AND','OR'...
            ,'ANDAND','OROR'}




            ops(Left(node));
            ops(Right(node));

        case{'CALL'}


            call(node);

        case{'SUBSCR'}


            name=tree2str(Left(subtree(node)));





            idx=find(strcmp(name,handleInputList.inputs));
            if~isempty(idx)
                name=handleInputList.handle{idx};
            end



            if ismember(name,handleVariables)


                neededVars{end+1}=name;



                numArgs=iAnalyzeArgs(node);

                if numArgs==0
                    encounteredError(errorMechanism,message('parallel:array:SubsrefOneSubscriptRequired'))
                end
            else
                encounteredError(errorMechanism,message('parallel:gpu:compiler:Indexing'));
            end



        otherwise

            switch fn

            case 'CHARVECTOR'

                encounteredError(errorMechanism,message('parallel:gpu:compiler:String'));

            case 'STRING'

                encounteredError(errorMechanism,message('parallel:gpu:compiler:StringClass'));

            case 'FIELD'


                if parallel.internal.tree.isTextLiteral(node)
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:StringClass'));
                else


                    encounteredError(errorMechanism,iCreateUnhandledNodeMessage(node));
                end

            case 'NAMEVALUE'


                encounteredError(errorMechanism,message('parallel:gpu:compiler:NameValue'));

            case 'LB'

                if iArgIsSquareEmpty(node)
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:SquareEmpty'));
                else
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:Concat'));
                end
            case 'LC'
                encounteredError(errorMechanism,message('parallel:gpu:compiler:Cellcat'));

            case 'ANON'

                encounteredError(errorMechanism,message('parallel:gpu:compiler:Anon'));

            case{'TRANS','DOTTRANS'}

                encounteredError(errorMechanism,message('parallel:gpu:compiler:Trans'));

            case{'DOT','DOTLP'}


                name=tree2str(Left(subtree(node)));





                matlabType=which(name);

                if isempty(matlabType)
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:DynamicAccess'));
                else
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:Package'));
                end

            case 'CELL'

                encounteredError(errorMechanism,message('parallel:gpu:compiler:Cell'));

            case{'AT'}
                encounteredError(errorMechanism,message('parallel:gpu:compiler:Fcnhandle'));

            case 'LP'




                counts=iGetLPTypes(node);
                if counts.Function>0&&(counts.Variable>0||counts.Global>0||counts.Persistent>0)
                    errmsg=message('MATLAB:front_end:mir_error_variable_and_nested_function',...
                    '',string(Left(node)));
                else
                    errmsg=iCreateUnhandledNodeMessage(node);
                end

                encounteredError(errorMechanism,errmsg);

            otherwise
                encounteredError(errorMechanism,iCreateUnhandledNodeMessage(node));

            end

        end

    end





    function call(node)

        fn=string(Left(node));


        isFnAGpuArrayMethod=parallel.internal.types.findOverloadedMethods(fn);
        if isFnAGpuArrayMethod
            iErrorIfIsInLocalScope(errorMechanism,node,fn);
        end

        switch fn



        case{'abs','angle','fix','ceil','floor','round','sign'...
            ,'isinf','isnan','isfinite'...
            ,'isfloat','isinteger','islogical','isnumeric','isreal','issparse'...
            ,'gamma','gammaln','erf','erfc','erfcinv'...
            ,'erfinv','erfcx','reallog','realsqrt'...
            ,'acos','acosd','acosh'...
            ,'acot','acotd','acoth'...
            ,'acsc','acscd','acsch'...
            ,'asec','asecd','asech'...
            ,'asin','asind','asinh'...
            ,'atan','atand','atanh'...
            ,'cos','cosd','cosh'...
            ,'cot','cotd','coth'...
            ,'csc','cscd','csch'...
            ,'sec','secd','sech'...
            ,'sin','sind','sinh'...
            ,'tan','tand','tanh'...
            ,'deg2rad','rad2deg'...
            ,'exp','expm1','expint'...
            ,'log','log10','log1p','log2','nextpow2'...
            ,'sqrt'...
            ,'double','single'...
            ,'int64','uint64','int32','uint32','int16','uint16','int8','uint8'...
            ,'logical'...
            ,'real','imag','conj','bitcmp'...
            ,'uplus','uminus','not'}

            iAnalyzeArgs(node,1,1,fn);

        case{'Inf','inf','NaN','nan','zeros','ones'}



            arg=parallel.internal.tree.firstArgNode(node);

            if~isnull(arg)
                if parallel.internal.tree.isTextLiteral(arg)
                    validStringArgs={'single','double'};
                    if ismember(fn,{'zeros','ones'})
                        validStringArgs=[validStringArgs,...
                        {'int32','uint32','int16','uint16','int8','uint8','logical'}];
                    end
                    iCheckBuildFcnTypeArgs(arg,validStringArgs,fn);
                else
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:SizeSpecification',fn,fn));
                end

            end

        case{'rand','randn'}


            arg=parallel.internal.tree.firstArgNode(node);

            if~isnull(arg)
                if parallel.internal.tree.isTextLiteral(arg)
                    validStringArgs={'single','double'};
                    iCheckBuildFcnTypeArgs(arg,validStringArgs,fn);
                else
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:SizeSpecification',fn,fn));
                end

            end

            callsRand=true;

        case 'randi'






            firstArg=parallel.internal.tree.firstArgNode(node);
            secondArg=parallel.internal.tree.nextArgNode(firstArg);

            if isnull(firstArg)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooFewInputs',fn));
            end


            [firstElemNode,otherNode]=parallel.internal.tree.resolveArrayEntries(firstArg);
            ops(firstElemNode);

            thirdElemNode=null(firstElemNode);
            if~isnull(otherNode)&&(otherNode~=secondArg)
                [secondElemNode,thirdElemNode]=parallel.internal.tree.resolveArrayEntries(otherNode);
                ops(secondElemNode);
            end


            if~isnull(thirdElemNode)
                encounteredError(errorMechanism,message('MATLAB:randi:invalidLimits'));
            end



            if isnull(secondArg)

            elseif parallel.internal.tree.isTextLiteral(secondArg)
                validStringArgs={'double','single','int8',...
                'uint8','int16','uint16','int32','uint32'};
                iCheckBuildFcnTypeArgs(secondArg,validStringArgs,fn);
            else
                encounteredError(errorMechanism,message('MATLAB:randi:invalidClassname'));
            end

            callsRand=true;

        case 'cast'




            firstArg=parallel.internal.tree.firstArgNode(node);
            if isnull(firstArg)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooFewInputs',fn));
            end

            secondArg=parallel.internal.tree.nextArgNode(firstArg);
            if isnull(secondArg)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooFewInputs',fn));
            end


            if parallel.internal.tree.isTextLiteral(secondArg)
                validStringArgs={'double','single','logical',...
                'int8','uint8','int16','uint16',...
                'int32','uint32','int64','uint64'};
                iCheckBuildFcnTypeArgs(secondArg,validStringArgs,fn);
            else
                encounteredError(errorMechanism,message('parallel:gpu:compiler:SizeSpecification',fn,fn));
            end

        case{'eps'}

            handled=iCheckNoArgOrTypeLiteral(parallel.internal.tree.firstArgNode(node),...
            {'double','single'},...
            'MATLAB:eps:invalidClass',fn);
            if~handled
                iAnalyzeArgs(node,1,1,fn);
            end

        case{'realmin','realmax'}

            handled=iCheckNoArgOrTypeLiteral(parallel.internal.tree.firstArgNode(node),...
            {'double','single'},...
            ['MATLAB:',fn,':invalidClassName'],fn);
            if~handled
                encounteredError(errorMechanism,message(['MATLAB:',fn,':invalidClassName']));
            end

        case{'intmin','intmax'}

            handled=iCheckNoArgOrTypeLiteral(parallel.internal.tree.firstArgNode(node),...
            {'int32','uint32','int16','uint16','int8','uint8'},...
            ['MATLAB:',fn,':invalidClassName'],fn);
            if~handled
                encounteredError(errorMechanism,message(['MATLAB:',fn,':inputMustBeString']));
            end


        case{'complex','psi'}
            iAnalyzeArgs(node,1,2,fn);


        case{'min','max'}

            iGetAndCheckNargs(node,1,4,fn);

            firstArg=parallel.internal.tree.firstArgNode(node);


            arg=firstArg;
            numDataArgs=0;
            while(~isnull(arg))&&~parallel.internal.tree.isTextLiteral(arg)
                numDataArgs=numDataArgs+1;
                ops(arg);
                arg=parallel.internal.tree.nextArgNode(arg);
            end

            if numDataArgs>3
                encounteredError(errorMechanism,message("MATLAB:"+fn+":unknownFlag"));
            end

            if numDataArgs>2&&~iArgIsSquareEmpty(parallel.internal.tree.nextArgNode(firstArg))
                encounteredError(errorMechanism,message("MATLAB:"+fn+":caseNotSupported"));
            end

            validmodes={'omitnan','includenan'};
            iAnalyzeFuncWithOptionalFlag(node,numDataArgs,fn,validmodes);

        case{'pow2'}
            iAnalyzeArgs(node,1,2,fn);



        case{'realpow','beta','betaln','hypot','atan2','atan2d'...
            ,'mod','rem'...
            ,'bitand','bitor','bitxor','bitshift','bitget','xor'...
            ,'plus','minus','mtimes','times'...
            ,'power','mldivide','mrdivide','mpower'...
            ,'nthroot',...
            'ldivide','rdivide','eq','ne','lt','gt','le','ge'...
            ,'and','or'}
            iAnalyzeArgs(node,2,2,fn);



        case{'bitset','besseli','besselj','besselk','bessely'}
            iAnalyzeArgs(node,2,3,fn);

        case{'gammainc'}
            numDataArgs=2;
            validmodes={'lower','upper','scaledlower','scaledupper'};
            iAnalyzeFuncWithOptionalTailArg(node,numDataArgs,fn,validmodes);

        case{'gammaincinv'}
            numDataArgs=2;
            validmodes={'lower','upper'};
            iAnalyzeFuncWithOptionalTailArg(node,numDataArgs,fn,validmodes);




        case{'betainc','betaincinv'}
            numDataArgs=3;
            validmodes={'lower','upper'};
            iAnalyzeFuncWithOptionalTailArg(node,numDataArgs,fn,validmodes);




        case{'true','false','pi'}

            if~isnull(parallel.internal.tree.firstArgNode(node))
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyInputs',fn));
            end

        case{'try','catch','parfor','switch','case',...
            'otherwise','persistent','global','dcall','bang',...
            'enumeration'}



            assert(false,'AST is broken.');
        case{'error'}




            setNodeForErrorMechanism(errorMechanism,node);
            encounteredError(errorMechanism,...
            message('parallel:gpu:compiler:LanguageConstruct',...
            upper(fn)));
        otherwise


            if isFnAGpuArrayMethod


                setNodeForErrorMechanism(errorMechanism,node);
                encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedOperation',fn));
            end



            nodeIdandNumArgs=[indices(node),1];

            if isfield(calledFcns,fn)
                a=calledFcns.(fn).nodeinfo;
                calledFcns.(fn).nodeinfo=[a;nodeIdandNumArgs];
            else
                calledFcns.(fn).nodeinfo=nodeIdandNumArgs;
            end





            argpos=1;

            handleInputList.idx=zeros(size(handleInputList.idx));

            argnode=parallel.internal.tree.firstArgNode(node);
            while~isnull(argnode)
                ops(argnode);
                strArgnode=strings(argnode);

                if iskind(argnode,'ID')&&any(strcmp(handleVariables,strArgnode))
                    handleInputList.idx=[handleInputList.idx,argpos];
                    handleInputList.handle=[handleInputList.handle,strArgnode];
                end
                argpos=argpos+1;
                argnode=parallel.internal.tree.nextArgNode(argnode);
            end
            calledFcns.(fn).HandleInputList=handleInputList;
        end

    end







    function iAnalyzeFuncWithOptionalStringArg(node,numDataArgs,fn,validmodes,matchfcn,errorid)

        nargs=iGetAndCheckNargs(node,numDataArgs,numDataArgs+1,fn);


        arg=parallel.internal.tree.firstArgNode(node);
        for kk=1:numDataArgs
            ops(arg);
            arg=parallel.internal.tree.nextArgNode(arg);
        end

        if nargs>numDataArgs
            if parallel.internal.tree.isTextLiteral(arg)
                mode=parallel.internal.tree.textLiteralContents(arg);
                if~matchfcn(mode,validmodes)
                    encounteredError(errorMechanism,message(errorid));
                end
            else

                encounteredError(errorMechanism,message(errorid));
            end
        end
    end




    function iAnalyzeFuncWithOptionalTailArg(node,numDataArgs,fn,validmodes)
        matchfcn=@iCaseSensitiveExactMatch;
        errorid=['MATLAB:',fn,':InvalidTailArg'];
        iAnalyzeFuncWithOptionalStringArg(node,numDataArgs,fn,validmodes,matchfcn,errorid);
    end




    function iAnalyzeFuncWithOptionalFlag(node,numDataArgs,fn,validmodes)
        matchfcn=@iCaseInsensitivePartialMatch;
        errorid=['MATLAB:',fn,':unknownFlag'];
        iAnalyzeFuncWithOptionalStringArg(node,numDataArgs,fn,validmodes,matchfcn,errorid);
    end

    function isvalid=iCaseSensitiveExactMatch(actual,valid)


        isvalid=ismember(actual,valid);
    end

    function isvalid=iCaseInsensitivePartialMatch(actual,valid)


        isvalid=false;
        for ii=1:numel(valid)
            N=min(length(actual),length(valid{ii}));
            if strncmpi(actual,valid{ii},N)
                isvalid=true;
                break;
            end
        end
    end

    function nargs=iCheckNargs(nargs,minNArg,maxNArg,fn)
        if(nargs<minNArg)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:TooFewInputs',fn));
        elseif(nargs>maxNArg)
            encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyInputs',fn));
        end
    end



    function nargs=iGetAndCheckNargs(node,minNArg,maxNArg,fn)
        nargs=parallel.internal.tree.countNumberOfArgs(node);
        iCheckNargs(nargs,minNArg,maxNArg,fn);
    end





    function iCheckBuildFcnTypeArgs(argNode,validArgs,fn)
        typeArg=parallel.internal.tree.textLiteralContents(argNode);

        if strcmp(typeArg,'like')

            prototypeArg=parallel.internal.tree.nextArgNode(argNode);
            if isnull(prototypeArg)
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooFewInputs',fn));
            elseif~isnull(parallel.internal.tree.nextArgNode(prototypeArg))
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyInputs',fn));
            else

                ops(prototypeArg);
            end
        elseif any(strcmp(typeArg,validArgs))

            if~isnull(parallel.internal.tree.nextArgNode(argNode))
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyInputs',fn));
            end
        else

            encounteredError(errorMechanism,message('parallel:gpu:compiler:IllegalType',typeArg,fn))
        end
    end






    function handled=iCheckNoArgOrTypeLiteral(argNode,validTypes,invalidTypeID,fn)
        handled=false;
        if isnull(argNode)

            handled=true;
        elseif parallel.internal.tree.isTextLiteral(argNode)
            ty=parallel.internal.tree.textLiteralContents(argNode);


            if~any(strcmp(ty,validTypes))
                encounteredError(errorMechanism,message(invalidTypeID));
            elseif~isnull(Next(argNode))

                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyInputs',fn));
            end

            handled=true;
        end
    end

    function numArgs=iAnalyzeArgs(callNode,minNumArgs,maxNumArgs,funcName)




        numArgs=0;
        arg=parallel.internal.tree.firstArgNode(callNode);
        while(~isnull(arg))
            numArgs=numArgs+1;
            ops(arg);
            arg=parallel.internal.tree.nextArgNode(arg);
        end

        if nargin>1
            iCheckNargs(numArgs,minNumArgs,maxNumArgs,funcName);
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

function counts=iGetLPTypes(node)



    idNode=Left(node);




    restOfFileNodes=~Full(node);



    counts.Function=count(mtfind(restOfFileNodes,'Kind','FUNCTION','Fname.SameID',idNode));
    counts.Global=count(mtfind(restOfFileNodes,'Kind','GLOBAL','Arg.SameID',idNode));
    counts.Persistent=count(mtfind(restOfFileNodes,'Kind','PERSISTENT','Arg.SameID',idNode));



    otherNodesWithID=mtfind(~Full(node),'SameID',idNode);
    counts.Variable=count(geteq(otherNodesWithID));


    counts.Other=count(otherNodesWithID)-counts.Function-counts.Variable-counts.Global-counts.Persistent;
end


function msg=iCreateUnhandledNodeMessage(node)


    fname=kind(node);

    while~isnull(node)&&~strcmp(kind(node),'FUNCTION')
        node=node.Parent;
    end

    if~isnull(node)
        fname=string(node.Fname);
    end
    msg=message('parallel:gpu:compiler:UnsupportedOperation',fname);
end


function iErrorIfIsInLocalScope(errorMechanism,node,fn)








    parentFuncs=null(node);
    p=Parent(node);
    while~isnull(p)
        parentFuncs=parentFuncs|p;
        p=Parent(p);
    end
    parentFuncs=mtfind(parentFuncs,'Kind','FUNCTION');


    scopedNodes=List(Body(parentFuncs));


    scopedNodes=scopedNodes|List(root(node));


    scopedWithName=mtfind(scopedNodes,'Fname.Fun',fn);

    if~isempty(scopedWithName)
        setNodeForErrorMechanism(errorMechanism,node);
        encounteredError(errorMechanism,message('parallel:gpu:compiler:MethodOverload',fn));
    end
end
