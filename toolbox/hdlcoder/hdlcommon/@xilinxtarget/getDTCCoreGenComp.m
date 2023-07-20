function hC=getDTCCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)



    hC=[];
    if~targetmapping.isValidDataType(hInSignals(1).Type)...
        &&~targetmapping.isValidDataType(hOutSignals(1).Type)
        return;
    end

    coregenBlkName=generateCoregenBlkName(hInSignals(1),hOutSignals(1),className);
    [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
    if dimlen>1
        hC=xilinxtarget.getVectorCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName,@getScalarDTCCoreGenComp,pipeline);
    else
        hC=getScalarDTCCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName,pipeline);
    end

    function hC=getScalarDTCCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName,pipeline)

        paramsTempFile=[];
        if~isempty(targetCompInventory)

            opInCLI='Convert';


            [fid,paramsTempFile]=xilinxtarget.generateCoregenParamsFile(targetCompInventory,pipeline);


            fprintf(fid,'# BEGIN Parameters\n');

            inType=hInSignals(1).Type;
            outType=hOutSignals(1).Type;

            [ip,fp]=extractFixPtParts(inType);
            OPERATION='';

            if ip>0
                OPERATION='Fixed_to_float';
                fprintf(fid,'CSET c_a_exponent_width=%d\n',ip);
                fprintf(fid,'CSET c_a_fraction_width=%d\n',fp);
                if fp==0
                    fprintf(fid,'CSET a_precision_type=Int32\n');
                else
                    fprintf(fid,'CSET a_precision_type=Custom\n');
                end

                if outType.isDoubleType
                    fprintf(fid,'CSET result_precision_type=Double\n');
                    fprintf(fid,'CSET c_result_exponent_width=11\n');
                    fprintf(fid,'CSET c_result_fraction_width=53\n');
                elseif outType.isSingleType
                    fprintf(fid,'CSET result_precision_type=Single\n');
                    fprintf(fid,'CSET c_result_exponent_width=8\n');
                    fprintf(fid,'CSET c_result_fraction_width=24\n');
                end
            else

                [ip,fp]=extractFixPtParts(outType);
                if ip>0
                    fprintf(fid,'CSET c_result_exponent_width=%d\n',ip);
                    fprintf(fid,'CSET c_result_fraction_width=%d\n',fp);
                    if fp==0
                        fprintf(fid,'CSET result_precision_type=Int32\n');
                    else
                        fprintf(fid,'CSET result_precision_type=Custom\n');
                    end
                    OPERATION='Float_to_fixed';
                    if inType.isDoubleType
                        fprintf(fid,'CSET a_precision_type=Double\n');
                        fprintf(fid,'CSET c_a_exponent_width=11\n');
                        fprintf(fid,'CSET c_a_fraction_width=53\n');
                    elseif inType.isSingleType
                        fprintf(fid,'CSET a_precision_type=Single\n');
                        fprintf(fid,'CSET c_a_exponent_width=8\n');
                        fprintf(fid,'CSET c_a_fraction_width=24\n');
                    end
                end
            end

            if isempty(OPERATION)

                hC=pirelab.getWireComp(hN,hInSignals,hOutSignals);
                fclose(fid);
                if~isempty(paramsTempFile)

                    delete(paramsTempFile);
                end
                return;
            end

            fprintf(fid,'CSET operation_type=%s\n',OPERATION);
            fprintf(fid,'CSET component_name=%s\n',coregenBlkName);
            fprintf(fid,'CSET c_latency=%d\n',pipeline);



            fc=hdlgetparameter('FloatingPointTargetConfiguration');
            typeStr=inType.getTargetCompDataTypeStr(outType,true);
            ipName='Convert';
            ips=fc.IPConfig.getIPSettings(ipName,typeStr);
            if(isempty(ips))
                typeStr=inType.getTargetCompDataTypeStr(outType,false);
                assert(~isempty(fc.IPConfig.getIPSettings(ipName,typeStr)));
            end
            extraArgs=xilinxtarget.generateStandardCoregenParams(fid,opInCLI,typeStr);


            fclose(fid);
        end


        [hC,num]=xilinxtarget.getTargetSpecificInstantiationCompsWithOneInput(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName);
        try
            if~isempty(paramsTempFile)

                xilinxtarget.generateCoregenBlk(targetCompInventory,coregenBlkName,opInCLI,paramsTempFile,extraArgs,pipeline,num);

                delete(paramsTempFile);
            end
        catch me
            rethrow(me);
        end



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


            function coregenBlkName=generateCoregenBlkName(hInSignal,hOutSignal,className)
                [~,baseInType]=pirelab.getVectorTypeInfo(hInSignal);
                [~,baseOutType]=pirelab.getVectorTypeInfo(hOutSignal);
                coregenBlkName=targetcodegen.xilinxdriver.getFunctionName(className);
                [ip,fp]=extractFixPtParts(baseInType);
                if ip>0
                    if baseOutType.isDoubleType
                        coregenBlkName=sprintf('%s_fixpt_w%d_f%d_to_double',coregenBlkName,ip+fp,fp);
                    elseif baseOutType.isSingleType
                        coregenBlkName=sprintf('%s_fixpt_w%d_f%d_to_single',coregenBlkName,ip+fp,fp);
                    end
                else
                    [ip,fp]=extractFixPtParts(baseOutType);
                    if ip>0
                        if baseInType.isDoubleType
                            coregenBlkName=sprintf('%s_double_to_fixpt_w%d_f%d',coregenBlkName,ip+fp,fp);
                        elseif baseInType.isSingleType
                            coregenBlkName=sprintf('%s_single_to_fixpt_w%d_f%d',coregenBlkName,ip+fp,fp);
                        end
                    end
                end



