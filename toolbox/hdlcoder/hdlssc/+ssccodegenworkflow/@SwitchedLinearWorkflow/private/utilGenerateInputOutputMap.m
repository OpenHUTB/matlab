function[PsBlockData,InputMapData,OutputMapData]=utilGenerateInputOutputMap(simscapeModel)




    [simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths]=utilGetSimscapeSF(simscapeModel);

    PsBlockData=cell(1,numel(simscapeSF));
    InputMapData=cell(1,numel(simscapeSF));
    OutputMapData=cell(1,numel(simscapeSF));
    inputs=cell(1,numel(simscapeSF));
    outputs=cell(1,numel(simscapeSF));
    dynamicSystems=cell(1,numel(simscapeSF));

    if iscell(simscapeSF)
        for k=1:numel(simscapeSF)
            dynamicSystem=utilGetDynamicSystem(simscapeSF{k},simscapeSFInputs{k},simscapeSFOutputs{k},solverPaths{k});
            inputs{k}=simscapeSFInputs{k};
            outputs{k}=simscapeSFOutputs{k};
            dynamicSystems{k}=dynamicSystem;
        end
    else
        dynamicSystems{1}=utilGetDynamicSystem(simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths);
        inputs{1}=simscapeSFInputs;
        outputs{1}=simscapeSFOutputs;
    end

    for i=1:numel(dynamicSystems)
        if strcmp(hdlfeature('SSCHDLNonLinear'),'on')


            spsBlks=find_system(simscapeModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','ReferenceBlock','nesl_utility/Simulink-PS Converter');
            pssBlks=find_system(simscapeModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','ReferenceBlock','nesl_utility/PS-Simulink Converter');
        else

            [spsBlks,pssBlks]=utilGetConverterBlocks(inputs{i},outputs{i});
        end
        [spsBlks,pssBlks]=utilOrderConverterBlocks(dynamicSystems{i},inputs{i},outputs{i},spsBlks,pssBlks);
        [inputMap,outputMap]=utilMapConverterBlocks(dynamicSystems{i},spsBlks,pssBlks);

        InputMapData{i}=inputMap;
        OutputMapData{i}=outputMap;
        PsBlockData{i}=[spsBlks,pssBlks];
    end


