classdef TolerenceService
    methods(Static)








        function diffTable=diffFcnInfoRegistryForRange(origRegistry,newRegistry,tol,dName,fxpCfg)
            diffTable=coder.internal.lib.Map();

            origFcns=origRegistry.getAllFunctions();
            for ii=1:length(origFcns)
                fcn=origFcns{ii};
                origFcnInfo=origRegistry.getFunctionTypeInfo(fcn);

                varMap=coder.internal.lib.Map();



                if strcmp(origFcnInfo.specializationName,dName)
                    newFcnName=[dName,fxpCfg.FixPtFileNameSuffix];
                else
                    newFcnName=origFcnInfo.specializationName;
                end

                newFcnInfos=newRegistry.getFunctionTypeInfosByName(newFcnName);
                if isempty(newFcnInfos)
                    continue;
                end
                newFcnInfo=newFcnInfos{1};


                origVarNames=origFcnInfo.getAllVarNames();

                for varNames=origVarNames
                    varName=varNames{1};

                    if varMap.isKey(varName)
                        continue;
                    end
                    varMap(varName)=true;


                    origVarInfo=origFcnInfo.getVarInfo(varName);
                    if isempty(origVarInfo)
                        continue;
                    end

                    newVarInfo=newFcnInfo.getVarInfo(varName);
                    if isempty(newVarInfo)
                        continue;
                    end


                    if~isVarInfoRangesAcceptable(tol,origVarInfo,newVarInfo)
                        diffTable.add(varName,[origVarInfo,newVarInfo]);
                    end
                end
            end

            function ret=isVarInfoRangesAcceptable(tol,varInfo1,varInfo2)

                min1=varInfo1.SimMin;
                min2=varInfo2.SimMin;

                max1=varInfo1.SimMax;
                max2=varInfo2.SimMax;

                ret=areValsWithinTolerance(tol,min1,min2)&&areValsWithinTolerance(tol,max1,max2);

                function res=areValsWithinTolerance(tol,val1,val2)
                    res=true;
                    if~isempty(val1)&&~isempty(val2)
                        if abs(val1-val2)>tol
                            res=false;
                        end
                    end
                end
            end
        end








        function messages=diffRegistries(goldRegistry,registry,tol,designName,expressionInfoMap,goldExpressionInfoMap)

            diffRegistry=containers.Map();
            nodeVisitationRegistry=containers.Map();
            nodeLookupRegistry=containers.Map();

            fcnId=designName;
            goldFcnId=designName;
            coder.internal.MtreeRangeDiffer(registry,goldRegistry,fcnId,goldFcnId,expressionInfoMap,goldExpressionInfoMap,diffRegistry,nodeLookupRegistry,nodeVisitationRegistry).run();

            errors=coder.internal.TolerenceService.reportErrors(tol,diffRegistry,fcnId,registry,nodeVisitationRegistry,@pos2node);

            messages=coder.internal.TolerenceService.buildTolerenceViolationMsgs(errors);

            function node=pos2node(fcnUniqId,pos)
                nodeLookup=nodeLookupRegistry(fcnUniqId);
                node=nodeLookup(pos);
            end
        end
    end

    methods(Static,Hidden)

        function messages=buildTolerenceViolationMsgs(errorTriplets)
            messages=coder.internal.lib.Message().empty();

            for ii=1:length(errorTriplets)
                errTriple=errorTriplets{ii};
                node=errTriple{1};
                fcnInfo=errTriple{2};
                rangeDiff=errTriple{3};

                messages(end+1)=buildMessage(fcnInfo...
                ,node...
                ,coder.internal.lib.Message.WARN...
                ,'Coder:FXPCONV:TolerenceDiff'...
                ,{sprintf('[%.17g %.17g]',rangeDiff(1),rangeDiff(2))});
            end

            function msg=buildMessage(fcnInfo,node,msgType,msgId,msgParams)
                if nargin<5
                    msgParams={};
                end

                if~iscell(msgParams)
                    msgParams={msgParams};
                end

                msg=coder.internal.lib.Message();
                msg.functionName=fcnInfo.functionName;%#ok<*AGROW>
                msg.specializationName=fcnInfo.specializationName;
                msg.file=fcnInfo.scriptPath;
                msg.type=msgType;

                msg.position=node.lefttreepos()-1;
                msg.length=node.righttreepos-msg.position;

                msg.text=message(msgId,msgParams{:}).getString();
                msg.id=msgId;
                msg.params=msgParams;

                msg.node.lineno=node.lineno;
                msg.node.charno=node.charno;
                msg.node.str=node.tree2str();
            end
        end

        function errors=reportErrors(tol,diffRegistry,fcnUniqId,registry,nodeVisitationRegistry,pos2node)

            allFcnIds=registry.registry.keys;
            visited=containers.Map(allFcnIds,zeros(1,length(allFcnIds)));
            diffs=diffRegistry(fcnUniqId);




            tol=1;
            errors={};
            checkFunction(fcnUniqId,diffs);
            function checkFunction(fcnId,diffs)

                if visited(fcnId)
                    return;
                end

                fcnInfo=registry.getFunctionTypeInfo(fcnId);
                cNodes=fcnInfo.getCallNodes();
                callPositions=cellfun(@(n)n.position,cNodes);

                diffExprPositions=nodeVisitationRegistry(fcnId);
                for ii=1:length(diffExprPositions)
                    exprPos=diffExprPositions{ii};
                    node=pos2node(fcnId,exprPos);
                    isCallNodePos=any(callPositions==str2double(exprPos));
                    fcnTol=tol;
                    if isCallNodePos
                        [hasViolation,rangeDiff]=checkViolation(exprPos,fcnTol);
                        if hasViolation
                            callNode=pos2node(fcnId,exprPos);
                            calledFunctionInfo=fcnInfo.treeAttributes(callNode).CalledFunction;
                            if~isempty(calledFunctionInfo)
                                calleeFcnId=calledFunctionInfo.uniqueId;
                                checkFunction(calleeFcnId,diffRegistry(calleeFcnId))
                            end
                        end
                    else
                        [hasViolation,rangeDiff]=checkViolation(exprPos,fcnTol);
                    end
                    if hasViolation
                        addViolation(fcnInfo,exprPos,rangeDiff);
                    end
                end

                function[hasViolation,rangeDiff]=checkViolation(exprPos,tol)
                    hasViolation=false;
                    rangeDiff=diffs(exprPos);
                    if any(abs(rangeDiff)>tol)
                        hasViolation=true;
                    end
                end

                function addViolation(fcnInfo,exprPos,rangeDiff)
                    errors{end+1}={pos2node(fcnInfo.uniqueId,exprPos),fcnInfo,rangeDiff};
                end
            end
        end
    end
end