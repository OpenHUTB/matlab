function writeSfcnMdlSetDefaultPortDimensionInfo(h,fid,infoStruct)







    if(infoStruct.DynamicSizeInfo.InputHasDynSize==false)&&...
        (infoStruct.DynamicSizeInfo.OutputHasDynSize==false)
        return
    end

    fprintf(fid,'#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO\n');
    fprintf(fid,'#if defined(MDL_SET_DEFAULT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)\n');
    fprintf(fid,'/* Function: mdlSetDefaultPortDimensionInfo ===============================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    This method is called when there is not enough information in your\n');
    fprintf(fid,' *    model to uniquely determine the port dimensionality of signals\n');
    fprintf(fid,' *    entering or leaving your block. When this occurs, Simulink''s\n');
    fprintf(fid,' *    dimension propagation engine calls this method to ask you to set\n');
    fprintf(fid,' *    your S-functions default dimensions for any input and output ports\n');
    fprintf(fid,' *    that are dynamically sized.\n');
    fprintf(fid,' *\n');
    fprintf(fid,' *    If you do not provide this method and you have dynamically sized ports\n');
    fprintf(fid,' *    where Simulink does not have enough information to propagate the\n');
    fprintf(fid,' *    dimensionality to your S-function, then Simulink will set these unknown\n');
    fprintf(fid,' *    ports to the ''block width'' which is determined by examining any known\n');
    fprintf(fid,' *    ports. If there are no known ports, the width will be set to 1.\n');
    fprintf(fid,' *\n');
    fprintf(fid,' */\n');
    fprintf(fid,'static void mdlSetDefaultPortDimensionInfo(SimStruct *S)\n');
    fprintf(fid,'{\n');


    for ii=1:length(infoStruct.DynamicSizeInfo.InputDynSize)
        thisDynSize=infoStruct.DynamicSizeInfo.InputDynSize{ii};


        if any(thisDynSize==true)
            fprintf(fid,'/* Set input port %d default dimension */\n',ii);



            nbDims=length(thisDynSize);
            fprintf(fid,'  if (ssGetInputPortWidth(S, %d) == DYNAMICALLY_SIZED) {\n',ii-1);

            if nbDims==1

                fprintf(fid,'ssSetInputPortWidth(S, %d, 1);\n',ii-1);

            elseif nbDims==2

                fprintf(fid,'if(!ssSetInputPortMatrixDimensions(S, %d, 1, 1)) return;\n',ii-1);

            else


                fprintf(fid,'  DECL_AND_INIT_DIMSINFO(dimsInfo);\n');
                fprintf(fid,'  int_T dims[%d];\n',nbDims);
                fprintf(fid,'\n');
                for jj=1:nbDims-1
                    fprintf(fid,'dims[%d] = 1;\n',jj-1);
                end
                fprintf(fid,'   dims[%d] = 2;\n',nbDims-1);
                fprintf(fid,'  dimsInfo.numDims = %d;\n',nbDims);
                fprintf(fid,'  dimsInfo.width = 2;\n');
                fprintf(fid,'  dimsInfo.dims = &dims[0];\n');
                fprintf(fid,'  ssSetInputPortDimensionInfo(S, %d, &dimsInfo);\n',ii-1);
            end
            fprintf(fid,'  }\n');
            fprintf(fid,'\n');
        end
    end



    for ii=1:length(infoStruct.DynamicSizeInfo.OutputDynSize)
        thisDynSize=infoStruct.DynamicSizeInfo.OutputDynSize{ii};



        if any(thisDynSize==true)


            str=h.generateSfcnDataDimStr(infoStruct,'Output',ii,'DYNAMICALLY_SIZED');
            nbDims=length(str);

            fprintf(fid,'/* Set output port %d default dimension */\n',ii);
            fprintf(fid,'{\n');
            if nbDims==1
                fprintf(fid,'int_T iWidth = %s;\n',str{1,1});
                fprintf(fid,'int_T oWidth = ssGetOutputPortWidth(S, %d);\n',ii-1);
                fprintf(fid,'\n');


                fprintf(fid,'if (oWidth==DYNAMICALLY_SIZED) {\n');
                fprintf(fid,'  oWidth = (iWidth==DYNAMICALLY_SIZED ? 1 : iWidth);\n');
                fprintf(fid,'\n');
                fprintf(fid,'  ssSetOutputPortWidth(S, %d, oWidth);\n',ii-1);
                fprintf(fid,'\n');
                fprintf(fid,'} else if (oWidth!=iWidth) {\n');
                fprintf(fid,'  ssSetErrorStatus(S, "Output %d: incompatible width during forward propagation versus default dimension");\n',ii);
                fprintf(fid,'\n');
                fprintf(fid,'  } else {\n');
                fprintf(fid,'}\n');

            elseif nbDims==2
                fprintf(fid,'int_T iRows = %s;\n',str{1,1});
                fprintf(fid,'int_T iCols = %s;\n',str{2,1});
                fprintf(fid,'int_T oRows = ssGetOutputPortDimensions(S, %d)[0];\n',ii-1);
                fprintf(fid,'int_T oCols = ssGetOutputPortDimensions(S, %d)[1];\n',ii-1);
                fprintf(fid,'\n');


                fprintf(fid,'if (oRows==DYNAMICALLY_SIZED || oCols==DYNAMICALLY_SIZED) {\n');
                fprintf(fid,'  oRows = (iRows==DYNAMICALLY_SIZED ? 1 : iRows);\n');
                fprintf(fid,'  oCols = (iCols==DYNAMICALLY_SIZED ? 1 : iCols);\n');
                fprintf(fid,'\n');
                fprintf(fid,'  if(!ssSetOutputPortMatrixDimensions(S, %d, oRows, oCols)) return;\n',ii-1);
                fprintf(fid,'\n');
                fprintf(fid,'} else if (oRows!=iRows || oCols!=iCols) {\n');
                fprintf(fid,'  ssSetErrorStatus(S, "Output %d: incompatible dimension during forward propagation versus default dimension");\n',ii);
                fprintf(fid,'\n');
                fprintf(fid,'} else {\n');
                fprintf(fid,'}\n');

            else

                fprintf(fid,'DECL_AND_INIT_DIMSINFO(dimsInfo);\n');
                fprintf(fid,'boolean_T hasDynSize = 0;\n');
                fprintf(fid,'int_T i;\n');
                fprintf(fid,'int_T iDims[%d];\n',nbDims);
                fprintf(fid,'int_T oDims[%d];\n',nbDims);
                fprintf(fid,'\n');

                fprintf(fid,'/* Get the specified dimensions */\n');
                for jj=1:nbDims
                    fprintf(fid,'iDims[%d] = %s;\n',jj-1,str{jj});
                end
                fprintf(fid,'\n');



                fprintf(fid,'/* Get the actual dimensions and compare against specification */\n');
                fprintf(fid,'for (i = 0; i < %d; i++) {\n',nbDims);
                fprintf(fid,'  if (i < ssGetOutputPortNumDimensions(S, %d)) {\n',ii-1);
                fprintf(fid,'    oDims[i] = ssGetOutputPortDimensions(S, %d)[i];\n',ii-1);
                fprintf(fid,'  } else {\n');
                fprintf(fid,'    oDims[i] = DYNAMICALLY_SIZED;\n');
                fprintf(fid,'  }\n');
                fprintf(fid,'\n');
                fprintf(fid,'  if (oDims[i]==DYNAMICALLY_SIZED) {\n');
                fprintf(fid,'    hasDynSize |= 1;\n');
                fprintf(fid,'    oDims[i] = (iDims[i]==DYNAMICALLY_SIZED ? 1 : iDims[i]);\n');
                fprintf(fid,'  } else {\n');
                fprintf(fid,'    if (oDims[i]!=iDims[i]) {\n');
                fprintf(fid,'      ssSetErrorStatus(S, "Output %d: incompatible dimension during forward propagation versus default dimension");\n',ii);
                fprintf(fid,'    }\n');
                fprintf(fid,'  }\n');
                fprintf(fid,'}\n');
                fprintf(fid,'\n');


                fprintf(fid,'/* Set default dimensions if some are dynamically sized */\n');
                fprintf(fid,'if (hasDynSize) {\n');
                fprintf(fid,'  oDims[%d] = (oDims[%d]==1 ? 2 : oDims[%d]);\n',nbDims-1,nbDims-1,nbDims-1);
                fprintf(fid,'  dimsInfo.numDims = %d;\n',nbDims);
                fprintf(fid,'  dimsInfo.dims = &oDims[0];\n');
                fprintf(fid,'  dimsInfo.width = 1;\n');
                fprintf(fid,'  for (i = 0; i < dimsInfo.numDims; i++) {\n');
                fprintf(fid,'    dimsInfo.width *= oDims[i];\n');
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

