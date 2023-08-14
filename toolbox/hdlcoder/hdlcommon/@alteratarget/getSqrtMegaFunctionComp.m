function hC=getSqrtMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)



    hC=[];
    if~targetmapping.isValidDataType(hInSignals(1).Type)...
        &&~targetmapping.isValidDataType(hOutSignals(1).Type)
        return;
    end

    [~,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));
    altMegaFunctionName=alteratarget.generateMegafunctionName(baseType,className);

    if baseType.isDoubleType
        WIDTH_EXP=11;
        WIDTH_MAN=52;
    elseif baseType.isSingleType
        WIDTH_EXP=8;
        WIDTH_MAN=23;
    end


    [hC,num]=alteratarget.getTargetSpecificInstantiationCompsWithOneInput(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName);

    [fid,mfparamsTempFile]=alteratarget.generateMegafunctionParamsFile;

    fprintf(fid,'dataa=dataa\n');
    fprintf(fid,'result=result\n');


    fprintf(fid,'PIPELINE=%d\n',pipeline);
    fprintf(fid,'WIDTH_EXP=%d\n',WIDTH_EXP);
    fprintf(fid,'WIDTH_MAN=%d\n',WIDTH_MAN);


    fclose(fid);

    if~isempty(targetCompInventory)

        alteratarget.generateMegafunction(targetCompInventory,altMegaFunctionName,'altfp_sqrt',mfparamsTempFile,pipeline,num);
    end

    try

        delete(mfparamsTempFile);
    catch me
        rethrow(me);
    end


