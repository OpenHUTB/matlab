function hC=getAddSubCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)



    hC=[];
    if~targetmapping.isValidDataType(hInSignals(1).Type)...
        &&~targetmapping.isValidDataType(hOutSignals(1).Type)
        return;
    end

    [~,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));

    coregenBlkName=xilinxtarget.generateCoregenBlkName(baseType,className,lower(mnemonic));
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


    [hC,num]=xilinxtarget.getTargetSpecificInstantiationCompsWithTwoInputs(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName);
    paramsTempFile=[];
    if~isempty(targetCompInventory)

        opInCLI='AddSub';


        [fid,paramsTempFile]=xilinxtarget.generateCoregenParamsFile(targetCompInventory,pipeline);

        operation='Add';
        if strcmpi(mnemonic,'SUB')
            operation='Subtract';
        end


        fprintf(fid,'# BEGIN Parameters\n');

        if~isempty(precisionType)
            fprintf(fid,'CSET a_precision_type=%s\n',precisionType);
            fprintf(fid,'CSET result_precision_type=%s\n',precisionType);
        end


        fprintf(fid,'CSET operation_type=Add_Subtract\n');
        fprintf(fid,'CSET add_sub_value=%s\n',operation);
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


