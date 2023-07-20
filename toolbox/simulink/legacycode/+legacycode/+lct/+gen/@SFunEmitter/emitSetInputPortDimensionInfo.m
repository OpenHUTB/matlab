



function emitSetInputPortDimensionInfo(this,codeWriter)


    if~this.LctSpecInfo.DynamicSizeInfo.InputHasDynSize
        return
    end

    codeWriter.wNewLine;
    codeWriter.wLine('#define MDL_SET_INPUT_PORT_DIMENSION_INFO');
    codeWriter.wLine('#if defined(MDL_SET_INPUT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)');
    codeWriter.wMultiCmtStart('Function: mdlSetInputPortDimensionInfo =================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  This method is called with the candidate dimensions for an input port');
    codeWriter.wMultiCmtMiddle('  with unknown dimensions. If the proposed dimensions are acceptable, the');
    codeWriter.wMultiCmtMiddle('  method should go ahead and set the actual port dimensions.');
    codeWriter.wMultiCmtMiddle('  If they are unacceptable an error should be generated via');
    codeWriter.wMultiCmtMiddle('  ssSetErrorStatus.');
    codeWriter.wMultiCmtMiddle('  Note that any other input or output ports whose dimensions are');
    codeWriter.wMultiCmtMiddle('  implicitly defined by virtue of knowing the dimensions of the given');
    codeWriter.wMultiCmtMiddle('  port can also have their dimensions set.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T portIndex, const DimsInfo_T *dimsInfo)');
    codeWriter.wBlockStart();

    emitBody(this,codeWriter);

    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');


    function emitBody(this,codeWriter)

        codeWriter.wCmt('Set input port dimension');
        codeWriter.wLine('if(!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo)) return;');


        for ii=1:numel(this.LctSpecInfo.DynamicSizeInfo.InputDynSize)

            dataSpec=this.LctSpecInfo.Inputs.Items(ii);
            if dataSpec.IsDynamicArray

            end

            thisDynSize=this.LctSpecInfo.DynamicSizeInfo.InputDynSize{ii};


            if~any(thisDynSize==true)
                continue
            end

            nbDims=length(thisDynSize);
            if nbDims>2



                codeWriter.wNewLine;
                codeWriter.wCmt('Verify input port %d dimension',ii);
                codeWriter.wLine('if ((portIndex == %d) && (ssGetInputPortNumDimensions(S, %d) != %d)) {',ii-1,ii-1,nbDims);
                codeWriter.wLine('    ssSetErrorStatus(S, "Input %d: number of dimensions must be %d");',ii,nbDims);
                codeWriter.wLine('}');
            end
        end



        for ii=1:numel(this.LctSpecInfo.DynamicSizeInfo.OutputDynSize)

            dataSpec=this.LctSpecInfo.Outputs.Items(ii);
            if dataSpec.IsDynamicArray
                continue
            end

            thisDynSize=this.LctSpecInfo.DynamicSizeInfo.OutputDynSize{ii};


            if~any(thisDynSize==true)
                continue
            end


            dataSpec=this.LctSpecInfo.Outputs.Items(ii);
            codeWriter.wNewLine;
            codeWriter.wCmt('Set output port %d dimension',ii);
            this.emitInputOutputDimsRegistration(codeWriter,dataSpec,true,'DYNAMICALLY_SIZED');
        end
