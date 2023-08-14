function generateHDLModel(obj)



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



        numNetworks=numel(obj.SolverTypes);
        stateSpaceParameters=obj.StateSpaceParameters;


        sschdlProductSumCustomLatency=hdlget_param(simscapeModel,'sschdlMatrixProductSumCustomLatency');




        [PsBlockData,inputMapData,outputMapData]=utilGenerateInputOutputMap(simscapeModel);
        obj.SpsPssConverterBlks=PsBlockData;
        obj.StateSpaceInputMap=inputMapData;
        obj.StateSpaceOutputMap=outputMapData;
        stateSpaceInputMap=obj.StateSpaceInputMap;
        stateSpaceOutputMap=obj.StateSpaceOutputMap;
        stateSpaceParametersVarName=cell(1,numNetworks);
        if~obj.SolverTypes(1)


            for i=1:numNetworks
                stateSpaceParametersVarName{i}=strcat(utilGetVarName(stateSpaceParameters),'_',num2str(i));


                [inputTable,outputTable]=utilLogicTableData(stateSpaceParameters(i).mode,stateSpaceParameters(i).ModeVec2StateConfig);
                stateSpaceParameters(i).logicTableInput=inputTable;
                stateSpaceParameters(i).logicTableOutput=outputTable;
                stateSpaceParameters(i).mode=logical(stateSpaceParameters(i).mode);
                eval([stateSpaceParametersVarName{i},'= stateSpaceParameters(i);']);
                fileName=utilGetVarName(stateSpaceParameters);
                if i==1
                    save(strcat(fileName,'.mat'),stateSpaceParametersVarName{i});
                else
                    save(strcat(fileName,'.mat'),stateSpaceParametersVarName{i},'-append');
                end
            end
        end



        if obj.linearize
            simscapeModel=obj.linearModel;
        end



        for validationMode=0:double(obj.GenerateValidation)


            genModel=utilGetValidIdentifier(strcat(obj.HDLModelPrefix,simscapeModel));


            if validationMode
                genModel=strcat(genModel,obj.HDLVnlModelSuffix);
                obj.HDLVnlModel=genModel;
            else
                obj.HDLModel=genModel;
            end






            sscReplaceFlag=~validationMode&&obj.GenerateAutomaticLayout...
            &&~obj.linearize;


            utilSaveAsModel(simscapeModel,genModel);


            [stateSpaceInputMap,stateSpaceOutputMap]=...
            utilUpdateInputOutputMap(stateSpaceInputMap,stateSpaceOutputMap,genModel);




            hhdlSystem=zeros(1,numNetworks);


            hinterfaceSystems=zeros(1,numNetworks);



            if sscReplaceFlag





                try

                    obj.FailedReplacementID='';



                    origSubsystem=utilPreprocessSimscapeNetwork(genModel,obj);



                    origSubsystemParent=cell(numNetworks,1);
                    for i=1:numNetworks
                        origSubsystemParent{i}=get_param(origSubsystem(i),'Parent');
                    end











                catch me





                    sscReplaceFlag=false;
                    obj.FailedReplacementMessage=me.message;
                    obj.FailedReplacementID=me.identifier;
                    bdclose(genModel);
                    utilSaveAsModel(simscapeModel,genModel);
                    [stateSpaceInputMap,stateSpaceOutputMap]=...
                    utilUpdateInputOutputMap(stateSpaceInputMap,stateSpaceOutputMap,genModel);




                end
            end


            for i=1:numNetworks
                if~obj.SolverTypes(i)


                    if stateSpaceParameters(i).NumberOfSwitchingModes==1
                        numberOfSolverIterations=1;
                    else


                        if obj.UseFixedCost
                            numberOfSolverIterations=obj.NumFixedCostIters;
                        else

                            numberOfSolverIterations=obj.NumberOfSolverIterations;
                        end
                    end




                    if obj.linearize
                        for ii=1:numel(obj.linearizationInfo(i).switchValues)
                            stateSpaceInputMap{i}{obj.linearizationInfo(i).switchValues(ii).inputNum,1}=getfullname(obj.linearizationInfo(i).switchValues(ii).handle);
                        end

                        for ii=1:numel(obj.linearizationInfo(i).IGBTValues)
                            stateSpaceInputMap{i}{obj.linearizationInfo(i).IGBTValues(ii).inputNum,1}=getfullname(obj.linearizationInfo(i).IGBTValues(ii).handle);
                        end
                    end
                    sampleTime(i)=stateSpaceParameters(i).DiscreteSampleTime;
                else




                    if obj.UseFixedCost
                        numberOfSolverIterations=obj.NumFixedCostIters;
                    else

                        numberOfSolverIterations=obj.NumberOfSolverIterations;
                    end
                    sampleTime(i)=obj.PartSolvers{i}.SampleTime;
                end




                if obj.SolverTypes(1)
                    numberOfSolverIterations=obj.PartSolvers{i}.setNumSolverIter(numberOfSolverIterations);
                end

                singleRateModel=obj.SingleRateModel&&numberOfSolverIterations>1&&...
                strcmpi(hdlfeature('SSCHDLModeIterOpt'),'on')&&...
                ~strcmpi(hdlfeature('SSCHDLNonLinear'),'on');

                if sscReplaceFlag


                    hinterfaceSystems(i)=utilAddSubsystem(origSubsystemParent{i},'Interface System',[100,100,150,150],'cyan');


                    if(~obj.SolverTypes(i))
                        initialInputs=stateSpaceParameters(i).U0;
                    else


                        initialInputs=0;
                    end


                    [interfaceSystemInMap,filterInfo]=utilRouteSPSInputsV2(hinterfaceSystems(i),stateSpaceInputMap{i},...
                    origSubsystem(i),initialInputs,obj.HDLAlgorithmDataType,obj.SolverTypes(i),obj.linearize);

                else


                    hinterfaceSystems(i)=utilAddSubsystem(genModel,'Interface System',[100,100*i,150,150*i],'cyan');


                    if(~obj.SolverTypes(i))
                        initialInputs=stateSpaceParameters(i).U0;
                    else




                        initialInputs=0;
                    end




                    [interfaceSystemInMap,filterInfo]=utilRouteSPSInputs(hinterfaceSystems(i),stateSpaceInputMap{i},i,...
                    initialInputs,obj.HDLAlgorithmDataType,obj.SolverTypes(i),obj.linearize);
                end







                [hhdlAlgorithmSystemIn,hhdlAlgorithmSystemOut,hhdlSystem(i),hhdlAlgorithmSystemEnableOut2,hhdlAlgorithmSystem]=utilConnectInterfaceSystem(hinterfaceSystems(i),...
                interfaceSystemInMap,stateSpaceOutputMap{i},...
                sampleTime(i),obj.HDLAlgorithmDataType,numberOfSolverIterations,...
                singleRateModel,sscReplaceFlag,stateSpaceInputMap{i},filterInfo,obj.SolverTypes(i));


                if obj.SolverTypes(1)

                    obj.PartSolvers{i}=obj.PartSolvers{i}.setLocationToDraw(getfullname(hhdlAlgorithmSystem));
                    obj.PartSolvers{i}=obj.PartSolvers{i}.sethInhOut(hhdlAlgorithmSystemIn,hhdlAlgorithmSystemOut,hhdlAlgorithmSystemEnableOut2);
                    obj.PartSolvers{i}=obj.PartSolvers{i}.setDataType(obj.HDLAlgorithmDataType);

                    numInputs=0;
                    for inputBlock=1:size(stateSpaceInputMap{i},1)
                        inputSize=prod(stateSpaceInputMap{i}{inputBlock,2}{3});
                        numInputs=numInputs+inputSize;
                    end
                    obj.PartSolvers{i}=obj.PartSolvers{i}.setNumInputs(numInputs);

                    obj.PartSolvers{i}.drawSolver();
                    obj.PartSolvers{i}.saveData();

                    partSolverOversampling(i)=obj.PartSolvers{i}.systemLatency;
                    stateSpaceParameters(i)=obj.StateSpaceParameters;
                    stateSpaceParametersVarName{i}='';
                else


                    if strcmpi(hdlfeature('SSCHDLModeIterOpt'),'on')&&~strcmpi(hdlfeature('SSCHDLNonLinear'),'on')

                        utilImplementHDLAlgorithm_v2(hhdlAlgorithmSystem,hhdlAlgorithmSystemIn,hhdlAlgorithmSystemOut,stateSpaceParametersVarName{i},...
                        stateSpaceParameters(i),numberOfSolverIterations,obj.HDLAlgorithmDataType,...
                        sschdlProductSumCustomLatency,hhdlAlgorithmSystemEnableOut2,singleRateModel,obj.linearizationInfo(i));
                    else

                        utilImplementHDLAlgorithm(hhdlAlgorithmSystem,hhdlAlgorithmSystemIn,hhdlAlgorithmSystemOut,stateSpaceParametersVarName{i},...
                        stateSpaceParameters(i),numberOfSolverIterations,obj.HDLAlgorithmDataType,sschdlProductSumCustomLatency);
                    end

                end
                if sscReplaceFlag




                    utilReplaceBlocks(hinterfaceSystems(i),origSubsystem(i));

                end
                if~obj.SolverTypes(i)


                    if nnz(stateSpaceParameters(i).Ad)>0




                        if size(size(stateSpaceParameters(i).Ad),2)>1
                            numMult=nnz(stateSpaceParameters(i).Ad(:,:,1))+nnz(stateSpaceParameters(i).Bd(:,:,1))+nnz(stateSpaceParameters(i).Cd(:,:,1))+nnz(stateSpaceParameters(i).Dd(:,:,1))...
                            +size(stateSpaceParameters(i).Ad,1);
                            numElementsA=nnz(stateSpaceParameters(i).Ad(:,:,1));
                        else
                            numMult=nnz(stateSpaceParameters(i).Ad)+nnz(stateSpaceParameters(i).Bd)+nnz(stateSpaceParameters(i).Cd)+nnz(stateSpaceParameters(i).Dd)...
                            +size(stateSpaceParameters(i).Ad,1);
                            numElementsA=nnz(stateSpaceParameters(i).Ad);
                        end

                        availibleMult=800;

                        sharingFactorA=ceil(-numElementsA/(numMult-availibleMult-numElementsA));
                        if sharingFactorA<1
                            sharingFactorA=1;
                        end
                        if sharingFactorA>size(stateSpaceParameters(i).Ad,1)
                            sharingFactorA=size(stateSpaceParameters(i).Ad,1);
                        end


                        hdlset_param(strcat(getfullname(hhdlSystem(i)),'/HDL Algorithm/State Update/Multiply State'),'SharingFactor',sharingFactorA);
                    end
                end

                setUseRam(hhdlSystem(i),obj.UseRAM,obj.UseRAMThreshold,stateSpaceParameters(i),stateSpaceParametersVarName{i},obj.SolverTypes(i));

                obj.HDLSubsystems(i)=hhdlSystem(i);
            end


            initFcn=get_param(genModel,'InitFcn');
            if~obj.SolverTypes(1)
                initFcn=[initFcn,newline,strcat('load(''',fullfile(newDir,strcat(fileName,'.mat')),''');')];%#ok<AGROW> 
            else
                for i=1:numel(obj.PartSolvers)
                    fileName=obj.PartSolvers{i}.DataName;
                    initFcn=[initFcn,newline,strcat('load(''',fullfile(newDir,strcat(fileName,'.mat')),''');')];%#ok<AGROW>
                end

            end
            set_param(genModel,'InitFcn',initFcn);



            if~sscReplaceFlag






                hhdlModel=get_param(genModel,'Handle');
                hhdlModelBlks=find_system(hhdlModel,'SearchDepth',1,...
                'FollowLinks','on',...
                'LookUnderMasks','all',...
                'IncludeCommented','on');

                hhdlModelAnnotations=find_system(hhdlModel,'SearchDepth',1,...
                'FindAll','on',...
                'Type','Annotation');

                hhdlModelBlks=setdiff(hhdlModelBlks,hhdlModel);

                hhdlModelBlks=setdiff(hhdlModelBlks,hinterfaceSystems);


                hhdlModelBlks=union(hhdlModelBlks,hhdlModelAnnotations);




                Simulink.BlockDiagram.createSubsystem(hhdlModelBlks);


                newSystem=find_system(hhdlModel,'SearchDepth',1,'Selected','on');




                if~validationMode
                    obj.SimscapeSubsystem=getfullname(newSystem);
                end

                for ii=1:numNetworks
                    interfaceSystemName=get_param(hinterfaceSystems(ii),'Name');
                    Simulink.BlockDiagram.expandSubsystem(hinterfaceSystems(ii));



                    hinterfaceSystemArea=find_system(hhdlModel,'SearchDepth',1,...
                    'FindAll','on',...
                    'Type','Annotation',...
                    'Name',interfaceSystemName);
                    if isempty(hinterfaceSystemArea)
                        hinterfaceSystemAreaPos=[100,100,150,150];
                    else
                        hinterfaceSystemAreaPos=get_param(hinterfaceSystemArea,'Position');
                    end

                    if ii==1
                        relPos=hinterfaceSystemAreaPos;
                    end





                    numOutputs=numel(stateSpaceOutputMap{ii});

                    if validationMode&&numOutputs>0
                        hvalidationSystem=utilAddSubsystem(genModel,'Validation',[700,100,800,175],'cyan');

                        utilImplementValidationSystem(hvalidationSystem,hhdlSystem(ii),getfullname(newSystem),stateSpaceOutputMap{ii},...
                        obj.ValidationTolerance,ii,sampleTime(ii));
                    else
                        hvalidationSystem=[];
                    end

                    if~isempty(hvalidationSystem)
                        set_param(hvalidationSystem,'Position',[hinterfaceSystemAreaPos(3)-125,hinterfaceSystemAreaPos(4)+25,hinterfaceSystemAreaPos(3),hinterfaceSystemAreaPos(4)+150]);
                    end
                end



                set_param(newSystem,'Position',[relPos(1),relPos(2)-500,relPos(1)+1200,relPos(2)-250]);
            end


            nfpConfigSettings=hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint','LatencyStrategy','MIN');
            hdlset_param(genModel,'FloatingPointTargetConfiguration',nfpConfigSettings);

            if strcmp(hdlfeature('SSCHDLAutoSharing'),'on')


                partNumber='IO334';
                utilAutoSharingFactor(obj.HDLSubsystems,stateSpaceParameters,obj.HDLAlgorithmDataType,nfpConfigSettings,partNumber);
            end


            if~(obj.linearize)&&~obj.SolverTypes(1)
                oversampling=utilOverSamplingFactor(obj.HDLSubsystems,...
                stateSpaceParameters,...
                obj.HDLAlgorithmDataType,...
                nfpConfigSettings);
            elseif(obj.linearize)
                oversampling=60;
            else

                oversampling=sum(partSolverOversampling(:));
            end


            hdlset_param(genModel,'ml2pir','on');
            hdlset_param(genModel,'HDLSubsystem',getfullname(hhdlSystem(end)));
            hdlset_param(genModel,'Oversampling',oversampling);
            hdlset_param(genModel,'MaskParameterAsGeneric','on');



            hdlset_param(genModel,'FPToleranceValue',obj.ValidationTolerance);



            set_param(genModel,'FixedStep','Auto');







            dtc=Simulink.findBlocksOfType(genModel,'DataTypeConversion');

            for i=1:length(dtc)
                set_param(getfullname(dtc(i)),'RndMeth','Nearest');
            end



            if~sscReplaceFlag
                Simulink.BlockDiagram.arrangeSystem(genModel,'FullLayout','True','Animation','False');
            end

            set_param(genModel,'Zoomfactor','fit to view')

            save_system(genModel);
            if~(validationMode)

                hdlSettingsFileName='hdl_settings.m';
                hdlsaveparams(genModel,hdlSettingsFileName,true);

                obj.HDLModelSettingsFile=fullfile(newDir,hdlSettingsFileName);
            end

            bdclose(genModel);

            load_system(genModel);
        end

        cd(currentDir);
    catch me

        if exist('genModel','var')
            if bdIsLoaded(genModel)
                bdclose(genModel);
            end
        end
        if bdIsLoaded(genModel)
            bdclose(genModel);
        end

        cd(currentDir);
        throwAsCaller(me);
    end
end

function setUseRam(h,useRAM,RAMMappingThreshold,stateSpaceParameters,stateSpaceParametersVarName,solverType)%#ok<INUSL>



    sysName=find_system(getfullname(h),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','hdlssclib/NFPSparseConstMultiply');

    for i=1:numel(sysName)
        matrixName=get_param(sysName{i},'constMatrix');
        if(solverType==0)

            matrix=eval(strrep(matrixName,stateSpaceParametersVarName,'stateSpaceParameters'));
        else

            sspMatFile=char(regexp(matrixName,'f\d+(?=.)','match'));
            load(sspMatFile,sspMatFile);
            matrix=eval(matrixName);
        end

        if nnz(matrix)>0
            numModes=size(matrix,3);
            if strcmpi(useRAM,'Auto')
                if(numModes>RAMMappingThreshold)
                    hdlset_param(sysName{i},'UseRAM','on');
                else
                    hdlset_param(sysName{i},'UseRAM','off');
                end
            else
                hdlset_param(sysName{i},'UseRAM',useRAM);
            end
        end
    end
end





