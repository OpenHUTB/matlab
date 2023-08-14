function writeSfcnMdlSetInputPortDimensionInfo(h,fid,infoStruct)







    if(infoStruct.DynamicSizeInfo.InputHasDynSize==false)
        return
    end

    fprintf(fid,'#define MDL_SET_INPUT_PORT_DIMENSION_INFO\n');
    fprintf(fid,'#if defined(MDL_SET_INPUT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)\n');
    fprintf(fid,'/* Function: mdlSetInputPortDimensionInfo =================================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    This method is called with the candidate dimensions for an input port\n');
    fprintf(fid,' *    with unknown dimensions. If the proposed dimensions are acceptable, the\n');
    fprintf(fid,' *    method should go ahead and set the actual port dimensions.\n');
    fprintf(fid,' *    If they are unacceptable an error should be generated via \n');
    fprintf(fid,' *    ssSetErrorStatus.  \n');
    fprintf(fid,' *    Note that any other input or output ports whose dimensions are\n');
    fprintf(fid,' *    implicitly defined by virtue of knowing the dimensions of the given\n');
    fprintf(fid,' *    port can also have their dimensions set.\n');
    fprintf(fid,' *\n');
    fprintf(fid,' */\n');
    fprintf(fid,'static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T portIndex, const DimsInfo_T *dimsInfo)\n');
    fprintf(fid,'{\n');

    fprintf(fid,'/* /* Set input port dimension */\n');
    fprintf(fid,'if(!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo)) return;\n');
    fprintf(fid,'\n');


    for ii=1:length(infoStruct.DynamicSizeInfo.InputDynSize)
        thisDynSize=infoStruct.DynamicSizeInfo.InputDynSize{ii};


        if any(thisDynSize==true)
            nbDims=length(thisDynSize);
            if nbDims>2



                fprintf(fid,'/* Verify input port %d dimension */\n',ii);
                fprintf(fid,'if ((portIndex == %d) && (ssGetInputPortNumDimensions(S, %d) != %d)) {\n',ii-1,ii-1,nbDims);
                fprintf(fid,'  ssSetErrorStatus(S, "Input %d: number of dimensions must be %d");\n',ii,nbDims);
                fprintf(fid,'}\n');
            end
            fprintf(fid,'\n');
        end
    end



    for ii=1:length(infoStruct.DynamicSizeInfo.OutputDynSize)
        thisDynSize=infoStruct.DynamicSizeInfo.OutputDynSize{ii};



        if any(thisDynSize==true)


            str=h.generateSfcnDataDimStr(infoStruct,'Output',ii,'DYNAMICALLY_SIZED');
            nbDims=length(str);

            fprintf(fid,'/* Set output port %d dimension */\n',ii);
            fprintf(fid,'{\n');
            if nbDims==1
                fprintf(fid,'int_T iWidth = %s;\n',str{1});
                fprintf(fid,'if (iWidth != DYNAMICALLY_SIZED) {\n');
                fprintf(fid,'  ssSetOutputPortWidth(S, %d, iWidth);\n',ii-1);
                fprintf(fid,'}\n');

            elseif nbDims==2
                fprintf(fid,'int_T iRows = %s;\n',str{1});
                fprintf(fid,'int_T iCols = %s;\n',str{2});
                fprintf(fid,'\n');
                fprintf(fid,'if ((iRows != DYNAMICALLY_SIZED) && (iCols != DYNAMICALLY_SIZED)) {\n');
                fprintf(fid,'  if(!ssSetOutputPortMatrixDimensions(S, %d, iRows, iCols)) return;\n',ii-1);
                fprintf(fid,'}\n');

            else
                fprintf(fid,'DECL_AND_INIT_DIMSINFO(dimsInfo);\n');
                fprintf(fid,'boolean_T hasDynSize = 0;\n');
                fprintf(fid,'int_T i;\n');
                fprintf(fid,'int_T iDims[%d];\n',nbDims);
                fprintf(fid,'\n');

                fprintf(fid,'/* Get the specified dimensions */\n');
                for jj=1:nbDims
                    fprintf(fid,'iDims[%d] = %s;\n',jj-1,str{jj});
                end
                fprintf(fid,'\n');



                fprintf(fid,'/* Look for unknown dimensions */\n');
                fprintf(fid,'for (i = 0; i < %d; i++) {\n',nbDims);
                fprintf(fid,'  if (iDims[i]==DYNAMICALLY_SIZED) {\n');
                fprintf(fid,'    hasDynSize |= 1;\n');
                fprintf(fid,'  }\n');
                fprintf(fid,'}\n');
                fprintf(fid,'\n');



                fprintf(fid,'/* Set dimensions if all aren''t dynamically sized */\n');
                fprintf(fid,'if (!hasDynSize) {\n');
                fprintf(fid,'  iDims[%d] = (iDims[%d]==1 ? 2 : iDims[%d]);\n',nbDims-1,nbDims-1,nbDims-1);
                fprintf(fid,'  dimsInfo.numDims = %d;\n',nbDims);
                fprintf(fid,'  dimsInfo.dims = &iDims[0];\n');
                fprintf(fid,'  dimsInfo.width = 1;\n');
                fprintf(fid,'  for (i = 0; i < dimsInfo.numDims; i++) {\n');
                fprintf(fid,'     dimsInfo.width *= iDims[i];\n');
                fprintf(fid,'  }\n');
                fprintf(fid,'\n');
                fprintf(fid,'  ssSetOutputPortDimensionInfo(S, %d, &dimsInfo);\n',ii-1);
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

