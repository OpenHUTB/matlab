



function emitSetWorkWidths(this,codeWriter)


    if(this.LctSpecInfo.Parameters.Numel<1)&&...
        ~this.LctSpecInfo.DynamicSizeInfo.DWorkHasDynSize&&...
        (this.LctSpecInfo.DWorksForNDArray.Numel<1)&&...
        ~(this.LctSpecInfo.hasBusOrStruct&&~this.LctSpecInfo.Specs.Options.stubSimBehavior)&&...
        ~this.LctSpecInfo.Specs.Options.supportsMultipleExecInstances
        return
    end

    codeWriter.wNewLine;
    codeWriter.wLine('#define MDL_SET_WORK_WIDTHS');
    codeWriter.wLine('#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)');
    codeWriter.wMultiCmtStart('Function: mdlSetWorkWidths =============================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  The optional method, mdlSetWorkWidths is called after input port');
    codeWriter.wMultiCmtMiddle('  width, output port width, and sample times of the S-function have');
    codeWriter.wMultiCmtMiddle('  been determined to set any state and work vector sizes which are');
    codeWriter.wMultiCmtMiddle('  a function of the input, output, and/or sample times. ');
    codeWriter.wMultiCmtMiddle('  Run-time parameters are registered in this method using methods ');
    codeWriter.wMultiCmtMiddle('  ssSetNumRunTimeParams, ssSetRunTimeParamInfo, and related methods.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlSetWorkWidths(SimStruct *S)');
    codeWriter.wBlockStart();

    emitBody(this,codeWriter);

    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');


    function emitBody(this,codeWriter)

        if this.LctSpecInfo.Specs.Options.supportsMultipleExecInstances
            codeWriter.wLine('#if defined(ssSupportsMultipleExecInstances)');
            codeWriter.wLine('ssSupportsMultipleExecInstances(S, 1);');
            codeWriter.wLine('#endif');
            codeWriter.wNewLine;
        end

        if this.LctSpecInfo.Parameters.Numel>0
            codeWriter.wCmt('Set number of run-time parameters');
            codeWriter.wLine('if (!ssSetNumRunTimeParams(S, %d)) return;',this.LctSpecInfo.Parameters.Numel);

            for ii=1:this.LctSpecInfo.Parameters.Numel
                paramSpec=this.LctSpecInfo.Parameters.Items(ii);

                codeWriter.wNewLine;
                codeWriter.wCmt('Register the run-time parameter %d',ii);

                dataType=this.LctSpecInfo.DataTypes.Items(paramSpec.DataTypeId);
                if dataType.IsLookupTable||dataType.IsBreakpoint
                    if dataType.IsLookupTable
                        lutOrBP='Simulink.LookupTable';
                    else
                        lutOrBP='Simulink.Breakpoint';
                    end
                    codeWriter.wBlockStart();
                    codeWriter.wLine('DTypeId dataTypeIdLUT;');
                    codeWriter.wNewLine;
                    codeWriter.wLine('ssGetSFcnParamDataType(S, %d, &dataTypeIdLUT);',ii-1);
                    codeWriter.wLine('if(dataTypeIdLUT == INVALID_DTYPE_ID) return;');
                    codeWriter.wLine('const char *dataTypeLUTName = ssGetDataTypeName(S, dataTypeIdLUT);');
                    codeWriter.wLine('if(!(strcmp(dataTypeLUTName, "%s") == 0)) ssSetErrorStatus(S, "Expected StructTypeInfo.Name=''%s'' for %s parameter %d");',dataType.DTName,dataType.DTName,lutOrBP,ii-1);
                    codeWriter.wNewLine;
                    codeWriter.wLine('ssRegDlgParamAsRunTimeParam(S, %d, %d, "p%d", dataTypeIdLUT);',ii-1,ii-1,ii);
                    codeWriter.wBlockEnd();
                elseif dataType.HasObject
                    codeWriter.wBlockStart();
                    codeWriter.wLine('DTypeId dataTypeIdReg;');
                    codeWriter.wNewLine;
                    codeWriter.wLine('ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);',dataType.DTName);
                    codeWriter.wLine('if(dataTypeIdReg == INVALID_DTYPE_ID) return;');
                    codeWriter.wNewLine;
                    codeWriter.wLine('ssRegDlgParamAsRunTimeParam(S, %d, %d, "p%d", dataTypeIdReg);',ii-1,ii-1,ii);
                    codeWriter.wBlockEnd();
                else
                    dataType=this.LctSpecInfo.DataTypes.Items(dataType.IdAliasedThruTo);
                    if this.LctSpecInfo.DataTypes.is64Bits(dataType)
                        codeWriter.wBlockStart();
                        codeWriter.wLine('DTypeId dataTypeIdReg;');
                        codeWriter.wNewLine;
                        codeWriter.wLine('dataTypeIdReg = ssRegisterDataTypeFxpBinaryPoint(S, %d, 64, 0, 1);',...
                        dataType.IsSigned);
                        codeWriter.wLine('if (dataTypeIdReg == INVALID_DTYPE_ID) return;');
                        codeWriter.wNewLine;
                        codeWriter.wLine('ssRegDlgParamAsRunTimeParam(S, %d, %d, "p%d", dataTypeIdReg);',ii-1,ii-1,ii);
                        codeWriter.wBlockEnd();
                    else
                        codeWriter.wLine('ssRegDlgParamAsRunTimeParam(S, %d, %d, "p%d", ssGetDataTypeId(S, "%s"));',...
                        ii-1,ii-1,ii,dataType.DTName);
                    end
                end
            end
        end



        for ii=1:numel(this.LctSpecInfo.DynamicSizeInfo.DWorkDynSize)
            thisDynSize=this.LctSpecInfo.DynamicSizeInfo.DWorkDynSize{ii};


            if~any(thisDynSize==true)
                continue
            end


            dWork=this.LctSpecInfo.DWorks.Items(ii);
            dimStr=legacycode.lct.gen.ExprSFunEmitter.emitAllDims(this.LctSpecInfo,dWork,'DYNAMICALLY_SIZED');
            nbDims=numel(dimStr);

            codeWriter.wNewLine;
            codeWriter.wCmt('Set DWork %d width',ii);

            if nbDims>1

                codeWriter.wBlockStart();
                codeWriter.wLine('  int_T dims[%d];',nbDims);
                codeWriter.wNewLine;


                width='';
                mult='';
                for jj=1:nbDims
                    codeWriter.wLine('dims[%d] = %s;',jj-1,dimStr{jj});
                    width=sprintf('%s %s dims[%d]',width,mult,jj-1);
                    mult='*';
                end
                codeWriter.wNewLine;
                codeWriter.wLine('ssSetDWorkWidth(S, %d, %s);',ii-1,width);
                codeWriter.wBlockEnd();

            else
                codeWriter.wLine('ssSetDWorkWidth(S, %d, %s);',ii-1,dimStr{1});
            end
        end

        if this.LctSpecInfo.DWorksForNDArray.Numel>0
            codeWriter.wNewLine;
            codeWriter.wCmt('Set the width of the DWork(s) used for marshaling the ND Row Major IOs');
            codeWriter.wBlockStart('if (!IS_ROW_MAJOR_CODEGEN_ENABLED(S))');

            for ii=1:this.LctSpecInfo.DWorksForNDArray.Numel

                dWork=this.LctSpecInfo.DWorksForNDArray.Items(ii);
                dWorkIdx=this.LctSpecInfo.DWorks.Numel+ii-1;


                apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dWork.CArrayND.Data,'sfun');

                codeWriter.wLine('ssSetDWorkWidth(S, %d, %s);',dWorkIdx,apiInfo.Width);
            end

            codeWriter.wBlockEnd();
        end


