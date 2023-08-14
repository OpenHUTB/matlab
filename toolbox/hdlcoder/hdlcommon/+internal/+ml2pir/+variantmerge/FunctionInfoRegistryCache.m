



















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
            fcnInfoRegistry=internal.ml2pir.variantmerge.FunctionInfoRegistryCache.createFunctionInfoRegistry(blockName,hC);

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




            blkTyp=get_param(blockName,'BlockType');
            if slfeature('STVariantsInHDL')>0&&strcmp(blkTyp,'VariantMerge')
                [functionName,inputVar,outputVar,body]=...
                internal.ml2pir.variantmerge.FunctionInfoRegistryCache.createVariantMergeFunction(hC);
            else
                error('unsupported block type');
            end
            scriptText=internal.ml2pir.variantmerge.FunctionInfoRegistryCache.Expr2Func(functionName,inputVar,outputVar,body);


            uniqueId=replace(blockName,'/','_');
            fcnTypeInfo=internal.mtree.FunctionTypeInfo(...
            functionName,functionName,uniqueId,[],scriptText,'',[]);
            fcnTypeInfo.isDesign=true;



            internal.ml2pir.variantmerge.FunctionInfoRegistryCache.setInputTypes(...
            blockName,inputVar,fcnTypeInfo);
            internal.ml2pir.variantmerge.FunctionInfoRegistryCache.setOutputTypes(...
            hC,fcnTypeInfo);






            coder.internal.FcnInfoRegistryBuilder.assignVariableSpecializationNames(fcnTypeInfo);
            fcnInfoRegistry.addFunctionTypeInfo(fcnTypeInfo);


            try
                internal.ml2pir.variantmerge.ConstAnnotator.run(fcnInfoRegistry);
            catch ex
                internal.mtree.utils.errorWithContext(ex,'Constant folding error: ');
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

        function[functionName,inputVar,outputVar,body]=createVariantMergeFunction(hC)
            if slfeature('STVariantsInHDL')==0
                return;
            end
            inSignals=hC.PirInputSignals;
            functionName='fcn_internal_vss';
            [slvarUsed,inputVar]=slInternal('getVariantSSInfoForHDL',hC.Owner.SimulinkHandle);
            assert(~slvarUsed);
            numOfChoiceBlks=length(inSignals);
            listOfExpr{numOfChoiceBlks}=[];
            for index=1:numOfChoiceBlks
                hDriver=inSignals(index).getDrivers;




                if(strcmp(get_param(hDriver.Owner.OrigModelHandle,'BlockType'),'Ground'))
                    listOfExpr{index}='(default)';
                else
                    listOfExpr{index}=get_param(hDriver.Owner.SimulinkHandle,'VariantControl');
                end
            end




            negatedCond='';
            for index=1:length(listOfExpr)
                if strcmp(listOfExpr{index},'(default)')
                    continue;
                end
                negatedCond=[negatedCond,' || (',listOfExpr{index},')'];%#ok<AGROW>
            end
            negatedCond(1:4)='';
            negatedCond=['~(',negatedCond,')'];


            for index=1:length(listOfExpr)
                if strcmp(listOfExpr{index},'(default)')
                    listOfExpr{index}=negatedCond;
                    break;
                end
            end
            bitLength=num2str(ceil(log2(numel(inSignals)+1)));
            fcnBodyStr=['if ',listOfExpr{1},newline,'SL_VAR_HDL_OUT = fi(1,0,',bitLength,',0);'];
            for index=2:numOfChoiceBlks
                fcnBodyStr=[fcnBodyStr,'elseif ',listOfExpr{index},newline,'SL_VAR_HDL_OUT = fi(',num2str(index),',0,',bitLength,',0);',newline];%#ok<AGROW>
            end
            fcnBodyStr=[fcnBodyStr,'else',newline,'SL_VAR_HDL_OUT = fi(0, 0,',bitLength,',0);'];
            outputVar={'SL_VAR_HDL_OUT'};
            body={fcnBodyStr};
        end

        function setInputTypes(blockName,inputVars,fcnTypeInfo)

            for index=1:numel(inputVars)
                val=internal.ml2pir.variantmerge.FunctionInfoRegistryCache.resolveWkspVar(inputVars{index},blockName);
                pirType=internal.mtree.Type.fromValue(val).toPIRType;

                internal.ml2pir.variantmerge.FunctionInfoRegistryCache.fillInferredInfo(...
                fcnTypeInfo,inputVars{index},pirType,'inputVar');
            end
        end

        function setOutputTypes(hC,fcnTypeInfo)
            numBits=ceil(log2(numel(hC.PirInputSignals)+1));

            internal.ml2pir.variantmerge.FunctionInfoRegistryCache.fillInferredInfo(...
            fcnTypeInfo,'SL_VAR_HDL_OUT',pir_unsigned_t(numBits),'outputVar');
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
                else
                    argSize=[1,1];
                end
                isCoderConst=false;

                ml2pirType=internal.mtree.Type.fromPIRType(pirType);
                if ml2pirType.isFi
                    inferredInfo.Class='embedded.fi';
                    inferredInfo.NumericType=ml2pirType.Numerictype;
                    inferredInfo.FiMath=ml2pirType.Fimath;
                else
                    inferredInfo.Class=ml2pirType.getMLName;
                end
            else
                argSize=size(val);
                isCoderConst=true;

                inferredInfo.Class=class(val);
            end


            inferredInfo.Size=uint32(reshape(argSize,2,1));



            varLogInfo=internal.mtree.FcnInfoRegistryBuilder.buildVarLogInfo(var,nodeTypeName,1,inferredInfo,{},{});




            varTypeInfo=coder.internal.VarTypeInfo(varLogInfo,inferredInfo,isCoderConst);


            fcnTypeInfo.addVarInfo(var,varTypeInfo);
        end

        function val=resolveWkspVar(wkspVar,blockName)
            try
                val=internal.ml2pir.variantmerge.FunctionInfoRegistryCache.resolveVarRecursively(wkspVar,blockName);
            catch me
                if strcmp(me.identifier,'Simulink:Data:SlResolveNotResolved')




                    val=[];
                else
                    throw(me);
                end
            end
        end





        function returnVar=resolveVarRecursively(variantVar,blk)
            variable=slResolve(variantVar,blk,'variable');


            if isa(variable,'Simulink.Parameter')
                if strcmp(variable.DataType,'auto')
                    returnVar=variable.Value;
                else
                    returnVar=eval([variable.DataType,'(',num2str(variable.Value),');']);
                end


            elseif~isa(variable,'Simulink.VariantControl')
                returnVar=variable;
            elseif~isa(variable.Value,'Simulink.Parameter')
                returnVar=variable.Value;
            else
                returnVar=resolveVarRecursively(variable.Value,blk);
            end
        end
    end
end


