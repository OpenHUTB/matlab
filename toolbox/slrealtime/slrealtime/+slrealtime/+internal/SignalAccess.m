







classdef SignalAccess<handle
    properties(SetAccess=private)
tgtconn
codeDescDir
    end

    methods(Access=public)
        function this=SignalAccess(tgtconn,codeDescDir)
            this.tgtconn=tgtconn;
            this.codeDescDir=codeDescDir;
        end

        function val=getSignal(this,blockPath,portIndex)




            codeDescriptor=coder.internal.getCodeDescriptorInternal(this.codeDescDir,247362);
            signal=this.getSignalInfoFromCodeDescriptor(codeDescriptor,blockPath,portIndex);
            val=this.getSignalWork(signal);
        end
    end

    methods(Access=private)

        function val=getSignalWork(this,signal)
            if signal.typeInfo.isNVBus



                valArray=[];
                for nDimEl=1:prod(signal.typeInfo.dimensions)
                    nDimElOffset=(nDimEl-1)*signal.typeInfo.dataTypeSize;

                    v=struct();
                    for nEl=1:length(signal.typeInfo.structElements)
                        el=signal.typeInfo.structElements(nEl);
                        elSignal=struct(...
                        'targetAddress',signal.targetAddress+int64(el.structElementOffset)+int64(nDimElOffset),...
                        'typeInfo',el);
                        v.(el.structElementName)=this.getSignalWork(elSignal);
                    end

                    valArray=[valArray,v];%#ok
                end

                val=valArray;
                sz=size(signal.typeInfo.dimensions);
                if max(sz)>1
                    val=reshape(val,signal.typeInfo.dimensions);
                end
            else






                numbytes=prod(signal.typeInfo.dimensions)*signal.typeInfo.dataTypeSize;
                if signal.typeInfo.isComplex
                    numbytes=2*numbytes;
                end
                bytes=uint8(this.tgtconn.upload(signal.targetAddress,numbytes));



                typename=this.convertDataTypeIDToString(signal.typeInfo.dataTypeID);
                if signal.typeInfo.isFixedPoint
                    if signal.typeInfo.fxpBias==0
                        fptype=fixdt(signal.typeInfo.fxpSignedness,signal.typeInfo.fxpWordLength,signal.typeInfo.fxpFractionLength);
                    else
                        fptype=fixdt(signal.typeInfo.fxpSignedness,signal.typeInfo.fxpWordLength,signal.typeInfo.fxpSlopeAdjFactor,signal.typeInfo.fxpFixedExponent,signal.typeInfo.fxpBias);
                    end
                    val=fi(0,fptype);
                    if signal.typeInfo.dataTypeSize==1
                        if signal.typeInfo.fxpSignedness
                            type='int8';
                        else
                            type='uint8';
                        end
                    elseif signal.typeInfo.dataTypeSize==2
                        if signal.typeInfo.fxpSignedness
                            type='int16';
                        else
                            type='uint16';
                        end
                    elseif signal.typeInfo.dataTypeSize==4
                        if signal.typeInfo.fxpSignedness
                            type='int32';
                        else
                            type='uint32';
                        end
                    else
                        if signal.typeInfo.fxpSignedness
                            type='int64';
                        else
                            type='uint64';
                        end
                    end
                    val.simulinkarray=typecast(bytes,type)';

                elseif signal.typeInfo.isHalf
                    val=half.typecast(typecast(bytes,'uint16'));

                elseif signal.typeInfo.isEnum
                    values=typecast(bytes,signal.typeInfo.enumClassification);
                    val=feval(signal.typeInfo.enumClassName,values);

                elseif strcmp(typename,'logical')
                    val=logical(bytes);

                elseif signal.typeInfo.isString
                    val=string(deblank(char(bytes)));

                else

                    val=typecast(bytes,typename);
                end

                if signal.typeInfo.isComplex


                    allvals=val;
                    val=val(1);
                    for x=1:prod(signal.typeInfo.dimensions)
                        avx=2*x-1;
                        val(x)=complex(allvals(avx),allvals(avx+1));
                    end
                end

                sz=size(signal.typeInfo.dimensions);
                if max(sz)>1
                    val=reshape(val,signal.typeInfo.dimensions);
                end
            end
        end
    end

    methods(Static,Access=public)
        function[blockPath,portIndex]=checkAndFormatArgs(blockPath,portIndex)







            if isempty(blockPath)
                slrealtime.internal.throw.Error('slrealtime:signalaccess:invalidArg');
            end
            if iscell(blockPath)
                blockPath=cellfun(@convertStringsToChars,blockPath,'UniformOutput',false);
                if any(cellfun(@isempty,blockPath))||~all(cellfun(@ischar,blockPath))
                    slrealtime.internal.throw.Error('slrealtime:signalaccess:invalidArg');
                end
                if length(blockPath)==1
                    blockPath=blockPath{1};
                end
            elseif length(blockPath)>1&&isstring(blockPath(1))
                blockPath=arrayfun(@convertStringsToChars,blockPath,'UniformOutput',false);
                if any(cellfun(@isempty,blockPath))||~all(cellfun(@ischar,blockPath))
                    slrealtime.internal.throw.Error('slrealtime:signalaccess:invalidArg');
                end
            else
                blockPath=convertStringsToChars(blockPath);
                if~ischar(blockPath)
                    slrealtime.internal.throw.Error('slrealtime:signalaccess:invalidArg');
                end
            end


            if isempty(portIndex)||~isnumeric(portIndex)||~isscalar(portIndex)||portIndex<1
                slrealtime.internal.throw.Error('slrealtime:signalaccess:invalidArg');
            else
                portIndex=double(portIndex);
            end
        end
    end

    methods(Static,Access=private)
        function signal=getSignalInfoFromCodeDescriptor(codeDescriptor,blockPath,portIndex)



            signal=struct;

            dataIntrf=[];

            cd_=codeDescriptor;
            bhm_=cd_.getBlockHierarchyMap();

            baseAddress=0;

            if iscell(blockPath)

                rtbAddress=0;
                rtdwAddress=0;
                for nBlockPathLevel=1:length(blockPath)-1
                    ps=split(blockPath{nBlockPathLevel},'/');
                    modelBlockName=ps{end};
                    blks=bhm_.getBlocksByName(modelBlockName);

                    if isempty(blks)
                        slrealtime.internal.throw.Error(...
                        'slrealtime:signalaccess:invalidBlock',...
                        blockPath{nBlockPathLevel});
                    end

                    foundIt=false;
                    for nBlk=1:length(blks)
                        if strcmp(regexprep(blockPath{nBlockPathLevel},'[\n]+',' '),regexprep(blks(nBlk).Path,'[\n]+',' '))
                            if~strcmp(blks(nBlk).Type,'ModelReference')
                                slrealtime.internal.throw.Error(...
                                'slrealtime:signalaccess:invalidBlock',...
                                blockPath{nBlockPathLevel});
                            end

                            if blks(nBlk).IsProtectedModelBlock
                                slrealtime.internal.throw.Error(...
                                'slrealtime:signalaccess:protectedModelBlock',...
                                blockPath{nBlockPathLevel});
                            end


                            if rtbAddress==0&&rtdwAddress==0


                                rtbAddress=blks(nBlk).rtbAddressOrOffset;
                                rtdwAddress=blks(nBlk).rtdwAddressOrOffset;
                            else


                                rtbAddress=rtdwAddress+blks(nBlk).rtbAddressOrOffset;
                                rtdwAddress=rtdwAddress+blks(nBlk).rtdwAddressOrOffset;
                            end

                            cd_=codeDescriptor.getReferencedModelCodeDescriptor(blks(nBlk).ReferencedModelName);
                            bhm_=cd_.getBlockHierarchyMap();

                            foundIt=true;
                            break;
                        end
                    end

                    if~foundIt
                        slrealtime.internal.throw.Error(...
                        'slrealtime:signalaccess:invalidBlock',...
                        blockPath{nBlockPathLevel});
                    end
                end

                baseAddress=rtbAddress;

                bp=blockPath{end};
            else
                bp=blockPath;
            end

            ps=split(bp,'/');
            blockName=ps{end};
            blks=bhm_.getBlocksByName(blockName);

            if isempty(blks)
                slrealtime.internal.throw.Error(...
                'slrealtime:signalaccess:invalidBlock',bp);
            end

            foundIt=false;
            for nBlk=1:length(blks)
                if strcmp(regexprep(bp,'[\n]+',' '),regexprep(blks(nBlk).Path,'[\n]+',' '))
                    if portIndex>blks(nBlk).DataOutputPorts.Size
                        slrealtime.internal.throw.Error(...
                        'slrealtime:signalaccess:invalidPortIndex',...
                        portIndex,bp);
                    end
                    port=blks(nBlk).DataOutputPorts(portIndex);

                    if port.DataInterfaces.Size~=1
                        slrealtime.internal.throw.Error(...
                        'slrealtime:signalaccess:signalNotAvailable',...
                        [bp,':',num2str(portIndex)]);
                    end

                    dataIntrf=port.DataInterfaces(1);

                    foundIt=true;
                    break;
                end
            end

            if~foundIt
                slrealtime.internal.throw.Error(...
                'slrealtime:signalaccess:invalidBlock',bp);
            end
            assert(~isempty(dataIntrf));

            impl=dataIntrf.Implementation;
            if~isempty(impl)&&impl.isDefined
                signal.typeInfo=slrealtime.internal.processCodeDescriptorType(dataIntrf.Type,impl.Type);
                signal.targetAddress=baseAddress+dataIntrf.AddressOrOffset;
            else
                slrealtime.internal.throw.Error(...
                'slrealtime:signalaccess:signalNotAvailable',...
                [bp,':',num2str(portIndex)]);
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

        function val=isDimensionsEqual(dims1,dims2)
            val=true;%#ok % assume equal

            if length(size(dims1))~=length(size(dims2))


                val=false;
                return;
            end

            dims1ScalarRowOrColumn=length(dims1)==1||(length(dims1)==2&&any(dims1==1));
            dims2ScalarRowOrColumn=length(dims2)==1||(length(dims2)==2&&any(dims2==1));
            if dims1ScalarRowOrColumn&&dims2ScalarRowOrColumn


                val=prod(dims1)==prod(dims2);
                return;
            end


            val=all(dims1==dims2);
        end
    end
end
