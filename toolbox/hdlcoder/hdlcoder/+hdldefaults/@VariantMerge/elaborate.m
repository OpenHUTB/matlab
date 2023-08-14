



function new_hC=elaborate(~,hN,hC)
    if slfeature('STVariantsInHDL')==0
        return;
    end
    hOutSignals=hC.PirOutputSignals;
    hInSignals=hC.PirInputSignals;
    hP=hOutSignals.getDrivers;
    hOutSignals.disconnectDriver(hP);



    parentVSSBlk=getParentVSSBlock(hInSignals);
    slbh=get_param(parentVSSBlk,'Handle');
    blkname=[parentVSSBlk,'/',hC.Name];

    ml2pirSettings={'OriginalSLHandle',slbh,'ParentNetwork',hN,...
    'SLRate',hC.PirInputSignals(1).SimulinkRate,'Traceability',hdlgetparameter('Traceability')};

    fcnInfoRegistry=internal.ml2pir.variantmerge.FunctionInfoRegistryCache.getCacheValue(blkname);

    fcnTypeInfo=fcnInfoRegistry.registry.values;
    fcnTypeInfo=fcnTypeInfo{1};

    builder=internal.ml2pir.variantmerge.PIRGraphBuilder(ml2pirSettings{:});

    fcn2pir=internal.ml2pir.Function2SubsystemConverter(...
    fcnInfoRegistry,[],fcnTypeInfo,builder);

    fcnNtwk=get_param(blkname,'Name');
    new_hC=fcn2pir.run(fcnNtwk);


    [~,inputVariables]=slInternal('getVariantSSInfoForHDL',slbh);

    assert(length(inputVariables)==length(unique(inputVariables)));
    variableSignals{length(inputVariables)}=[];
    for index=1:length(inputVariables)



        pirType=new_hC.ReferenceNetwork.PirInputSignals(index).Type;
        variableSignals{index}=hN.addSignal(pirType,['variable_signal_',inputVariables{index}]);
        variableSignals{index}.SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
        pirelab.getConstComp(hN,...
        variableSignals{index},...
        0,...
        inputVariables{index},'on',1,inputVariables{index},'','');
    end

    for index=1:numel(variableSignals)
        variableSignals{index}.addReceiver(new_hC,index-1);
    end

    outSignal=hN.addSignal(new_hC.ReferenceNetwork.PirOutputSignals.Type,'Selected_Index');
    outSignal.SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
    outSignal.addDriver(new_hC,0);




    hInSig=[new_hC.PirOutputSignals(1)];

    for index=1:length(hInSignals)
        hInSig(end+1)=hInSignals(index);%#ok<AGROW>
    end

    pirelab.getMultiPortSwitchComp(hN,...
    hInSig,...
    hOutSignals(1),...
    1,2,...
    'Floor','Wrap','VSS_Switch');


    hN.flattenNic(new_hC);
    new_hC=hC;
end


function vssBlk=getParentVSSBlock(hInSignals)
    vssBlk=get_param(hInSignals(1).SimulinkHandle,'Parent');
    while strcmp(get_param(vssBlk,'variant'),'off')
        vssBlk=get_param(vssBlk,'Parent');
    end
end


