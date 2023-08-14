



















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
        function[s,fcnInfoRegistry]=setImplFcn(blockName,hC)
            fcnInfoRegistry=internal.ml2pir.fcn.FunctionInfoRegistryCache.createFunctionInfoRegistry(blockName,hC);

            s=struct;
            s.fcnInfoRegistry=fcnInfoRegistry;
        end

        function fcnInfoRegistry=getImplFcn(s)
            fcnInfoRegistry=s.fcnInfoRegistry;
        end
    end

    methods(Static,Access=protected)
        function fcnInfoRegistry=createFunctionInfoRegistry(blockName,hC)



            fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry;










            expr=get_param(blockName,'Expr');

            expr=replace(expr,'!','~');

            expr=replace(expr,'[','(');
            expr=replace(expr,']',')');

            existSignVar=regexp(expr,'sign(?=\W)','once');
            if~isempty(existSignVar)




                newSignVarName='sign_renamed';
                existSignVar=regexp(expr,[newSignVarName,'(?=\W)'],'once');
                iterCount=0;
                while~isempty(existSignVar)



                    iterCount=iterCount+1;
                    existSignVar=regexp(expr,[newSignVarName,int2str(iterCount),'(?=\W)'],'once');
                end
                if iterCount~=0


                    newSignVarName=[newSignVarName,int2str(iterCount)];
                end


                expr=regexprep(expr,'sign(?=\W)',newSignVarName);
            else
                newSignVarName='';
            end


            expr=regexprep(expr,'sgn(?=\W)','sign');


            functionName='fcn';
            outputVar='y';
            inputVar='u';
            scriptText=internal.ml2pir.fcn.FunctionInfoRegistryCache.Expr2Func(expr,inputVar,outputVar,functionName);





            callNodes=mtfind(Full(mtree(scriptText)),'Kind','CALL');
            callNames=callNodes.Left;
            workspaceVars=cell(callNames.count,1);
            workspaceVarCount=0;
            validFunctions=...
            {'abs','acos','asin','atan','atan2','ceil','cos','cosh',...
            'exp','floor','hypot','log','log10','power','rem','sign',...
            'sin','sinh','sqrt','tan','tanh'};
            for ii=indices(callNames)
                callName=callNames.select(ii).tree2str;
                isValidFunction=any(strcmp(callName,validFunctions));
                if~isValidFunction&&...
                    (strcmp(callName,newSignVarName)||~isempty(internal.ml2pir.fcn.FunctionInfoRegistryCache.resolveWkspVar(callName,blockName)))

                    workspaceVarCount=workspaceVarCount+1;
                    workspaceVars{workspaceVarCount}=callName;
                end
            end
            workspaceVars(workspaceVarCount+1:end)=[];

            if~isempty(workspaceVars)


                scriptText=internal.ml2pir.fcn.FunctionInfoRegistryCache.Expr2Func(expr,[{inputVar};workspaceVars],outputVar,functionName);
            end


            uniqueId=replace(blockName,'/','_');
            fcnTypeInfo=internal.mtree.FunctionTypeInfo(functionName,functionName,uniqueId,[],scriptText,'',[]);
            fcnTypeInfo.isDesign=true;



            assert(numel(hC.PirInputSignals)==1,'fcn block is expected to have one input');
            assert(numel(hC.PirOutputSignals)==1,'fcn block is expected to have one output');
            inputVars={inputVar};
            outputVars={outputVar};
            ioVars={inputVars,outputVars,workspaceVars};
            internal.ml2pir.fcn.FunctionInfoRegistryCache.setInputOutputTypes(blockName,hC,ioVars,fcnTypeInfo,newSignVarName);






            coder.internal.FcnInfoRegistryBuilder.assignVariableSpecializationNames(fcnTypeInfo);
            fcnInfoRegistry.addFunctionTypeInfo(fcnTypeInfo);


            try
                internal.ml2pir.fcn.ConstAnnotator.run(fcnInfoRegistry);
            catch ex
                errorDesc='';

                for i=1:numel(ex.stack)
                    stack=ex.stack(i);

                    if contains(stack.file,fullfile('+internal','+ml2pir','+fcn'))
                        errorDesc=[stack.name,': ',num2str(stack.line),': ',ex.message];
                        break
                    end
                end

                if isempty(errorDesc)
                    stack=ex.stack(1);
                    errorDesc=[stack.name,': ',num2str(stack.line),': ',ex.message];
                end

                error(['Constant folding error: ',errorDesc]);
            end
        end

        function scriptText=Expr2Func(expr,inputVar,outputVarStr,functionName)
            if iscell(inputVar)
                inputVarStr=strjoin(inputVar,', ');
            else
                inputVarStr=inputVar;
            end
            scriptText=['function ',outputVarStr,' = ',functionName,'(',inputVarStr,')',newline,...
            outputVarStr,' = ',expr,';',newline,...
            'end'];
        end

        function setInputOutputTypes(blockName,hC,ioVars,fcnTypeInfo,newSignVarName)
            for ii=1:numel(ioVars)


                assert(ii<4,'incorrect use of setInputOutputTypes')
                vars=ioVars{ii};
                for jj=1:numel(ioVars{ii})



                    var=vars{jj};


                    inferredInfo=coder.internal.FcnInfoRegistryBuilder.getDefaultInferredTypeInfo;
                    switch ii
                    case 1

                        nodeTypeName='inputVar';
                        pirType=hC.PirInputSignals(jj).type;
                        if pirType.isArrayType
                            if pirType.isRowVector
                                argSize=[1,pirType.Dimensions];
                            else
                                argSize=[pirType.Dimensions,1];
                            end
                        else
                            argSize=[1,1];
                        end
                        isCoderConst=false;
                    case 2

                        nodeTypeName='outputVar';
                        pirType=hC.PirOutputSignals(jj).type;
                        assert(~pirType.isArrayType,'output is expected to be scalar')
                        argSize=[1,1];
                        isCoderConst=false;
                    case 3


                        if strcmp(newSignVarName,var)




                            wkspVar='sign';
                        else
                            wkspVar=var;
                        end
                        val=internal.ml2pir.fcn.FunctionInfoRegistryCache.resolveWkspVar(wkspVar,blockName);
                        varType=class(val);


                        fcnTypeInfo.chartData.addData(internal.mtree.mlfb.ConstantParameter(var,varType,val));


                        nodeTypeName='inputVar';
                        argSize=size(val);
                        isCoderConst=true;
                    otherwise
                        error('incorrect use of setInputOutputTypes')
                    end

                    inferredInfo.Size=uint32(reshape(argSize,2,1));

                    if ii<3

                        switch class(pirType.BaseType)
                        case 'hdlcoder.tp_single'
                            inferredInfo.Class='single';
                        case 'hdlcoder.tp_double'
                            inferredInfo.Class='double';
                        otherwise



                            error(['unexpected type found in ',blockName]);
                        end
                    else

                        inferredInfo.Class=varType;
                    end



                    varLogInfo=internal.mtree.FcnInfoRegistryBuilder.buildVarLogInfo(var,nodeTypeName,1,inferredInfo,{},{});




                    varTypeInfo=coder.internal.VarTypeInfo(varLogInfo,inferredInfo,isCoderConst);


                    fcnTypeInfo.addVarInfo(var,varTypeInfo);
                end
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


