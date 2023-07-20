function hC=getRelopMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline,relopType)



    hC=[];
    if~targetmapping.isValidDataType(hInSignals(1).Type)
        return;
    end


    [dimlen,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));
    altMegaFunctionName=generateMegafunctionName(relopType,baseType,className);
    if dimlen>1
        hC=alteratarget.getVectorRelopMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName,@getScalarRelopMegafunctionComp,pipeline,relopType);
    else
        hC=getScalarRelopMegafunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName,pipeline,relopType);
    end

    function hC=getScalarRelopMegafunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName,pipeline,relopType)



        [fid,mfparamsTempFile]=alteratarget.generateMegafunctionParamsFile;

        fprintf(fid,'dataa=dataa\n');
        fprintf(fid,'datab=datab\n');

        [~,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));

        if baseType.isDoubleType
            WIDTH_EXP=11;
            WIDTH_MAN=52;
        elseif baseType.isSingleType
            WIDTH_EXP=8;
            WIDTH_MAN=23;
        end


        fprintf(fid,'PIPELINE=%d\n',pipeline);
        fprintf(fid,'WIDTH_EXP=%d\n',WIDTH_EXP);
        fprintf(fid,'WIDTH_MAN=%d\n',WIDTH_MAN);

        switch(relopType)
        case '==',
            outPort='aeb';
            fprintf(fid,'aeb=aeb\n');
        case '~=',
            outPort='aneb';
            fprintf(fid,'aneb=aneb\n');
        case '<',
            outPort='alb';
            fprintf(fid,'alb=alb\n');
        case '<=',
            outPort='aleb';
            fprintf(fid,'aleb=aleb\n');
        case '>',
            outPort='agb';
            fprintf(fid,'agb=agb\n');
        case '>=',
            outPort='ageb';
            fprintf(fid,'ageb=ageb\n');
        case 'isNaN',
            outPort='unordered';
            fprintf(fid,'unordered=unordered\n');
        case{'isInf','isFinite'},
            error(message('hdlcommon:targetcodegen:AlteraMegaWizardUnsupportedMode',relopType));
        end


        alteratarget.applyExtraArgs(fid,'Relop',baseType);


        fclose(fid);


        [hC,numOfInst]=alteratarget.getTargetSpecificInstantiationCompsWithTwoInputs(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName);

        hC.setOutputPortName(0,outPort);

        if~isempty(targetCompInventory)

            alteratarget.generateMegafunction(targetCompInventory,altMegaFunctionName,'altfp_compare',mfparamsTempFile,pipeline,numOfInst);
        end

        try

            delete(mfparamsTempFile);
        catch me
            rethrow(me);
        end

        hC.setTargetIP(true);


        function altMegaFunctionName=generateMegafunctionName(relopType,baseType,className)
            altMegaFunctionName=alteratarget.generateMegafunctionName(baseType,className);
            switch(relopType)
            case '==',
                altMegaFunctionName=sprintf('%s_aeb',altMegaFunctionName);
            case '~=',
                altMegaFunctionName=sprintf('%s_aneb',altMegaFunctionName);
            case '<',
                altMegaFunctionName=sprintf('%s_alb',altMegaFunctionName);
            case '<=',
                altMegaFunctionName=sprintf('%s_aleb',altMegaFunctionName);
            case '>',
                altMegaFunctionName=sprintf('%s_agb',altMegaFunctionName);
            case '>=',
                altMegaFunctionName=sprintf('%s_ageb',altMegaFunctionName);
            case 'isNaN',
                altMegaFunctionName=sprintf('%s_unordered',altMegaFunctionName);
            case{'isInf','isFinite'},
                error(message('hdlcommon:targetcodegen:AlteraMegaWizardUnsupportedMode',relopType));
            end



