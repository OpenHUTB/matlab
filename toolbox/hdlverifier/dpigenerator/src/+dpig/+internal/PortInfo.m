classdef PortInfo<handle
    properties
DataType
StructInfo
StructFieldInfo
IsComplex
IsEnum
DataTypeSize
Dim
Name
MultiRateCounter
SamplePeriod
SampleOffset
NormalizedSamplePeriod
IsMultirate
FlatNumPorts
DPIPortsDataType
DPIFixedPointInterfaceMarshallingObj
FlatNamePrefix
    end

    properties(Access=private)

ForLoopBegin
ForLoopEnd
FlattenedIndexing
ExtraDimOffsetDueToBitRepresentation

        EnumInfo=struct('EnumType','',...
        'EnumUnderlyingType','',...
        'EnumStrVals',{},...
        'EnumIntVals',[]);



        SVStructAccessId;
    end

    properties(Dependent)
SVDataType
    end

    properties(Access=protected,Dependent)

IsPortPassedByValueFromInterface
DoesPortRequireMarshalling
IsPortAnArray
IsArrayOfStructs
    end

    properties(Access=private,Dependent)

IsPortAnArrayField_ThatBelongsToStructArray
IsPortAScalarField_ThatBelongsToStructArray
IsPortAnArrayField_ThatBelongsToStruct
IsPortAScalarField_ThatBelongsToStruct

IsComplexVector
    end

    methods
        function obj=PortInfo(rtwVarInfo,PortFlatNamePrefix,PortFlatNameIdentifier,StructFieldInfo,Dimensions,DPITB_FlattenedDim,MultirateCounterName,IsComplex)
            if nargin==0

                obj.StructInfo=containers.Map;
                return;
            end
            obj.StructInfo=containers.Map;

            if rtwVarInfo.isNumeric
                cs=getActiveConfigSet(bdroot);
                IsNonFloating=~(rtwVarInfo.isDouble||rtwVarInfo.isSingle||rtwVarInfo.isHalf);
                if strcmpi(cs.getPropOwner('DPIFixedPointDataType').getProp('DPIFixedPointDataType'),'BitVector')&&IsNonFloating
                    obj.DPIPortsDataType='BitVector';
                    obj.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(obj.DPIPortsDataType,rtwVarInfo.WordLength,rtwVarInfo.Identifier,Dimensions);
                elseif strcmpi(cs.getPropOwner('DPIFixedPointDataType').getProp('DPIFixedPointDataType'),'LogicVector')&&IsNonFloating
                    obj.DPIPortsDataType='LogicVector';
                    obj.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(obj.DPIPortsDataType,rtwVarInfo.WordLength,rtwVarInfo.Identifier,Dimensions);
                else
                    obj.DPIPortsDataType='CompatibleCType';
                    obj.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(obj.DPIPortsDataType,nan,'',nan);
                end
                obj.DataType=rtwVarInfo.Identifier;
                obj.StructInfo={};
                obj.StructFieldInfo={};
                obj.IsComplex=IsComplex;
                obj.IsEnum=false;
                obj.DataTypeSize=rtwVarInfo.WordLength;
                obj.Dim=Dimensions;
            elseif rtwVarInfo.isComplex


                n_getFieldStructInfo('internal');
                obj.DataType=rtwVarInfo.Identifier;



                if isempty(PortFlatNamePrefix)
                    Delim='';
                else
                    Delim='_';
                end


                obj.StructInfo(num2str(1))=dpig.internal.PortInfo(rtwVarInfo.BaseType,[PortFlatNamePrefix,Delim,PortFlatNameIdentifier],'re',StructFieldInfo,1,DPITB_FlattenedDim,MultirateCounterName,true);

                obj.StructInfo(num2str(2))=dpig.internal.PortInfo(rtwVarInfo.BaseType,[PortFlatNamePrefix,Delim,PortFlatNameIdentifier],'im',StructFieldInfo,1,DPITB_FlattenedDim,MultirateCounterName,true);

                obj.StructFieldInfo={};
                obj.IsComplex=true;
                obj.IsEnum=false;
                obj.DataTypeSize=rtwVarInfo.BaseType.WordLength;
                obj.Dim=Dimensions;
            elseif rtwVarInfo.isStructure

                n_getFieldStructInfo('internal');
                obj.DataType=rtwVarInfo.Identifier;
                for idx=1:numel(rtwVarInfo.Elements)
                    if isempty(PortFlatNamePrefix)
                        Delim='';
                    else
                        Delim='_';
                    end
                    Temp_StructInfo=dpig.internal.PortInfo(rtwVarInfo.Elements(idx).Type,[PortFlatNamePrefix,Delim,PortFlatNameIdentifier],rtwVarInfo.Elements(idx).Identifier,StructFieldInfo,1,DPITB_FlattenedDim,MultirateCounterName,IsComplex);
                    obj.StructInfo(num2str(idx))=Temp_StructInfo;
                end


                obj.StructFieldInfo={};
                obj.IsComplex=false;
                obj.IsEnum=false;
                obj.DataTypeSize=8;
                obj.Dim=Dimensions;
            elseif rtwVarInfo.isEnum
                obj.DPIPortsDataType='CompatibleCType';
                obj.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(obj.DPIPortsDataType,nan,'',nan);
                obj.DataType=l_getEnumUnderlyingType(rtwVarInfo.Identifier,'C',any(rtwVarInfo.Values<0));
                obj.StructInfo={};
                obj.StructFieldInfo={};
                obj.IsComplex=false;
                obj.DataTypeSize=32;
                obj.Dim=Dimensions;
                obj.IsEnum=true;
                obj.EnumInfo=struct('EnumType',rtwVarInfo.Identifier,...
                'EnumUnderlyingType',l_getEnumUnderlyingType(rtwVarInfo.Identifier,'SV',any(rtwVarInfo.Values<0)),...
                'EnumStrVals',{rtwVarInfo.Strings'},...
                'EnumIntVals',rtwVarInfo.Values);
            else
                obj=dpig.internal.PortInfo(rtwVarInfo.BaseType,PortFlatNamePrefix,PortFlatNameIdentifier,StructFieldInfo,int32(obj.getScalarDim(rtwVarInfo.Dimensions)),DPITB_FlattenedDim,MultirateCounterName,IsComplex);
                return;
            end
            obj.Name=PortFlatNameIdentifier;
            obj.FlatNamePrefix=PortFlatNamePrefix;
            obj.MultiRateCounter=MultirateCounterName;




            if isempty(obj.StructInfo)&&~isempty(StructFieldInfo.TopStructType)


                n_getFieldStructInfo('leaf');
                obj.StructFieldInfo=StructFieldInfo;

                DPITB_FlattenedDimTemp=DPITB_FlattenedDim('FlattenedDimensions');
                DPITB_FlattenedDim('FlattenedDimensions')=[DPITB_FlattenedDimTemp,prod([obj.StructFieldInfo.TopStructDim,obj.Dim])];%#ok<NASGU>
            elseif isempty(obj.StructInfo)


                DPITB_FlattenedDimTemp=DPITB_FlattenedDim('FlattenedDimensions');
                DPITB_FlattenedDim('FlattenedDimensions')=[DPITB_FlattenedDimTemp,obj.Dim];%#ok<NASGU>
            end


            function n_getFieldStructInfo(Location)

                StructFieldInfo.TopStructName=[StructFieldInfo.TopStructName,PortFlatNameIdentifier];

                if strcmp(Location,'leaf')

                    StructFieldInfo.TopStructDim=[StructFieldInfo.TopStructDim,1];
                else
                    StructFieldInfo.TopStructDim=[StructFieldInfo.TopStructDim,Dimensions];
                end

                TempElementAccessIndexNumber=StructFieldInfo.ElementAccessIndexNumber;

                if isempty(TempElementAccessIndexNumber)
                    TempElementAccessIndexNumber=0;
                end
                TempTopStructDim=StructFieldInfo.TopStructDim;






                if isempty(StructFieldInfo.TopStructFlatName)


                    StructFieldInfo.TopStructFlatName=[StructFieldInfo.TopStructFlatName,[PortFlatNamePrefix,'_',PortFlatNameIdentifier,'_Ptr']];

                    if TempTopStructDim(end)==1


                        TempTopStructName=['(*',StructFieldInfo.TopStructFlatName{1},')'];
                    else


                        TempTopStructName=StructFieldInfo.TopStructFlatName{1};
                    end
                else


                    StructFieldInfo.TopStructFlatName=[StructFieldInfo.TopStructFlatName,''];

                    TempTopStructName=StructFieldInfo.TopStructName{end};
                end

                TempElementAccess=StructFieldInfo.ElementAccess;

                if isempty(TempElementAccess)
                    TempElementAccess={''};
                end


                if strcmp(Location,'leaf')
                    StructFieldInfo.ElementAccessIndexNumber=[StructFieldInfo.ElementAccessIndexNumber,TempElementAccessIndexNumber(end)];
                    StructFieldInfo.TopStructIndexing=[StructFieldInfo.TopStructIndexing,{''}];
                    StructFieldInfo.ElementAccess=[StructFieldInfo.ElementAccess,[TempElementAccess{end},TempTopStructName]];
                    StructFieldInfo.ElementAccessIndexVariable=[StructFieldInfo.ElementAccessIndexVariable,{''}];
                elseif TempTopStructDim(end)==1
                    StructFieldInfo.ElementAccessIndexNumber=[StructFieldInfo.ElementAccessIndexNumber,TempElementAccessIndexNumber(end)];
                    StructFieldInfo.TopStructIndexing=[StructFieldInfo.TopStructIndexing,{''}];
                    StructFieldInfo.ElementAccess=[StructFieldInfo.ElementAccess,[TempElementAccess{end},TempTopStructName,'.']];
                    StructFieldInfo.ElementAccessIndexVariable=[StructFieldInfo.ElementAccessIndexVariable,{''}];
                else
                    StructFieldInfo.ElementAccessIndexNumber=[StructFieldInfo.ElementAccessIndexNumber,TempElementAccessIndexNumber(end)+1];
                    StructFieldInfo.TopStructIndexing=[StructFieldInfo.TopStructIndexing,['[',num2str(TempTopStructDim(end)),']']];
                    StructFieldInfo.ElementAccess=[StructFieldInfo.ElementAccess,[TempElementAccess{end},...
                    TempTopStructName,...
                    '[idx',num2str(TempElementAccessIndexNumber(end)),'].']];
                    StructFieldInfo.ElementAccessIndexVariable=[StructFieldInfo.ElementAccessIndexVariable,{['idx',num2str(TempElementAccessIndexNumber(end))]}];
                end
                StructFieldInfo.TopStructType=[StructFieldInfo.TopStructType,rtwVarInfo.Identifier];
            end
        end

        function val=get.ForLoopBegin(obj)
            [val,~,~]=obj.getFlattenedArrayOfStructsIndexing();
        end

        function val=get.FlattenedIndexing(obj)
            [~,val,~]=obj.getFlattenedArrayOfStructsIndexing();
        end

        function val=get.ForLoopEnd(obj)
            [~,~,val]=obj.getFlattenedArrayOfStructsIndexing();
        end

        function val=getSVEnumDecl(obj)
            val='';
            EnumAccum='';
            if obj.IsEnum
                cellfun(@(EStr,EVal)n_EnumAccum(EStr,EVal),obj.EnumInfo.EnumStrVals,num2cell(obj.EnumInfo.EnumIntVals));
                val=sprintf('typedef enum %s {%s} %s;',obj.EnumInfo.EnumUnderlyingType,EnumAccum(1:end-1),obj.EnumInfo.EnumType);
            end
            function n_EnumAccum(EStr_,EVal_)
                switch obj.EnumInfo.EnumUnderlyingType
                case{'byte','byte unsigned'}
                    BitWidth=8;
                case{'shortint','shortint unsigned'}
                    BitWidth=16;
                case{'int','int unsigned'}
                    BitWidth=32;
                end

                if EVal_<0
                    EnumAccum=sprintf('%s%s=-%d''d%d,',EnumAccum,EStr_,BitWidth,abs(EVal_));
                else
                    EnumAccum=sprintf('%s%s=%d''d%d,',EnumAccum,EStr_,BitWidth,EVal_);
                end


            end
        end

        function val=getSVEnumType(obj)
            val='';
            if obj.IsEnum
                val=obj.EnumInfo.EnumType;
            end
        end
        function val=getIsArrayOfStructsVal(obj)
            val=obj.IsArrayOfStructs;
        end

    end

    methods

        function val=get.SVDataType(obj)
            val='';
            if~isempty(obj.StructInfo)
                val=obj.DataType;
                return;
            end

            if any(strcmpi(obj.DPIPortsDataType,{'BitVector','LogicVector'}))

                if strcmpi(obj.DataType(1),'u')||strcmpi(obj.DataType(1:4),'bool')
                    SignedKeyword='';
                else
                    SignedKeyword='signed ';
                end


                VectorSize=['[',num2str(obj.DataTypeSize-1),':0]'];



            end

            if strcmpi(obj.DPIPortsDataType,'BitVector')
                val=['bit ',SignedKeyword,VectorSize];
            elseif strcmpi(obj.DPIPortsDataType,'LogicVector')
                val=['logic ',SignedKeyword,VectorSize];
            elseif obj.IsEnum
                val=obj.EnumInfo.EnumType;
            else
                switch obj.DataType
                case 'uint8_T'
                    val='byte unsigned';
                case 'uint16_T'
                    val='shortint unsigned';
                case 'uint32_T'
                    val='int unsigned';
                case 'uint64_T'
                    val='longint unsigned';
                case 'int8_T'
                    val='byte';
                case 'int16_T'
                    val='shortint';
                case 'int32_T'
                    val='int';
                case 'int64_T'
                    val='longint';
                case 'real32_T'
                    val='shortreal';
                case 'real64_T'
                    val='real';
                case 'real_T'
                    val='real';
                case 'boolean_T'
                    val='byte unsigned';
                case 'single_T'
                    val='shortreal';
                otherwise
                    error(message('HDLLink:DPITargetCC:dpigInvalidDataTypeSL',obj.DataType,obj.Name));
                end
            end

        end



        function val=DPI_C_InterfaceDataType(obj)
            switch obj.DPIPortsDataType
            case 'CompatibleCType'
                val=n_getCInterfaceDataType();
            case 'BitVector'
                val='svBitVecVal *';
            case 'LogicVector'
                val='svLogicVecVal *';
            otherwise
                error(message('HDLLink:DPITargetCC:dpigInvalidFixedPointInterface'));
            end
            function val=n_getCInterfaceDataType()
                if obj.IsPortAnArray||...
                    obj.IsPortAScalarField_ThatBelongsToStructArray
                    val='void *';
                else
                    val=obj.DataType;
                end
            end
        end


        function val=FlatName(obj)

            if isempty(obj.FlatNamePrefix)
                Prefix='';
            else
                Prefix=[obj.FlatNamePrefix,'_'];
            end

            val=[Prefix,obj.Name];
        end

        function val=FlatName_uf2f(obj,Ctx,SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix)
            val='';
            switch Ctx
            case 'comb_event_express'



                if obj.IsArrayOfStructs
                    [~,uf_inports]=n_arrayofstruct_call_list(SVScalarizePortsEnabled,SVStructEnabled);
                    val=strjoin(cellfun(@(e)([IdInterfacePrefix,e]),uf_inports,'UniformOutput',false),' or ');
                elseif obj.IsPortAnArray
                    tempPortName=n_regular_call_list(SVStructEnabled);
                    dim=obj.Dim;
                    for idx=1:dim
                        if SVScalarizePortsEnabled
                            val=sprintf(['%s',IdInterfacePrefix,tempPortName,'_%d',' or '],val,idx-1);
                        else
                            val=sprintf(['%s',IdInterfacePrefix,tempPortName,'[%d]',' or '],val,idx-1);
                        end
                    end
                    val=sprintf('%s',val(1:end-3));
                else
                    val=[IdInterfacePrefix,n_regular_call_list(SVStructEnabled)];
                end
            case 'uf2f_input_cl'
                if obj.IsArrayOfStructs
                    val=n_arrayofstruct_call_list(SVScalarizePortsEnabled,SVStructEnabled);
                elseif obj.IsPortAnArray&&SVScalarizePortsEnabled
                    tempPortName=n_regular_call_list(SVStructEnabled);
                    dim=obj.Dim;
                    for idx=1:dim
                        val=sprintf(['%s',tempPortName,'_%d',','],val,idx-1);
                    end
                    val=sprintf('{%s}',val(1:end-1));
                else
                    val=n_regular_call_list(SVStructEnabled);
                end
            case 'uf2f_output_cl'
                if obj.IsArrayOfStructs||(obj.IsPortAnArray&&SVScalarizePortsEnabled)
                    val=obj.FlatName;
                else
                    val=n_regular_call_list(SVStructEnabled);
                end
            case 'testbench'
                if obj.IsArrayOfStructs
                    val=obj.SVStructAccessId;
                elseif SVStructEnabled
                    val=n_regular_call_list(SVStructEnabled);
                end
            case 'uf2f_flat_scalar_cl'
                if obj.IsArrayOfStructs
                    if isempty(obj.SVStructAccessId)
                        n_arrayofstruct_call_list(SVScalarizePortsEnabled,SVStructEnabled);
                    end
                    val=obj.SVStructAccessId;
                end
            otherwise
                error('Invalid Flat Name option')
            end


            function val_n=n_regular_call_list(SVStructEnabled)
                if~isempty(obj.StructFieldInfo)&&SVStructEnabled
                    val_n='';
                    for idx_n=1:length(obj.StructFieldInfo.TopStructName)
                        val_n=sprintf('%s%s.',val_n,obj.StructFieldInfo.TopStructName{idx_n});
                    end
                    val_n=val_n(1:end-1);
                else
                    val_n=obj.FlatName;
                end
            end




            function[val_n,uf_ports]=n_arrayofstruct_call_list(SVScalarizePortsEnabled,SVStructEnabled)

                assert(~isempty(obj.StructFieldInfo));
                val_n_base='';
                val_n='';
                uf_ports={};
                IdxInfoStruct=struct('SzOfCurrGroup',cell(1,nnz(obj.StructFieldInfo.TopStructDim>1)),...
                'SzOfDownStreamGroup',cell(1,nnz(obj.StructFieldInfo.TopStructDim>1)));
                if SVScalarizePortsEnabled
                    obj.SVStructAccessId={};
                else
                    obj.SVStructAccessId='';
                end
                IdxInfoStruct_counter=1;
                for idx_n=1:length(obj.StructFieldInfo.TopStructName)
                    if obj.StructFieldInfo.TopStructDim(idx_n)>1&&length(obj.StructFieldInfo.TopStructName)~=idx_n

                        SzOfDownStreamGroup=prod([obj.StructFieldInfo.TopStructDim(idx_n+1:end-1),obj.Dim]);
                        SzOfCurrGroup=obj.StructFieldInfo.TopStructDim(idx_n);
                        if SVStructEnabled
                            if SVScalarizePortsEnabled
                                val_n_base=sprintf('%s%s_%s.',val_n_base,obj.StructFieldInfo.TopStructName{idx_n},'%d');
                            else
                                val_n_base=sprintf('%s%s[%s].',val_n_base,obj.StructFieldInfo.TopStructName{idx_n},'%d');


                                obj.SVStructAccessId=sprintf('%s%s[(%s/%d)%%%d].',obj.SVStructAccessId,obj.StructFieldInfo.TopStructName{idx_n},...
                                '<index>',SzOfDownStreamGroup,SzOfCurrGroup);
                            end
                        elseif SVScalarizePortsEnabled
                            if obj.IsComplex&&idx_n==length(obj.StructFieldInfo.TopStructName)-1


                                val_n_base=sprintf('%s%s_',val_n_base,obj.StructFieldInfo.TopStructName{idx_n});
                            else
                                val_n_base=sprintf('%s%s_%s_',val_n_base,obj.StructFieldInfo.TopStructName{idx_n},'%d');
                            end
                        end
                        IdxInfoStruct(IdxInfoStruct_counter).SzOfCurrGroup=SzOfCurrGroup;
                        IdxInfoStruct(IdxInfoStruct_counter).SzOfDownStreamGroup=SzOfDownStreamGroup;
                        IdxInfoStruct_counter=IdxInfoStruct_counter+1;
                    else

                        if SVStructEnabled
                            val_n_base=sprintf('%s%s.',val_n_base,obj.StructFieldInfo.TopStructName{idx_n});
                        elseif SVScalarizePortsEnabled
                            if obj.IsComplex&&idx_n==length(obj.StructFieldInfo.TopStructName)&&obj.StructFieldInfo.TopStructDim(idx_n-1)>1






                                val_n_base=sprintf('%s%s_%s_',val_n_base,obj.StructFieldInfo.TopStructName{idx_n},'%d');
                            else
                                val_n_base=sprintf('%s%s_',val_n_base,obj.StructFieldInfo.TopStructName{idx_n});
                            end
                        end
                        if~SVScalarizePortsEnabled
                            obj.SVStructAccessId=sprintf('%s%s.',obj.SVStructAccessId,obj.StructFieldInfo.TopStructName{idx_n});
                        end
                    end
                end
                val_n_base=val_n_base(1:end-1);
                obj.SVStructAccessId=obj.SVStructAccessId(1:end-1);

                for idx_n=1:prod([obj.StructFieldInfo.TopStructDim(1:end-1),obj.Dim])
                    arrfun_idx_n=idx_n-1;
                    if obj.IsPortAnArray
                        if SVScalarizePortsEnabled
                            sub_val_n=sprintf([val_n_base,'_%d'],arrayfun(@(x)mod(floor(arrfun_idx_n/x.SzOfDownStreamGroup),x.SzOfCurrGroup),IdxInfoStruct),mod(arrfun_idx_n,obj.Dim));
                            val_n=sprintf(['%s',sub_val_n,','],val_n);
                        else
                            sub_val_n=sprintf([val_n_base,'[%d]'],arrayfun(@(x)mod(floor(arrfun_idx_n/x.SzOfDownStreamGroup),x.SzOfCurrGroup),IdxInfoStruct),mod(arrfun_idx_n,obj.Dim));
                            val_n=sprintf(['%s',sub_val_n,','],val_n);
                        end
                    else
                        sub_val_n=sprintf(val_n_base,arrayfun(@(x)mod(floor(arrfun_idx_n/x.SzOfDownStreamGroup),x.SzOfCurrGroup),IdxInfoStruct));
                        val_n=sprintf(['%s',sub_val_n,','],val_n);
                    end
                    if SVScalarizePortsEnabled
                        obj.SVStructAccessId=[obj.SVStructAccessId,sub_val_n];
                    end
                    uf_ports{end+1}=sub_val_n;%#ok<AGROW>
                end
                val_n=sprintf('{%s}',val_n(1:end-1));
            end

        end

        function val=get.IsPortPassedByValueFromInterface(obj)
            val=obj.Dim==1;
        end

        function val=get.DoesPortRequireMarshalling(obj)
            val=~strcmpi(obj.DPIPortsDataType,'CompatibleCType');
        end

        function val=get.IsPortAnArray(obj)
            val=obj.Dim>1;
        end
        function val=get.IsArrayOfStructs(obj)
            val=~isempty(obj.StructFieldInfo)&&nnz(obj.StructFieldInfo.TopStructDim>1)>0;
        end


        function val=get.ExtraDimOffsetDueToBitRepresentation(obj)
            if~obj.DoesPortRequireMarshalling


                val=1;
            else
                val=ceil(double(obj.DataTypeSize)/32);
            end
        end

        function val=get.IsPortAnArrayField_ThatBelongsToStructArray(obj)
            if isempty(obj.StructInfo)
                val=~isempty(obj.StructFieldInfo)&&obj.IsPortAnArray&&obj.IsArrayOfStructs;
            else
                val=false;
            end
        end

        function val=get.IsPortAScalarField_ThatBelongsToStructArray(obj)
            if isempty(obj.StructInfo)
                val=~isempty(obj.StructFieldInfo)&&~obj.IsPortAnArray&&obj.IsArrayOfStructs;
            else
                val=false;
            end
        end

        function val=get.IsPortAnArrayField_ThatBelongsToStruct(obj)
            if isempty(obj.StructInfo)
                val=~isempty(obj.StructFieldInfo)&&obj.IsPortAnArray&&~obj.IsArrayOfStructs;
            else
                val=false;
            end
        end

        function val=get.IsPortAScalarField_ThatBelongsToStruct(obj)
            if isempty(obj.StructInfo)
                val=~isempty(obj.StructFieldInfo)&&~obj.IsPortAnArray&&~obj.IsArrayOfStructs;
            else
                val=false;
            end
        end

        function val=get.IsComplexVector(obj)
            val=obj.IsComplex&&obj.IsPortAScalarField_ThatBelongsToStructArray;
        end
    end


    methods
        function str=getInputPtrFromInterfaceOrLocals(portInfo)
            str='';
            if~portInfo.DoesPortRequireMarshalling
                if portInfo.IsPortPassedByValueFromInterface
                    str=[portInfo.DataType,'* ',portInfo.FlatName,'_Ptr = &',portInfo.FlatName,';'];
                else
                    str=[portInfo.DataType,'* ',portInfo.FlatName,'_Ptr = (',portInfo.DataType,'*) (',portInfo.FlatName,');'];
                end
            end
        end

        function str=getInputPtrFromRTW(portInfo,rtmVarName,objhandlecast)
            if portInfo.IsPortPassedByValueFromInterface
                str=[portInfo.DataType,'* ',rtmVarName,'_input_',portInfo.Name,'_Ptr = &(',objhandlecast,'->inputs->',portInfo.Name,');'];
            else
                str=[portInfo.DataType,'* ',rtmVarName,'_input_',portInfo.Name,'_Ptr = ',objhandlecast,'->inputs->',portInfo.Name,';'];
            end
        end

        function str=getCopyInputsToRTW(portInfo,rtmVarName)











            Source=portInfo.getExternalVarsHandlesToCopy('input');
            Destination=portInfo.getRTWHandlesToCopy(rtmVarName,'input');
            SizeToCopy=portInfo.getSizeToCopy();
            if~portInfo.DoesPortRequireMarshalling
                if portInfo.IsPortAnArray
                    str=sprintf('memcpy(%s,%s,sizeof(%s));',Destination,Source,SizeToCopy);
                else
                    str=sprintf('%s=%s;',Destination,Source);
                end
            else
                if~portInfo.IsPortAnArray

                    Destination=['&',Destination];
                end
                str=portInfo.DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(Destination,Source);
            end
        end

        function str=getInputTopStructInitialization(portInfo)
            str=sprintf('%s\n%s\n%s\n',...
            portInfo.ForLoopBegin,...
            portInfo.getCopyInputsToRTW(''),...
            portInfo.ForLoopEnd);
        end
    end

    methods
        function str=getSVAutoVarDecl4SVWrapperFcn(obj,SVScalarizePortsEnabled)

            str='';
            if obj.IsArrayOfStructs
                str=sprintf('\tautomatic %s %s [%s];\n',obj.SVDataType,obj.FlatName,...
                num2str(prod([obj.Dim,obj.StructFieldInfo.TopStructDim])));
            elseif obj.IsPortAnArray&&SVScalarizePortsEnabled
                str=sprintf('\tautomatic %s %s [%s];\n',obj.SVDataType,obj.FlatName,...
                num2str(obj.Dim));
            end
        end

        function str=getSVAutoVars2SVWrapperFcnOutput(obj,SVStructEnabled,SVScalarizePortsEnabled)
            str='';
            if obj.IsArrayOfStructs
                val_base='';

                IdxInfoStruct=struct('SzOfCurrGroup',cell(1,nnz(obj.StructFieldInfo.TopStructDim>1)),...
                'SzOfDownStreamGroup',cell(1,nnz(obj.StructFieldInfo.TopStructDim>1)));
                if SVScalarizePortsEnabled
                    obj.SVStructAccessId={};
                else
                    obj.SVStructAccessId='';
                end
                IdxInfoStruct_counter=1;
                for idx=1:length(obj.StructFieldInfo.TopStructName)
                    if obj.StructFieldInfo.TopStructDim(idx)>1&&length(obj.StructFieldInfo.TopStructName)~=idx

                        SzOfDownStreamGroup=prod([obj.StructFieldInfo.TopStructDim(idx+1:end),obj.Dim]);
                        SzOfCurrGroup=obj.StructFieldInfo.TopStructDim(idx);
                        if SVStructEnabled
                            if SVScalarizePortsEnabled
                                val_base=sprintf('%s%s_%s.',val_base,obj.StructFieldInfo.TopStructName{idx},'%d');
                            else
                                val_base=sprintf('%s%s[%s].',val_base,obj.StructFieldInfo.TopStructName{idx},'%d');
                                obj.SVStructAccessId=sprintf('%s%s[(%s/%d)%%%d].',obj.SVStructAccessId,obj.StructFieldInfo.TopStructName{idx},...
                                '<index>',SzOfDownStreamGroup,SzOfCurrGroup);
                            end
                        else
                            if SVScalarizePortsEnabled
                                if obj.IsComplex&&idx==length(obj.StructFieldInfo.TopStructName)-1


                                    val_base=sprintf('%s%s_',val_base,obj.StructFieldInfo.TopStructName{idx});
                                else
                                    val_base=sprintf('%s%s_%s_',val_base,obj.StructFieldInfo.TopStructName{idx},'%d');
                                end
                            end
                        end
                        IdxInfoStruct(IdxInfoStruct_counter).SzOfCurrGroup=SzOfCurrGroup;
                        IdxInfoStruct(IdxInfoStruct_counter).SzOfDownStreamGroup=SzOfDownStreamGroup;
                        IdxInfoStruct_counter=IdxInfoStruct_counter+1;
                    else

                        if SVStructEnabled
                            val_base=sprintf('%s%s.',val_base,obj.StructFieldInfo.TopStructName{idx});
                        else
                            if obj.IsComplex&&idx==length(obj.StructFieldInfo.TopStructName)&&obj.StructFieldInfo.TopStructDim(idx-1)>1






                                val_base=sprintf('%s%s_%s_',val_base,obj.StructFieldInfo.TopStructName{idx},'%d');
                            else
                                val_base=sprintf('%s%s_',val_base,obj.StructFieldInfo.TopStructName{idx});
                            end
                        end
                        if~SVScalarizePortsEnabled
                            obj.SVStructAccessId=sprintf('%s%s.',obj.SVStructAccessId,obj.StructFieldInfo.TopStructName{idx});
                        end
                    end
                end
                val_base=val_base(1:end-1);
                if~SVScalarizePortsEnabled
                    obj.SVStructAccessId=obj.SVStructAccessId(1:end-1);
                end

                for idx_1=1:prod([obj.StructFieldInfo.TopStructDim(1:end-1),obj.Dim])
                    arrfun_idx=idx_1-1;
                    if obj.IsPortAnArray




                        if SVScalarizePortsEnabled
                            substr=sprintf([val_base,'_%d'],...
                            arrayfun(@(x)mod(floor(arrfun_idx/x.SzOfDownStreamGroup),x.SzOfCurrGroup),IdxInfoStruct),mod(arrfun_idx,obj.Dim));
                            str=sprintf(['%s\t',substr,'=%s[%d];\n'],str,obj.FlatName,arrfun_idx);
                        else
                            str=sprintf(['%s\t',val_base,'[%d]=%s[%d];\n'],str,arrayfun(@(x)mod(floor(arrfun_idx/x.SzOfDownStreamGroup),x.SzOfCurrGroup),IdxInfoStruct),mod(arrfun_idx,obj.Dim),...
                            obj.FlatName,arrfun_idx);
                        end
                    else
                        substr=sprintf(val_base,arrayfun(@(x)mod(floor(arrfun_idx/x.SzOfDownStreamGroup),x.SzOfCurrGroup),IdxInfoStruct));
                        str=sprintf(['%s\t',substr,'=%s[%d];\n'],str,obj.FlatName,arrfun_idx);
                    end
                    if SVScalarizePortsEnabled
                        obj.SVStructAccessId=[obj.SVStructAccessId,substr];
                    end
                end
            elseif obj.IsPortAnArray&&SVScalarizePortsEnabled
                if~isempty(obj.StructFieldInfo)&&SVStructEnabled
                    tempPortName='';
                    for idx_n=1:length(obj.StructFieldInfo.TopStructName)
                        tempPortName=sprintf('%s%s.',tempPortName,obj.StructFieldInfo.TopStructName{idx_n});
                    end
                    tempPortName=tempPortName(1:end-1);
                else
                    tempPortName=obj.FlatName;
                end
                if obj.IsArrayOfStructs
                    dim=prod([obj.StructFieldInfo.TopStructDim(1:end-1),obj.Dim]);
                else
                    dim=obj.Dim;
                end
                for idx=1:dim
                    str=sprintf('%s\t%s_%d=%s[%d];\n',...
                    str,...
                    tempPortName,...
                    idx-1,...
                    obj.FlatName,...
                    idx-1);
                end
            end
        end

        function str=getOutputPtrFromInterfaceOrLocals(portInfo)
            str='';
            if~portInfo.DoesPortRequireMarshalling
                if portInfo.IsPortAnArray
                    str=[portInfo.DataType,'* ',portInfo.FlatName,'_Ptr = (',portInfo.DataType,'*) (',portInfo.FlatName,');'];
                else
                    str=[portInfo.DataType,'* ',portInfo.FlatName,'_Ptr = ',portInfo.FlatName,';'];
                end
            end
        end

        function str=getOutputPtrFromRTW(portInfo,rtmVarName,objhandlecast)
            if portInfo.IsPortAnArray
                str=[portInfo.DataType,'* ',rtmVarName,'_output_',portInfo.Name,'_Ptr = ',objhandlecast,'->outputs->',portInfo.Name,';'];
            else
                str=[portInfo.DataType,'* ',rtmVarName,'_output_',portInfo.Name,'_Ptr = &(',objhandlecast,'->outputs->',portInfo.Name,');'];
            end
        end

        function str=getCopyRTWToOutput(portInfo,rtmVarName)











            Destination=portInfo.getExternalVarsHandlesToCopy('output');
            Source=portInfo.getRTWHandlesToCopy(rtmVarName,'output');
            SizeToCopy=portInfo.getSizeToCopy();
            if~portInfo.DoesPortRequireMarshalling
                if portInfo.IsPortAnArray
                    str=sprintf('memcpy(%s,%s,sizeof(%s));',Destination,Source,SizeToCopy);
                else
                    str=sprintf('%s=%s;',Destination,Source);
                end
            else
                if~portInfo.IsPortAnArray

                    Source=['&',Source];
                end
                str=portInfo.DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(Destination,Source);
            end
        end

        function str=getOutputTopStructInitialization(portInfo)
            str=sprintf('%s\n%s\n%s\n',...
            portInfo.ForLoopBegin,...
            portInfo.getCopyRTWToOutput(''),...
            portInfo.ForLoopEnd);
        end
    end

    methods(Access=private)
        function[ForLoopBegin,FlattenedIndexing,ForLoopEnd]=getFlattenedArrayOfStructsIndexing(portInfo)

            StructArrayIndices=find(portInfo.StructFieldInfo.TopStructDim>1);
            ForLoopBegin='';
            ForLoopEnd='';
            TabbingForEnd='';
            FlattenedIndexing='';
            for idx=StructArrayIndices

                ForLoopBegin=sprintf('%sfor(%s=0;%s<%s;%s++){\n\t',ForLoopBegin,...
                portInfo.StructFieldInfo.ElementAccessIndexVariable{idx},...
                portInfo.StructFieldInfo.ElementAccessIndexVariable{idx},...
                num2str(portInfo.StructFieldInfo.TopStructDim(idx)),...
                portInfo.StructFieldInfo.ElementAccessIndexVariable{idx});










                FlattenedIndexing=sprintf('%s%s*%s+',FlattenedIndexing,...
                portInfo.StructFieldInfo.ElementAccessIndexVariable{idx},...
                num2str(prod([portInfo.StructFieldInfo.TopStructDim(idx+1:end),portInfo.Dim])));

                ForLoopEnd=sprintf('%s}\n%s',TabbingForEnd,ForLoopEnd);
                TabbingForEnd=sprintf('%s\t',TabbingForEnd);
            end

            FlattenedIndexing=FlattenedIndexing(1:end-1);





            if~isempty(StructArrayIndices)
                FlattenedIndexing=sprintf('(%s)*%s',FlattenedIndexing,num2str(portInfo.ExtraDimOffsetDueToBitRepresentation));
            end
        end

    end

    methods(Access=protected)

        function str=getSizeToCopy(portInfo)
            if portInfo.IsPortAnArray
                str=sprintf('%s[%s]',portInfo.DataType,num2str(portInfo.Dim));
            else
                str=sprintf('%s',portInfo.DataType);
            end
        end

        function str=getExternalVarsHandlesToCopy(portInfo,direction)
            if portInfo.DoesPortRequireMarshalling
                if portInfo.IsComplexVector||...
                    portInfo.IsPortAnArrayField_ThatBelongsToStructArray||...
                    portInfo.IsPortAScalarField_ThatBelongsToStructArray
                    str=sprintf('&%s[%s]',...
                    portInfo.FlatName,...
                    portInfo.FlattenedIndexing);
                else



                    str=sprintf('%s',portInfo.FlatName);
                end
                return;
            end

            if portInfo.IsPortAnArrayField_ThatBelongsToStructArray
                str=sprintf('&((%s)%s)[%s]',...
                [portInfo.DataType,'*'],...
                portInfo.FlatName,...
                portInfo.FlattenedIndexing);
            elseif portInfo.IsPortAScalarField_ThatBelongsToStructArray
                str=sprintf('((%s)%s)[%s]',...
                [portInfo.DataType,'*'],...
                portInfo.FlatName,...
                portInfo.FlattenedIndexing);
            elseif portInfo.IsPortAnArrayField_ThatBelongsToStruct||(portInfo.IsPortAScalarField_ThatBelongsToStruct&&strcmpi(direction,'input'))
                str=sprintf('%s',portInfo.FlatName);
            elseif portInfo.IsPortAScalarField_ThatBelongsToStruct&&strcmpi(direction,'output')

                str=sprintf('*%s',portInfo.FlatName);
            else
                if portInfo.IsPortAnArray
                    str=sprintf('%s',[portInfo.FlatName,'_Ptr']);
                else
                    str=sprintf('*%s',[portInfo.FlatName,'_Ptr']);
                end
            end
        end

        function str=getRTWHandlesToCopy(portInfo,rtmVarName,direction)
            if portInfo.IsPortAnArrayField_ThatBelongsToStructArray||...
                portInfo.IsPortAScalarField_ThatBelongsToStructArray||...
                portInfo.IsPortAnArrayField_ThatBelongsToStruct||...
                portInfo.IsPortAScalarField_ThatBelongsToStruct

                str=sprintf('%s',portInfo.StructFieldInfo.ElementAccess{end});
            else
                if portInfo.IsPortAnArray
                    str=sprintf('%s',[rtmVarName,'_',direction,'_',portInfo.Name,'_Ptr']);
                else
                    str=sprintf('*%s',[rtmVarName,'_',direction,'_',portInfo.Name,'_Ptr']);
                end
            end
        end

        function dim=getScalarDim(obj,dimArray)%#ok<INUSL>


            dim=prod(reshape(dimArray,numel(dimArray),1));
        end
    end
end

function Type=l_getEnumUnderlyingType(EnumType,TargetLang,IsThereNegativeVal)
    StorageT=Simulink.data.getEnumTypeInfo(EnumType,'StorageType');
    switch StorageT
    case 'int8'
        Ctype='int8_T';
        SVtype='byte';
    case 'uint8'
        Ctype='uint8_T';
        SVtype='byte unsigned';
    case 'int16'
        Ctype='int16_T';
        SVtype='shortint';
    case 'uint16'
        Ctype='uint16_T';
        SVtype='shortint unsigned';
    case{'int32','int'}
        if IsThereNegativeVal
            Ctype='int32_T';
            SVtype='int';
        else
            Ctype='uint32_T';
            SVtype='int unsigned';
        end
    otherwise
        Ctype='uint32_T';
        SVtype='int unsigned';
    end

    if strcmp(TargetLang,'C')
        Type=Ctype;
    else
        Type=SVtype;
    end
end
