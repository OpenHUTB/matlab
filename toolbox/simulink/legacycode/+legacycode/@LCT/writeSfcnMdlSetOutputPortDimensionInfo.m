function writeSfcnMdlSetOutputPortDimensionInfo(h,fid,infoStruct)







    if(infoStruct.DynamicSizeInfo.OutputHasDynSize==false)&&...
        (infoStruct.DynamicSizeInfo.InputHasDynSize==false)
        return
    end

    fprintf(fid,'#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO\n');
    fprintf(fid,'#if defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)\n');
    fprintf(fid,'/* Function: mdlSetOutputPortDimensionInfo ================================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    This method is called with the candidate dimensions for an output port\n');
    fprintf(fid,' *    with unknown dimensions. If the proposed dimensions are acceptable, the\n');
    fprintf(fid,' *    method should go ahead and set the actual port dimensions.\n');
    fprintf(fid,' *    If they are unacceptable an error should be generated via\n');
    fprintf(fid,' *    ssSetErrorStatus.\n');
    fprintf(fid,' *    Note that any other input or output ports whose dimensions are\n');
    fprintf(fid,' *    implicitly defined by virtue of knowing the dimensions of the given\n');
    fprintf(fid,' *    port can also have their dimensions set.\n');
    fprintf(fid,' *\n');
    fprintf(fid,' */\n');
    fprintf(fid,'static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T portIndex, const DimsInfo_T *dimsInfo)\n');
    fprintf(fid,'{\n');


    fprintf(fid,'/* Set output port dimension */\n');
    fprintf(fid,'if(!ssSetOutputPortDimensionInfo(S, portIndex, dimsInfo)) return;\n');
    fprintf(fid,'\n');



    for ii=1:length(infoStruct.DynamicSizeInfo.OutputDynSize)
        thisDynSize=infoStruct.DynamicSizeInfo.OutputDynSize{ii};



        if any(thisDynSize==true)


            str=h.generateSfcnDataDimStr(infoStruct,'Output',ii,'DYNAMICALLY_SIZED');
            nbDims=length(str);

            fprintf(fid,'/* Verify output port %d dimension */\n',ii);
            fprintf(fid,'{\n');
            if nbDims==1
                fprintf(fid,'int_T width = %s;\n',str{1});
                fprintf(fid,'\n');
                fprintf(fid,'if (width != DYNAMICALLY_SIZED) {\n');
                fprintf(fid,'  if ((dimsInfo->numDims != 1) || (dimsInfo->width != width)) {\n');
                fprintf(fid,['   ssSetErrorStatus(S, "Invalid output port width. ',...
                'The output signal %d must be a 1D signal.");\n'],ii);
                fprintf(fid,'  }\n');
                fprintf(fid,'}\n');

            elseif nbDims==2
                fprintf(fid,'int_T nRows = %s;\n',str{1});
                fprintf(fid,'int_T nCols = %s;\n',str{2});
                fprintf(fid,'\n');
                fprintf(fid,'if ((nRows != DYNAMICALLY_SIZED) && (nCols != DYNAMICALLY_SIZED)) {\n');
                fprintf(fid,'  if ((dimsInfo->numDims != 2) || (dimsInfo->dims[0] != nRows) || (dimsInfo->dims[1] != nCols)) {\n');
                fprintf(fid,['   ssSetErrorStatus(S, "Invalid output port dimensions. ',...
                'The output signal %d must be a 2D (matrix) signal.");\n'],ii);
                fprintf(fid,'  }\n');
                fprintf(fid,'}\n');

            else
                fprintf(fid,'boolean_T hasDynSize = 0;\n');
                fprintf(fid,'boolean_T hasBadDim = 0;\n');
                fprintf(fid,'int_T i;\n');
                fprintf(fid,'int_T iDims[%d];\n',nbDims);
                fprintf(fid,'\n');

                fprintf(fid,'/* Get the specified dimensions */\n');
                for jj=1:nbDims
                    fprintf(fid,'iDims[%d] = %s;\n',jj-1,str{jj});
                end
                fprintf(fid,'\n');



                fprintf(fid,'/* Compare the candidate dimensions against specification */\n');
                fprintf(fid,'if (dimsInfo->numDims != %d) {\n',nbDims);
                fprintf(fid,'  hasBadDim = 1;\n');
                fprintf(fid,'} else {\n');
                fprintf(fid,'  for (i = 0; i < %d; i++) {\n',nbDims);
                fprintf(fid,'    if (iDims[i]==DYNAMICALLY_SIZED) {\n');
                fprintf(fid,'      hasDynSize |= 1;\n');
                fprintf(fid,'    } else {\n');
                fprintf(fid,'      if (dimsInfo->dims[i] != iDims[i]) {\n');
                fprintf(fid,'        hasBadDim |= 1;\n');
                fprintf(fid,'      }\n');
                fprintf(fid,'    }\n');
                fprintf(fid,'  }\n');
                fprintf(fid,'}\n');
                fprintf(fid,'\n');
                fprintf(fid,'if (!hasDynSize && hasBadDim) {\n');
                fprintf(fid,['   ssSetErrorStatus(S, "Invalid output port dimensions. ',...
                'The output signal %d must be a %dD signal.");\n'],ii,nbDims);
                fprintf(fid,'}\n');
                fprintf(fid,'\n');

            end
            fprintf(fid,'}\n');
            fprintf(fid,'\n');
        end
    end

    fprintf(fid,'}\n');
    fprintf(fid,'#endif\n');
    fprintf(fid,'\n');

