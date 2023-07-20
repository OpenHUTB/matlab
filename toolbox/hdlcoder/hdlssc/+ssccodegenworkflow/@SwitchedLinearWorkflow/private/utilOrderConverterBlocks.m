function[spsBlks,pssBlks]=utilOrderConverterBlocks(dynamicSystem,Inputs,Outputs,spsBlks,pssBlks)





    expectedIn=cell(1,numel(dynamicSystem.Input));
    actualIn=cell(1,numel(dynamicSystem.Input));

    for sps=1:numel(spsBlks)
        expectedIn{sps}=dynamicSystem.Input(sps).Name;
        actualIn{sps}=Inputs(sps).path;
    end

    [~,idxIn]=ismember(expectedIn,actualIn);

    spsBlks=spsBlks(idxIn);

    expectedOut=cell(1,numel(dynamicSystem.Output));
    actualOut=cell(1,numel(dynamicSystem.Output));

    for pss=1:numel(pssBlks)
        expectedOut{pss}=dynamicSystem.Output(pss).Name;
        actualOut{pss}=Outputs(pss).path;
    end

    [~,idxOut]=ismember(expectedOut,actualOut);

    pssBlks=pssBlks(idxOut);
end
