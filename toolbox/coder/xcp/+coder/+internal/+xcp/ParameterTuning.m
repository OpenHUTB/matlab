























classdef ParameterTuning<handle
    properties(SetAccess=private)
tgtconn
MemUnitTransformer
BytesPerMultiWordChunk
CodeDescriptor
NumBitsPerDouble
IsPurelyIntegerCode
setparams
    end

    methods(Access=public)
        function this=ParameterTuning(tgtconn,bytesPerMultiWordChunk,codeDescDir)
            this.tgtconn=tgtconn;

            this.MemUnitTransformer=tgtconn.MemUnitTransformer;
            this.CodeDescriptor=coder.internal.getCodeDescriptorInternal(codeDescDir,247362);

            assert(ismember(bytesPerMultiWordChunk,[4,8]),...
            'Only 32 or 64-bit chunks are supported for multi-word fixed point data types');
            this.BytesPerMultiWordChunk=bytesPerMultiWordChunk;
            this.NumBitsPerDouble=64;
            this.IsPurelyIntegerCode=false;
            this.setparams=[];
        end

        function setPurelyIntegerCode(this,isTargetIntegerCode)
            this.IsPurelyIntegerCode=isTargetIntegerCode;
        end

        function isParamTuningSupported=checkParamTuningSupported(this,val,fullParamName,paramTypeName)
            if((strcmp(paramTypeName,'double')||strcmp(paramTypeName,'single'))&&...
                this.IsPurelyIntegerCode)
                DAStudio.error('coder_xcp:host:TuningFloatingPointNotSupportedInPurelyIntegerCode',...
                fullParameterName);
            end


            isParamTuningSupported=~isstruct(val);

            if~isParamTuningSupported
                MSLDiagnostic('coder_xcp:host:StructParamDataTypeTuningNotSupported',fullParamName).reportAsWarning;
            end
        end

        function setNumBitsPerDouble(this,value)
            this.NumBitsPerDouble=value;
        end

        function targetDouble=convertToTargetDouble(this,val,paramName)

            if(~any(this.NumBitsPerDouble==[32,64]))
                DAStudio.error('coder_xcp:host:InvalidDoubleSizeParameter',...
                paramName);
            end



            if(this.NumBitsPerDouble==32)
                targetDouble=single(val);
                MSLDiagnostic('coder_xcp:host:XcpConvertedSimulinkDoubleToTargetDouble',paramName).reportAsWarning;
            else
                targetDouble=val;
            end
        end

        function setParam(this,blockPath,paramName,val)


            param=this.getParameterInfoFromCodeDescriptor(this.CodeDescriptor,blockPath,paramName);
            if isempty(param)
                MSLDiagnostic('coder_xcp:host:ParamNotFound',...
                paramName).reportAsWarning;
                return;
            end


            invalid=false;
            if param.isFixedPoint
                if~isfi(val)||...
                    param.fxpSlopeAdjFactor~=val.SlopeAdjustmentFactor||...
                    param.fxpFractionLength~=val.FractionLength||...
                    param.fxpBias~=val.Bias||...
                    param.fxpWordLength~=val.WordLength||...
                    param.fxpFixedExponent~=val.FixedExponent||...
                    param.fxpSignedness~=val.Signed
                    invalid=true;
                end
            elseif param.isEnum
                if~isenum(val)||...
                    ~strcmp(param.enumClassName,class(val))
                    invalid=true;
                end
            elseif param.isString
                if~isstring(val)
                    invalid=true;
                end






                if(strlength(val)>=param.dataTypeSize)


                    val=extractBefore(val,param.dataTypeSize);
                end

            elseif param.isHalf
                if~isa(val,'half')
                    invalid=true;
                else
                    val=val.storedInteger;
                end
            else
                typename=this.convertDataTypeIDToString(param.dataTypeID);
                if~strcmp(typename,class(val))
                    invalid=true;
                end
            end
            if param.isComplex&&isreal(val)
                invalid=true;
            end

            if(isvector(val))
                if(param.dimensions~=length(val))
                    invalid=true;
                end
            else
                if any(param.dimensions~=size(val))
                    invalid=true;
                end
            end
            if invalid
                DAStudio.error('coder_xcp:host:ParamInvalidValue',...
                paramName,blockPath);
            end



            if isfi(val)
                val=this.getFixedPointStoredIntegersForDownload(val);
            elseif isenum(val)
                type=Simulink.data.getEnumTypeInfo(class(val),'StorageType');
                if strcmp(type,'int')






                    type=param.enumClassification;
                end
                val=cast(val,type);
            elseif islogical(val)
                val=cast(val,'uint8');
            elseif isstring(val)
                val=cast(val.char,'uint8');
            end

            if(isa(val,'double'))

                val=this.convertToTargetDouble(val,paramName);
            end



            bytes=this.getByteArray(val);

            if param.isString

                bytes=[bytes,uint8(0)];
            end


            if~isempty(this.MemUnitTransformer)
                underlyingType=class(val);
                bytes=this.MemUnitTransformer.transform(...
                underlyingType,...
                coder.internal.connectivity.MemUnitTransformDirection.OUTBOUND,...
                bytes);
            end



            [targetAddress,targetAddressExtension]=...
            coder.internal.xcp.XCPTargetHandler.getXcpAddress(param.targetAddress,param.targetSymbolName);
            this.setparams=[this.setparams,struct('address',targetAddress,...
            'addressExtension',targetAddressExtension,...
            'bytes',bytes)];
        end

        function tuneParams(this)
            for i=1:length(this.setparams)
                this.tgtconn.writeData(this.setparams(i).address,...
                this.setparams(i).addressExtension,...
                this.setparams(i).bytes);
            end



            this.clearParams;
        end

        function clearParams(this)
            this.setparams=[];
        end

        function val=getParam(this,blockPath,paramName)




            param=this.getParameterInfoFromCodeDescriptor(this.CodeDescriptor,blockPath,paramName);
            if isempty(param)
                MSLDiagnostic('coder_xcp:host:ParamNotFound',...
                paramName).reportAsWarning;
                val=[];
                return;
            end




            needsMultiWordTransform=this.getParamNeedsMultiWordTransform(param);
            if needsMultiWordTransform
                targetNumChunksPerElement=ceil(double(param.fxpWordLength)/double(8*this.BytesPerMultiWordChunk));
                param.dataTypeSize=targetNumChunksPerElement*double(this.BytesPerMultiWordChunk);
            end




            numbytes=prod(param.dimensions)*param.dataTypeSize;
            if param.isComplex
                numbytes=2*numbytes;
            end

            [targetAddress,targetAddressExtension]=...
            coder.internal.xcp.XCPTargetHandler.getXcpAddress(param.targetAddress,param.targetSymbolName);
            bytes=uint8(this.tgtconn.readData(targetAddress,targetAddressExtension,numbytes));




            typename=this.convertDataTypeIDToString(param.dataTypeID);
            if param.isFixedPoint
                if param.fxpBias==0
                    fptype=fixdt(param.fxpSignedness,param.fxpWordLength,param.fxpFractionLength);
                else
                    fptype=fixdt(param.fxpSignedness,param.fxpWordLength,param.fxpSlopeAdjFactor,param.fxpFixedExponent,param.fxpBias);
                end
                val=fi(0,fptype);
                val.simulinkarray=this.getStoredIntegerForFixDt(param,bytes);
            elseif param.isEnum
                values=this.doInboundTransformAndTypeCast(bytes,param.enumClassification);









                val=feval(param.enumClassName,values);

            elseif strcmp(typename,'logical')

                values=this.doInboundTransformAndTypeCast(bytes,'logical');
                val=logical(values);

            elseif param.isString

                values=this.doInboundTransformAndTypeCast(bytes,'uint8');
                val=string(deblank(char(values)));

            else

                val=this.doInboundTransformAndTypeCast(bytes,typename);
            end

            if param.isComplex


                allvals=val;
                val=val(1);
                for x=1:prod(param.dimensions)
                    avx=2*x-1;
                    val(x)=complex(allvals(avx),allvals(avx+1));
                end
            end

            sz=size(param.dimensions);
            if max(sz)>1
                val=reshape(val,param.dimensions);
            end
        end
    end

    methods(Access=private)
        function typedVal=doInboundTransformAndTypeCast(this,bytes,typeName)
            if~isempty(this.MemUnitTransformer)
                bytes=this.MemUnitTransformer.transform(...
                typeName,...
                coder.internal.connectivity.MemUnitTransformDirection.INBOUND,...
                bytes);
            end
            if strcmp(typeName,'logical')
                typedVal=logical(bytes);
            else
                typedVal=typecast(bytes,typeName);
            end
        end

        function val=getFixedPointStoredIntegersForDownload(this,val)
            isMultiWordFixedAndNeedsTransform=...
            this.BytesPerMultiWordChunk~=8&&...
            (val.WordLength>8*this.BytesPerMultiWordChunk);
            if isMultiWordFixedAndNeedsTransform


                val=coder.internal.xcp.multiWordFixedPointOutboundTransform(...
                this.BytesPerMultiWordChunk,...
                val);
            else
                val=val.interleavedsimulinkarray;
            end
        end

        function ret=getParamNeedsMultiWordTransform(this,param)
            ret=param.isFixedPoint&&...
            this.BytesPerMultiWordChunk~=8&&...
            param.dataTypeSize>this.BytesPerMultiWordChunk;
        end

        function type=getStoredIntegerTypeForFixDt(this,param)
            if this.getParamNeedsMultiWordTransform(param)
                type='uint32';
            elseif param.dataTypeSize==1
                if param.fxpSignedness
                    type='int8';
                else
                    type='uint8';
                end
            elseif param.dataTypeSize==2
                if param.fxpSignedness
                    type='int16';
                else
                    type='uint16';
                end
            elseif param.dataTypeSize==4
                if param.fxpSignedness
                    type='int32';
                else
                    type='uint32';
                end
            elseif param.dataTypeSize==8
                if param.fxpSignedness
                    type='int64';
                else
                    type='uint64';
                end
            else

                type='uint64';
            end
        end

        function storedInteger=getStoredIntegerForFixDt(this,param,bytes)
            type=this.getStoredIntegerTypeForFixDt(param);
            if this.getParamNeedsMultiWordTransform(param)


                chunks=this.doInboundTransformAndTypeCast(bytes,type)';


                hostNumChunksPerElement=ceil(double(param.fxpWordLength)/64);
                hostDataTypeSize=hostNumChunksPerElement*8;
                hostChunks=coder.internal.xcp.multiWordFixedPointInboundTransform(...
                param.dataTypeSize,...
                hostDataTypeSize,...
                chunks);
                storedInteger=hostChunks;
            else
                storedInteger=this.doInboundTransformAndTypeCast(bytes,type)';
            end
        end
    end

    methods(Static,Access=private)
        function param=getDataInterfaceIfMatches(paramName,dataInterface)
            if strcmp(paramName,dataInterface.GraphicalName)
                param=dataInterface;
            else
                param=[];
            end
        end

        function typename=convertDataTypeIDToString(id)



            switch(id)
            case 0
                typename='double';
            case 1
                typename='single';
            case 2
                typename='int8';
            case 3
                typename='uint8';
            case 4
                typename='int16';
            case 5
                typename='uint16';
            case 6
                typename='int32';
            case 7
                typename='uint32';
            case 8
                typename='logical';
            otherwise
                typename='';
            end
        end

        function bytes=getByteArray(val)
            if isreal(val)
                bytes=typecast(reshape(val,1,numel(val)),'uint8');
            else
                reals=reshape(real(val),1,numel(real(val)));
                imags=reshape(imag(val),1,numel(imag(val)));
                bytes=[];
                for i=1:length(reals)
                    bytes=[bytes,typecast(reals(i),'uint8'),typecast(imags(i),'uint8')];%#ok
                end
            end
        end
    end

    methods(Static,Access=public)
        function param=getParameterInfoFromCodeDescriptor(codeDescriptor,blockPath,paramName)



            if(isempty(blockPath))


                dataIntrf=loc_getWorkspaceParameter(codeDescriptor,paramName);
            else


                dataIntrf=loc_getBlockParameter(codeDescriptor,paramName,blockPath);
            end

            if isempty(dataIntrf)
                param=[];
                return;
            end

            impl=dataIntrf.Implementation;
            if isempty(impl)||~impl.isDefined
                param=[];
                return
            end

            fullModel=codeDescriptor.getMF0FullModel();
            compiledCodeMaps=fullModel.CompiledCode;
            diSymbol=compiledCodeMaps.findDataInterfaceSymbol(dataIntrf);

            if isempty(diSymbol)||isempty(diSymbol.AddressOrOffset)



                param=[];
                return;
            end
            param.targetAddress=diSymbol.AddressOrOffset;

            t=coder.internal.xcp.processCodeDescriptorType(dataIntrf.Type,impl.Type);
            if isempty(t)

                param=[];
                return;
            end

            param.dimensions=t.dimensions;
            param.dataTypeID=t.dataTypeID;
            param.dataTypeSize=t.dataTypeSize;
            param.isEnum=t.isEnum;
            param.isFixedPoint=t.isFixedPoint;
            param.isString=t.isString;
            param.isHalf=t.isHalf;
            param.isComplex=t.isComplex;
            param.isFrame=t.isFrame;
            param.isHalf=t.isHalf;
            param.enumClassification=t.enumClassification;
            param.enumClassName=t.enumClassName;
            param.enumLabels=t.enumLabels;
            param.enumValues=t.enumValues;
            param.fxpSlopeAdjFactor=t.fxpSlopeAdjFactor;
            param.fxpNumericType=t.fxpNumericType;
            param.fxpFractionLength=t.fxpFractionLength;
            param.fxpBias=t.fxpBias;
            param.fxpWordLength=t.fxpWordLength;
            param.fxpFixedExponent=t.fxpFixedExponent;
            param.fxpSignedness=t.fxpSignedness;










            if param.isEnum&&strcmp(param.enumClassification,'int32')
                param.dataTypeSize=diSymbol.TargetSize/prod(param.dimensions);
                isSigned=any(param.enumValues<0);
                sizeInBits=param.dataTypeSize*8;
                if isSigned
                    unsignedPrefix='';
                else
                    unsignedPrefix='u';
                end
                param.enumClassification=sprintf('%s%s%d',unsignedPrefix,'int',sizeInBits);
            end
            param.targetSymbolName=impl.assumeOwnershipAndGetExpression();

        end
    end


end


function dataIntrf=loc_getWorkspaceParameter(codeDescriptor,paramName)

    dataIntrf=[];
    modelParamDataInterfaces=codeDescriptor.getDataInterfaces('Parameters');

    for x=1:numel(modelParamDataInterfaces)
        currentParam=modelParamDataInterfaces(x);
        dataIntrf=coder.internal.xcp.ParameterTuning.getDataInterfaceIfMatches(paramName,currentParam);
        if isempty(dataIntrf)&&currentParam.isLookupTableDataInterface
            for y=1:currentParam.Breakpoints.Size
                dataIntrf=coder.internal.xcp.ParameterTuning.getDataInterfaceIfMatches(paramName,...
                currentParam.Breakpoints(y));
                if~isempty(dataIntrf)
                    break;
                end
            end
        end
        if~isempty(dataIntrf)
            break;
        end
    end
end

function dataIntrf=loc_getBlockParameter(codeDescriptor,paramName,blockPath)

    dataIntrf=[];






    bp=coder.internal.xcp.getBlockParameter(codeDescriptor,blockPath,paramName);
    if isempty(bp)
        return;
    end


    if numel(bp)>1
        assert(all(arrayfun(@(x)isequal(x,bp(1)),bp)),'Ambiguous block parameter for %s -> %s in Code Descriptor',blockPath,paramName);
        bp=bp(1);
    end

    if bp.ModelParameters.Size==1








        dataIntrf=bp.ModelParameters.at(1).DataInterface;
    end
end
