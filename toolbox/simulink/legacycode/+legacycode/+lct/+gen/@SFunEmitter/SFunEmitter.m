



classdef SFunEmitter<legacycode.lct.gen.CodeEmitter


    properties(Access=protected)
        HasSampleTimeAsParameter logical=false
        HasBusInfoToRegister logical=false
        Filename char=''
    end


    methods




        function this=SFunEmitter(lctObj)

            narginchk(1,1);
            this@legacycode.lct.gen.CodeEmitter(lctObj);
        end




        emit(this,varargin)

    end


    methods(Static)




        function emitFile(def)
            narginchk(1,1)
            o=legacycode.lct.gen.SFunEmitter(def);
            o.emit();
        end


        stmts=genCheckDimension(dataSpec,checkForDynSize,dimExpr,dimVar,dimIdx)
    end


    methods(Access=protected)


        emitHeader(this,codeWriter)
        emitDefines(this,codeWriter)
        emitCheckParameters(this,codeWriter)
        emitInitializeSizes(this,codeWriter)
        emitInitializeSampleTimes(this,codeWriter)
        emitRegisterGlobalDataStoreInfo(this,codeWriter);
        emitSetInputPortDimensionInfo(this,codeWriter)
        emitSetOutputPortDimensionInfo(this,codeWriter)
        emitSetDefaultPortDimensionInfo(this,codeWriter)
        emitSetWorkWidths(this,codeWriter)
        emitStart(this,codeWriter)
        emitInitializeConditions(this,codeWriter)
        emitOutputs(this,codeWriter)
        emitTerminate(this,codeWriter)
        emitTrailer(this,codeWriter)

        emitSSOptions(this,codeWriter)

        emitParameterRegistration(this,codeWriter)
        typeIdSet=emitDWorkRegistration(this,codeWriter,typeIdSet)
        typeIdSet=emitInputRegistration(this,codeWriter,typeIdSet)
        typeIdSet=emitOutputRegistration(this,codeWriter,typeIdSet)
        emitInputOutputDimsRegistration(this,codeWriter,dataSpec,checkForDynSize,defaultStr,setValStmts)

        emitLocalsForFunCall(this,codeWriter,funSpec)
        emitLocalsForStructMarshaling(this,codeWriter,funSpec)
        emitLocalsForNDMarshaling(this,codeWriter,funSpec)
        emitLocalsForStructInfo(this,codeWriter)

        emitFunCall(this,codeWriter,funSpec)

        emitStructConversion(this,codeWriter,funSpec,sl2User)
        emitNDArrayConversion(this,codeWriter,funSpec,col2Row)

        emitBlockMethod(this,codeWriter,funSpec,canAllocPWork,canDeallocPWork)

        emitPWorkUpdate(this,codeWriter,funSpec)




        function emitSFunCgClass(this,codeWriter)



            if this.LctSpecInfo.canUseSFunCgAPI==false
                return
            end


            cgEmitter=legacycode.lct.gen.SFunCgEmitter(this.LctSpecInfo);
            outWriter=legacycode.lct.gen.BufferedWriter();
            cgEmitter.emit(outWriter);
            codeWriter.wLine(outWriter.TxtBuffer);
        end





        function emitNamedTypeRegistration(~,codeWriter,typeName,dataIdx,apiFcn)
            codeWriter.wLine('#if defined(MATLAB_MEX_FILE) ');
            codeWriter.wBlockStart('if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY)');
            codeWriter.wLine('DTypeId dataTypeIdReg;');
            codeWriter.wNewLine;
            codeWriter.wLine('ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);',typeName);
            codeWriter.wLine('if(dataTypeIdReg == INVALID_DTYPE_ID) return;');
            codeWriter.wNewLine;
            codeWriter.wLine('%s(S, %d, dataTypeIdReg);',apiFcn,dataIdx);
            codeWriter.wBlockEnd();
            codeWriter.wLine('#endif');
        end






        function emitOpaqueTypeRegistration(~,codeWriter,typeName,dataIdx,apiFcn)
            codeWriter.wLine('#if defined(MATLAB_MEX_FILE) ');
            codeWriter.wBlockStart('if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY)');
            codeWriter.wLine('DTypeId dataTypeIdReg;');
            codeWriter.wLine('int_T status;');
            codeWriter.wNewLine;
            codeWriter.wLine('dataTypeIdReg = ssRegisterDataType(S, "%s");',typeName);
            codeWriter.wLine('if(dataTypeIdReg == INVALID_DTYPE_ID) return;');
            codeWriter.wNewLine;




            codeWriter.wLine('status = ssSetDataTypeSize(S, dataTypeIdReg, sizeof(int_T));');
            codeWriter.wLine('if(status == 0) return;');
            codeWriter.wNewLine;
            codeWriter.wLine('%s(S, %d, dataTypeIdReg);',apiFcn,dataIdx);
            codeWriter.wBlockEnd();
            codeWriter.wLine('#endif');
        end





        function emitBuiltinTypeRegistration(this,codeWriter,dataType,dataIdx,apiFcn)
            dataType=this.LctSpecInfo.DataTypes.Items(dataType.IdAliasedThruTo);
            if this.LctSpecInfo.DataTypes.is64Bits(dataType)
                codeWriter.wBlockStart();
                codeWriter.wLine('DTypeId dataTypeIdReg;');
                codeWriter.wNewLine;
                codeWriter.wLine('dataTypeIdReg = ssRegisterDataTypeFxpBinaryPoint(S, %d, 64, 0, 1);',...
                dataType.IsSigned);
                codeWriter.wLine('if (dataTypeIdReg == INVALID_DTYPE_ID) return;');
                codeWriter.wNewLine;
                codeWriter.wLine('%s(S, %d, dataTypeIdReg);',apiFcn,dataIdx);
                codeWriter.wBlockEnd();
            else
                codeWriter.wLine('%s(S, %d, %s);',apiFcn,dataIdx,dataType.Enum);
            end
        end

    end
end


