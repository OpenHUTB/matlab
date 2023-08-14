function linearizeSwitches(obj)




    simscapeModel=obj.SimscapeModel;

    try








        currentDir=pwd;

        newDir=fullfile(currentDir,'sschdl',simscapeModel);
        utilCreateDir(newDir);
        obj.ProjectDir=newDir;

        oldMatlabPath=path;
        path(pwd,oldMatlabPath);
        restoreOldMatlabPath=onCleanup(@()path(oldMatlabPath));

        cd(newDir);
        restoreCurrentDir=onCleanup(@()cd(currentDir));



        obj.utilCalculateRs();

        if obj.modelOrderReductionValLogic
            obj.utilModelOrderReductionValidation();
        end
        linearModel=utilGetValidIdentifier(strcat(obj.linearModelPrefix,simscapeModel));
        utilSaveAsModel(simscapeModel,linearModel);
        obj.linearModel=linearModel;



        dynamicSystems=obj.DynamicSystemObj;
        listOfSwitches=obj.listOfSwitches;
        switches=cell(numel(dynamicSystems),1);
        diodes=cell(numel(dynamicSystems),1);
        IGBTs=cell(numel(dynamicSystems),1);
        nlInductors=cell(numel(dynamicSystems),1);

        for i=1:numel(listOfSwitches)
            if listOfSwitches(i).Approx
                switch listOfSwitches(i).Type

                case 'Switch'
                    switches{listOfSwitches(i).NetworkNum}=[switches{listOfSwitches(i).NetworkNum};{listOfSwitches(i).Name,listOfSwitches(i).Rs}];
                case 'Diode'
                    diodes{listOfSwitches(i).NetworkNum}=[diodes{listOfSwitches(i).NetworkNum};{listOfSwitches(i).Name,listOfSwitches(i).Rs}];
                case 'IGBT'
                    IGBTs{listOfSwitches(i).NetworkNum}=[IGBTs{listOfSwitches(i).NetworkNum};{listOfSwitches(i).Name,listOfSwitches(i).Rs}];
                case 'Nonlinear Inductor'
                    nlInductors{listOfSwitches(i).NetworkNum}=[nlInductors{listOfSwitches(i).NetworkNum};{listOfSwitches(i).Name,listOfSwitches(i).Rs}];
                end
            end
        end





        for numNetworks=1:numel(dynamicSystems)

            if isempty(switches)&&isempty(diodes)&&isempty(IGBTs)&&isempty(nlInductors)
                obj.linearModel='';
                me=MException('linearizecallback:NothingToLinearize',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:NothingToLinearize').getString);
                throwAsCaller(me);
            end

            if obj.modelOrderReductionValLogic
                utilPejovicReplacement(switches{numNetworks},...
                diodes{numNetworks},IGBTs{numNetworks},nlInductors{numNetworks},obj.spsBlks{numNetworks},...
                obj.linearModelVldn);
            end


            [switchValues,diodeValues,IGBTValues,nlInductorValues]=utilPejovicReplacement(switches{numNetworks},...
            diodes{numNetworks},IGBTs{numNetworks},nlInductors{numNetworks},obj.spsBlks{numNetworks},...
            linearModel);
            obj.linearizationInfo(numNetworks).switchValues=switchValues;
            obj.linearizationInfo(numNetworks).diodeValues=diodeValues;
            obj.linearizationInfo(numNetworks).IGBTValues=IGBTValues;
            obj.linearizationInfo(numNetworks).nlInductorValues=nlInductorValues;
        end




        numModeBlks=0;
        for i=1:numel(obj.SolverConfiguration)
            blk=find_system(obj.SolverConfiguration{i},'LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',2,'Name','STATE_1');

            hblk=get_param(blk{1},'handle');
            graphInfo=get_param(hblk,'MxParameters');
            numModeBlks=numModeBlks+graphInfo.dae.NumModes;
        end

        if numModeBlks==0

            set_param(linearModel,'StopTime','0')
        end





        [simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths]=utilGetSimscapeSF(linearModel);

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


        for numNetworks=1:numel(obj.SolverConfiguration)

            [spsBlks,pssBlks]=utilGetConverterBlocks(inputs{numNetworks},outputs{numNetworks});


            [switchSourceMap,diodeSourceMap,IGBTSourceMap,nlInductorSourceMap]=createConverterMaps(size(switches{numNetworks},1),...
            size(diodes{numNetworks},1),size(IGBTs{numNetworks},1),size(nlInductors{numNetworks},1),spsBlks,pssBlks,...
            arrayfun(@(IO)IO.Dimension(1,2),dynamicSystems{numNetworks}.Input),...
            arrayfun(@(IO)IO.Dimension(1,2),dynamicSystems{numNetworks}.Output));


            obj.linearizationInfo(numNetworks).switchMap=switchSourceMap;
            obj.linearizationInfo(numNetworks).diodeMap=diodeSourceMap;
            obj.linearizationInfo(numNetworks).IGBTMap=IGBTSourceMap;
            obj.linearizationInfo(numNetworks).nlInductorMap=nlInductorSourceMap;
        end
        save_system(linearModel);
        if obj.modelOrderReductionValLogic
            save_system(obj.linearModelVldn)
        end
    catch me

        throwAsCaller(me);
    end
end


function[switchSourceMap,diodeSourceMap,IGBTSourceMap,nlInductorSourceMap]=createConverterMaps(numSwitches,numDiodes,numIGBTS,numInductors,spsBlks,pssBlks,inputDimentions,outputDimentions)
    switchSourceMap=zeros(numSwitches,3);
    diodeSourceMap=zeros(numDiodes,3);
    IGBTSourceMap=zeros(numIGBTS,3);
    nlInductorSourceMap=zeros(numInductors,3);
















    inputNum=1;

    for i=1:numel(spsBlks)

        converterFullName=split(spsBlks{i},'/');



        switchNumber=regexp(converterFullName{end},'HDLLinSwitchJ(\d+)','tokens');
        if~isempty(switchNumber)
            switchSourceMap(str2double(switchNumber{1}{1}),1)=inputNum;

        end

        diodeNumber=regexp(converterFullName{end},'HDLLinDiodeJ(\d+)','tokens');
        if~isempty(diodeNumber)
            diodeSourceMap(str2double(diodeNumber{1}{1}),1)=inputNum;

        end
        IGBTNumber=regexp(converterFullName{end},'HDLLinIGBTJ(\d+)','tokens');
        if~isempty(IGBTNumber)
            IGBTSourceMap(str2double(IGBTNumber{1}{1}),1)=inputNum;

        end

        nlInductorNumber=regexp(converterFullName{end},'HDLLinnlInductorJ(\d+)','tokens');
        if~isempty(nlInductorNumber)
            nlInductorSourceMap(str2double(nlInductorNumber{1}{1}),1)=inputNum;

        end
        inputNum=inputNum+inputDimentions(i);
    end

    outputNum=1;

    for i=1:numel(pssBlks)

        converterFullName=split(pssBlks{i},'/');



        switchNumber=regexp(converterFullName{end},'HDLLinSwitchVoltage(\d+)','tokens');
        if~isempty(switchNumber)
            switchSourceMap(str2double(switchNumber{1}{1}),2)=outputNum;

        end
        switchNumber=regexp(converterFullName{end},'HDLLinSwitchCurrent(\d+)','tokens');
        if~isempty(switchNumber)
            switchSourceMap(str2double(switchNumber{1}{1}),3)=outputNum;

        end

        diodeNumber=regexp(converterFullName{end},'HDLLinDiodeVoltage(\d+)','tokens');
        if~isempty(diodeNumber)
            diodeSourceMap(str2double(diodeNumber{1}{1}),2)=outputNum;

        end
        diodeNumber=regexp(converterFullName{end},'HDLLinDiodeCurrent(\d+)','tokens');
        if~isempty(diodeNumber)
            diodeSourceMap(str2double(diodeNumber{1}{1}),3)=outputNum;

        end
        IGBTNumber=regexp(converterFullName{end},'HDLLinIGBTVoltage(\d+)','tokens');
        if~isempty(IGBTNumber)
            IGBTSourceMap(str2double(IGBTNumber{1}{1}),2)=outputNum;

        end

        IGBTNumber=regexp(converterFullName{end},'HDLLinIGBTCurrent(\d+)','tokens');
        if~isempty(IGBTNumber)
            IGBTSourceMap(str2double(IGBTNumber{1}{1}),3)=outputNum;
        end

        nlInductorNumber=regexp(converterFullName{end},'HDLLinnlInductorVoltage(\d+)','tokens');
        if~isempty(nlInductorNumber)
            nlInductorSourceMap(str2double(nlInductorNumber{1}{1}),2)=outputNum;

        end

        nlInductorNumber=regexp(converterFullName{end},'HDLLinnlInductorCurrent(\d+)','tokens');
        if~isempty(nlInductorNumber)
            nlInductorSourceMap(str2double(nlInductorNumber{1}{1}),3)=outputNum;
        end

        outputNum=outputNum+outputDimentions(i);

    end
end










