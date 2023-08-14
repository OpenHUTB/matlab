function hC=getRelopCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline,relopType)



    hC=[];
    if~targetmapping.isValidDataType(hInSignals(1).Type)
        return;
    end

    [~,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));
    coregenBlkName=generateCoregenBlkName(relopType,baseType,className);
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


    targetLanguage=hdlgetparameter('target_language');
    if strcmpi(targetLanguage,'vhdl')


        [hC,num]=xilinxtarget.getTargetSpecificRelopInstantiationComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName);
    else
        [hC,num]=xilinxtarget.getTargetSpecificInstantiationCompsWithTwoInputs(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName);
    end

    paramsTempFile=[];
    if~isempty(targetCompInventory)

        opInCLI='Relop';


        [fid,paramsTempFile]=xilinxtarget.generateCoregenParamsFile(targetCompInventory,pipeline);


        fprintf(fid,'# BEGIN Parameters\n');

        if~isempty(precisionType)
            fprintf(fid,'CSET a_precision_type=%s\n',precisionType);
        end


        fprintf(fid,'CSET operation_type=Compare\n');
        switch(relopType)
        case '==',
            fprintf(fid,'CSET c_compare_operation=Equal\n');
        case '~=',
            fprintf(fid,'CSET c_compare_operation=Not_Equal\n');
        case '<',
            fprintf(fid,'CSET c_compare_operation=Less_Than\n');
        case '<=',
            fprintf(fid,'CSET c_compare_operation=Less_Than_Or_Equal\n');
        case '>',
            fprintf(fid,'CSET c_compare_operation=Greater_Than\n');
        case '>=',
            fprintf(fid,'CSET c_compare_operation=Greater_Than_Or_Equal\n');
        case 'isNaN',
            fprintf(fid,'CSET c_compare_operation=Unordered\n');
        case{'isInf','isFinite'},
            error(message('hdlcommon:targetcodegen:XilinxCoregenUnsupportedMode',relopType));
        end

        fprintf(fid,'CSET c_a_exponent_width=%d\n',WIDTH_EXP);
        fprintf(fid,'CSET c_a_fraction_width=%d\n',WIDTH_MAN);
        fprintf(fid,'CSET c_result_exponent_width=1\n');
        fprintf(fid,'CSET c_result_fraction_width=0\n');
        fprintf(fid,'CSET component_name=%s\n',coregenBlkName);
        fprintf(fid,'CSET c_latency=%d\n',pipeline);
        fprintf(fid,'CSET result_precision_type=Custom\n');


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


    function coregenBlkName=generateCoregenBlkName(relopType,baseType,className)
        coregenBlkName=xilinxtarget.generateCoregenBlkName(baseType,className);
        switch(relopType)
        case '==',
            coregenBlkName=sprintf('%s_aeb',coregenBlkName);
        case '~=',
            coregenBlkName=sprintf('%s_aneb',coregenBlkName);
        case '<',
            coregenBlkName=sprintf('%s_alb',coregenBlkName);
        case '<=',
            coregenBlkName=sprintf('%s_aleb',coregenBlkName);
        case '>',
            coregenBlkName=sprintf('%s_agb',coregenBlkName);
        case '>=',
            coregenBlkName=sprintf('%s_ageb',coregenBlkName);
        case 'isNaN',
            coregenBlkName=sprintf('%s_unordered',coregenBlkName);
        case{'isInf','isFinite'},
            error(message('hdlcommon:targetcodegen:AlteraMegaWizardUnsupportedMode',relopType));
        end



