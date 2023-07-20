function writeSfcnMdlStart(h,fid,infoStruct)






    nbInfo=size(infoStruct.DataTypes.BusInfo.BusElementHashTable,1);


    if(infoStruct.Fcns.Start.IsSpecified==0)&&(nbInfo==0)
        return
    end

    fprintf(fid,'#define MDL_START\n');
    fprintf(fid,'#if defined(MDL_START)\n');
    fprintf(fid,'  /* Function: mdlStart =====================================================\n');
    fprintf(fid,'   * Abstract:\n');
    fprintf(fid,'   *    This function is called once at start of model execution. If you\n');
    fprintf(fid,'   *    have states that should be initialized once, this is the place\n');
    fprintf(fid,'   *    to do it.\n');
    fprintf(fid,'   */\n');
    fprintf(fid,'  static void mdlStart(SimStruct *S)\n');
    fprintf(fid,'  {\n');



    if infoStruct.hasBusOrStruct==true
        fprintf(fid,'if (isDWorkNeeded(S)) {\n');
    end

    if nbInfo~=0

        h.writeSfcnTempVariableForStructInfo(fid,infoStruct);

        fprintf(fid,'/* Get common data type Id */\n');
        for ii=1:numel(infoStruct.DataTypes.BusInfo.DataTypeSizeTable)
            fprintf(fid,'DTypeId __%sId = ssGetDataTypeId(S, "%s");\n',...
            infoStruct.DataTypes.BusInfo.DataTypeSizeTable{ii},...
            infoStruct.DataTypes.BusInfo.DataTypeSizeTable{ii});
        end
        fprintf(fid,'\n');

        fprintf(fid,'/* Get common data type size */\n');
        for ii=1:numel(infoStruct.DataTypes.BusInfo.DataTypeSizeTable)
            fprintf(fid,'__dtSizeInfo[%d] = ssGetDataTypeSize(S, __%sId);\n',...
            ii-1,infoStruct.DataTypes.BusInfo.DataTypeSizeTable{ii});
        end
        fprintf(fid,'\n');


        for ii=1:size(infoStruct.DataTypes.BusInfo.BusElementHashTable,1)
            fprintf(fid,'/* Get information for accessing %s */\n',...
            infoStruct.DataTypes.BusInfo.BusElementHashTable{ii,2}.PathStr);
            fprintf(fid,'__dtBusInfo[%d] = %s;\n',...
            infoStruct.DataTypes.BusInfo.BusElementHashTable{ii,2}.OffsetIdx,...
            infoStruct.DataTypes.BusInfo.BusElementHashTable{ii,2}.OffsetStr);

            fprintf(fid,'__dtBusInfo[%d] = %s;\n',...
            infoStruct.DataTypes.BusInfo.BusElementHashTable{ii,2}.SizeIdx,...
            infoStruct.DataTypes.BusInfo.BusElementHashTable{ii,2}.SizeStr);

            fprintf(fid,'\n');
        end


        for ii=1:infoStruct.DWorks.NumDWorkForBus

            thisDWork=infoStruct.DWorks.DWorkForBus(ii);
            thisDataType=infoStruct.DataTypes.DataType(thisDWork.DataTypeId);
            thisDWorkNumber=infoStruct.DWorks.NumPWorks+ii-1;

            switch thisDWork.BusInfo.Type
            case 'Input'
                sizeStr=sprintf('ssGetInputPortWidth(S, %d)',thisDWork.BusInfo.DataId-1);

            case 'Output'
                sizeStr=sprintf('ssGetOutputPortWidth(S, %d)',thisDWork.BusInfo.DataId-1);

            case 'DWork'
                sizeStr=sprintf('ssGetDWorkWidth(S, %d)',thisDWork.BusInfo.DataId-1);

            case 'Parameter'
                sizeStr=sprintf('mxGetNumberOfElements(ssGetSFcnParam(S, %d))',thisDWork.BusInfo.DataId-1);

            otherwise

            end

            varName=sprintf('__%sBUS',thisDWork.Identifier);
            fprintf(fid,'/*\n');
            fprintf(fid,' * Configure the pwork %d (%s)\n',thisDWorkNumber,varName);
            fprintf(fid,' */\n');
            fprintf(fid,'{\n');
            fprintf(fid,'    %s* %s = (%s*)calloc(sizeof(%s), %s);',...
            thisDataType.DTName,varName,thisDataType.DTName,thisDataType.DTName,sizeStr);
            fprintf(fid,'    if (%s==NULL) { ssSetErrorStatus(S, "Unexpected error during the memory allocation for %s"); return; }\n',...
            varName,varName);
            fprintf(fid,'    ssSetPWorkValue(S, %d, %s);\n',thisDWorkNumber,varName);
            fprintf(fid,'}\n');
        end

        fprintf(fid,'\n');
    end

    if infoStruct.Fcns.Start.IsSpecified
        if nbInfo~=0
            fprintf(fid,'{\n');
        end


        h.writeSfcnArgumentAccess(fid,infoStruct,infoStruct.Fcns.Start);

        fprintf(fid,'\n');


        h.writeSfcnTempVariableFor2DRowMatrix(fid,infoStruct,infoStruct.Fcns.Start);


        h.writeSfcnTempVariableForUserStruct(fid,infoStruct,infoStruct.Fcns.Start);


        h.writeSfcnSLStructToUserStruct(fid,infoStruct,infoStruct.Fcns.Start);


        h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.Start,true);


        fprintf(fid,'/*\n');
        fprintf(fid,' * Call the legacy code function\n');
        fprintf(fid,' */\n');
        fprintf(fid,'%s;\n',h.generateSfcnFcnCallString(infoStruct,infoStruct.Fcns.Start));
        fprintf(fid,'\n');


        h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.Start,false);


        h.writeSfcnUserStructToSLStruct(fid,infoStruct,infoStruct.Fcns.Start);


        h.writeSfcnPWorkUpdate(fid,infoStruct,infoStruct.Fcns.Start);

        if nbInfo~=0
            fprintf(fid,'}\n');
        end

    end


    if infoStruct.hasBusOrStruct==true

        fprintf(fid,'}\n');
    end

    fprintf(fid,'  }\n');
    fprintf(fid,'#endif\n');

    fprintf(fid,'\n');


