classdef IR




    properties(SetAccess=private)



        ContextToFcnRecordsMap;



        ContextFcnCallsMap;


        FcnLabelFromCallNodeMap;



        BoundFcnLabel;


        NonStaticLoop;
        NeedsRand;


        MATLABUplevels;

    end


    methods(Static=true)
        function errorEvalCausingAnonNameConflict(evalnode,errorMechanism)
            setNodeForErrorMechanism(errorMechanism,evalnode);
            encounteredError(errorMechanism,message('parallel:gpu:compiler:DispatcherEvalAnonAmbiguity'));
        end


        function errorIfUnableToLocateExternalFcn(fcnContext,callerContext,fnode,callsites,fname,errorMechanism)
            if isempty(fcnContext)
                setCurrentContextForErrorMechanism(errorMechanism,callerContext);
                callnodeids=parallel.internal.gpu.IR.extractCallNodeids(callsites,fname);
                setNodeForErrorMechanism(errorMechanism,select(full(fnode),callnodeids(1,1)));
                encounteredError(errorMechanism,message('parallel:gpu:compiler:IrUnknownFcn',fname));
            end
        end


        function errorIfRecursionIsPresent(callGraph,fcnNames,contextToFcnRecordsMap,errorMechanism)


            [containsCycle,fcnNameId]=parallel.internal.gpu.IR.findRecursiveFcn(callGraph);

            if containsCycle

                fcnName=fcnNames{fcnNameId};


                split=strfind(fcnName,iGetCallGraphFcnKeyDelimiter());
                fcnContext=fcnName(1:(split-1));
                fcnName=fcnName((split+3):end);
                fcnRecords=contextToFcnRecordsMap(fcnContext);
                fcnRecord=fcnRecords(fcnName);

                setNodeForErrorMechanism(errorMechanism,fcnRecord.FcnDefinitionNode);
                setCurrentContextForErrorMechanism(errorMechanism,fcnContext);
                encounteredError(errorMechanism,message('parallel:gpu:compiler:IrRecursion',fcnName));

            end


        end


        function errorIfVarargInOut(outputs,inputs,node,errorMechanism)

            if any(strcmp(inputs,'varargin'))
                setNodeForErrorMechanism(errorMechanism,node);
                encounteredError(errorMechanism,message('parallel:gpu:compiler:VariableNumberInput'));
            end

            if any(strcmp(outputs,'varargout'))
                setNodeForErrorMechanism(errorMechanism,node);
                encounteredError(errorMechanism,message('parallel:gpu:compiler:VariableNumberOutput'));
            end

        end

        function errorIfSuppresssedInputs(inputs,node,errorMechanism)

            for kk=1:numel(inputs)
                if isempty(inputs{kk})||strcmp(inputs{kk},'~')
                    setNodeForErrorMechanism(errorMechanism,node);
                    encounteredError(errorMechanism,message('parallel:gpu:compiler:SuppressedInput'));
                end
            end

        end

        function errorIfTooManyFewInputs(callnode,calledFcnRecord,errorMechanism)

            numberOfInputs=0;
            inputArg=parallel.internal.tree.firstArgNode(callnode);

            while~isnull(inputArg)
                numberOfInputs=numberOfInputs+1;
                inputArg=parallel.internal.tree.nextArgNode(inputArg);
            end


            numberOfInputsFiltered=sum(calledFcnRecord.HandleInputList.idx~=0);
            numberOfInputs=numberOfInputs-numberOfInputsFiltered;
            nin=numel(calledFcnRecord.Inputs);

            if nin<numberOfInputs
                setNodeForErrorMechanism(errorMechanism,callnode);
                fname=calledFcnRecord.FcnLabel.Name;
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyInputs',fname));
            end

            if numberOfInputs<nin
                setNodeForErrorMechanism(errorMechanism,callnode);
                fname=calledFcnRecord.FcnLabel.Name;
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooFewInputs',fname));
            end

        end

        function errorIfTooManyOutputs(nlhs,maxNlhs,callnode,calledFcnRecord,errorMechanism)
            if maxNlhs<nlhs
                setNodeForErrorMechanism(errorMechanism,callnode);
                fname=calledFcnRecord.FcnLabel.Name;
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyOutputs',fname));
            end
        end

        function checkNumArgsForCalledFcns(fcnRecords,theFcnName,fcnLabelFromCallNodeMap,callerContext,contextToFcnRecordsMap,errorMechanism)
            fcnRecord=fcnRecords(theFcnName);
            ftree=fullsubtree(fcnRecord.FcnBeginNode);
            calls=fcnRecord.Calls;

            calledFcnNames=fields(calls);

            if isempty(calledFcnNames)


                return
            end

            callNodeMap=fcnLabelFromCallNodeMap(callerContext);
            setCurrentContextForErrorMechanism(errorMechanism,callerContext);

            for ll=1:numel(calledFcnNames)
                callsites=parallel.internal.gpu.IR.extractCallNodeids(calls,calledFcnNames{ll});
                [n,~]=size(callsites);

                for rr=1:n
                    callsitepair=callsites(rr,:);
                    callnodeid=callsitepair(1);
                    callnode=select(ftree,callnodeid);


                    calledFcnLabel=callNodeMap(callnodeid);
                    calledFcnRecords=contextToFcnRecordsMap(calledFcnLabel.Context);
                    calledFcnRecord=calledFcnRecords(iGetScopedNameFromLabel(calledFcnLabel));


                    parallel.internal.gpu.IR.errorIfTooManyFewInputs(callnode,calledFcnRecord,errorMechanism);


                    nlhs=callsitepair(2);
                    maxNlhs=numel(calledFcnRecord.Outputs);
                    parallel.internal.gpu.IR.errorIfTooManyOutputs(nlhs,maxNlhs,callnode,calledFcnRecord,errorMechanism);
                end
            end
        end

        function errorIfWrongNumberOfArgs(contextToFcnRecordsMap,fcnLabelFromCallNodeMap,errorMechanism)



            contextsToProcess=keys(contextToFcnRecordsMap);

            for kk=1:numel(contextsToProcess)

                callerContext=contextsToProcess{kk};
                fcnRecords=contextToFcnRecordsMap(callerContext);

                fcnNames=keys(fcnRecords);

                for jj=1:numel(fcnNames)
                    parallel.internal.gpu.IR.checkNumArgsForCalledFcns(fcnRecords,fcnNames{jj},fcnLabelFromCallNodeMap,callerContext,contextToFcnRecordsMap,errorMechanism);
                end

            end

        end

        function errorIfAssigningMATLABUplevels(boundFcnRecord,boundFcnLabel,matlabUplevels,errorMechanism)

            fdefnode=boundFcnRecord.FcnDefinitionNode;
            assignedToVariables=strings(asgvars(fullsubtree(Body(fdefnode))));
            if any(ismember(matlabUplevels,assignedToVariables))
                setCurrentContextForErrorMechanism(errorMechanism,boundFcnLabel.Context);
                setNodeForErrorMechanism(errorMechanism,fdefnode);
                variables=intersect(matlabUplevels,assignedToVariables);
                variables=[sprintf('%s, ',variables{1:(end-1)}),variables{end}];
                encounteredError(errorMechanism,message('parallel:gpu:compiler:ParentWorkspace',variables,boundFcnLabel.Name));
            end

        end


        function callnodeids=extractCallNodeids(calls,name)

            callsInfo=calls.(name).nodeinfo;
            N=numel(callsInfo);
            callnodeids=zeros(N,2);
            for kk=1:N
                callinfo=callsInfo{kk}{1};
                callnodeids(kk,:)=callinfo;
            end

        end

        function calls=insertCallNodeNumOuts(calls,nodeid,name,numouts)

            callsInfo=calls.(name).nodeinfo;
            N=numel(callsInfo);
            for kk=1:N
                callinfo=callsInfo{kk}{1};
                if nodeid==callinfo(1,1)
                    callinfo(1,2)=numouts;
                    callsInfo{kk}{1}=callinfo;
                end
            end

        end


        function fcnKeys=constructFcnNames(contextToFcnRecordsMap)

            contextsToProcess=keys(contextToFcnRecordsMap);
            fcnKeys={};

            for kk=1:numel(contextsToProcess)

                currentContext=contextsToProcess{kk};

                fcnRecords=contextToFcnRecordsMap(currentContext);
                scopedNames=keys(fcnRecords);

                for jj=1:numel(scopedNames)
                    fcnKeys{end+1}=[currentContext,iGetCallGraphFcnKeyDelimiter(),scopedNames{jj}];%#ok<AGROW>
                end

            end

        end

        function id=findFcnIndex(fcnKeys,calledFcnKey)

            id=0;
            for kk=1:numel(fcnKeys)
                if strcmp(fcnKeys{kk},calledFcnKey)
                    id=kk;
                    break;
                end
            end

        end

        function[callGraph,fcnKeys]=buildCallGraph(boundFcnLabel,contextToFcnRecordsMap,fcnLabelFromCallNodeMap)

            fcnKeys=parallel.internal.gpu.IR.constructFcnNames(contextToFcnRecordsMap);
            callGraph=false(numel(fcnKeys),numel(fcnKeys));

            N=numel(fcnKeys);
            boundFcnKey=iGetCallGraphKeyFromFcnLabel(boundFcnLabel);
            mask=strcmp(fcnKeys,boundFcnKey);
            ids=1:N;
            target=ids(mask);
            fcnKeys=[fcnKeys(target),fcnKeys(1:(target-1)),fcnKeys((target+1):end)];

            for kk=ids

                callerFcnKey=fcnKeys{kk};
                [callerContext,callerScopedName]=iGetContextAndScopedFcnNameFromCallGraphKey(callerFcnKey);


                i=parallel.internal.gpu.IR.findFcnIndex(fcnKeys,callerFcnKey);

                fcnRecords=contextToFcnRecordsMap(callerContext);
                callerFcnRecord=fcnRecords(callerScopedName);
                calls=callerFcnRecord.Calls;
                calledFcns=fields(calls);
                N=numel(calledFcns);

                if N>0

                    callNodeMap=fcnLabelFromCallNodeMap(callerContext);

                    for jj=1:numel(calledFcns)

                        callsites=parallel.internal.gpu.IR.extractCallNodeids(calls,calledFcns{jj});
                        [n,~]=size(callsites);

                        for ll=1:n
                            calledFcnLabel=callNodeMap(callsites(n,1));


                            calledFcnKey=iGetCallGraphKeyFromFcnLabel(calledFcnLabel);
                            j=parallel.internal.gpu.IR.findFcnIndex(fcnKeys,calledFcnKey);

                            callGraph(i,j)=true;

                        end

                    end

                end

            end

        end




        function[containsCycle,fcnNameId]=findRecursiveFcn(callGraph)

            containsCycle=false;
            fcnNameId=0;

            [m,n]=size(callGraph);
            assert(m==n,'graph must be square.');





            white=0;
            grey=1;
            black=2;

            vertices=zeros(m,1);

            for v=1:m
                if vertices(v)==white
                    partOfCycle=visit(callGraph,v);
                    if partOfCycle
                        containsCycle=true;
                        fcnNameId=partOfCycle;
                        return;
                    end
                end
            end


            function partOfCycle=visit(callGraph,v)

                assert(vertices(v)==white);
                partOfCycle=0;
                vertices(v)=grey;

                children=find(callGraph(v,:));

                for u=children

                    if vertices(u)==grey
                        partOfCycle=u;
                        return;
                    elseif vertices(u)==white
                        if visit(callGraph,u)
                            partOfCycle=u;
                            return;
                        end
                    end

                end

                vertices(v)=black;

            end

        end




        function permutation=topologicalSort(callGraph)

            N=size(callGraph,1);

            permutation=[];






            S=1:N;
            S=S(~any(callGraph(:,S)));

            while~isempty(S)

                n=S(end);
                S(end)=[];

                notpresent=isempty(find(permutation==n,1));
                if notpresent
                    permutation=[n,permutation];%#ok
                end


                nodesCalled=callGraph(n,:);


                callGraph(n,:)=0;


                nodesCalledByOthers=any(callGraph(:,nodesCalled),1);
                if~all(nodesCalledByOthers)



                    childIdx=find(nodesCalled);
                    S=[S,childIdx(~nodesCalledByOthers)];%#ok
                end
            end
        end



        function workspaceInfo=makeWorkspaceInfo(availableAsUplevel,neededAsUplevel)
            workspaceInfo=struct(...
            'AvailableAsUplevel',{availableAsUplevel},...
            'NeededAsUplevel',{neededAsUplevel}...
            );
        end

        function BackPropagateUplevelVariables(callGraph,fcnNames,allNestedFcns,contextToFcnRecordsMap)







            permutation=parallel.internal.gpu.IR.topologicalSort(callGraph);

            N=numel(allNestedFcns);
            nestedKeys=cell(1,N);
            for kk=1:N
                nestedFcnLabel=allNestedFcns{kk};
                fcnKey=iGetCallGraphKeyFromFcnLabel(nestedFcnLabel);
                nestedKeys{kk}=fcnKey;
            end


            N=numel(permutation);
            for kk=permutation

                fcnName=fcnNames{kk};
                id=strcmp(fcnName,nestedKeys);

                if any(id)








                    fcnLabel=allNestedFcns{id};
                    fcnRecords=contextToFcnRecordsMap(fcnLabel.Context);
                    nestedFcnKey=iGetScopedNameFromLabel(fcnLabel);
                    nestedFcnRecord=fcnRecords(nestedFcnKey);


                    usedHandleVariables=union(nestedFcnRecord.UsedHandleVariables,...
                    nestedFcnRecord.HandleInputList.handle);


                    potentialParents=false(N,1);
                    potentialParents(1:(kk-1),1)=callGraph(1:(kk-1),kk);


                    for jj=1:(kk-1)

                        if(potentialParents(jj))

                            parentFcn=fcnNames{jj};


                            [~,parentFcnKey]=iGetContextAndScopedFcnNameFromCallGraphKey(parentFcn);
                            parentFcnRecord=fcnRecords(parentFcnKey);


                            parentFcnUsedHandleVariables=parentFcnRecord.UsedHandleVariables;
                            parentFcnUsedHandleVariables=union(usedHandleVariables,parentFcnUsedHandleVariables);


                            parentFcnInputsAndOutputs=union(parentFcnRecord.Outputs,parentFcnRecord.Inputs);
                            parentFcnUsedHandleVariables=setdiff(parentFcnUsedHandleVariables,parentFcnInputsAndOutputs);


                            parentFcnRecord.UsedHandleVariables=parentFcnUsedHandleVariables;


                            fcnRecords(parentFcnKey)=parentFcnRecord;

                        end

                    end

                end

            end





        end


        function RemoveUnneededMATLABVariables(fcnLabel,contextToFcnRecordsMap)

            context=fcnLabel.Context;
            fcnKey=iGetScopedNameFromLabel(fcnLabel);

            fcnRecords=contextToFcnRecordsMap(context);
            fcnRecord=fcnRecords(fcnKey);

            handleInputs=fcnRecord.HandleInputs;


            fcnArgs=union(fcnRecord.Outputs,fcnRecord.Inputs);
            usedHandleVariables=setdiff(fcnRecord.UsedHandleVariables,fcnArgs);

            fcnWorkspaceSymbols=fcnRecord.FcnWorkspaceSymbols;

            variablesToBeRemoved=setdiff(handleInputs,usedHandleVariables);
            removeSymbols(fcnWorkspaceSymbols,variablesToBeRemoved);

            fcnRecord.HandleInputs=usedHandleVariables;
            fcnRecord.FcnWorkspaceSymbols=fcnWorkspaceSymbols;

            fcnRecords(fcnKey)=fcnRecord;%#ok<NASGU> handle

        end



        function matlabUplevels=BindUplevelMATLABVariables(contextToFcnRecordsMap,boundFcnLabel,fcnInfoStruct,errorMechanism)

            matlabUplevels=cell(1,0);
            if~isfield(fcnInfoStruct,'workspace')

                return
            end

            fcnRecords=contextToFcnRecordsMap(boundFcnLabel.Context);
            boundFcnKey=iGetScopedNameFromLabel(boundFcnLabel);
            boundFcnRecord=fcnRecords(boundFcnKey);
            fWorkspaceSymbols=boundFcnRecord.FcnWorkspaceSymbols;



            matlabUplevels=cell(1,0);

            fworkspace=fcnInfoStruct.workspace;
            W=numel(fworkspace);


            inputHandleVariables=boundFcnRecord.HandleInputs;
            N=numel(inputHandleVariables);
            for kk=1:N
                name=inputHandleVariables{kk};

                for jj=1:W
                    currentWS=fworkspace{jj};
                    if isfield(currentWS,name)
                        variable=currentWS.(name);
                        addUplevelVariableToSymbolTable(fWorkspaceSymbols,name,variable,errorMechanism);
                        matlabUplevels{end+1}=name;%#ok
                        break;
                    end
                end

            end

            boundFcnRecord.FcnWorkspaceSymbols=fWorkspaceSymbols;
            fcnRecords(boundFcnKey)=boundFcnRecord;%#ok<NASGU> handle
        end






        function parentfcns=findParentOfAnonymousFcn(fnode,ftree)

            fcnnodes=dominates(ftree,fnode)&mtfind(ftree,'Kind','FUNCTION');

            if isnull(fcnnodes)
                parentfcns=fcnnodes;
                return
            end



            nodeids=indices(fcnnodes);
            kk=numel(nodeids);
            fcnnode=select(fcnnodes,nodeids(kk));




            while isnull(subtree(fcnnode)&fnode)
                fcnnode=select(fcnnodes,nodeids(kk));
                kk=kk-1;
            end
            parentfcns=fcnnode;

            while~isnull(fcnnode)
                parentfcns=parentfcns|fcnnode;
                fcnnode=trueparent(fcnnode);
            end
        end



        function[fscope,fnode,workspaceInfo]=findFcnInTree(callernode,currentscope,calledFcns,fname)


            fdefnode=callernode;
            cut=strfind(currentscope,'@');
            if~isempty(cut)


                currentscope=currentscope(1:(cut-1));
                fdefnode=parallel.internal.gpu.IR.findParentOfAnonymousFcn(fdefnode,full(fdefnode));
            end

            scopes=regexp(currentscope,'\/','split');
            scopes=scopes(1:(end-1));



            fnode=null(fdefnode);
            while~isnull(fdefnode)&&isnull(fnode)

                fnode=mtfind(List(Body(fdefnode)),'Fname.Fun',fname);

                if isnull(fnode)

                    fdefnode=trueparent(fdefnode);
                    scopes=scopes(1:(end-1));
                end
            end


            fscope=sprintf('%s/',scopes{:});



            if isempty(fscope)&&isnull(fnode)
                fnode=mtfind(List(root(callernode)),'Fname.Fun',fname);
            end

            if~isempty(calledFcns.(fname).HandleInputList.handle)
                fscope=currentscope;
            end




            availableAsUplevel=cell(1,0);
            neededAsUplevel=cell(1,0);
            if~isempty(fscope)&&~isnull(fnode)


                fbody=fullsubtree(Body(fnode));
                functionDefs=mtfind(fbody,'Kind','FUNCTION');
                variables2ignore=unique(strings(list(Outs(fnode))|list(Ins(fnode))));


                handles=calledFcns.(fname).HandleInputList.handle;
                if~isempty(handles)
                    variables2ignore(ismember(variables2ignore,handles))=[];
                end





                callsites=calledFcns.(fname).nodeinfo;
                N=numel(callsites);
                availableAsUplevel=callsites{1}{2};
                for kk=2:N
                    availableAsUplevel=intersect(availableAsUplevel,callsites{kk}{2});
                end

                availableAsUplevel=setdiff(availableAsUplevel,variables2ignore);



                fbody=fbody-subtree(functionDefs);
                allvars=setdiff(strings(mtfind(fbody,'Isvar',true)),strings(asgvars(fbody)));
                neededAsUplevel=setdiff(allvars,variables2ignore);

            end

            workspaceInfo=parallel.internal.gpu.IR.makeWorkspaceInfo(availableAsUplevel,neededAsUplevel);

        end



        function fcnContext=resolveNewFcnContext(fcnName,currentContext)
            fcnContext=builtin('_gpu_resolveContextForFcn',fcnName,currentContext);
            fcnContext=regexprep(fcnContext,'\.m$','\.m');
        end





        function fcnlabel=buildFcnLabelFromContextScopeName(aContext,aScope,aName)
            fcnlabel=struct(...
            'Context',aContext,...
            'Scope',aScope,...
            'Name',aName...
            );
        end







        function[found,calledFcnLabel]=searchFcnRecordsForFcn(fcnRecords,fscope,fname)

            found=false;
            calledFcnLabel='';


            scopes=[fliplr(strfind(fscope,'/')),0];
            for kk=scopes
                fcnScopedName=[fscope(1:kk),fname];
                if isKey(fcnRecords,fcnScopedName)
                    found=true;
                    fcnRecord=fcnRecords(fcnScopedName);
                    calledFcnLabel=fcnRecord.FcnLabel;
                    break;
                end
            end

        end


        function emptyFilter=makeEmptyHandleInputList()
            emptyFilter=struct('idx',[],'inputs',[],'handle',[]);
        end


        function aMap=makeEmptyContextMap()
            aMap=containers.Map('KeyType','char','ValueType','any');
        end

        function contextToFcnRecordsMap=makeEmptyContextToFcnRecordsMap()
            contextToFcnRecordsMap=parallel.internal.gpu.IR.makeEmptyContextMap();
        end

        function fcnLabelFromCallNodeMap=makeEmptyFcnLabelFromCallNodeMap()
            fcnLabelFromCallNodeMap=parallel.internal.gpu.IR.makeEmptyContextMap();
        end

        function contextFcnCallsMap=makeEmptyContextFcnCallsMap()
            contextFcnCallsMap=parallel.internal.gpu.IR.makeEmptyContextMap();
        end


        function contextToFcnRecordsMap=updateContextToFcnRecordsMap(contextToFcnRecordsMap,fcnLabel,fcnRecord)

            fcnContext=fcnLabel.Context;
            scopedFname=iGetScopedNameFromLabel(fcnLabel);

            if isKey(contextToFcnRecordsMap,fcnContext)
                fcnRecords=contextToFcnRecordsMap(fcnContext);
                fcnRecords(scopedFname)=fcnRecord;
            else
                fcnRecords=containers.Map('KeyType','char','ValueType','any');
                fcnRecords(scopedFname)=fcnRecord;
            end

            contextToFcnRecordsMap(fcnContext)=fcnRecords;

        end

        function contextFcnCallsMap=updateContextFcnCallsMap(contextFcnCallsMap,callerContext,fcnContext,fname)

            if~isKey(contextFcnCallsMap,callerContext)
                externalFunctions=struct;
            else
                externalFunctions=contextFcnCallsMap(callerContext);
            end

            if~isfield(externalFunctions,fname)
                externalFunctions.(fname)=fcnContext;
                contextFcnCallsMap(callerContext)=externalFunctions;
            end

        end



        function fcnLabelFromCallNodeMap=updateFcnLabelFromCallNodeMap(fcnLabelFromCallNodeMap,currentContext,calls,fcnLabel)









            callnodeids=parallel.internal.gpu.IR.extractCallNodeids(calls,fcnLabel.Name);

            if isKey(fcnLabelFromCallNodeMap,currentContext)
                callNodeMap=fcnLabelFromCallNodeMap(currentContext);
            else
                callNodeMap=containers.Map('KeyType','double','ValueType','any');
            end

            [n,~]=size(callnodeids);
            for kk=1:n
                callNodeMap(callnodeids(kk,1))=fcnLabel;
            end

            fcnLabelFromCallNodeMap(currentContext)=callNodeMap;

        end


        function[contextToFcnRecordsMap,fcnLabelFromCallNodeMap,contextFcnCallsMap,nonStaticLoop,needsRand,allNestedFcns]=...
            buildContextMaps(fcnInfoStruct,boundFcnLabel,boundFcnRecord,errorMechanism)


            contextToFcnRecordsMap=parallel.internal.gpu.IR.makeEmptyContextToFcnRecordsMap();
            contextToFcnRecordsMap=...
            parallel.internal.gpu.IR.updateContextToFcnRecordsMap(contextToFcnRecordsMap,boundFcnLabel,boundFcnRecord);

            fcnLabelFromCallNodeMap=parallel.internal.gpu.IR.makeEmptyFcnLabelFromCallNodeMap();

            contextFcnCallsMap=parallel.internal.gpu.IR.makeEmptyContextFcnCallsMap();

            nonStaticLoop=false;
            needsRand=false;

            allNestedFcns=cell(1,0);
            if~isempty(boundFcnLabel.Scope)
                allNestedFcns{end+1}=boundFcnLabel;
            end


            labelsToProcess=parallel.internal.datastructs.Stack(boundFcnLabel);
            while~isempty(labelsToProcess)

                currentLabel=top(labelsToProcess);
                pop(labelsToProcess);


                currentContext=currentLabel.Context;
                setCurrentContextForErrorMechanism(errorMechanism,currentContext);

                fcnRecordsInCurrentContext=contextToFcnRecordsMap(currentContext);
                scopedName=iGetScopedNameFromLabel(currentLabel);
                fcnRecord=fcnRecordsInCurrentContext(scopedName);


                calledFcns=fcnRecord.Calls;
                calledFcnShortNames=fields(calledFcns);

                for kk=1:numel(calledFcnShortNames)

                    fname=calledFcnShortNames{kk};
                    currentScope=[scopedName,'/'];

                    [found,calledFcnLabel]=parallel.internal.gpu.IR.searchFcnRecordsForFcn(fcnRecordsInCurrentContext,currentScope,fname);

                    if~found





                        callerDefFcnNode=fcnRecord.FcnDefinitionNode;
                        [fscope,fnode,workspaceInfo]=parallel.internal.gpu.IR.findFcnInTree(callerDefFcnNode,currentScope,calledFcns,fname);

                        if~isnull(fnode)

                            if~isempty(fscope)







                                callsites=calledFcns.(fname).nodeinfo;
                                neededAsUplevel=workspaceInfo.NeededAsUplevel;
                                N=numel(callsites);
                                for jj=1:N
                                    missing=~ismember(neededAsUplevel,[fcnRecord.HandleInputList.inputs,callsites{jj}{2}]);
                                    if any(missing)
                                        nodeid=callsites{jj}{1};
                                        node=select(full(fnode),nodeid(1));
                                        setNodeForErrorMechanism(errorMechanism,node);
                                        missingvariables=sprintf('%s ',neededAsUplevel{missing});
                                        encounteredError(errorMechanism,message('parallel:gpu:compiler:UplevelUninitialized',missingvariables));
                                    end
                                end

                            end

                            fcnContext=currentContext;

                        else




                            fcnContext=parallel.internal.gpu.IR.resolveNewFcnContext(fname,currentContext);
                            parallel.internal.gpu.IR.errorIfUnableToLocateExternalFcn(fcnContext,currentContext,fnode,calledFcns,fname,errorMechanism);



                            fscope='';
                            fcnType='simple';
                            discoveredftree=parallel.internal.tree.getTreeForFile(fcnContext,fcnType,errorMechanism);
                            fnode=root(discoveredftree);





                            if~strcmp(string(Fname(fnode)),fname)&&~strcmp(currentLabel.Context,fcnContext)
                                parallel.internal.gpu.errorFcnFileNameMismatch(fcnContext,discoveredftree,errorMechanism);
                            end

                            contextFcnCallsMap=parallel.internal.gpu.IR.updateContextFcnCallsMap(...
                            contextFcnCallsMap,currentContext,fcnContext,fname);

                        end


                        [calledFcnLabel,calledFcnRecord,nonStaticLoopLocal,needsRandLocal]=...
                        parallel.internal.gpu.IR.buildFcnInfo(fcnContext,fscope,fname,fnode,workspaceInfo,errorMechanism,calledFcns.(fname).HandleInputList);

                        if~isempty(fscope)
                            allNestedFcns{end+1}=calledFcnLabel;%#ok <AGROW>
                        end


                        nonStaticLoop=nonStaticLoop|nonStaticLoopLocal;
                        needsRand=needsRand|needsRandLocal;

                        contextToFcnRecordsMap=parallel.internal.gpu.IR.updateContextToFcnRecordsMap(...
                        contextToFcnRecordsMap,calledFcnLabel,calledFcnRecord);

                        fcnLabelFromCallNodeMap=parallel.internal.gpu.IR.updateFcnLabelFromCallNodeMap(...
                        fcnLabelFromCallNodeMap,currentContext,calledFcns,calledFcnLabel);


                        push(labelsToProcess,calledFcnLabel);

                    else


                        fcnLabelFromCallNodeMap=parallel.internal.gpu.IR.updateFcnLabelFromCallNodeMap(...
                        fcnLabelFromCallNodeMap,currentContext,calledFcns,calledFcnLabel);
                    end

                end

            end




            if strcmp(fcnInfoStruct.type,'anonymous')
                contextToFcnRecordsMap=parallel.internal.gpu.IR.updateAnonFcnRecord(...
                contextToFcnRecordsMap,fcnLabelFromCallNodeMap,boundFcnLabel);
            end

        end


        function contextToFcnRecordsMap=updateAnonFcnRecord(contextToFcnRecordsMap,fcnLabelFromCallNodeMap,fcnLabel)

            callerContext=fcnLabel.Context;
            anonFcnRecords=contextToFcnRecordsMap(callerContext);

            anonScopedName=iGetScopedNameFromLabel(fcnLabel);
            anonFcnRecord=anonFcnRecords(anonScopedName);
            calledFcns=anonFcnRecord.Calls;
            calledFcnNames=fields(calledFcns);

            if~isempty(calledFcnNames)

                anonBody=Right(Arg(anonFcnRecord.FcnBeginNode));
                while~isnull(anonBody)&&strcmp(kind(anonBody),'PARENS')
                    anonBody=Arg(anonBody);
                end





                calledFcnName=calledFcnNames{1};





                if~isnull(anonBody)&&strcmp(kind(anonBody),'CALL')...
                    &&isequal(string(Left(anonBody)),calledFcnName)

                    callNodeMap=fcnLabelFromCallNodeMap(callerContext);
                    nodeid=indices(anonBody);
                    calledFcnLabel=callNodeMap(nodeid);

                    calledFcnRecords=contextToFcnRecordsMap(calledFcnLabel.Context);
                    calledFcnRecord=calledFcnRecords(iGetScopedNameFromLabel(calledFcnLabel));

                    inputs=anonFcnRecord.Inputs;
                    varout=sprintf('anon%s',inputs{:});

                    n=numel(calledFcnRecord.Outputs);
                    outputs=cell(1,n);

                    for kk=1:n
                        outputs{kk}=sprintf('%s%i',varout,kk);
                    end

                    anonFcnRecord.Outputs=outputs;


                    lifetimes=anonFcnRecord.Lifetimes;
                    symbolInfo=lifetimes(1);
                    symbolInfo.declare=outputs;
                    lifetimes(1)=symbolInfo;
                    anonFcnRecord.Lifetimes=lifetimes;


                    nodeid=indices(anonBody);
                    calledFcns=parallel.internal.gpu.IR.insertCallNodeNumOuts(calledFcns,nodeid,calledFcnName,numel(outputs));
                    anonFcnRecord.Calls=calledFcns;

                    anonFcnRecords(anonScopedName)=anonFcnRecord;%#ok<NASGU> handle

                end

            end

        end


        function fcnRecord=initializeFcnRecord(fcnLabel,fnode,outputs,inputs,beginnode,filter)

            fcnRecord=struct(...
            'FcnLabel',fcnLabel,...
            'FcnDefinitionNode',fnode,...
            'Outputs',{outputs},...
            'Inputs',{inputs},...
            'FcnBeginNode',beginnode,...
            'FcnWorkspaceSymbols',parallel.internal.gpu.Symbols({},{},{}),...
            'HandleOutputs',{cell(1,0)},...
            'HandleInputs',{cell(1,0)},...
            'UsedHandleVariables',{cell(1,0)},...
            'Lifetimes',{{}},...
            'Calls',struct,...
            'HandleInputList',filter...
            );

        end

        function fcnRecord=buildFcnRecord(fcnLabel,fnode,errorMechanism,handleInputList)

            setCurrentContextForErrorMechanism(errorMechanism,fcnLabel.Context);

            fnodekind=kind(fnode);

            if strcmp(fnodekind,'FUNCTION')

                outputs=strings(list(Outs(fnode)));
                inputs=strings(list(Ins(fnode)));


                nonInheritedIdx=handleInputList.idx~=0;
                handleInputList.inputs=[handleInputList.inputs,...
                inputs(handleInputList.idx(nonInheritedIdx))];
                inputs(handleInputList.idx(nonInheritedIdx))=[];

                ftree=subtree(fnode);
                beginnode=Body(ftree);
                idx=indices(beginnode);

                if~isempty(idx)
                    beginnode=select(ftree,idx(1));
                end

            else

                ftree=full(fnode);


                inputs={};
                idx=indices(Left(Arg(ftree)));
                if~isempty(idx)
                    input=select(ftree,idx(1));

                    inputs{1}=string(input);
                    input=Next(input);

                    while~isnull(input)
                        inputs{end+1}=string(input);%#ok<AGROW>
                        input=Next(input);
                    end

                end

                outputs={sprintf('Anon%s',[inputs{:}])};
                beginnode=fnode;

            end

            parallel.internal.gpu.IR.errorIfVarargInOut(outputs,inputs,fnode,errorMechanism);
            parallel.internal.gpu.IR.errorIfSuppresssedInputs(inputs,fnode,errorMechanism);

            fcnRecord=parallel.internal.gpu.IR.initializeFcnRecord(fcnLabel,fnode,outputs,inputs,beginnode,handleInputList);

        end


        function[boundFcnLabel,boundFcnRecord,boundFcnNonStaticLoop,boundFcnNeedsRand]=...
            buildBoundFcnInfo(fcnInfoStruct,ftree,errorMechanism)



            ftype=fcnInfoStruct.type;
            boundFcnContext=fcnInfoStruct.file;
            emptyFilter=parallel.internal.gpu.IR.makeEmptyHandleInputList;

            switch ftype
            case{'simple','scopedfunction','classsimple'}

                fname=fcnInfoStruct.function;
                fscope='';

                fnode=mtfind(ftree,'Kind','FUNCTION','Fname.Fun',fname);

                workspaceInfo=parallel.internal.gpu.IR.makeWorkspaceInfo({},{});

                [boundFcnLabel,boundFcnRecord,boundFcnNonStaticLoop,boundFcnNeedsRand]=...
                parallel.internal.gpu.IR.buildFcnInfo(boundFcnContext,fscope,fname,fnode,workspaceInfo,errorMechanism,emptyFilter);

            case{'nested'}

                fname=fcnInfoStruct.function;
                resolvedfname=regexp(fname,'\/','split');
                N=numel(resolvedfname);

                fscope=sprintf('%s/',resolvedfname{1:(N-1)});

                fnode=mtfind(ftree,'Kind','FUNCTION','Fname.Fun',resolvedfname{1});



                if isnull(fnode)
                    parallel.internal.gpu.errorFcnFileNameMismatch(fcnInfoStruct.file,ftree,errorMechanism);
                end

                for kk=2:N
                    fnode=mtfind(fullsubtree(Body(fnode)),'Kind','FUNCTION','Fname.Fun',resolvedfname{kk});
                end

                fname=string(Fname(fnode));

                boundFcnLabel=parallel.internal.gpu.IR.buildFcnLabelFromContextScopeName(boundFcnContext,fscope,fname);
                boundFcnRecord=parallel.internal.gpu.IR.buildFcnRecord(boundFcnLabel,fnode,errorMechanism,emptyFilter);



                populateWorkspaceFromMATLAB(boundFcnRecord.FcnWorkspaceSymbols,fcnInfoStruct.workspace);






















                uplevelVariables=getAllSymbolInsNames(boundFcnRecord.FcnWorkspaceSymbols);
                explicitVariables=union(boundFcnRecord.Outputs,boundFcnRecord.Inputs);
                visibleHandles=setdiff(uplevelVariables,explicitVariables);
                boundFcnRecord.HandleInputs=visibleHandles;


                [boundFcnRecord,boundFcnNonStaticLoop,boundFcnNeedsRand]=generateControlFlow(boundFcnRecord,errorMechanism);
            case{'anonymous'}


                fname=fcnInfoStruct.function;



                anon=strfind(fname,'@');
                anon=anon(1);
                if(anon==1)||isempty(fcnInfoStruct.file)
                    fname=fname(anon:end);
                    [fnode,fdefnode,fscope]=...
                    iGetInfoBasedOnFcnHandleOnly(fname,fcnInfoStruct,...
                    errorMechanism);
                else


                    assert(strcmp(fname(1:4),'taf%'),'illegal anonymous function definition');
                    anonNumberStart=strfind(fname,'sf%');
                    anonNumber=str2double(fname((anonNumberStart+3):(anon-1)))+1;
                    totalanonNumber=str2double(fname(5:(anonNumberStart-1)));

                    fname=fname(anon:end);






                    [fnode,fdefnode,fscope]=...
                    iGetInfoBasedOnFcnHandleOnly(fname,fcnInfoStruct,...
                    errorMechanism);



                    if iShouldParseTheWholeFile(fnode)
                        [fnode,fdefnode,fscope]=iGetInfoBasedOnEntireFile(anonNumber,totalanonNumber,...
                        fname,fcnInfoStruct,errorMechanism);
                    end
                end

                if~isempty(boundFcnContext)
                    fdefnode=fnode;
                    fnode=root(parallel.internal.tree.getTreeForFunction(fname,fcnInfoStruct.type,errorMechanism));
                end

                boundFcnLabel=parallel.internal.gpu.IR.buildFcnLabelFromContextScopeName(boundFcnContext,fscope,fname);
                boundFcnRecord=parallel.internal.gpu.IR.buildFcnRecord(boundFcnLabel,fnode,errorMechanism,emptyFilter);



                populateWorkspaceFromMATLAB(boundFcnRecord.FcnWorkspaceSymbols,fcnInfoStruct.workspace);
                boundFcnRecord.HandleInputs=getAllSymbolInsNames(boundFcnRecord.FcnWorkspaceSymbols);


                [boundFcnRecord,boundFcnNonStaticLoop,boundFcnNeedsRand]=generateControlFlow(boundFcnRecord,errorMechanism);

                calledFcnNames=fields(boundFcnRecord.Calls);
                for kk=1:numel(calledFcnNames)
                    if symbolPresent(boundFcnRecord.FcnWorkspaceSymbols,calledFcnNames{kk})
                        setCurrentContextForErrorMechanism(errorMechanism,boundFcnContext);
                        setNodeForErrorMechanism(errorMechanism,fdefnode);




                        origWorkspace=fcnInfoStruct.workspace;
                        symbolValue=origWorkspace{1}.(calledFcnNames{kk});
                        if iIsNestedFcn(symbolValue)
                            encounteredError(errorMechanism,message('parallel:gpu:compiler:AnonCallingNested',boundFcnLabel.Name,func2str(symbolValue)));
                        end

                        encounteredError(errorMechanism,message('parallel:gpu:compiler:FunctionWorkspace'));
                    end
                end

                if~isempty(boundFcnContext)
                    boundFcnRecord.FcnDefinitionNode=fdefnode;
                end

            otherwise
                assert(false,'unknown function type, ''%s''.',ftype);

            end

        end


        function[fcnLabel,fcnRecord,nonStaticLoop,needsRand]=...
            buildFcnInfo(fcnContext,fscope,fname,fnode,workspaceInfo,errorMechanism,handleInputList)

            fcnLabel=parallel.internal.gpu.IR.buildFcnLabelFromContextScopeName(fcnContext,fscope,fname);
            fcnRecord=parallel.internal.gpu.IR.buildFcnRecord(fcnLabel,fnode,errorMechanism,handleInputList);


            availableAsUplevel=workspaceInfo.AvailableAsUplevel;
            if~isempty(availableAsUplevel)

                populateWorkspaceInternally(fcnRecord.FcnWorkspaceSymbols,availableAsUplevel);
                fcnRecord.HandleOutputs=availableAsUplevel;
                fcnRecord.HandleInputs=availableAsUplevel;
            end


            [fcnRecord,nonStaticLoop,needsRand]=generateControlFlow(fcnRecord,errorMechanism);
        end

    end


    methods(Access=private)

        function fcnRecord=getFcnRecord(obj,fcnLabel)
            context=fcnLabel.Context;
            fcnRecordMap=obj.ContextToFcnRecordsMap(context);
            fcnScopedName=iGetScopedNameFromLabel(fcnLabel);
            fcnRecord=fcnRecordMap(fcnScopedName);
        end

    end


    methods(Access=public)


        function obj=IR(fcnInfoStruct,ftree,errorMechanism)



            [boundFcnLabel,boundFcnRecord,boundFcnNonStaticLoop,boundFcnNeedsRand]=...
            parallel.internal.gpu.IR.buildBoundFcnInfo(fcnInfoStruct,ftree,errorMechanism);


            [contextToFcnRecordsMap,fcnLabelFromCallNodeMap,contextFcnCallsMap,nonStaticLoop,needsRand,allNestedFcns]=...
            obj.buildContextMaps(fcnInfoStruct,boundFcnLabel,boundFcnRecord,errorMechanism);


            obj.errorIfWrongNumberOfArgs(contextToFcnRecordsMap,fcnLabelFromCallNodeMap,errorMechanism);


            [callGraph,fcnNames]=parallel.internal.gpu.IR.buildCallGraph(boundFcnLabel,contextToFcnRecordsMap,fcnLabelFromCallNodeMap);
            obj.errorIfRecursionIsPresent(callGraph,fcnNames,contextToFcnRecordsMap,errorMechanism);


            obj.MATLABUplevels=cell(1,0);
            if~isempty(allNestedFcns)

                obj.BackPropagateUplevelVariables(callGraph,fcnNames,allNestedFcns,contextToFcnRecordsMap);
                obj.RemoveUnneededMATLABVariables(boundFcnLabel,contextToFcnRecordsMap);







                matlabUplevels=obj.BindUplevelMATLABVariables(contextToFcnRecordsMap,boundFcnLabel,fcnInfoStruct,errorMechanism);
                obj.MATLABUplevels=matlabUplevels;

            end

            if~isempty(obj.MATLABUplevels)
                obj.errorIfAssigningMATLABUplevels(boundFcnRecord,boundFcnLabel,matlabUplevels,errorMechanism);
            end


            obj.ContextToFcnRecordsMap=contextToFcnRecordsMap;

            obj.ContextFcnCallsMap=contextFcnCallsMap;
            obj.FcnLabelFromCallNodeMap=fcnLabelFromCallNodeMap;

            obj.BoundFcnLabel=boundFcnLabel;


            obj.NonStaticLoop=nonStaticLoop|boundFcnNonStaticLoop;
            obj.NeedsRand=needsRand|boundFcnNeedsRand;

        end


        function errorIfBoundFcnWrongNumberOfArgs(obj,errorMechanism,varargin)




            boundFcnLabel=obj.BoundFcnLabel;

            inputs=getFcnInputs(obj,boundFcnLabel);
            nin=numel(inputs);
            nvar=numel(varargin{1});

            if nin<nvar
                setCurrentContext(errorMechanism,getFcnContext(obj,boundFcnLabel));
                setNodeForErrorMechanism(errorMechanism,getFcnDefinitionNode(obj,boundFcnLabel));
                fname=boundFcnLabel.Name;
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooManyInputs',fname));
            end

            if nvar<nin
                setCurrentContext(errorMechanism,getFcnContext(obj,boundFcnLabel));
                setNodeForErrorMechanism(errorMechanism,getFcnDefinitionNode(obj,boundFcnLabel));
                fname=boundFcnLabel.Name;
                encounteredError(errorMechanism,message('parallel:gpu:compiler:TooFewInputs',fname));
            end

        end




        function fcnContext=getFcnContext(obj,fcnLabel)%#ok
            fcnContext=fcnLabel.Context;
        end

        function fcnScope=getFcnScope(obj,fcnLabel)%#ok
            fcnScope=fcnLabel.Scope;
        end

        function fcnName=getFcnName(obj,fcnLabel)%#ok
            fcnName=fcnLabel.Name;
        end





        function fcnName=getBoundFcnName(obj)
            fcnName=obj.BoundFcnLabel.Name;
        end



        function fcnLabel=getBoundFcnLabel(obj)
            fcnLabel=obj.BoundFcnLabel;
        end

        function fcnLabel=getFcnLabelFromCallNode(obj,callerFcnLabel,nodeid)
            callerContext=callerFcnLabel.Context;
            callNodeMap=obj.FcnLabelFromCallNodeMap(callerContext);
            fcnLabel=callNodeMap(nodeid);
        end

        function nodeid=getFcnDefinitionNode(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);
            nodeid=fcnRecord.FcnDefinitionNode;
        end

        function inputs=getFcnOutputs(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);
            inputs=fcnRecord.Outputs;
        end

        function inputs=getFcnInputs(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);
            inputs=fcnRecord.Inputs;
        end

        function beginnode=getFcnBeginNode(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);
            beginnode=fcnRecord.FcnBeginNode;
        end

        function fcnWorkspaceSymbols=getFcnWorkspaceSymbols(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);
            fcnWorkspaceSymbols=fcnRecord.FcnWorkspaceSymbols;
        end

        function fcnHandleInputList=getFcnHandleInputList(obj,fcnLabel)





            fcnRecord=getFcnRecord(obj,fcnLabel);
            fcnHandleInputList=fcnRecord.HandleInputList;
        end

        function usedHandleVariables=getFcnUsedHandleVariables(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);
            usedHandleVariables=fcnRecord.UsedHandleVariables;
        end

        function matlabUplevels=getMATLABUplevelVariables(obj)
            matlabUplevels=obj.MATLABUplevels;
        end

        function lifetimes=getFcnLifetimes(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);
            lifetimes=fcnRecord.Lifetimes;
        end

        function calls=getFcnCalls(obj,fcnLabel)
            fcnRecord=getFcnRecord(obj,fcnLabel);


            calls=fcnRecord.Calls;
        end


        function nonStaticLoop=containsNonStaticLoop(obj)
            nonStaticLoop=obj.NonStaticLoop;
        end

        function needsRand=isRandCalled(obj)
            needsRand=obj.NeedsRand;
        end



        function contextFcnCalls=getContextFcnCallsMap(obj)

            contextFcnCallsMap=obj.ContextFcnCallsMap;
            contextsToProcess=keys(contextFcnCallsMap);
            contextFcnCalls=cell(1,numel(contextsToProcess));

            for kk=1:numel(contextsToProcess)
                currentContext=contextsToProcess{kk};
                contextSwitches=contextFcnCallsMap(currentContext);
                contextFcnCalls{kk}={currentContext,contextSwitches};
            end
        end
    end
end


function scopedFcnName=iGetScopedNameFromLabel(fcnLabel)
    assert(isstruct(fcnLabel),'Invalid function label encountered.')
    scopedFcnName=[fcnLabel.Scope,fcnLabel.Name];
end

function[fnode,fdefnode,fscope]=iGetInfoBasedOnFcnHandleOnly(fname,fcnInfoStruct,errorMechanism)
    fnode=root(parallel.internal.tree.getTreeForFunction(fname,fcnInfoStruct.type,errorMechanism));
    fdefnode=fnode;
    fscope='';
end

function[fnode,fdefnode,fscope]=iGetInfoBasedOnEntireFile(anonNumber,totalanonNumber,fname,fcnInfoStruct,errorMechanism)
    ftree=parallel.internal.tree.getTreeForFile(fcnInfoStruct.file,fcnInfoStruct.type,errorMechanism);
    anons=indices(mtfind(ftree,'Kind','ANON'));


    fnode=null(ftree);

    if~isempty(anons)
        numanons=numel(anons);
        if(numanons~=totalanonNumber)





            count=0;
            for kk=1:numanons

                fnodecurrent=select(ftree,anons(kk));
                currentanon=regexprep(tree2str(fnodecurrent),' ','');

                if(strcmp(fname,currentanon))
                    count=count+1;
                    fnode=fnodecurrent;

                    if(count>1)
                        setNodeForErrorMechanism(errorMechanism,root(ftree));
                        encounteredError(errorMechanism,message('parallel:gpu:compiler:LanguageAnonAmbiguity'));
                    end
                end
            end
        else
            fnode=select(ftree,anons(anonNumber));
        end
    end



    evalnodes=mtfind(ftree,'Kind','ID','String','eval');
    ids=indices(evalnodes);



    for kk=1:numel(ids)
        evalnode=select(evalnodes,ids(kk));
        defnode=Right(Parent(evalnode));

        if iskind(defnode,'CHARVECTOR')
            amatch=strfind(string(defnode),fname);
        else
            amatch=[];
        end

        if~isempty(amatch)&&~isnull(fnode)
            parallel.internal.gpu.IR.errorEvalCausingAnonNameConflict(evalnode,errorMechanism);
        end
    end

    parentfcns=parallel.internal.gpu.IR.findParentOfAnonymousFcn(fnode,ftree);
    fscopenames=strings(Fname(parentfcns));
    fscope=sprintf('%s/',fscopenames{:});



    fdefnode=root(fnode);
end





function tf=iShouldParseTheWholeFile(theTree)




    theTree=wholetree(theTree);







    acceptedVars=strings(mtfind(theTree,'Kind','ANONID'));








    acceptedConstants=strings(mtfind(theTree,'Kind',{'DOUBLE','INT','CHARVECTOR','STRING'}));



    acceptedFcns=parallel.internal.types.getRowVectorOfGpuarrayMethods();

    expectedStrings=[acceptedVars,acceptedConstants,acceptedFcns];


    actualStrings=strings(theTree);

    unexpectedStrings=setdiff(actualStrings,expectedStrings);



    tf=~(isempty(unexpectedStrings)||all(strcmp(unexpectedStrings,'')));
end

function delimiter=iGetCallGraphFcnKeyDelimiter()
    delimiter='+>+';
end

function key=iGetCallGraphKeyFromFcnLabel(fcnLabel)
    key=[fcnLabel.Context,iGetCallGraphFcnKeyDelimiter(),iGetScopedNameFromLabel(fcnLabel)];
end

function[context,scopedName]=iGetContextAndScopedFcnNameFromCallGraphKey(callGraphKey)
    keyDelimiter=iGetCallGraphFcnKeyDelimiter();
    split=strfind(callGraphKey,keyDelimiter);
    context=callGraphKey(1:split-1);
    scopedName=callGraphKey(split+length(keyDelimiter):end);
end

function tf=iIsNestedFcn(symbolValue)
    if~isa(symbolValue,'function_handle')
        tf=false;
        return;
    end


    fcnNameAsString=func2str(symbolValue);
    tf=strfind(fcnNameAsString,'/');

end
