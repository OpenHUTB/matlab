function hC=getSqrtCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)



    hC=[];
    if~targetmapping.isValidDataType(hInSignals(1).Type)...
        &&~targetmapping.isValidDataType(hOutSignals(1).Type)
        return;
    end

    [~,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));
    coregenBlkName=xilinxtarget.generateCoregenBlkName(baseType,className);
    precisionType=[];
    if baseType.isDoubleType
        WIDTH_EXP=11;
        WIDTH_MAN=53;
        precisionType='Double';
    elseif baseType.isSingleType
        WIDTH_EXP=8;
        WIDTH_MAN=24;
        precisionType='Single';
    end


    [hC,num]=xilinxtarget.getTargetSpecificInstantiationCompsWithOneInput(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName);
    paramsTempFile=[];
    if~isempty(targetCompInventory)

        opInCLI='Sqrt';


        [fid,paramsTempFile]=xilinxtarget.generateCoregenParamsFile(targetCompInventory,pipeline);


        fprintf(fid,'# BEGIN Parameters\n');

        if~isempty(precisionType)
            fprintf(fid,'CSET a_precision_type=%s\n',precisionType);
            fprintf(fid,'CSET result_precision_type=%s\n',precisionType);
        end


        fprintf(fid,'CSET operation_type=Square_root\n');
        fprintf(fid,'CSET c_a_exponent_width=%d\n',WIDTH_EXP);
        fprintf(fid,'CSET c_a_fraction_width=%d\n',WIDTH_MAN);
        fprintf(fid,'CSET c_result_exponent_width=%d\n',WIDTH_EXP);
        fprintf(fid,'CSET c_result_fraction_width=%d\n',WIDTH_MAN);
        fprintf(fid,'CSET component_name=%s\n',coregenBlkName);
        fprintf(fid,'CSET c_latency=%d\n',pipeline);


        extraArgs=xilinxtarget.generateStandardCoregenParams(fid,opInCLI,precisionType);


        fclose(fid);

        xilinxtarget.generateCoregenBlk(targetCompInventory,coregenBlkName,opInCLI,paramsTempFile,extraArgs,pipeline,num);
    end

    try
        if~isempty(paramsTempFile)

            delete(paramsTempFile);
        end
    catch me
        rethrow(me);
    end


