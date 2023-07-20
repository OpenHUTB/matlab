function[fcnRecord,nonStaticLoop,needsRand]=generateControlFlow(fcnRecord,errorMechanism)






    rootftree=fcnRecord.FcnDefinitionNode;




    lifetimes=containers.Map('KeyType','double','ValueType','any');



    calledFcns=struct;

    nonStaticLoop=false;
    needsRand=false;

    ftree=subtree(rootftree);



    assignedvariables=asgvars(ftree);











    suppressedvariables=mtfind(ftree,'Kind','NOT','Arg.Null','true');

    outputs=fcnRecord.Outputs;
    inputs=[fcnRecord.Inputs,fcnRecord.HandleInputs];
    declaredVariables=union(outputs,inputs);

    variableNodes=mtfind(ftree,'Isvar',true);
    variableNames=union(strings(variableNodes),declaredVariables);

    N=numel(variableNames);
    if N==0,return;end
    variableNamesMap=containers.Map(variableNames,1:N,'UniformValues',true);

    novars=false(1,N);
    isLoopCounter=novars;


    handleVariables=fcnRecord.HandleInputs;
    handle=getVariableIndices(handleVariables);
    usedhandle=novars;

    arrayIndexNodes=mtfind(ftree,'Kind','CELL')|mtfind(ftree,'Kind','SUBSCR');
    structIndexNodes=mtfind(ftree,'Kind','DOT')|mtfind(ftree,'Kind','DOTLP');

    setCurrentContextForErrorMechanism(errorMechanism,fcnRecord.FcnLabel.Context);



    beginnode=fcnRecord.FcnBeginNode;



    computedouts=generateLifetimes(getVariableIndices(inputs),beginnode);


    usedHandleVariables=variableNames(usedhandle);
    usedHandleVariables=reshape(usedHandleVariables,1,[]);


    setNodeForErrorMechanism(errorMechanism,fcnRecord.FcnDefinitionNode);
    updateAndCheckVariableUsage(getVariableIndices(outputs),computedouts);


    fcnRecord.Lifetimes=lifetimes;
    fcnRecord.Calls=calledFcns;
    fcnRecord.UsedHandleVariables=usedHandleVariables;
    return;










    function outs=generateLifetimes(ins,node)

        outs=ins;

        while~isnull(node)

            setNodeForErrorMechanism(errorMechanism,node);

            switch kind(node)

            case 'IF'

                current=Arg(node);




                rhs=Left(current);
                [needed,calledFcnsTmp,callsRand]=analyzeExpr(rhs,handleVariables,errorMechanism);
                updateCalledUnknownFcns(calledFcnsTmp,outs);

                needsRand=needsRand|callsRand;
                needed=getVariableIndices(needed);
                updateAndCheckVariableUsage(needed,outs);

                gentmp=iGenerateVariablesWithPatchForUnreachableCode(current,outs);

                gentmp=xor(gentmp,outs)&gentmp;
                gen=gentmp;



                [~]=updateLifetimesFromControlStruct(indices(current),novars,outs,novars);


                sp=sparse(logical([]));

                current=Next(current);


                while~isnull(current)&&strcmp(kind(current),'ELSEIF')

                    setNodeForErrorMechanism(errorMechanism,current);

                    rhs=Left(current);
                    [needed,calledFcnsTmp,callsRand]=analyzeExpr(rhs,handleVariables,errorMechanism);
                    updateCalledUnknownFcns(calledFcnsTmp,outs);

                    needsRand=needsRand|callsRand;
                    needed=getVariableIndices(needed);
                    updateAndCheckVariableUsage(needed,outs);

                    if any(gentmp)
                        sp(:,indices(current))=gentmp';%#ok
                    else
                        [~]=updateLifetimesFromControlStruct(indices(current),outs,novars,novars);
                    end

                    gentmp=iGenerateVariablesWithPatchForUnreachableCode(current,outs);

                    gentmp=xor(gentmp,outs)&gentmp;
                    gen=gen&gentmp;

                    current=Next(current);

                end







                if~isnull(current)

                    killelse=gentmp;

                    gentmp=generateLifetimes(outs,Body(current));
                    gentmp=xor(gentmp,outs)&gentmp;
                    gen=gen&gentmp;



                    killelse=xor(killelse,gen)&killelse;
                    [~]=updateLifetimesFromControlStruct(indices(current),novars,novars,killelse);



                    gentmp=xor(gen,gentmp)&gentmp;



                    outs=updateLifetimesFromControlStruct(indices(node),outs,gen,gentmp);

                else

                    kill=xor(gentmp,outs)&gentmp;
                    [~]=updateLifetimesFromControlStruct(indices(node),outs,novars,kill);
                    gen=novars;

                end



                ids=find(any(sp));
                for jj=ids
                    kill=sp(:,jj)';
                    kill=xor(kill,gen)&kill;
                    [~]=updateLifetimesFromControlStruct(jj,novars,novars,kill);
                end

                node=Next(node);

            case{'EXPR','PRINT'}


                while~isnull(node)&&(strcmp(kind(node),'EXPR')||strcmp(kind(node),'PRINT'))


                    argNode=Arg(node);
                    [needed,calledFcnsTmp,callsRand]=analyzeExpr(argNode,handleVariables,errorMechanism,fcnRecord.HandleInputList);


                    outputNames=strings(subtree(node)&(assignedvariables|suppressedvariables));


                    usedHandles=ismember(handleVariables,outputNames);
                    if any(usedHandles)
                        needed=union(needed,handleVariables(usedHandles));
                    end

                    if iskind(argNode,'ANON')
                        outputNames=outputs;
                    end


                    lhs=subtree(Left(argNode));

                    if~isnull(arrayIndexNodes&lhs)
                        encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedIndexing'));
                    end

                    if~isnull(structIndexNodes&lhs)
                        encounteredError(errorMechanism,message('parallel:gpu:compiler:UnsupportedStructIndexing'));
                    end





                    if any(ismember(outputNames,'false'))||any(ismember(outputNames,'true'))
                        encounteredError(errorMechanism,message('parallel:gpu:compiler:LanguageOverloadLogical'));
                    end


                    validnamesmask=cellfun(@(x)(~isempty(x)),outputNames);
                    gen=getVariableIndices(outputNames(validnamesmask));

                    numberOfCalledFcns=numel(fields(calledFcnsTmp));

                    if numberOfCalledFcns==0



                        if(1<numel(outputNames))

                            setNodeForErrorMechanism(errorMechanism,node);

                            if strcmp(kind(Right(Arg(node))),'CALL')
                                fn=string(Left(Right(Arg(node))));
                            else
                                fn=parallel.internal.types.opConversionMtreeToMATLAB(kind(Right(Arg(node))));
                            end

                            encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyOutputs',fn));

                        end

                    else


                        if strcmp(kind(argNode),'EQUALS')
                            rhs=Right(argNode);

                        else
                            rhs=argNode;
                        end



                        if strcmp(kind(rhs),'CALL')

                            topFcnName=string(Left(rhs));

                            if isfield(calledFcnsTmp,topFcnName)
                                a=calledFcnsTmp.(topFcnName).nodeinfo;
                                nodeid=indices(rhs);
                                idx=find(a(:,1)==nodeid);
                                a(idx,2)=numel(outputNames);%#ok % nlhs
                                calledFcnsTmp.(topFcnName).nodeinfo=a;
                            end

                        end


                        updateCalledUnknownFcns(calledFcnsTmp,outs);

                    end

                    needsRand=needsRand|callsRand;

                    needed=getVariableIndices(needed);
                    updateAndCheckVariableUsage(needed,outs);

                    updateLifetimesFromAssignment(indices(node),outputNames);

                    outs=outs|gen;
                    node=Next(node);
                    setNodeForErrorMechanism(errorMechanism,node);

                end




            case 'FOR'

                previous=outs;







                colonroot=Vector(node);
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


                [neededBegin,calledFcnsTmp,callsRand]=analyzeExpr(beginroot,handleVariables,errorMechanism);
                updateCalledUnknownFcns(calledFcnsTmp,outs);

                needsRand=needsRand|callsRand;
                neededBegin=getVariableIndices(neededBegin);


                neededLast=novars;
                if~isnull(lastroot)
                    [neededLast,calledFcnsTmp,callsRand]=analyzeExpr(lastroot,handleVariables,errorMechanism);
                    updateCalledUnknownFcns(calledFcnsTmp,outs);

                    needsRand=needsRand|callsRand;
                    neededLast=getVariableIndices(neededLast);

                end


                neededStep=novars;
                if~isnull(steproot)

                    [neededStep,calledFcnsTmp,callsRand]=analyzeExpr(steproot,handleVariables,errorMechanism);
                    updateCalledUnknownFcns(calledFcnsTmp,outs);

                    needsRand=needsRand|callsRand;
                    neededStep=getVariableIndices(neededStep);

                end

                needed=neededBegin|neededLast|neededStep;
                updateAndCheckVariableUsage(needed,previous);



                loopCounter=getVariableIndices(strings(Index(node)));
                availables=previous|loopCounter;
                isLoopCounter=isLoopCounter|loopCounter;









                loopvariables=generateLifetimes(availables,Body(node));
                kill=xor(loopvariables,previous)&loopvariables;

                [~]=updateLifetimesFromControlStruct(indices(node),novars,availables,kill);


                nonStaticLoop=true;


                node=Next(node);

            case 'WHILE'

                previous=outs;

                rhs=Left(node);
                [needed,calledFcnsTmp,callsRand]=analyzeExpr(rhs,handleVariables,errorMechanism);
                updateCalledUnknownFcns(calledFcnsTmp,outs);

                needsRand=needsRand|callsRand;
                needed=getVariableIndices(needed);
                updateAndCheckVariableUsage(needed,previous);

                loopvariables=generateLifetimes(previous,Body(node));
                kill=xor(loopvariables,previous)&loopvariables;





                [~]=updateLifetimesFromControlStruct(indices(node),novars,previous,kill);


                nonStaticLoop=true;


                node=Next(node);

            case 'RETURN'

                updateAndCheckVariableUsage(getVariableIndices(outputs),outs);
                [~]=updateLifetimesFromControlStruct(indices(node),novars,getVariableIndices(outputs),novars);


                node=null(node);

            case 'BREAK'


                node=null(node);

            case 'CONTINUE'


                node=null(node);

            case 'FUNCTION'




                node=Next(node);

            otherwise


                theKind=upper(kind(node));
                switch theKind

                case{'TRY','CATCH'}
                    msg=message('parallel:gpu:compiler:LanguageTryCatch');

                case{'CLASSDEF','PROPERTIES','METHODS','EVENTS','ENUMERATION'}
                    msg=message('parallel:gpu:compiler:LanguageMCOS',...
                    'MCOS',theKind);

                case{'SWITCH','CASE','OTHERWISE'}
                    msg=message('parallel:gpu:compiler:LanguageSwitch',...
                    'SWITCH');

                case 'DCALL'
                    msg=message('parallel:gpu:compiler:LanguageConstructDcall');

                case 'BANG'
                    msg=message('parallel:gpu:compiler:LanguageConstructSystem');

                otherwise
                    msg=message('parallel:gpu:compiler:LanguageConstruct',theKind);

                end

                encounteredError(errorMechanism,msg);

            end

        end

    end















    function gentmp=iGenerateVariablesWithPatchForUnreachableCode(current,outs)
        testnode=Left(current);

        if parallel.internal.tree.isNodeFalse(testnode)

            gentmp=novars;
        else


            gentmp=generateLifetimes(outs,Body(current));
        end
    end




    function available=getVariableIndices(names)

        NN=numel(names);
        available=novars;

        for jj=1:NN



            if isKey(variableNamesMap,names{jj})
                available(variableNamesMap(names{jj}))=true;
            end
        end

    end




    function outs=updateLifetimesFromControlStruct(id,ins,gen,kill)


        declareIdx=xor(ins,gen)&gen;

        if any(declareIdx)
            declare={variableNames(declareIdx)};
        else
            declare={{}};
        end


        if any(kill)
            remove={variableNames(kill)};
        else
            remove={{}};
        end

        outs=ins|gen;

        lifetimes(id)=struct(...
        'declare',declare,...
        'remove',remove...
        );

    end





    function updateLifetimesFromAssignment(id,outputs)

        lifetimes(id)=struct(...
        'declare',{outputs},...
        'remove',{{}}...
        );

    end




    function updateCalledUnknownFcns(calledFcnsTmp,available)

        calledFcnNames=fields(calledFcnsTmp);

        for kk=1:numel(calledFcnNames)

            calledFcnName=calledFcnNames{kk};
            callsites=calledFcnsTmp.(calledFcnName).nodeinfo;
            [n,~]=size(callsites);
            info=cell(1,n);
            for jj=1:n
                entry={callsites(jj,:),variableNames(available)};
                info{jj}=entry;
            end

            if isfield(calledFcns,calledFcnName)
                a=calledFcns.(calledFcnName).nodeinfo;
                calledFcns.(calledFcnName).nodeinfo=horzcat(a,info);
            else
                calledFcns.(calledFcnName).nodeinfo=info;
                calledFcns.(calledFcnName).HandleInputList=calledFcnsTmp.(calledFcnName).HandleInputList;
            end

        end

    end




    function updateAndCheckVariableUsage(needed,available)


        usedhandle=(needed&handle)|usedhandle;


        errorIfMissingVariable(needed,available);

    end




    function errorIfMissingVariable(needed,available)

        present=(needed&available);

        if any(needed~=present)
            missingVariableIndices=xor(needed,present)&needed;
            missingLoopCounterIndices=missingVariableIndices&isLoopCounter;
            if any(missingLoopCounterIndices)
                missingLoopCounters=sprintf('%s',variableNames{missingLoopCounterIndices});
                encounteredError(errorMechanism,message('parallel:gpu:compiler:LoopVariableReuse',missingLoopCounters));
            elseif any(missingVariableIndices)
                missingvariables=sprintf('%s ',variableNames{missingVariableIndices});
                encounteredError(errorMechanism,message('parallel:gpu:compiler:VarcheckUninitialized',missingvariables));
            end
        end

    end

end
