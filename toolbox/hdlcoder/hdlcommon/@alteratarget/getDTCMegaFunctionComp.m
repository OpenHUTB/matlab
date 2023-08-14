function hC=getDTCMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)




    hC=[];
    if~targetmapping.isValidDataType(hInSignals(1).Type)...
        &&~targetmapping.isValidDataType(hOutSignals(1).Type)
        return;
    end

    altMegaFunctionName=generateMegafunctionName(hInSignals(1),hOutSignals(1),className);

    [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
    if dimlen>1
        hC=alteratarget.getVectorMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName,@getScalarDTCMegafunctionComp,pipeline);
    else
        hC=getScalarDTCMegafunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName,pipeline);
    end

    function hC=getScalarDTCMegafunctionComp(targetCompInventory,hN,hInSignal,hOutSignal,altMegaFunctionName,pipeline)
        inType=hInSignal.Type;
        outType=hOutSignal.Type;

        [ip,fp]=extractFixPtParts(inType);
        OPERATION='';
        if ip>0
            if fp==0
                OPERATION='INT2FLOAT';
            else
                OPERATION='FIXED2FLOAT';
            end
            WIDTH_DATA=ip+fp;
            WIDTH_INT=ip;
            if outType.isDoubleType
                WIDTH_EXP_OUTPUT=11;
                WIDTH_MAN_OUTPUT=52;
                WIDTH_RESULT=64;
            elseif outType.isSingleType
                WIDTH_EXP_OUTPUT=8;
                WIDTH_MAN_OUTPUT=23;
                WIDTH_RESULT=32;
            end
        else

            [ip,fp]=extractFixPtParts(outType);
            if ip>0
                WIDTH_RESULT=ip+fp;
                WIDTH_INT=ip;
                if fp==0
                    OPERATION='FLOAT2INT';
                else
                    OPERATION='FLOAT2FIXED';
                end
                if inType.isDoubleType
                    WIDTH_EXP_INPUT=11;
                    WIDTH_MAN_INPUT=52;
                    WIDTH_DATA=64;
                elseif inType.isSingleType
                    WIDTH_EXP_INPUT=8;
                    WIDTH_MAN_INPUT=23;
                    WIDTH_DATA=32;
                end
            end
        end

        if isempty(OPERATION)

            hC=pirelab.getWireComp(hN,hInSignal,hOutSignal);
            return;
        end


        [hC,num]=alteratarget.getTargetSpecificInstantiationCompsWithOneInput(targetCompInventory,hN,hInSignal,hOutSignal,altMegaFunctionName);

        hC.setInputPortName(0,'dataa');


        [fid,mfparamsTempFile]=alteratarget.generateMegafunctionParamsFile;

        fprintf(fid,'dataa=dataa\n');
        fprintf(fid,'result=result\n');


        fprintf(fid,'OPERATION=%s\n',OPERATION);
        fprintf(fid,'WIDTH_DATA=%d\n',WIDTH_DATA);
        fprintf(fid,'WIDTH_INT=%d\n',WIDTH_INT);
        fprintf(fid,'WIDTH_RESULT=%d\n',WIDTH_RESULT);

        switch(OPERATION)
        case{'INT2FLOAT','FIXED2FLOAT'},





            fprintf(fid,'WIDTH_EXP_OUTPUT=%d\n',WIDTH_EXP_OUTPUT);
            fprintf(fid,'WIDTH_MAN_OUTPUT=%d\n',WIDTH_MAN_OUTPUT);
        case{'FLOAT2INT','FLOAT2FIXED'},
            fprintf(fid,'WIDTH_EXP_INPUT=%d\n',WIDTH_EXP_INPUT);
            fprintf(fid,'WIDTH_MAN_INPUT=%d\n',WIDTH_MAN_INPUT);
        end

        fprintf(fid,'PIPELINE=%d\n',pipeline);



        fc=hdlgetparameter('FloatingPointTargetConfiguration');
        typeStr=inType.getTargetCompDataTypeStr(outType,true);
        ipName='Convert';
        ips=fc.IPConfig.getIPSettings(ipName,typeStr);
        if(isempty(ips))
            typeStr=inType.getTargetCompDataTypeStr(outType,false);
            assert(~isempty(fc.IPConfig.getIPSettings(ipName,typeStr)));
        end
        extraArgs=targetcodegen.targetCodeGenerationUtils.getExtraArgs(ipName,typeStr);
        fprintf(fid,'%s\n',extraArgs);


        fclose(fid);

        if~isempty(targetCompInventory)

            alteratarget.generateMegafunction(targetCompInventory,altMegaFunctionName,'altfp_convert',mfparamsTempFile,pipeline,num);
        end

        try

            delete(mfparamsTempFile);
        catch me
            rethrow(me);
        end

        hC.setTargetIP(true);


        function[ip,fp]=extractFixPtParts(aType)
            ip=0;
            fp=0;
            if~aType.isFloatType
                wl=aType.WordLength;
                fl=aType.FractionLength;
                ip=wl+fl;

                if fl<0
                    fp=0-fl;
                end
            end


            function altMegaFunctionName=generateMegafunctionName(hInSignal,hOutSignal,className)
                [~,baseInType]=pirelab.getVectorTypeInfo(hInSignal);
                [~,baseOutType]=pirelab.getVectorTypeInfo(hOutSignal);
                altMegaFunctionName=targetcodegen.alteradriver.getFunctionName(className);
                [ip,fp]=extractFixPtParts(baseInType);
                if ip>0
                    if baseOutType.isDoubleType
                        altMegaFunctionName=sprintf('%s_fixpt_w%d_f%d_to_double',altMegaFunctionName,ip+fp,fp);
                    elseif baseOutType.isSingleType
                        altMegaFunctionName=sprintf('%s_fixpt_w%d_f%d_to_single',altMegaFunctionName,ip+fp,fp);
                    end
                else
                    [ip,fp]=extractFixPtParts(baseOutType);
                    if ip>0
                        if baseInType.isDoubleType
                            altMegaFunctionName=sprintf('%s_double_to_fixpt_w%d_f%d',altMegaFunctionName,ip+fp,fp);
                        elseif baseInType.isSingleType
                            altMegaFunctionName=sprintf('%s_single_to_fixpt_w%d_f%d',altMegaFunctionName,ip+fp,fp);
                        end
                    end
                end



