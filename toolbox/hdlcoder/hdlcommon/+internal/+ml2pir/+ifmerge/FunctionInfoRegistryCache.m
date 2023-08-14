



















classdef FunctionInfoRegistryCache

    methods(Static,Access=public)
        function varargout=retrieveAndSetCacheValue(varargin)

            implFcn=eval(['@',mfilename('class'),'.setImplFcn']);
            [varargout{1:nargout}]=...
            internal.ml2pir.FunctionInfoRegistryCache.retrieveAndSetCacheValue(implFcn,varargin{:});
        end

        function varargout=getCacheValue(blockName)

            implFcn=eval(['@',mfilename('class'),'.getImplFcn']);
            [varargout{1:nargout}]=...
            internal.ml2pir.FunctionInfoRegistryCache.getCacheValue(blockName,implFcn);
        end
    end

    methods(Static,Access=private)
        function[s,fcnInfoRegistry,createFcnInfoMsgs]=setImplFcn(blockName,hC)
            [fcnInfoRegistry,createFcnInfoMsgs]=...
            internal.ml2pir.ifmerge.FunctionInfoRegistryCache.createFunctionInfoRegistry(blockName,hC);

            s=struct;
            s.fcnInfoRegistry=fcnInfoRegistry;
        end

        function fcnInfoRegistry=getImplFcn(s)
            fcnInfoRegistry=s.fcnInfoRegistry;
        end
    end

    methods(Static,Access=protected)
        function[fcnInfoRegistry,createFcnInfoMsgs]=createFunctionInfoRegistry(blockName,hC)



            fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry;




            blkTyp=get_param(blockName,'BlockType');
            if strcmp(blkTyp,'If')
                [functionName,inputVar,outputVar,body]=...
                internal.ml2pir.ifmerge.FunctionInfoRegistryCache.createIfFunction(blockName);
            else
                assert(strcmp(blkTyp,'Merge'),'unsupported block type');
                [functionName,inputVar,outputVar,body]=...
                internal.ml2pir.ifmerge.FunctionInfoRegistryCache.createMergeFunction(blockName);
            end
            scriptText=internal.ml2pir.ifmerge.FunctionInfoRegistryCache.Expr2Func(functionName,inputVar,outputVar,body);





            callNodes=mtfind(Full(mtree(scriptText)),'Kind','CALL');
            callNames=callNodes.Left;
            wkspNames=cell(callNames.count,1);
            workspaceVarCount=0;
            for ii=indices(callNames)
                callName=callNames.select(ii).tree2str;
                if~isempty(internal.ml2pir.ifmerge.FunctionInfoRegistryCache.resolveWkspVar(callName,blockName))
                    workspaceVarCount=workspaceVarCount+1;
                    wkspNames{workspaceVarCount}=callName;
                end
            end
            wkspNames(workspaceVarCount+1:end)=[];

            if~isempty(wkspNames)

                if~iscell(wkspNames)
                    error('wkspNames should be a cell array');
                end


                scriptText=internal.ml2pir.ifmerge.FunctionInfoRegistryCache.Expr2Func(...
                functionName,[inputVar;wkspNames],outputVar,body);
            end


            uniqueId=replace(blockName,'/','_');
            fcnTypeInfo=internal.mtree.FunctionTypeInfo(...
            functionName,functionName,uniqueId,[],scriptText,'',[]);
            fcnTypeInfo.isDesign=true;



            internal.ml2pir.ifmerge.FunctionInfoRegistryCache.setInputTypes(...
            blockName,hC,inputVar,fcnTypeInfo);
            internal.ml2pir.ifmerge.FunctionInfoRegistryCache.setOutputTypes(...
            blockName,hC,outputVar,fcnTypeInfo);
            createFcnInfoMsgs=internal.ml2pir.ifmerge.FunctionInfoRegistryCache.setWkspVarTypes(...
            blockName,wkspNames,fcnTypeInfo);






            coder.internal.FcnInfoRegistryBuilder.assignVariableSpecializationNames(fcnTypeInfo);
            fcnInfoRegistry.addFunctionTypeInfo(fcnTypeInfo);


            if~internal.mtree.Message.containErrorMsgs(createFcnInfoMsgs)
                try
                    internal.ml2pir.ifmerge.ConstAnnotator.run(fcnInfoRegistry);
                catch ex
                    internal.mtree.utils.errorWithContext(ex,'Constant folding error: ');
                end
            end
        end

        function scriptText=Expr2Func(functionName,inputVar,outputVar,body)
            inputVarStr=strjoin(inputVar,', ');
            outputVarStr=strjoin(outputVar,', ');
            bodyStr=strjoin(body,newline);
            scriptText=['function [',outputVarStr,'] = ',functionName,'(',inputVarStr,')',newline,...
            bodyStr,newline,...
            'end'];
        end

        function[functionName,inputVar,outputVar,body]=createIfFunction(blockName)

            ifExpr=get_param(blockName,'IfExpression');
            elseIfExprs=get_param(blockName,'ElseIfExpressions');
            hasElse=get_param(blockName,'ShowElse');
            inputNum=str2double(get_param(blockName,'NumInputs'));

            if isempty(elseIfExprs)
                conditions={ifExpr};
            else
                conditions=cat(1,ifExpr,split(elseIfExprs,[',',' ']));
            end
            condNum=numel(conditions);



            functionName='fcn_internal_if';

            outputVar=arrayfun(@(i)sprintf('y%d',i),1:condNum,'UniformOutput',false);


            for ii=condNum:-1:1
                if ii==condNum
                    nestedBody='';
                else
                    nestedBody=body{ii+1};
                end
                if ii==1
                    initVars=arrayfun(@(i)[outputVar{i},' = false;',newline],...
                    2:condNum,'UniformOutput',false);
                    body{ii}=[outputVar{ii},' = ',conditions{ii},';',newline,...
                    strjoin(initVars,''),newline,...
                    nestedBody];
                else

                    body{ii}=['if ~',outputVar{ii-1},newline,...
                    outputVar{ii},' = ',conditions{ii},';',newline,...
                    nestedBody,newline,...
                    'end'];
                end
            end


            if strcmp(hasElse,'on')
                elseIndex=condNum+1;
                elseVar=sprintf('y%d',elseIndex);
                body{elseIndex}=[elseVar,' = ~(',strjoin(outputVar,' || '),');'];
                outputVar{elseIndex}=elseVar;
                body={[body{1},newline,body{elseIndex}]};
            else
                body={[body{1}]};
            end

            inputVar=arrayfun(@(i)sprintf('u%d',i),1:inputNum,'UniformOutput',false);

        end

        function[functionName,inputVar,outputVar,body]=createMergeFunction(blockName)
            functionName='fcn_internal_merge';
            inputNum=str2double(get_param(blockName,'Inputs'));
            inputCondVar=arrayfun(@(i)sprintf('c%d',i),1:inputNum,...
            'UniformOutput',false);
            inputBranchVar=arrayfun(@(i)sprintf('u%d',i),1:inputNum,...
            'UniformOutput',false);
            inputVar=[inputBranchVar,inputCondVar,'yPrev'];
            outputVar={'y'};

            ifBranch={['if c1',newline,...
            'y = u1;']};
            elseIfBranches=arrayfun(@(i)sprintf(['elseif c%d',newline,'y = u%d;'],i,i),2:inputNum,...
            'UniformOutput',false);



            elseBranch=['else',newline,...
            'y = yPrev;',newline,...
            'end',newline];

            body=[ifBranch,elseIfBranches,{elseBranch}];
        end

        function setInputTypes(blockName,hC,inputVars,fcnTypeInfo)
            isMergeBlk=strcmp(get_param(blockName,'BlockType'),'Merge');
            blkNumIn=numel(hC.PirInputPorts);
            varNumIn=numel(inputVars);

            for ii=1:varNumIn
                var=inputVars{ii};


                if ii<=blkNumIn

                    pirType=hC.PirInputSignals(ii).type;
                else
                    assert(isMergeBlk,'unexpected number of inputs for If block')
                    if ii<varNumIn

                        pirType=pir_boolean_t;
                    else


                        pirType=hC.PirOutputSignals(1).type;
                    end
                end

                internal.ml2pir.ifmerge.FunctionInfoRegistryCache.fillInferredInfo(...
                fcnTypeInfo,var,pirType,'inputVar');
            end
        end

        function setOutputTypes(blockName,hC,outputVars,fcnTypeInfo)
            blkType=get_param(blockName,'BlockType');
            isIfBlk=strcmp(blkType,'If');
            for ii=1:numel(outputVars)
                var=outputVars{ii};
                if isIfBlk
                    pirType=pir_boolean_t;
                else
                    assert(strcmp(blkType,'Merge'),'unexpected block type. expected If or Merge.');
                    assert(ii==1,'Merge block unexpectedly has more than 1 output');
                    pirType=hC.PirOutputSignals(1).type;
                end

                internal.ml2pir.ifmerge.FunctionInfoRegistryCache.fillInferredInfo(...
                fcnTypeInfo,var,pirType,'outputVar');
            end
        end

        function wkspVarMsgs=setWkspVarTypes(blockName,wkspVars,fcnTypeInfo)
            wkspVarMsgs=internal.mtree.Message.preallocate(numel(wkspVars));
            msgIdx=1;

            for ii=1:numel(wkspVars)
                var=wkspVars{ii};



                val=internal.ml2pir.ifmerge.FunctionInfoRegistryCache.resolveWkspVar(var,blockName);
                varType=internal.mtree.Type.fromValue(val);

                if varType.isUnknown
                    wkspVarMsgs(msgIdx)=internal.mtree.Message(...
                    [],...
                    [],...
                    internal.mtree.MessageType.Error,...
                    'hdlcoder:validate:ifActionInvalidWkspVarType',...
                    blockName,...
                    var,...
                    varType.getMLName);
                    msgIdx=msgIdx+1;
                end



                fcnTypeInfo.chartData.addData(internal.mtree.mlfb.ConstantParameter(var,varType,val));


                nodeTypeName='inputVar';

                internal.ml2pir.ifmerge.FunctionInfoRegistryCache.fillInferredInfo(...
                fcnTypeInfo,var,pir_unsigned_t(32),nodeTypeName,val);
            end

            wkspVarMsgs(msgIdx:end)=[];
        end

        function fillInferredInfo(fcnTypeInfo,var,pirType,nodeTypeName,val)


            inferredInfo=coder.internal.FcnInfoRegistryBuilder.getDefaultInferredTypeInfo;

            if nargin<5
                if pirType.isArrayType
                    if pirType.is2DMatrix
                        argSize=pirType.Dimensions;
                    elseif pirType.isRowVector
                        argSize=[1,pirType.Dimensions];
                    else
                        argSize=[pirType.Dimensions,1];
                    end
                    baseType=pirType.BaseType;
                else
                    argSize=[1,1];
                    baseType=pirType;
                end
                isCoderConst=false;

                inferredInfo.Class=internal.ml2pir.ifmerge.FunctionInfoRegistryCache.fromPIRType(pirType.getLeafType);
                inferredInfo.Complex=baseType.isComplexType;
            else
                argSize=size(val);
                isCoderConst=true;

                inferredInfo.Class=class(val);
                inferredInfo.Complex=~isreal(val);
            end


            inferredInfo.Size=uint32(reshape(argSize,2,1));



            varLogInfo=internal.mtree.FcnInfoRegistryBuilder.buildVarLogInfo(var,nodeTypeName,1,inferredInfo,{},{});




            varTypeInfo=coder.internal.VarTypeInfo(varLogInfo,inferredInfo,isCoderConst);


            fcnTypeInfo.addVarInfo(var,varTypeInfo);
        end


        function mlClass=fromPIRType(pt)
            if pt.isWordType
                if pt.Signed
                    mlClass=sprintf('int%d',pt.WordLength);
                else
                    mlClass=sprintf('uint%d',pt.WordLength);
                end
            elseif pt.is1BitType
                mlClass='logical';
            elseif pt.isSingleType
                mlClass='single';
            elseif pt.isDoubleType
                mlClass='double';
            else
                error('unknown PIR type in conversion');
            end
        end

        function val=resolveWkspVar(wkspVar,blockName)
            try
                val=slResolve(wkspVar,blockName,'variable');
            catch me
                if strcmp(me.identifier,'Simulink:Data:SlResolveNotResolved')




                    val=[];
                else
                    throw(me);
                end
            end
        end
    end

end


