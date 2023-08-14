classdef TestbenchExport<handle






    properties(Access=public)
serdesSystem
systemName
        customWorkflow=false;
        workspaceVariablesToSet=struct('position',{},'blockName',{},'parmeterName',{},'parameterValue',{});
    end
    properties(Constant,Access=public)

        mlSystemBlock='simulink/User-Defined Functions/MATLAB System';
        mlConstantBlock='simulink/Sources/Constant';
        mlDataStoreWriteBlock='simulink/Signal Routing/Data Store Write';
        mlDataStoreReadBlock='simulink/Signal Routing/Data Store Read';
        mlTerminatorBlock='simulink/Sinks/Terminator';
        stDataPathLibrary='serdesDatapath/';
        stUtilitiesLibrary='serdesUtilities/';

        template='serdesTxRxDual';

        subsystems={'Tx','Rx'};
        paramStorage='model_ws';
        blockSource='library';
        rowSizeParamName='RowSize';
        aggressorsParamName='Aggressors';

        sampleTimeParamName='SampleInterval';
        symbolTimeParamName='SymbolTime';
        targetBERParamName='TargetBER';
        channelImpulseParamName='ChannelImpulse';
        initImpulseParamName='ImpulseMatrix';
        stimulusParamName='StimulusPattern';
        modulationParamName='Modulation';
    end
    properties(Access=private)
        TxTree=[]
        RxTree=[]
        modelHandle=[]
    end
    methods

        function obj=TestbenchExport(sdsys)
            obj.serdesSystem=sdsys;
        end

        function systemHandle=exportSimulink(obj,varargin)

            warnstate=warning('off','Coder:configSet:Invalid_ToolchainName');
            systemHandle=Simulink.createFromTemplate(slfullfile(matlabroot,'toolbox','serdes','templates','serdesTxRxDual.sltx'));
            obj.modelHandle=systemHandle;
            warning(warnstate);
            load_system(systemHandle);


            serdes.internal.SetToolChain(systemHandle);

            coderTargetData=get_param(systemHandle,'CoderTargetData');
            coderTargetData.Placement.dllFileLocation=pwd;
            set_param(systemHandle,'CoderTargetData',coderTargetData);

            obj.systemName=get_param(systemHandle,'Name');
            paramWorkspace=get_param(systemHandle,'ModelWorkspace');


            if~isempty(obj.workspaceVariablesToSet)
                questdlg(message('serdes:export:WorkspaceVariables').getString,'Workspace variables','OK','OK');
            end

            codertarget.target.copyInactiveCodeMappingsIfNeeded(systemHandle);

            obj.createAmiTreesAndBlockVariables(paramWorkspace);


            maskConfig=Simulink.Mask.get([obj.systemName,'/Configuration']);
            maskConfigNames={maskConfig.Parameters.Name};
            tempSamplesPerSymbol=obj.serdesSystem.SymbolTime/obj.serdesSystem.dt;

            engSymbolTime=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.SymbolTime);
            maskConfig.Parameters(strcmp(maskConfigNames,'SymbolTime')).Value=engSymbolTime;
            maskConfig.Parameters(strcmp(maskConfigNames,'SamplesPerSymbol')).Value=num2str(tempSamplesPerSymbol);
            maskConfig.Parameters(strcmp(maskConfigNames,'TargetBER')).Value=num2str(obj.serdesSystem.BERtarget);



            if obj.serdesSystem.Modulation==3||obj.serdesSystem.Modulation>4

                obj.TxTree.removeLegacyModulationParameters;
                obj.RxTree.removeLegacyModulationParameters;

                obj.TxTree.addModulationParameters;
                obj.RxTree.addModulationParameters;

                obj.TxTree.setReservedParameterCurrentValue('Modulation_Levels',obj.serdesSystem.Modulation);
                obj.RxTree.setReservedParameterCurrentValue('Modulation_Levels',obj.serdesSystem.Modulation);
            end

            tempModulationValue=serdes.internal.callbacks.convertModulation(obj.serdesSystem.Modulation);
            maskConfig.Parameters(strcmp(maskConfigNames,'Modulation')).Value=string(tempModulationValue);

            clockmode=obj.serdesSystem.JitterAndNoise.RxClockMode;
            maskConfig.Parameters(strcmp(maskConfigNames,'EyeDiagramClockMode')).Value=clockmode;

            signaling=obj.serdesSystem.Signaling;
            signalingString='Differential';
            if~isempty(signaling)
                if strcmp(signaling,'Single Ended')||strcmp(signaling,'Single-ended')
                    convertedZ_c=obj.serdesSystem.ChannelData.ChannelDifferentialImpedance/2;
                    signalingString='Single-ended';
                else
                    convertedZ_c=obj.serdesSystem.ChannelData.ChannelDifferentialImpedance;
                end
            end
            maskConfig.Parameters(strcmp(maskConfigNames,'Signaling')).Value=signalingString;

            rt=obj.serdesSystem.TxModel.RiseTime;
            volts=obj.serdesSystem.TxModel.VoltageSwingIdeal;
            txR=obj.serdesSystem.TxModel.AnalogModel.R;
            txC=obj.serdesSystem.TxModel.AnalogModel.C;
            rxR=obj.serdesSystem.RxModel.AnalogModel.R;
            rxC=obj.serdesSystem.RxModel.AnalogModel.C;
            exportSerDesFileObj=serdes.internal.ibisami.ibis.SerDesIBISFile('name','SerdesIBIS');
            if~isempty(rt)
                exportSerDesFileObj.RiseTime=rt;
            end
            if~isempty(volts)
                exportSerDesFileObj.Voltage=volts;
            end
            if~isempty(txR)
                exportSerDesFileObj.ResistanceTx=txR;
            end
            if~isempty(txC)
                exportSerDesFileObj.CapacitanceTx=txC;
            end
            if~isempty(rxR)
                exportSerDesFileObj.ResistanceRx=rxR;
            end
            if~isempty(rxC)
                exportSerDesFileObj.CapacitanceRx=rxC;
            end
            if strcmp(signalingString,'Single-ended')
                exportSerDesFileObj.Differential=false;
            else
                exportSerDesFileObj.Differential=true;
            end
            paramWorkspace.assignin('SerdesIBIS',exportSerDesFileObj);




            maskChannel=Simulink.Mask.get([obj.systemName,'/Analog Channel']);
            maskChannelNames={maskChannel.Parameters.Name};

            engRiseTime=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.TxModel.RiseTime);
            engTxC=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.TxModel.AnalogModel.C);
            engRxC=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.RxModel.AnalogModel.C);
            engTargetFrequency=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.ChannelData.ChannelLossFreq);



            maskChannel.Parameters(strcmp(maskChannelNames,'TargetFrequency')).Value=engTargetFrequency;
            maskChannel.Parameters(strcmp(maskChannelNames,'Loss')).Value=num2str(obj.serdesSystem.ChannelData.ChannelLossdB);
            maskChannel.Parameters(strcmp(maskChannelNames,'Zc')).Value=num2str(convertedZ_c);

            maskChannel.Parameters(strcmp(maskChannelNames,'TxR')).Value=num2str(obj.serdesSystem.TxModel.AnalogModel.R);
            maskChannel.Parameters(strcmp(maskChannelNames,'TxC')).Value=engTxC;
            maskChannel.Parameters(strcmp(maskChannelNames,'RxR')).Value=num2str(obj.serdesSystem.RxModel.AnalogModel.R);
            maskChannel.Parameters(strcmp(maskChannelNames,'RxC')).Value=engRxC;
            maskChannel.Parameters(strcmp(maskChannelNames,'RiseTime')).Value=engRiseTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'VoltageSwingIdeal')).Value=num2str(obj.serdesSystem.TxModel.VoltageSwingIdeal);



            engSymbolTime=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.SymbolTime);
            maskChannel.Parameters(strcmp(maskChannelNames,'UIFEXT')).Value=engSymbolTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'UINEXT')).Value=engSymbolTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'UI1')).Value=engSymbolTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'UI2')).Value=engSymbolTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'UI3')).Value=engSymbolTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'UI4')).Value=engSymbolTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'UI5')).Value=engSymbolTime;
            maskChannel.Parameters(strcmp(maskChannelNames,'UI6')).Value=engSymbolTime;

            maskChannel.Parameters(strcmp(maskChannelNames,'ModulationFEXT')).Value=string(tempModulationValue);
            maskChannel.Parameters(strcmp(maskChannelNames,'ModulationNEXT')).Value=string(tempModulationValue);
            maskChannel.Parameters(strcmp(maskChannelNames,'Modulation1')).Value=string(tempModulationValue);
            maskChannel.Parameters(strcmp(maskChannelNames,'Modulation2')).Value=string(tempModulationValue);
            maskChannel.Parameters(strcmp(maskChannelNames,'Modulation3')).Value=string(tempModulationValue);
            maskChannel.Parameters(strcmp(maskChannelNames,'Modulation4')).Value=string(tempModulationValue);
            maskChannel.Parameters(strcmp(maskChannelNames,'Modulation5')).Value=string(tempModulationValue);
            maskChannel.Parameters(strcmp(maskChannelNames,'Modulation6')).Value=string(tempModulationValue);


            checkboxstr={'off','on'};
            maskChannel.Parameters(strcmp(maskChannelNames,'IncludeCrosstalkCheckBox')).Value=checkboxstr{obj.serdesSystem.ChannelData.EnableCrosstalk+1};
            if obj.serdesSystem.ChannelData.OptionSel==3&&obj.serdesSystem.ChannelData.EnableCrosstalk==1
                maskChannel.Parameters(strcmp(maskChannelNames,'CrosstalkSpecification')).Value=obj.serdesSystem.ChannelData.CrosstalkSpecification;
                if strcmp('Custom',obj.serdesSystem.ChannelData.CrosstalkSpecification)
                    engFEXTICN=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.ChannelData.FEXTICN);
                    maskChannel.Parameters(strcmp(maskChannelNames,'FEXTICN')).Value=engFEXTICN;

                    engNEXTICN=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.ChannelData.NEXTICN);
                    maskChannel.Parameters(strcmp(maskChannelNames,'NEXTICN')).Value=engNEXTICN;
                end
            end


            if obj.serdesSystem.ChannelData.OptionSel==1







                indexInStruct=find(strcmp('Channel',{obj.workspaceVariablesToSet.blockName}));


                if~isempty(indexInStruct)
                    blockParameterValue=obj.workspaceVariablesToSet(indexInStruct).parameterValue;
                    baseWorkspaceParameterValue=evalin('base',blockParameterValue);
                    paramWorkspace.assignin(blockParameterValue,baseWorkspaceParameterValue);
                    impulseStr=blockParameterValue;
                else

                    impulse=obj.serdesSystem.ChannelData.Impulse;
                    impulseStr='[';
                    for ii=1:size(impulse,1)
                        tmpstr=sprintf('%.50g,',impulse(ii,:));
                        tmpstr(end)=';';
                        impulseStr=[impulseStr,tmpstr];%#ok<AGROW>
                    end
                    impulseStr(end)=']';
                end
                maskChannel.Parameters(strcmp(maskChannelNames,'ImpulseResponse')).Value=impulseStr;
                maskChannel.Parameters(strcmp(maskChannelNames,'ChannelType')).Value='Impulse response';
                engdt=serdes.internal.callbacks.numberToEngString(obj.serdesSystem.ChannelData.dt);
                maskChannel.Parameters(strcmp(maskChannelNames,'ImpulseSampleInterval')).Value=engdt;
            end




            maskStimulus=Simulink.Mask.get([obj.systemName,'/Stimulus']);
            maskStimulusNames={maskStimulus.Parameters.Name};

            maskStimulus.Parameters(strcmp(maskStimulusNames,'NumberOfSymbols')).Value=string(20000);



            serdes.internal.callbacks.configurationUpdate([obj.systemName,'/Configuration'],"Initialization");
            serdes.internal.callbacks.analogChannelUpdate([obj.systemName,'/Analog Channel'],"Initialization");
            serdes.internal.callbacks.stimulusUpdate([obj.systemName,'/Stimulus'],"Initialization");


            IgnoreBits=10;
            for subsystemIdx=1:size(obj.subsystems,2)

                isTx=subsystemIdx==1;
                if isTx
                    tree=obj.TxTree;
                else
                    tree=obj.RxTree;
                end

                allproplist=properties(obj.serdesSystem.JitterAndNoise);
                if isTx
                    ndx=strncmpi(allproplist,'tx_',3);
                    proplist=allproplist(ndx);
                else
                    ndx=strncmpi(allproplist,'rx_',3);
                    proplist=allproplist(ndx);
                end



                uiUnitStr='in units of UI.';
                secUnitStr='in units of seconds.';
                hzUnitStr='in units of Hz.';
                for ii=1:length(proplist)

                    simpleJ=obj.serdesSystem.JitterAndNoise.(proplist{ii});

                    if simpleJ.Include

                        Param=serdes.internal.ibisami.ami.parameter.AmiParameter.getReservedParameter(...
                        proplist{ii});



                        Param.Type=simpleJ.Type;
                        Param.CurrentValue=simpleJ.Value;


                        switch proplist{ii}
                        case 'Tx_DCD'
                            d1='Transmit duty cycle distortion, defined as half of the peak to peak clock duty cycle distortion ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Tx_Rj'
                            d1='Transmit random jitter: the standard deviation of a white Gaussian phase noise process ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Tx_Dj'
                            d1='Transmit uncorrelated uniform jitter: the worst case half of the peak to peak variation ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Tx_Sj'
                            d1='Transmit sinusoidal jitter: half of the peak to peak amplitude ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Tx_Sj_Frequency'
                            d1='Transmit sinusoidal jitter frequency ';
                            d2=[d1,hzUnitStr];
                        case 'Rx_DCD'
                            d1='Receive duty cycle distortion, defined as half of the peak to peak clock duty cycle distortion ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Rj'
                            d1='Receive random jitter: the standard deviation of a Gaussian phase noise driven by impairments external to the receiver that are input to the Rx CDR but are not included in the CDR clock times output ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Dj'
                            d1='Receive uncorrelated uniform jitter: the worst case half of the peak to peak variation of the recovered clock not included by other receiver jitter ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Sj'
                            d1='Receive sinusoidal jitter: half of the peak to peak variation of a sinusoidal phase noise ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Clock_Recovery_Mean'
                            d1='Receive clock recovery mean: a static offset between the recovered clock and the point half way between the PDF median of consecutive edge transition times ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Clock_Recovery_Rj'
                            d1='Receive clock recovery random jitter: The standard deviation of a Gaussian phase noise exhibited by the recovered clock and included in the clock_times vector returned by the AMI_GetWave function ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Clock_Recovery_Dj'
                            d1='Receive clock uniform jitter: The worst case half of the peak to peak variation exhibited by the recovered clock and included in the clock_times vector returned by the AMI_GetWave function ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Clock_Recovery_Sj'
                            d1='Receive clock sinusoidal jitter: half of the peak to peak variation of a sinusoidal phase noise exhibited by the recovered clock and included in the clock_times vector returned by the AMI_GetWave function ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Clock_Recovery_DCD'
                            d1='Receive clock duty cycle distortion: half of the peak to peak variation of a clock duty cycle distortion exhibited by the recovered clock and included in the clock_times vector returned by the AMI_GetWave function ';
                            if strcmp(simpleJ.Type,'Float')
                                d2=[d1,secUnitStr];
                            else
                                d2=[d1,uiUnitStr];
                            end
                        case 'Rx_Receiver_Sensitivity'
                            d2='Minimum receiver voltage at data decision point to ensure proper sampling.';
                        case 'Rx_GaussianNoise'
                            d2='Receiver Gaussian random process to be added at the sampling latch: the standard deviation, in volts.';
                        case 'Rx_UniformNoise'
                            d2='Receiver bounded uniform random process to be added at the sampling latch: the worst-case half peak-to-peak variation, in volts.';
                        otherwise
                            d2='';
                        end
                        Param.Description=d2;


                        tree.addReservedParameter(Param)
                    end
                end


                subsystem=obj.subsystems{subsystemIdx};
                container=[obj.systemName,'/',subsystem];
                containerHandle=get_param(container,'Handle');

                inportHandle=get_param([obj.systemName,'/',subsystem,'/WaveIn'],'PortHandles');
                lastConnectionHandle=inportHandle.Outport(1);


                simulinkBlocks=obj.getSLBlocks(subsystem);


                if~isTx

                    ib=serdes.internal.ibisami.ami.parameter.general.IgnoreBits;
                    ib.CurrentValue=1000;
                    tree.addReservedParameter(ib);
                elseif isTx

                    ib=serdes.internal.ibisami.ami.parameter.general.IgnoreBits;
                    ib.CurrentValue=10;
                    tree.addReservedParameter(ib);
                end
                IgnoreBits=max([IgnoreBits,ib.CurrentValue]);

                for blockIdx=1:size(simulinkBlocks,2)
                    simulinkBlock=simulinkBlocks(blockIdx);
                    if~obj.customWorkflow
                        libraryBlockToAdd=[obj.stDataPathLibrary,extractAfter(simulinkBlock.sysobjname,'serdes.')];

                        simulinkBlock.handle=obj.addSimulinkBlock(libraryBlockToAdd,subsystem,simulinkBlock.instname);
                        blockMask=Simulink.Mask.get(simulinkBlock.handle);
                    else
                        libraryBlockToAdd=[obj.stDataPathLibrary,'PassThrough'];

                        simulinkBlock.handle=obj.addSimulinkBlock(libraryBlockToAdd,subsystem,simulinkBlock.instname);
                        blockMask=Simulink.Mask.get(simulinkBlock.handle);
                        subsystemPath=getfullname(simulinkBlock.handle);
                        isCDR=strcmp(simulinkBlock.sysobjname,'serdes.CDR');
                        isDFE=strcmp(simulinkBlock.sysobjname,'serdes.DFECDR');
                        soPath=[subsystemPath,'/PassThrough'];

                        maskDisplayCode=['disp(''Custom'');',newline...
                        ,'port_label(''input'',1,''WaveIn'');',newline...
                        ,'port_label(''output'',1,''WaveOut'');'];
                        blockMask.Display=maskDisplayCode;


                        if isCDR
                            soOutPort='PassThrough/1';
                            inPort='In/1';
                            outPort='Out/1';
                            delete_line(subsystemPath,soOutPort,outPort);
                            add_line(subsystemPath,inPort,outPort);
                        end


                        set_param(soPath,'System',simulinkBlock.sysobjname);

                        set_param(soPath,'Name',simulinkBlock.instname);
                        soPath=[subsystemPath,'/',simulinkBlock.instname];
                        soName=simulinkBlock.instname;

                        blockNode=getBlockNode(tree,soName);
                        blockAMIParameters=tree.getChildren(blockNode);
                        soBlockMask=Simulink.Mask.get(soPath);

                        for amiIdx=1:size(blockAMIParameters,2)
                            blockAMIParameters{amiIdx}.New=1;
                            portsToConnect=[];
                            amiParamName=blockAMIParameters{amiIdx}.NodeName;
                            isTaps=strcmp(amiParamName,'TapWeights');

                            [inputPortNames,outputPortNames]=...
                            serdes.internal.callbacks.getPortNames(soPath);

                            if isTaps
                                usage=tree.getTapsUsageOfBlock(soName);
                            else
                                usage=blockAMIParameters{amiIdx}.Usage.Name;
                            end
                            addReferences=false;
                            if strcmp(usage,'In')
                                inputPortToConnect=find(contains(inputPortNames,amiParamName));
                                portsToConnect=string([soName,'/',num2str(inputPortToConnect)]);
                                addReferences=true;
                            elseif strcmp(usage,'InOut')
                                inputPortToConnect=find(contains(inputPortNames,amiParamName));
                                outputPortToConnect=find(contains(outputPortNames,amiParamName));
                                portsToConnect=[string([soName,'/',num2str(inputPortToConnect)])...
                                ,string([soName,'/',num2str(outputPortToConnect)])];
                                addReferences=true;
                            elseif strcmp(usage,'Out')
                                outputPortToConnect=find(contains(outputPortNames,amiParamName));
                                portsToConnect=string([soName,'/',num2str(outputPortToConnect)]);
                                addReferences=true;
                            end

                            if addReferences
                                serdes.internal.ibisami.ami.manageAMISources('add',tree,blockAMIParameters{amiIdx},portsToConnect);
                            end
                        end




                        if isDFE||isCDR

                            obj.addClockBlock(subsystemPath,soName,outputPortNames);

                            obj.addPAM4Thresholds(subsystemPath,soName,outputPortNames);
                        end

                        warnStruct=warning('off','diagram_autolayout:autolayout:layoutRejectedCommandLine');
                        Simulink.BlockDiagram.arrangeSystem(simulinkBlock.handle);

                        warning(warnStruct);
                    end
                    simulinkBlocks(blockIdx).handle=simulinkBlock.handle;

                    blockPortHandles=get_param(simulinkBlock.handle,'PortHandles');
                    add_line(containerHandle,lastConnectionHandle(1),blockPortHandles.Inport(1),'autorouting','on');


                    if~strcmp(simulinkBlock.sysobjname,'serdes.CDR')||obj.customWorkflow
                        lastConnectionHandle=blockPortHandles.Outport(1);
                    end



                    serdesBlock=simulinkBlock.serdesBlock;
                    serdesBlockParameters=properties(serdesBlock);
                    blockAMIParameters=serdesBlock.getAMIParameters;
                    blockAMIParameterNames=string.empty;

                    for amiIdx=1:size(blockAMIParameters,2)
                        parameter=blockAMIParameters(amiIdx);

                        if isa(parameter{1},'serdes.internal.ibisami.ami.TappedDelayLine')
                            blockAMIParameterNames{amiIdx,1}=char(parameter{1}.Name);
                        else
                            blockAMIParameterNames{amiIdx,1}=char(parameter{1}.NodeName);
                        end
                    end

                    if obj.customWorkflow
                        blockMask=soBlockMask;
                    end
                    blockMaskNames={blockMask.Parameters.Name}';
                    parametersToSet=intersect(serdesBlockParameters,blockMaskNames);
                    parametersToSet=setdiff(parametersToSet,blockAMIParameterNames);
                    reservedParameters={'SymbolTime','SampleInterval','Modulation'};







                    blockToFind=simulinkBlock.instname;
                    blockHasWorkspaceVariable=false;
                    indexInStruct=find(strcmp(blockToFind,{obj.workspaceVariablesToSet.blockName}));
                    if isTx
                        currentPosition='Tx';
                    else
                        currentPosition='Rx';
                    end



                    if~isempty(indexInStruct)&&strcmp(obj.workspaceVariablesToSet(indexInStruct).position,currentPosition)
                        blockParameterName=obj.workspaceVariablesToSet(indexInStruct).parameterName;
                        blockParameterValue=obj.workspaceVariablesToSet(indexInStruct).parameterValue;
                        baseWorkspaceParameterValue=evalin('base',blockParameterValue);
                        paramWorkspace.assignin(blockParameterValue,baseWorkspaceParameterValue);
                        blockHasWorkspaceVariable=true;
                    end

                    for indxName=1:numel(parametersToSet)
                        if any(strcmp(parametersToSet{indxName},reservedParameters))
                            blockMask.Parameters(strcmp(blockMaskNames,parametersToSet{indxName})).Value=parametersToSet{indxName};
                        elseif~strcmp(parametersToSet{indxName},'WaveType')
                            if blockHasWorkspaceVariable&&strcmp(parametersToSet{indxName},blockParameterName)
                                parameterToSetValue=blockParameterValue;
                            else
                                parameterToSetValue=get(serdesBlock,parametersToSet{indxName});
                            end
                            if isa(parameterToSetValue,'char')
                                blockMask.Parameters(strcmp(blockMaskNames,parametersToSet{indxName})).Value=parameterToSetValue;
                            elseif isa(parameterToSetValue,'logical')
                                if parameterToSetValue
                                    parameterToSetValue='on';
                                else
                                    parameterToSetValue='off';
                                end
                                blockMask.Parameters(strcmp(blockMaskNames,parametersToSet{indxName})).Value=parameterToSetValue;
                            else
                                blockMask.Parameters(strcmp(blockMaskNames,parametersToSet{indxName})).Value=mat2str(parameterToSetValue);
                            end
                        end
                    end


                    if strcmp(simulinkBlock.sysobjname,'serdes.CTLE')&&~obj.customWorkflow

                        serdes.internal.callbacks.datapathCtleConfigUpdate(simulinkBlock.handle);

                        parameter=blockAMIParameters{strcmp('ConfigSelect',blockAMIParameterNames)};
                        set_param(simulinkBlock.handle,'ConfigSelect',string(parameter.CurrentValue));


                        subsystemPath=getfullname(simulinkBlock.handle);
                        soPath=[subsystemPath,'/CTLE'];
                        set_param(soPath,'PerformanceCriteria',simulinkBlock.serdesBlock.PerformanceCriteria);
                        set_param(soPath,'FilterMethod',simulinkBlock.serdesBlock.FilterMethod);
                    end
                end



                outportHandle=get_param(find_system(containerHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Outport'),'PortHandles');
                add_line(containerHandle,lastConnectionHandle(1),outportHandle.Inport(1),'autorouting','on');

                set_param(containerHandle,'ZoomFactor','FitSystem');


                serdes.internal.callbacks.initializeFunUpdate(container);


                if obj.customWorkflow
                    serdes.internal.callbacks.initializeFunUpdate(container);
                end
            end

            paramWorkspace.assignin('IgnoreBits',IgnoreBits);

            if systemHandle>0
                makeAMI=false;
                if nargin==3
                    makeAMI=varargin{1};
                    desiredMgrPos=varargin{2};
                end
                if~makeAMI




                    open_system(systemHandle);
                else
                    mgr=IbisAmiManager(exportSerDesFileObj,obj.TxTree,obj.RxTree,false);
                    currentMgrPos=mgr.ManagerFigure.Position;
                    screensize=get(0,'Screensize');
                    padX=9;
                    padY=30;
                    mgrPos=[desiredMgrPos(1)+padX...
                    ,screensize(4)-desiredMgrPos(2)-currentMgrPos(4)-padY...
                    ,currentMgrPos(3),currentMgrPos(4)];
                    mgr.ManagerFigure.Position=mgrPos;
                end
            end
        end
        function newBlockHandle=addSimulinkBlock(obj,blockLibPath,targetSubsystem,newBlockName,varargin)

            targetSubsystemPath=[obj.systemName,'/',targetSubsystem];
            newBlockPath=[targetSubsystemPath,'/',newBlockName];
            newBlockHandle=add_block(blockLibPath,newBlockPath,'MakeNameUnique','on');
            if~isempty(varargin)
                set_param(newBlockHandle,varargin{:});
            end

            newBlockPosition=get_param(newBlockHandle,'Position');
            blockHeight=newBlockPosition(4)-newBlockPosition(2);
            blockWidth=newBlockPosition(3)-newBlockPosition(1);


            deltaX=blockWidth*1.5;


            outportPath=find_system(targetSubsystemPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Outport');
            if~isempty(outportPath)

                outportPosition=get_param(char(outportPath),'Position');
                newOutportPosition=[outportPosition(1)+deltaX,outportPosition(2),...
                outportPosition(3)+deltaX,outportPosition(4)];
                set_param(outportPath{1},'Position',newOutportPosition);


                tweak=6;
                newBlockSize=[outportPosition(1),outportPosition(2)-(blockHeight/2-tweak),...
                outportPosition(1)+blockWidth,outportPosition(2)+(blockHeight/2+tweak)];
                set_param(newBlockHandle,'Position',newBlockSize);
            end
        end

        function simulinkBlocks=getSLBlocks(obj,subsystem)

            serdesSystemBlocks=obj.serdesSystem.([subsystem,'Model']).Blocks;


            simulinkBlocks=struct('sysobjname',{});

            for blockIdx=1:size(serdesSystemBlocks,2)
                simulinkBlocks(blockIdx).inputNames=getInputNames(serdesSystemBlocks{blockIdx});
                simulinkBlocks(blockIdx).outputNames=getOutputNames(serdesSystemBlocks{blockIdx});

                metaclassObj=metaclass(serdesSystemBlocks{blockIdx});
                simulinkBlocks(blockIdx).sysobjname=metaclassObj.Name;
                simulinkBlocks(blockIdx).defname=strrep(metaclassObj.Name,'serdes.','');
                simulinkBlocks(blockIdx).instname=serdesSystemBlocks{blockIdx}.BlockName;
                simulinkBlocks(blockIdx).properties=metaclassObj.PropertyList;
                simulinkBlocks(blockIdx).serdesBlock=serdesSystemBlocks{blockIdx};
                simulinkBlocks(blockIdx).amiParameters=serdesSystemBlocks{blockIdx}.getAMIParameters;
            end
        end





        function[inputPortNames,outputPortNames]=getPortNames(~,soMaskObj)
            display=soMaskObj.Display;
            splitDisplay=splitlines(display);
            displaySize=size(splitDisplay,1)-2;

            inputPortNames=cell(1,displaySize);
            inputPortNames(:)={''};
            outputPortNames=inputPortNames;
            for displayIdx=2:displaySize+1
                rowSplit=split(splitDisplay{displayIdx},'''');
                if strcmp(rowSplit{2},'input')
                    inputPortNames{displayIdx-1}=rowSplit{4};
                elseif strcmp(rowSplit{2},'output')
                    outputPortNames{displayIdx-1}=rowSplit{4};
                end
            end

            inputPortNames=inputPortNames(~cellfun('isempty',inputPortNames));
            outputPortNames=outputPortNames(~cellfun('isempty',outputPortNames));
        end

        function addClockBlock(obj,subsystemPath,soName,outputPortNames)

            busSelectorClockBlockHandle=add_block(...
            'simulink/Signal Routing/Bus Selector',...
            [subsystemPath,'/Clock Select'],...
            'MakeNameUnique','on');
            set_param(busSelectorClockBlockHandle,'OutputSignals','clockValidOnRising,clockTime');
            outputPortToConnect=find(contains(outputPortNames,'ClkAMI'));
            add_line(subsystemPath,...
            string([soName,'/',num2str(outputPortToConnect)]),...
            'Clock Select/1',...
            'autorouting','on');


            add_block(...
            [obj.stUtilitiesLibrary,'IBIS-AMI clock_times'],...
            [subsystemPath,'/Clock Times'],...
            'MakeNameUnique','on');
            add_line(subsystemPath,...
            'Clock Select/1',...
            'Clock Times/1',...
            'autorouting','on');
            add_line(subsystemPath,...
            'Clock Select/2',...
            'Clock Times/2',...
            'autorouting','on');
        end

        function addPAM4Thresholds(obj,subsystemPath,soName,outputPortNames)

            busSelectorPAM4BlockHandle=add_block(...
            'simulink/Signal Routing/Bus Selector',...
            [subsystemPath,'/PAM4 Select'],...
            'MakeNameUnique','on');
            set_param(busSelectorPAM4BlockHandle,'OutputSignals','PAM4Threshold');
            outputPortToConnect=find(contains(outputPortNames,'Interior'));
            add_line(subsystemPath,...
            string([soName,'/',num2str(outputPortToConnect)]),...
            'PAM4 Select/1',...
            'autorouting','on');

            pam4UpperBlockHandle=add_block(...
            obj.mlDataStoreWriteBlock,...
            [subsystemPath,'/PAM4 Upper'],...
            'MakeNameUnique','on');
            set_param(pam4UpperBlockHandle,'DataStoreName','PAM4_UpperThreshold');
            add_line(subsystemPath,...
            'PAM4 Select/1',...
            'PAM4 Upper/1',...
            'autorouting','on');

            pam4CenterBlockHandle=add_block(...
            obj.mlDataStoreWriteBlock,...
            [subsystemPath,'/PAM4 Center'],...
            'MakeNameUnique','on');
            set_param(pam4CenterBlockHandle,'DataStoreName','PAM4_CenterThreshold');
            pam4CenterConstantBlockHandle=add_block(...
            obj.mlConstantBlock,...
            [subsystemPath,'/PAM4 Center Value'],...
            'MakeNameUnique','on');
            set_param(pam4CenterConstantBlockHandle,'Value','0');
            add_line(subsystemPath,...
            'PAM4 Center Value/1',...
            'PAM4 Center/1',...
            'autorouting','on');

            pam4LowerBlockHandle=add_block(...
            obj.mlDataStoreWriteBlock,...
            [subsystemPath,'/PAM4 Lower'],...
            'MakeNameUnique','on');
            set_param(pam4LowerBlockHandle,'DataStoreName','PAM4_LowerThreshold');
            pam4LowerGainBlockHandle=add_block(...
            'simulink/Math Operations/Gain',...
            [subsystemPath,'/PAM4 Lower Inverter'],...
            'MakeNameUnique','on');
            set_param(pam4LowerGainBlockHandle,'Gain','-1');
            add_line(subsystemPath,...
            'PAM4 Select/1',...
            'PAM4 Lower Inverter/1',...
            'autorouting','on');
            add_line(subsystemPath,...
            'PAM4 Lower Inverter/1',...
            'PAM4 Lower/1',...
            'autorouting','on');
        end
    end
    methods(Access=private)
        function createAmiTreesAndBlockVariables(obj,modelWorkspace)




            for subSystemIdx=1:length(obj.subsystems)


                isTx=subSystemIdx==1;
                if isTx
                    treeVarName="TxTree";
                    treeName="serdes_tx";
                    blocks=obj.serdesSystem.TxModel.Blocks;
                else
                    treeVarName="RxTree";
                    treeName="serdes_rx";
                    blocks=obj.serdesSystem.RxModel.Blocks;
                end

                tree=serdes.internal.ibisami.ami.SerDesTree(treeName);
                tree.modelHandle=obj.modelHandle;
                if isTx
                    tree.Direction=serdes.internal.ibisami.ami.Tree.TxDirectionFlag;
                    obj.TxTree=tree;
                else
                    tree.Direction=serdes.internal.ibisami.ami.Tree.RxDirectionFlag;
                    obj.RxTree=tree;
                end
                tree.createStructsAndParameters();
                for blockIdx=1:length(blocks)
                    block=blocks{blockIdx};
                    blockName=string(block.BlockName);
                    amiParams=block.getAMIParameters;
                    tree.addBlock(blockName,amiParams);
                end
                tree.createStructsAndParameters(true);
                assignin(modelWorkspace,treeVarName,tree);
            end
        end
    end
end
