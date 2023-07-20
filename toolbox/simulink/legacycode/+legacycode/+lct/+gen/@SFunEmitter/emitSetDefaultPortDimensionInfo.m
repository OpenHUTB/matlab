



function emitSetDefaultPortDimensionInfo(this,codeWriter)


    if~this.LctSpecInfo.DynamicSizeInfo.InputHasDynSize&&...
        ~this.LctSpecInfo.DynamicSizeInfo.OutputHasDynSize
        return
    end

    codeWriter.wNewLine;
    codeWriter.wLine('#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO');
    codeWriter.wLine('#if defined(MDL_SET_DEFAULT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)');
    codeWriter.wMultiCmtStart('Function: mdlSetDefaultPortDimensionInfo ===============================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  This method is called when there is not enough information in your');
    codeWriter.wMultiCmtMiddle('  model to uniquely determine the port dimensionality of signals');
    codeWriter.wMultiCmtMiddle('  entering or leaving your block. When this occurs, Simulink''s');
    codeWriter.wMultiCmtMiddle('  dimension propagation engine calls this method to ask you to set');
    codeWriter.wMultiCmtMiddle('  your S-functions default dimensions for any input and output ports');
    codeWriter.wMultiCmtMiddle('  that are dynamically sized.');
    codeWriter.wMultiCmtMiddle('  If you do not provide this method and you have dynamically sized ports');
    codeWriter.wMultiCmtMiddle('  where Simulink does not have enough information to propagate the');
    codeWriter.wMultiCmtMiddle('  dimensionality to your S-function, then Simulink will set these unknown');
    codeWriter.wMultiCmtMiddle('  ports to the ''block width'' which is determined by examining any known');
    codeWriter.wMultiCmtMiddle('  ports. If there are no known ports, the width will be set to 1.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlSetDefaultPortDimensionInfo(SimStruct *S)');
    codeWriter.wBlockStart();

    emitBody(this,codeWriter);

    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');


    function emitBody(this,codeWriter)


        for ii=1:numel(this.LctSpecInfo.DynamicSizeInfo.InputDynSize)

            dataSpec=this.LctSpecInfo.Inputs.Items(ii);
            thisDynSize=this.LctSpecInfo.DynamicSizeInfo.InputDynSize{ii};


            if~any(thisDynSize==true)
                continue
            end

            codeWriter.wNewLine;
            codeWriter.wCmt('Set input port %d default dimension',ii);


            nbDims=numel(thisDynSize);
            if dataSpec.IsDynamicArray
                sizeMode='SS_INT32_INF_DIM ';
            else
                sizeMode='DYNAMICALLY_SIZED';
            end
            codeWriter.wBlockStart('if (ssGetInputPortWidth(S, %d) == %s)',ii-1,sizeMode);

            if nbDims==1

                codeWriter.wLine('ssSetInputPortWidth(S, %d, 1);',ii-1);
            elseif nbDims==2

                codeWriter.wLine('if (!ssSetInputPortMatrixDimensions(S, %d, 1, 1)) return;',ii-1);
            else


                codeWriter.wLine('DECL_AND_INIT_DIMSINFO(dimsInfo);');
                varDims=sprintf('%sDims',dataSpec.Identifier);
                codeWriter.wLine('int_T %s[%d];',varDims,nbDims);
                codeWriter.wNewLine;
                for jj=1:nbDims-1
                    codeWriter.wLine('%s[%d] = 1;',varDims,jj-1);
                end
                codeWriter.wLine('%s[%d] = 2;',varDims,nbDims-1);
                codeWriter.wLine('dimsInfo.numDims = %d;',nbDims);
                codeWriter.wLine('dimsInfo.width = 2;');
                codeWriter.wLine('dimsInfo.dims = &%s[0];',varDims);
                codeWriter.wLine('ssSetInputPortDimensionInfo(S, %d, &dimsInfo);',ii-1);
            end
            codeWriter.wBlockEnd();
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




            codeWriter.wNewLine;
            codeWriter.wCmt('Set output port %d default dimension',ii);
            this.emitInputOutputDimsRegistration(codeWriter,dataSpec,true,'DYNAMICALLY_SIZED');
        end


