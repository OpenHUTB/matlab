function blkInfo=getBlockInfo(~,hC)











    inputType=getInputType(hC);
    if isa(hC,'hdlcoder.sysobj_comp')
        denominator=hC.getSysObjImpl.Denominator;
    else
        denominator=hdlslResolve('denominator',hC.SimulinkHandle());
    end
    blkInfo.algorithm=fixed.system.ModByConstant.getAlgorithm(denominator,inputType);
    blkInfo.Latency=fixed.system.ModByConstant.getAlgorithmLatency(inputType,blkInfo.algorithm);
    ratPack=struct('Numerator',1,'Denominator',denominator,'Multiple',1);
    divByConstTypes=fixed.system.RoundToMultiple.getTypesTable(ratPack,inputType,false);
    divByConstConstants=fixed.system.RoundToMultiple.getConstantsTable(ratPack,inputType);
    blkInfo.typesTable=fixed.system.ModByConstant.getTypesTable(denominator,inputType);
    blkInfo.constTable=fixed.system.ModByConstant.getConstantsTable(denominator,inputType);

    for f=fieldnames(divByConstTypes)'
        blkInfo.typesTable.(f{1})=divByConstTypes.(f{1});
    end
    blkInfo.typesTable=emblibhdl.pirutils.toPirTypesTable(blkInfo.typesTable);

    for f=fieldnames(divByConstConstants)'
        blkInfo.constTable.(f{1})=divByConstConstants.(f{1});
    end




    blkInfo.SimulinkRate=hC.PirInputSignals(1).SimulinkRate;

end

function inputType=getInputType(hC)


    inputPort=hC.PirInputPorts();
    inputType=fixed.internal.type.extractNumericType(inputPort(1).getSLTypeInfo);
    inputType=fi([],inputType);

end
