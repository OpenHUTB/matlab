function writeSfcnMdlOutputs(h,fid,infoStruct)




    fprintf(fid,'/* Function: mdlOutputs ===================================================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    In this function, you compute the outputs of your S-function\n');
    fprintf(fid,' *    block. Generally outputs are placed in the output vector(s),\n');
    fprintf(fid,' *    ssGetOutputPortSignal.\n');
    fprintf(fid,' */\n');

    fprintf(fid,'static void mdlOutputs(SimStruct *S, int_T tid)\n');
    fprintf(fid,'{\n');

    if infoStruct.Fcns.Output.IsSpecified



        if infoStruct.hasBusOrStruct==true
            fprintf(fid,'if (isDWorkNeeded(S)) {\n');
        end


        h.writeSfcnTempVariableForStructInfo(fid,infoStruct);



        h.writeSfcnArgumentAccess(fid,infoStruct,infoStruct.Fcns.Output);

        fprintf(fid,'\n');


        h.writeSfcnTempVariableFor2DRowMatrix(fid,infoStruct,infoStruct.Fcns.Output);


        h.writeSfcnTempVariableForUserStruct(fid,infoStruct,infoStruct.Fcns.Output);


        h.writeSfcnSLStructToUserStruct(fid,infoStruct,infoStruct.Fcns.Output);


        h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.Output,true);


        fprintf(fid,'/*\n');
        fprintf(fid,' * Call the legacy code function\n');
        fprintf(fid,' */\n');
        fprintf(fid,'%s;\n',h.generateSfcnFcnCallString(infoStruct,infoStruct.Fcns.Output));


        h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.Output,false);


        h.writeSfcnUserStructToSLStruct(fid,infoStruct,infoStruct.Fcns.Output);


        h.writeSfcnPWorkUpdate(fid,infoStruct,infoStruct.Fcns.Output);


        if infoStruct.hasBusOrStruct==true

            fprintf(fid,'}\n');
        end

    end

    fprintf(fid,'}\n');
    fprintf(fid,'\n');


