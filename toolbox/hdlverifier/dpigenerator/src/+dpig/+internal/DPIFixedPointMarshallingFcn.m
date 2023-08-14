classdef DPIFixedPointMarshallingFcn<handle
    properties(Access=private)
InterfaceType
NumberOfBits
ArraySize
CDataType
IsVarSize
    end

    properties(Access=private,Constant)

        CDataVariableName='CData'
        SVBitDataVariableName='SVBitData'

        TempVarToHoldData='TempData'
        LoopIdx='idx'
    end

    properties(Access=private,Dependent)
IsSigned
IsUnpackedArray
IsMultiWord
IsMultiWordInMATLAB
CDataFromBits_FunctionName
BitsFromCData_FunctionName
SV_Underlying_CDataType
SignatureCDataType
SignatureSVDataType
CDataDims
NumberOf32BitWords
UnderlyingCDataType
leftoverbitsmod32
    end

    methods
        function val=get.IsSigned(obj)

            val=~(strcmpi(obj.CDataType(1),'u')||strcmpi(obj.CDataType(1:4),'bool'));
        end
        function val=get.leftoverbitsmod32(obj)
            if obj.NumberOfBits==32||obj.NumberOfBits==64||obj.NumberOfBits==96||obj.NumberOfBits==128
                val=32;
            else
                val=mod(obj.NumberOfBits,32);
            end
        end
        function val=get.UnderlyingCDataType(obj)
            if obj.NumberOfBits<=64
                val=obj.CDataType;
            else
                if obj.IsSigned
                    val='int64_T';
                else
                    val='uint64_T';
                end
            end
        end

        function val=get.NumberOf32BitWords(obj)
            val=num2str(ceil(obj.NumberOfBits/32));
        end

        function val=get.IsUnpackedArray(obj)
            val=obj.ArraySize>1;
        end

        function val=get.IsMultiWord(obj)
            val=obj.NumberOfBits>32;
        end

        function val=get.IsMultiWordInMATLAB(obj)
            val=obj.NumberOfBits>64;
        end

        function val=get.CDataFromBits_FunctionName(obj)

            if obj.IsSigned
                Sign='Signed';
            else
                Sign='Unsigned';
            end

            if obj.IsUnpackedArray
                if obj.IsVarSize
                    UnpackedDim='ByVarSized';
                else
                    UnpackedDim=['By',num2str(obj.ArraySize)];
                end
                UnpackedPosFix='Array';
            else
                UnpackedDim='';
                UnpackedPosFix='';
            end
            val=['get',Sign,'CDataFrom',num2str(obj.NumberOfBits),UnpackedDim,'Bit',UnpackedPosFix];
        end

        function val=get.BitsFromCData_FunctionName(obj)

            if obj.IsSigned
                Sign='Signed';
            else
                Sign='Unsigned';
            end

            if obj.IsUnpackedArray
                if obj.IsVarSize
                    UnpackedDim='ByVarSizedArray';
                else
                    UnpackedDim=['By',num2str(obj.ArraySize),'Array'];
                end
            else
                UnpackedDim='';
            end
            val=['get',num2str(obj.NumberOfBits),'Bit',UnpackedDim,'From',Sign,'CData'];
        end

        function val=get.SV_Underlying_CDataType(obj)
            if strcmpi(obj.InterfaceType,'BitVector')
                val='svBitVecVal';
            elseif strcmpi(obj.InterfaceType,'LogicVector')
                val='uint32_T';
            else
                error('Invalid fixed point data type.');
            end
        end

        function val=get.SignatureCDataType(obj)
            if obj.IsUnpackedArray
                val=obj.CDataType;
            else
                val=[obj.CDataType,'*'];
            end
        end

        function val=get.SignatureSVDataType(obj)
            if strcmpi(obj.InterfaceType,'BitVector')
                val='svBitVecVal *';
            elseif strcmpi(obj.InterfaceType,'LogicVector')
                val='svLogicVecVal *';
            else
                error('Invalid fixed point data type.');
            end
        end

        function val=get.CDataDims(obj)
            if obj.IsUnpackedArray
                val=['[',num2str(obj.ArraySize),']'];
            else
                val='';
            end
        end
    end

    methods
        function obj=DPIFixedPointMarshallingFcn(FixedPointInterface,NumberOfBits,CDataType,Dimensions,varargin)
            if strcmpi(FixedPointInterface,'CompatibleCType')
                obj.InterfaceType=FixedPointInterface;
                obj.IsVarSize=false;
            else
                if nargin>4
                    obj.IsVarSize=varargin{1};
                else
                    obj.IsVarSize=false;
                end
                obj.InterfaceType=FixedPointInterface;
                obj.NumberOfBits=double(NumberOfBits);
                obj.CDataType=CDataType;
                obj.ArraySize=Dimensions;
            end
        end


        function str=getCDataFromBits_FcnDef(obj)
            if strcmpi(obj.InterfaceType,'CompatibleCType')
                str='';
                return;
            end
            if obj.IsVarSize&&obj.IsUnpackedArray



                str_signature=sprintf('static void %s(%s * %s,const %s %s,int size)',...
                obj.CDataFromBits_FunctionName,...
                obj.SignatureCDataType,...
                obj.CDataVariableName,...
                obj.SignatureSVDataType,...
                obj.SVBitDataVariableName);
            else
                str_signature=sprintf('static void %s(%s %s%s,const %s %s)',...
                obj.CDataFromBits_FunctionName,...
                obj.SignatureCDataType,...
                obj.CDataVariableName,...
                obj.CDataDims,...
                obj.SignatureSVDataType,...
                obj.SVBitDataVariableName);
            end

            str_local_declaration=sprintf('%s %s;',...
            obj.CDataType,obj.TempVarToHoldData);


            str_data_marshalling_and_copy=obj.get_SV_To_C_MarshallingImplementation();

            if obj.IsUnpackedArray
                [str_local_declaration,str_data_marshalling_and_copy]=obj.AddForLoop(str_local_declaration,str_data_marshalling_and_copy);
            end
            str=sprintf(['%s\n',...
            '{\n',...
            '%s\n%s',...
            '}'],...
            str_signature,...
            str_local_declaration,str_data_marshalling_and_copy);
        end

        function str=getCDataFromBits_FcnCall(obj,Destination,Source,varargin)
            if nargin>3
                size=varargin{1};
            else
                size='';
            end
            if strcmpi(obj.InterfaceType,'CompatibleCType')
                str='';
                return;
            end
            if obj.IsVarSize&&obj.IsUnpackedArray



                str=sprintf('%s(%s,%s,%s);',...
                obj.CDataFromBits_FunctionName,Destination,Source,size);
            else
                str=sprintf('%s(%s,%s);',...
                obj.CDataFromBits_FunctionName,Destination,Source);
            end

        end

        function str=getBitsFromCData_FcnDef(obj)
            if strcmpi(obj.InterfaceType,'CompatibleCType')
                str='';
                return;
            end
            if obj.IsVarSize&&obj.IsUnpackedArray



                str_signature=sprintf('static void %s(%s %s,%s * %s,int size)',...
                obj.BitsFromCData_FunctionName,...
                obj.SignatureSVDataType,...
                obj.SVBitDataVariableName,...
                obj.SignatureCDataType,...
                obj.CDataVariableName);
            else
                str_signature=sprintf('static void %s(%s %s,%s %s%s)',...
                obj.BitsFromCData_FunctionName,...
                obj.SignatureSVDataType,...
                obj.SVBitDataVariableName,...
                obj.SignatureCDataType,...
                obj.CDataVariableName,...
                obj.CDataDims);
            end


            if obj.IsMultiWord
                str_local_declaration='';
                for idx=1:ceil(obj.NumberOfBits/32)
                    str_local_declaration=sprintf('%s%s %s;\n',...
                    str_local_declaration,...
                    obj.SV_Underlying_CDataType,...
                    [obj.TempVarToHoldData,num2str(idx)]);
                end
            else
                str_local_declaration='';
            end

            str_data_marshalling_and_copy=obj.get_C_To_SV_MarshallingImplementation();

            if obj.IsUnpackedArray
                [str_local_declaration,str_data_marshalling_and_copy]=obj.AddForLoop(str_local_declaration,str_data_marshalling_and_copy);
            end

            str=sprintf(['%s\n',...
            '{',...
            '%s\n%s\n',...
            '}'],...
            str_signature,...
            str_local_declaration,str_data_marshalling_and_copy);
        end

        function str=getBitsFromCData_FcnCall(obj,Destination,Source,varargin)
            if nargin>3
                size=varargin{1};
            else
                size='';
            end
            if strcmpi(obj.InterfaceType,'CompatibleCType')
                str='';
                return;
            end
            if obj.IsVarSize&&obj.IsUnpackedArray



                str=sprintf('%s(%s,%s,%s);',...
                obj.BitsFromCData_FunctionName,Destination,Source,size);
            else
                str=sprintf('%s(%s,%s);',...
                obj.BitsFromCData_FunctionName,Destination,Source);
            end
        end

        function str=getDPICanonicalRepresentation(obj,varargin)
            if nargin>1
                svdpiIncluded=varargin{1};
            else
                svdpiIncluded=false;
            end
            if strcmpi(obj.InterfaceType,'CompatibleCType')
                str='';
                return;
            end
            if strcmpi(obj.InterfaceType,'BitVector')
                if svdpiIncluded


                    str='';
                else
                    str='typedef uint32_T svBitVecVal;';
                end
            elseif strcmpi(obj.InterfaceType,'LogicVector')
                if svdpiIncluded


                    str=sprintf(['#ifndef VPI_VECVAL\n',...
                    '#define VPI_VECVAL\n',...
                    'typedef struct t_vpi_vecval{\n',...
                    'uint32_T aval;\n',...
                    'uint32_T bval;\n',...
                    '} s_vpi_vecval, *p_vpi_vecval;\n',...
                    '#endif']');
                else
                    str=sprintf(['#ifndef VPI_VECVAL\n',...
                    '#define VPI_VECVAL\n',...
                    'typedef struct t_vpi_vecval{\n',...
                    'uint32_T aval;\n',...
                    'uint32_T bval;\n',...
                    '} s_vpi_vecval, *p_vpi_vecval;\n',...
                    '#endif\n',...
                    'typedef s_vpi_vecval svLogicVecVal;']');
                end
            else
                str='';
            end
        end
    end

    methods(Access=private)
        function str=get_SV_To_C_MarshallingImplementation(obj)
            if obj.IsUnpackedArray
                if obj.IsMultiWord
                    [DataAccess,SVMSB_DataAccess]=getDataAccessForMultiwordUnpacked();
                    ExtractionExp=getExtractionExpression(DataAccess,SVMSB_DataAccess);

                    Source=['&',obj.TempVarToHoldData];
                    Destination=['&',obj.CDataVariableName,'[',obj.LoopIdx,']'];
                else
                    LSB_DataAccess=obj.getSVBitData_ForNonMultiwordUnpacked('aval');
                    ExtractionExp=['(',obj.UnderlyingCDataType,')','(',LSB_DataAccess,'&',obj.getBitPattern(1),')'];


                    ExtractionExp=sprintf('%s=%s;',obj.TempVarToHoldData,obj.getSignedBitExtension(ExtractionExp,false,LSB_DataAccess));

                    Source=['&',obj.TempVarToHoldData];
                    Destination=['&',obj.CDataVariableName,'[',obj.LoopIdx,']'];
                end
            else
                if obj.IsMultiWord
                    [DataAccess,SVMSB_DataAccess]=getDataAccessForMultiwordPacked();
                    ExtractionExp=getExtractionExpression(DataAccess,SVMSB_DataAccess);

                    Source=['&',obj.TempVarToHoldData];
                    Destination=obj.CDataVariableName;
                else

                    LSB_DataAccess=obj.getSVBitData_ForNonMultiwordPacked('aval');

                    ExtractionExp=['(',obj.UnderlyingCDataType,')','(',LSB_DataAccess,'&',obj.getBitPattern(1),')'];


                    ExtractionExp=sprintf('%s=%s;',obj.TempVarToHoldData,obj.getSignedBitExtension(ExtractionExp,false,LSB_DataAccess));

                    Source=['&',obj.TempVarToHoldData];
                    Destination=obj.CDataVariableName;
                end
            end
            str=sprintf(['%s\n',...
            'memcpy(%s,%s,sizeof(%s));\n'],...
            ExtractionExp,...
            Destination,Source,[obj.CDataType]);

            function[DataAccess_local,SVMSB_DataAccess_local]=getDataAccessForMultiwordUnpacked()
                DataAccess_local=cell(1,ceil(obj.NumberOfBits/32));
                for idx_local=1:ceil(obj.NumberOfBits/32)
                    if mod(idx_local,2)


                        DataAccess_local{idx_local}=sprintf('(%s)%s',...
                        obj.UnderlyingCDataType,...
                        obj.getSVBitData_ForMultiwordUnpacked('aval',obj.SVWordOffset(idx_local)));
                    else


                        DataAccess_local{idx_local}=sprintf('((%s)(%s & %s)<<32)',...
                        obj.UnderlyingCDataType,...
                        obj.getSVBitData_ForMultiwordUnpacked('aval',obj.SVWordOffset(idx_local)),...
                        obj.getBitPattern(idx_local));
                    end

                    if idx_local==ceil(obj.NumberOfBits/32)

                        SVMSB_DataAccess_local=sprintf('%s',obj.getSVBitData_ForMultiwordUnpacked('aval',obj.SVWordOffset(idx_local)));
                    end
                end
            end

            function[DataAccess_local,SVMSB_DataAccess_local]=getDataAccessForMultiwordPacked()
                DataAccess_local=cell(1,ceil(obj.NumberOfBits/32));
                for idx_local=1:ceil(obj.NumberOfBits/32)
                    if mod(idx_local,2)


                        DataAccess_local{idx_local}=sprintf('(%s)%s',...
                        obj.UnderlyingCDataType,...
                        obj.getSVBitData_ForMultiwordPacked('aval',obj.SVWordOffset(idx_local)));
                    else


                        DataAccess_local{idx_local}=sprintf('((%s)(%s & %s)<<32)',...
                        obj.UnderlyingCDataType,...
                        obj.getSVBitData_ForMultiwordPacked('aval',obj.SVWordOffset(idx_local)),...
                        obj.getBitPattern(idx_local));
                    end

                    if idx_local==ceil(obj.NumberOfBits/32)

                        SVMSB_DataAccess_local=sprintf('%s',obj.getSVBitData_ForMultiwordPacked('aval',obj.SVWordOffset(idx_local)));
                    end
                end
            end

            function ExtractionExp_local=getExtractionExpression(DataAccess_local,SVMSB_DataAccess_local)
                ExtractionExp_local='';%#ok<NASGU>
                if length(DataAccess_local)==3
                    MSBC_Data=DataAccess_local{3};


                    MSBC_Data=obj.getSignedBitExtension(MSBC_Data,true,SVMSB_DataAccess_local);
                    LSBC_Data=sprintf('%s|%s',DataAccess_local{2},DataAccess_local{1});
                    ExtractionExp_local=sprintf('%s.%s=%s;\n%s.%s=%s;',...
                    obj.TempVarToHoldData,...
                    obj.getCoderMultiwordChunk(2),...
                    LSBC_Data,...
                    obj.TempVarToHoldData,...
                    obj.getCoderMultiwordChunk(3),...
                    MSBC_Data);
                elseif length(DataAccess_local)==4
                    MSBC_Data=sprintf('%s|%s',DataAccess_local{4},DataAccess_local{3});


                    MSBC_Data=obj.getSignedBitExtension(MSBC_Data,true,SVMSB_DataAccess_local);
                    LSBC_Data=sprintf('%s|%s',DataAccess_local{2},DataAccess_local{1});
                    ExtractionExp_local=sprintf('%s.%s=%s;\n%s.%s=%s;',...
                    obj.TempVarToHoldData,...
                    obj.getCoderMultiwordChunk(2),...
                    LSBC_Data,...
                    obj.TempVarToHoldData,...
                    obj.getCoderMultiwordChunk(4),...
                    MSBC_Data);
                else
                    LSBC_Data=sprintf('%s|%s',DataAccess_local{2},DataAccess_local{1});


                    LSBC_Data=obj.getSignedBitExtension(LSBC_Data,true,SVMSB_DataAccess_local);
                    ExtractionExp_local=sprintf('%s=%s;',...
                    obj.TempVarToHoldData,...
                    LSBC_Data);
                end
            end
        end

        function str=getBitPattern(obj,idx)
            if idx<ceil(obj.NumberOfBits/32)
                str=['0x',dec2hex(intmax('uint32'),8)];
            else
                str=['0x',dec2hex(bitshift(intmax('uint32'),-(32-obj.leftoverbitsmod32)),8)];
            end
        end

        function str=getSignCheckBitPattern(obj,IsMultiWord)
            if IsMultiWord
                str=['0x',dec2hex(bitshift(uint32(1),obj.leftoverbitsmod32-1),8)];
            else
                str=['0x',dec2hex(bitshift(uint32(1),obj.NumberOfBits-1),8)];
            end
        end

        function str=getBitExtensionBitPattern(obj,IsMultiWord)
            if IsMultiWord
                if ceil(obj.NumberOfBits/32)==3



                    str=['0xFFFFFFFF',dec2hex(bitshift(intmax('uint32'),obj.leftoverbitsmod32),8)];
                else




                    str=['0x',dec2hex(bitshift(intmax('uint32'),obj.leftoverbitsmod32)),'00000000'];
                end
            else

                str=['0x',dec2hex(bitshift(intmax('uint32'),obj.NumberOfBits),8)];
            end
        end

        function str=getCoderMultiwordChunk(obj,idx)

            if obj.IsMultiWordInMATLAB
                str=sprintf('chunks[%s]',num2str(floor(idx/3)));
            else
                str='';
            end
        end

        function str=SVWordOffset(obj,idx)%#ok<INUSL>
            if obj.IsUnpackedArray
                str=['+ ',num2str(idx-1)];
            else
                str=num2str(idx-1);
            end
        end

        function str=getSignedBitExtension(obj,UnsignedExtraction,IsMultiword,SignedInfoDataAccess)
            if obj.IsSigned
                str=sprintf('((%s)&%s)!=0 ? (%s)((%s) | %s) : %s',...
                SignedInfoDataAccess,...
                obj.getSignCheckBitPattern(IsMultiword),...
                obj.UnderlyingCDataType,...
                UnsignedExtraction,...
                obj.getBitExtensionBitPattern(IsMultiword),...
                UnsignedExtraction);
            else
                str=UnsignedExtraction;
            end
        end

        function str=get_C_To_SV_MarshallingImplementation(obj)
            if obj.IsUnpackedArray
                if obj.IsMultiWord
                    [ExtractionExp,CopyExp]=getMultiwordExtractionAndCopyCodeForUnpackedArrays();
                else
                    ExtractionExp='';
                    CopyExp=sprintf('%s=(%s)%s[%s]&%s;\n%s',...
                    obj.getSVBitData_ForNonMultiwordUnpacked('aval'),...
                    obj.SV_Underlying_CDataType,...
                    obj.CDataVariableName,...
                    obj.LoopIdx,...
                    obj.getBitPattern(1),...
                    obj.getInitializationOfBVals_ForLogicVector(obj.getSVBitData_ForNonMultiwordUnpacked('bval')));
                end
            else
                if obj.IsMultiWord
                    [ExtractionExp,CopyExp]=getMultiwordExtractionAndCopyCodeForPackedArrays();
                else
                    ExtractionExp='';
                    CopyExp=sprintf('%s=(%s)(*%s)&%s;\n%s',...
                    obj.getSVBitData_ForNonMultiwordPacked('aval'),...
                    obj.SV_Underlying_CDataType,...
                    obj.CDataVariableName,...
                    obj.getBitPattern(1),...
                    obj.getInitializationOfBVals_ForLogicVector(obj.getSVBitData_ForNonMultiwordPacked('bval')));
                end
            end
            str=sprintf('%s\n%s',ExtractionExp,CopyExp);

            function[ExtractionExp_local,CopyExp_local]=getMultiwordExtractionAndCopyCodeForUnpackedArrays()
                ExtractionExp_local='';
                CopyExp_local='';

                if obj.IsMultiWordInMATLAB
                    CDataAccess='%s[%s].%s';
                else
                    CDataAccess='%s[%s]%s';
                end

                for idx=1:ceil(obj.NumberOfBits/32)
                    if mod(idx,2)


                        ExtractionExp_Eval=sprintf(['(%s)((',CDataAccess,') & %s);'],...
                        obj.SV_Underlying_CDataType,...
                        obj.CDataVariableName,...
                        obj.LoopIdx,...
                        obj.getCoderMultiwordChunk(idx),...
                        obj.getBitPattern(idx));
                    else


                        ExtractionExp_Eval=sprintf(['(%s)(((',CDataAccess,')>>32) & %s);'],...
                        obj.SV_Underlying_CDataType,...
                        obj.CDataVariableName,...
                        obj.LoopIdx,...
                        obj.getCoderMultiwordChunk(idx),...
                        obj.getBitPattern(idx));
                    end
                    CopyExp_Eval=sprintf('memcpy(&%s,&%s,sizeof(%s));\n%s',...
                    obj.getSVBitData_ForMultiwordUnpacked('aval',obj.SVWordOffset(idx)),...
                    [obj.TempVarToHoldData,num2str(idx)],...
                    obj.SV_Underlying_CDataType,...
                    obj.getInitializationOfBVals_ForLogicVector(obj.getSVBitData_ForMultiwordUnpacked('bval',obj.SVWordOffset(idx))));

                    ExtractionExp_local=sprintf('%s%s=%s\n',...
                    ExtractionExp_local,...
                    [obj.TempVarToHoldData,num2str(idx)],...
                    ExtractionExp_Eval);
                    CopyExp_local=sprintf('%s%s\n',CopyExp_local,CopyExp_Eval);
                end
            end

            function[ExtractionExp_local,CopyExp_local]=getMultiwordExtractionAndCopyCodeForPackedArrays()
                ExtractionExp_local='';
                CopyExp_local='';

                if obj.IsMultiWordInMATLAB
                    CDataAccess='%s->%s';
                else
                    CDataAccess='*%s%s';
                end

                for idx=1:ceil(obj.NumberOfBits/32)
                    if mod(idx,2)


                        ExtractionExp_Eval=sprintf(['(%s)((',CDataAccess,') & %s);'],...
                        obj.SV_Underlying_CDataType,...
                        obj.CDataVariableName,...
                        obj.getCoderMultiwordChunk(idx),...
                        obj.getBitPattern(idx));
                    else


                        ExtractionExp_Eval=sprintf(['(%s)(((',CDataAccess,')>>32) & %s);'],...
                        obj.SV_Underlying_CDataType,...
                        obj.CDataVariableName,...
                        obj.getCoderMultiwordChunk(idx),...
                        obj.getBitPattern(idx));
                    end
                    CopyExp_Eval=sprintf('memcpy(&%s,&%s,sizeof(%s));\n%s',...
                    obj.getSVBitData_ForMultiwordPacked('aval',obj.SVWordOffset(idx)),...
                    [obj.TempVarToHoldData,num2str(idx)],...
                    obj.SV_Underlying_CDataType,...
                    obj.getInitializationOfBVals_ForLogicVector(obj.getSVBitData_ForMultiwordPacked('bval',obj.SVWordOffset(idx))));

                    ExtractionExp_local=sprintf('%s%s=%s\n',...
                    ExtractionExp_local,...
                    [obj.TempVarToHoldData,num2str(idx)],...
                    ExtractionExp_Eval);
                    CopyExp_local=sprintf('%s%s\n',CopyExp_local,CopyExp_Eval);
                end
            end
        end

        function[str_local_declaration,str_data_marshalling_and_copy]=AddForLoop(obj,local_decl,data_marsh)
            if obj.IsVarSize
                loopHigh='size';
            else
                loopHigh=num2str(obj.ArraySize);
            end
            idxType='int';

            str_local_declaration=sprintf('%s\n%s\t%s;',local_decl,...
            idxType,obj.LoopIdx);
            str_data_marshalling_and_copy=sprintf(['for(',obj.LoopIdx,'=0;',obj.LoopIdx,'<',loopHigh,';',obj.LoopIdx,'++)\n',...
            '{\n',...
            '%s\n',...
            '}'],data_marsh);
        end

        function str=getSVBitData_ForNonMultiwordPacked(obj,ValType)
            if strcmpi(obj.InterfaceType,'BitVector')
                str=['*',obj.SVBitDataVariableName];
            elseif strcmpi(obj.InterfaceType,'LogicVector')
                if strcmpi(ValType,'aval')
                    val='->aval';
                elseif strcmpi(ValType,'bval')
                    val='->bval';
                else
                    error('Invalid val type for logic vector');
                end
                str=[obj.SVBitDataVariableName,val];
            else
                error('Invalid fixed point data type.');
            end
        end

        function str=getSVBitData_ForNonMultiwordUnpacked(obj,ValType)
            if strcmpi(obj.InterfaceType,'BitVector')
                str=sprintf('%s[%s]',obj.SVBitDataVariableName,obj.LoopIdx);
            elseif strcmpi(obj.InterfaceType,'LogicVector')
                if strcmpi(ValType,'aval')
                    val='.aval';
                elseif strcmpi(ValType,'bval')
                    val='.bval';
                else
                    error('Invalid val type for logic vector');
                end
                str=sprintf('%s[%s]%s',obj.SVBitDataVariableName,obj.LoopIdx,val);
            else
                error('Invalid fixed point data type.');
            end
        end

        function str=getSVBitData_ForMultiwordPacked(obj,ValType,Offset)
            if strcmpi(obj.InterfaceType,'BitVector')
                str=sprintf('%s[%s]',obj.SVBitDataVariableName,Offset);
            elseif strcmpi(obj.InterfaceType,'LogicVector')
                if strcmpi(ValType,'aval')
                    val='.aval';
                elseif strcmpi(ValType,'bval')
                    val='.bval';
                else
                    error('Invalid val type for logic vector');
                end
                str=sprintf('%s[%s]%s',obj.SVBitDataVariableName,Offset,val);
            else
                error('Invalid fixed point data type.');
            end
        end

        function str=getSVBitData_ForMultiwordUnpacked(obj,ValType,Offset)
            if strcmpi(obj.InterfaceType,'BitVector')
                str=sprintf('%s[%s*%s%s]',obj.SVBitDataVariableName,obj.NumberOf32BitWords,obj.LoopIdx,Offset);
            elseif strcmpi(obj.InterfaceType,'LogicVector')
                if strcmpi(ValType,'aval')
                    val='.aval';
                elseif strcmpi(ValType,'bval')
                    val='.bval';
                else
                    error('Invalid val type for logic vector');
                end
                str=sprintf('%s[%s*%s%s]%s',obj.SVBitDataVariableName,obj.NumberOf32BitWords,obj.LoopIdx,Offset,val);
            else
                error('Invalid fixed point data type.');
            end
        end

        function str=getInitializationOfBVals_ForLogicVector(obj,SVBitData)
            if strcmpi(obj.InterfaceType,'LogicVector')
                str=sprintf('memset(&%s,0,sizeof(%s));',SVBitData,obj.SV_Underlying_CDataType);
            else
                str='';
            end
        end

    end
end
