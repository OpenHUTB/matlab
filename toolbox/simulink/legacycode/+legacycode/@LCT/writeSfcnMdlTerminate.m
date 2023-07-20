function writeSfcnMdlTerminate(h,fid,infoStruct)






    nbInfo=size(infoStruct.DataTypes.BusInfo.BusElementHashTable,1);

    fprintf(fid,'/* Function: mdlTerminate =================================================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    In this function, you should perform any actions that are necessary\n');
    fprintf(fid,' *    at the termination of a simulation.\n');
    fprintf(fid,' */\n');
    fprintf(fid,'static void mdlTerminate(SimStruct *S)\n');
    fprintf(fid,'{\n');



    if infoStruct.hasBusOrStruct==true
        fprintf(fid,'if (isDWorkNeeded(S)) {\n');
    end

    if infoStruct.Fcns.Terminate.IsSpecified
        if nbInfo~=0
            fprintf(fid,'{\n');
        end


        h.writeSfcnTempVariableForStructInfo(fid,infoStruct);


        h.writeSfcnArgumentAccess(fid,infoStruct,infoStruct.Fcns.Terminate);

        fprintf(fid,'\n');


        h.writeSfcnTempVariableFor2DRowMatrix(fid,infoStruct,infoStruct.Fcns.Terminate);


        h.writeSfcnTempVariableForUserStruct(fid,infoStruct,infoStruct.Fcns.Terminate);


        h.writeSfcnSLStructToUserStruct(fid,infoStruct,infoStruct.Fcns.Terminate);


        h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.Terminate,true);

        fprintf(fid,'/*\n');
        fprintf(fid,' * Call the legacy code function\n');
        fprintf(fid,' */\n');
        fprintf(fid,'%s;\n',h.generateSfcnFcnCallString(infoStruct,infoStruct.Fcns.Terminate));


        h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.Terminate,false);


        h.writeSfcnUserStructToSLStruct(fid,infoStruct,infoStruct.Fcns.Terminate);


        h.writeSfcnPWorkUpdate(fid,infoStruct,infoStruct.Fcns.Terminate);

        if nbInfo~=0
            fprintf(fid,'}\n');
        end

    end



    if infoStruct.hasBusOrStruct==true


        if nbInfo~=0

            for ii=1:infoStruct.DWorks.NumDWorkForBus

                thisDWork=infoStruct.DWorks.DWorkForBus(ii);
                thisDataType=infoStruct.DataTypes.DataType(thisDWork.DataTypeId);
                thisDWorkNumber=infoStruct.DWorks.NumPWorks+ii-1;
                varName=sprintf('__%sBUS',thisDWork.Identifier);
                fprintf(fid,'/*\n');
                fprintf(fid,' * Free memory for the pwork %d (%s)\n',thisDWorkNumber,varName);
                fprintf(fid,' */\n');
                fprintf(fid,'{\n');
                fprintf(fid,'    %s* %s = (%s*)ssGetPWorkValue(S, %d);',...
                thisDataType.DTName,varName,thisDataType.DTName,thisDWorkNumber);
                fprintf(fid,'    if (%s!=NULL) {\n',varName);
                fprintf(fid,'        free(%s);\n',varName);
                fprintf(fid,'        ssSetPWorkValue(S, %d, NULL);\n',thisDWorkNumber);
                fprintf(fid,'    }\n');
                fprintf(fid,'}\n');
            end
        end
        fprintf(fid,'}\n');
    end

    fprintf(fid,'}\n\n');


