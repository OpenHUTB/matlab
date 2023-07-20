classdef FcnCallerHelper<handle




    properties
        ChangeLogger;
        SysConstsValueMap;
    end

    methods(Access=public)

        function this=FcnCallerHelper(changeLogger,sysConstsValueMap)
            this.ChangeLogger=changeLogger;
            this.SysConstsValueMap=sysConstsValueMap;
        end





        function syncBlk(this,blk,m3iOperation,m3iPort)
            narginchk(4,4);

            import autosar.mm.util.FcnCallerHelper;
            import autosar.mm.mm2sl.SLModelBuilder;

            if autosar.validation.ClientServerValidator.checkFcnCallerMappableToOperation(blk,m3iOperation)




                m3iArguments=m3iOperation.Arguments;
                argNames=m3i.mapcell(@(x)x.Name,m3iArguments);
                argCell=m3i.mapcell(@(x)x,m3iArguments);

                [inParams,outParams]=autosar.validation.ClientServerValidator.getBlockInOutParams(blk);

                inArgCell=argCell(ismember(argNames,inParams));
                outArgCell=argCell(ismember(argNames,outParams));

                [~,inputArgSpec]=this.getArgSpec(inArgCell,this.SysConstsValueMap);
                [~,outputArgSpec]=this.getArgSpec(outArgCell,this.SysConstsValueMap);

                SLModelBuilder.set_param(this.ChangeLogger,blk,...
                'InputArgumentSpecifications',inputArgSpec,...
                'OutputArgumentSpecifications',outputArgSpec);
            else
                [fcnPrototype,inputArgSpec,outputArgSpec]=...
                FcnCallerHelper.getFcnCallerParameters(m3iOperation,m3iPort,this.SysConstsValueMap);
                SLModelBuilder.set_param(this.ChangeLogger,blk,...
                'FunctionPrototype',fcnPrototype,...
                'InputArgumentSpecifications',inputArgSpec,...
                'OutputArgumentSpecifications',outputArgSpec);
            end
        end
    end

    methods(Static)



        function blkType=getBlkType()
            blkType='FunctionCaller';
        end




        function functionName=getDefaultFunctionName(portName,operationName)
            functionName=[portName,'_',operationName];
        end





        function createWorkspaceObjects(m3iOp,slTypeBuilder,slParameterBuilder)
            narginchk(3,3);

            for ii=1:m3iOp.Arguments.size()
                arg=m3iOp.Arguments.at(ii);
                if arg.Type.isvalid()
                    slTypeBuilder.buildType(arg.Type);
                    slTypeBuilder.createAll(slTypeBuilder.SharedWorkSpace);
                    slParameterBuilder.buildArgSpecParam(slTypeBuilder.SharedWorkSpace,arg);
                elseif strcmp(arg.Direction.toString(),'Error')
                    slTypeBuilder.buildStdReturnType();
                    slTypeBuilder.createAll(slTypeBuilder.SharedWorkSpace);
                    slParameterBuilder.buildArgSpecParam(slTypeBuilder.SharedWorkSpace,arg);
                end
            end
        end

        function dtOrArgSpec=getDataTypeOrArgumentSpec(m3iOp,sysConstsValueMap)
            import autosar.mm.util.FcnCallerHelper;

            dtOrArgSpec='';

            inArgCell=m3i.filter(@FcnCallerHelper.isInArg,m3iOp.Arguments);
            outArgCell=m3i.filter(@FcnCallerHelper.isOutArgNoERR,m3iOp.Arguments);

            [~,inputArgSpec]=FcnCallerHelper.getArgSpec(inArgCell,sysConstsValueMap);
            [~,outputArgSpec]=FcnCallerHelper.getArgSpec(outArgCell,sysConstsValueMap);

            argSpecs=[strsplit(inputArgSpec,','),strsplit(outputArgSpec,',')];
            argSpecs=argSpecs(cellfun(@(x)~isempty(x),argSpecs));
            if~isempty(argSpecs)
                dtOrArgSpec=argSpecs{1};
            end
        end




        function[fcnPrototype,inputArgSpec,outputArgSpec]=...
            getFcnCallerParameters(m3iOp,m3iPort,sysConstsValueMap)
            import autosar.mm.util.FcnCallerHelper;

            narginchk(3,3);

            inArgCell=m3i.filter(@FcnCallerHelper.isInArg,m3iOp.Arguments);
            outArgCell=m3i.filter(@FcnCallerHelper.isOutArg,m3iOp.Arguments);

            [inputArgProto,inputArgSpec]=FcnCallerHelper.getArgSpec(inArgCell,sysConstsValueMap);
            [outputArgProto,outputArgSpec,numOutputArgs]=FcnCallerHelper.getArgSpec(outArgCell,sysConstsValueMap);

            if numOutputArgs>1
                outputArgProto=sprintf('[%s]',outputArgProto);
            end

            if numOutputArgs>0
                outputArgProto=sprintf('%s = ',outputArgProto);
            end

            if autosar.mm.util.FcnCallerHelper.usesFunctionPorts(m3iPort)
                functionName=[m3iPort.Name,'.',m3iOp.Name];
            else
                functionName=autosar.mm.util.FcnCallerHelper.getDefaultFunctionName(m3iPort.Name,m3iOp.Name);
            end
            fcnPrototype=sprintf('%s%s(%s)',outputArgProto,functionName,inputArgProto);
        end
    end

    methods(Static,Access=private)
        function usesFcnPorts=usesFunctionPorts(m3iPort)
            usesFcnPorts=(isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceRequiredPort'));
        end



        function[argProto,argSpec,numArgs]=getArgSpec(argCell,sysConstsValueMap)
            argProto='';
            argSpec='';
            numArgs=0;

            argProtoSep='';
            argSpecSep='';
            for ii=1:length(argCell)
                arg=argCell{ii};
                if~arg.Type.isvalid()
                    switch arg.Direction.toString()
                    case 'Error'
                        paramStr=sprintf('P_%s','Std_ReturnType');
                    otherwise

                        paramStr='double(1)';
                    end
                else


                    bottomType=autosar.mm.mm2sl.TypeBuilder.getUnderlyingType(arg.Type);
                    if autosar.mm.util.BuiltInTypeMapper.isARBuiltIn(arg.Type)||...
                        autosar.mm.util.BuiltInTypeMapper.isARBuiltIn(bottomType)
                        switch class(arg.Type)
                        case 'Simulink.metamodel.types.Integer'
                            if arg.Type.IsSigned
                                typeCast='int';
                            else
                                typeCast='uint';
                            end
                            paramStr=sprintf('%s(1)',[typeCast,num2str(arg.Type.Length.value)]);
                        case 'Simulink.metamodel.types.Boolean'
                            paramStr='boolean(true)';
                        case 'Simulink.metamodel.types.FloatingPoint'
                            if arg.Type.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Single
                                kindStr='single';
                            else
                                kindStr='double';
                            end
                            paramStr=sprintf('%s(1)',kindStr);
                        case 'Simulink.metamodel.types.Matrix'
                            if~isequal(arg.Type.BaseType,bottomType)
                                paramStr=sprintf('P_%s',arg.Type.Name);
                            elseif isa(bottomType,'Simulink.metamodel.types.Integer')
                                if bottomType.IsSigned
                                    typeCast='int';
                                else
                                    typeCast='uint';
                                end
                                paramStr=sprintf('%s([',[typeCast,num2str(bottomType.Length.value)]);
                                dims=autosar.mm.mm2sl.TypeBuilder.getSLDimensions(arg.Type);
                                for idim=1:dims.evaluated()
                                    paramStr=sprintf('%s1;',paramStr);
                                end
                                paramStr=sprintf('%s])',paramStr(1:end-1));
                            else
                                if isa(bottomType,'Simulink.metamodel.types.FloatingPoint')&&...
                                    bottomType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Single
                                    kindStr='single';
                                else
                                    kindStr=lower(bottomType.Name);
                                end
                                paramDim=autosar.mm.mm2sl.TypeBuilder.getSLDimensions(arg.Type,sysConstsValueMap);
                                paramStr=sprintf('%s(ones(%i,1))',kindStr,paramDim.evaluated);
                            end
                        otherwise
                            assert(false,'Unsupported type.');
                        end
                    else
                        if isa(bottomType,'Simulink.metamodel.types.Enumeration')
                            if isa(arg.Type,'Simulink.metamodel.types.Matrix')
                                paramDim=autosar.mm.mm2sl.TypeBuilder.getSLDimensions(arg.Type,sysConstsValueMap);
                                paramStr=sprintf('repmat(%s(%d), 1, %d)',bottomType.Name,bottomType.DefaultValue,...
                                paramDim.evaluated());
                            else
                                paramStr=sprintf('%s(%d)',arg.Type.Name,arg.Type.DefaultValue);
                            end
                        else
                            paramStr=sprintf('P_%s',arg.Type.Name);
                        end
                    end
                end
                argProto=sprintf('%s%s%s',argProto,argProtoSep,arg.Name);
                argSpec=sprintf('%s%s%s',argSpec,argSpecSep,paramStr);
                argProtoSep=',';
                argSpecSep=', ';
                numArgs=numArgs+1;
            end

            argProto=sprintf('%s',argProto);
        end


        function isInArg=isInArg(arg)
            switch arg.Direction.toString()
            case{'In','InOut'}
                isInArg=true;
            case{'Out','Error'}
                isInArg=false;
            otherwise
                assert(false,'Did not recognize direction');
            end
        end

        function isOutArg=isOutArg(arg)
            switch arg.Direction.toString()
            case{'Out','InOut','Error'}
                isOutArg=true;
            case 'In'
                isOutArg=false;
            otherwise
                assert(false,'Did not recognize direction');
            end
        end

        function isOutArg=isOutArgNoERR(arg)
            switch arg.Direction.toString()
            case{'Out','InOut'}
                isOutArg=true;
            case{'In','Error'}
                isOutArg=false;
            otherwise
                assert(false,'Did not recognize direction');
            end
        end

    end
end


