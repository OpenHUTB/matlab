classdef ImplBlockCharacterization<characterization.STA.ImplModelCreation




    properties
        m_charSpecInfo=struct();
        m_folders=struct();
m_characterizationDriver
m_inportToIteratorIndex
m_widthKeys
m_paramToIteratorIndex
m_indexToParamValues
m_modelName
m_characterizationIndex
m_characterizationSpec
m_paramParser
m_portParser
        m_derivedKeys;
    end

    methods
        function self=ImplBlockCharacterization(characterizationDriver)
            self=self@characterization.STA.ImplModelCreation();
            self.m_characterizationDriver=characterizationDriver;
            self.m_folders=characterizationDriver.m_folders;
            self.m_characterizationIndex=1;
            self.m_portParser={};
            self.m_paramParser={};
        end

        function[status,msg]=createImplModel(self,sourceBlockPath,sourceBlockImpl,implComp)


            [status,msg]=self.createImplModel@characterization.STA.ImplModelCreation(sourceBlockPath,...
            sourceBlockImpl,implComp);
        end

        function[status,msg,paramKey,widthSpec]=runCharacterization(self)

            cd(self.m_folders.workingDir);
            [status,msg]=self.executeCharacterization();

            if status==1
                paramKey=self.m_paramParser.getParamSpecForOutput;



                paramKey=self.addDerivedParameterToKey(paramKey);
                widthSpec=self.m_modelInfo.widthSpec;
            else
                paramKey="NA";
                widthSpec="NA";
            end

        end
    end

    methods(Access=private)

        function[status,msg]=executeCharacterization(self)


            status=1;
            msg="NA";


            status=self.readCharacterizationSpec();

            if status==0
                msg=sprintf('\nError in reading characterization specifications.');
                return;
            end


            modelDependantIter=self.m_paramParser.getModelDependentIterator();
            while modelDependantIter.hasCurrent()

                self.m_modelInfo.modelDependantParams=self.m_paramParser.getModelDependentParamSettings(modelDependantIter.current());



                if strcmp(self.m_modelInfo.dataType,'nfpdt')
                    if all(self.m_modelInfo.modelDependantParams.isKey({'MantissaMultiplyStrategy','PartAddShiftMultiplierSize'}))
                        mm=self.m_modelInfo.modelDependantParams('MantissaMultiplyStrategy');
                        pm=self.m_modelInfo.modelDependantParams('PartAddShiftMultiplierSize');
                        mm=mm{1};
                        pm=pm{1};
                        if~strcmp(mm,'PartMultiplierPartAddShift')&&...
                            ~strcmp(pm,'18x24')
                            modelDependantIter.next();
                            continue;
                        end
                    end
                end



                status=self.loadGoldModel();
                if status==0
                    msg=sprintf('\nError in loading model.');
                    msg=logParamInfo(self,msg);
                    break;
                end




                try
                    self.m_characterizationDriver.preprocessModelDependentParams(self.m_modelInfo);
                catch
                    status=0;
                    msg=sprintf('\nError in preprocessing model dependent block parameters.');

                    msg=logParamInfo(self,msg);
                    break;
                end


                if strcmp(self.m_modelInfo.dataType,'fixdt')
                    status=self.setParamSettings(self.m_modelInfo.modelDependantParams);
                else
                    status=self.setParamSettings_NFP(self.m_modelInfo.modelDependantParams);
                end

                if status==0
                    msg=sprintf('\nError in setting model dependent block parameters.');

                    msg=logParamInfo(self,msg);
                    break;
                end





                [status]=self.updateModel();
                if status==0
                    msg=sprintf('\nError in redrawing with model dependent block parameters.');

                    msg=logParamInfo(self,msg);
                    break;
                end


                modelIndependantIter=self.m_paramParser.getModelIndependentIterator();
                modelIndependantIter.begin();
                while modelIndependantIter.hasCurrent()

                    self.m_modelInfo.modelIndependantParams=self.m_paramParser.getModelIndependentParamSettings(modelDependantIter.current(),...
                    modelIndependantIter.current());


                    wIter=self.m_portParser.getIterator();
                    wIter.begin();
                    while wIter.hasCurrent()
                        wtuple=wIter.current();


                        self.m_modelInfo.wmap=self.m_portParser.getWidthSettings(wtuple,self.m_portRegisters.in.Count);


                        try
                            self.m_characterizationDriver.preprocessModelIndependentParams(self.m_modelInfo);
                        catch
                            status=0;
                            msg=sprintf('\nError in preprocessing model independent block parameters.');

                            msg=logParamInfo(self,msg);
                            break;
                        end


                        try
                            self.m_characterizationDriver.preprocessWidthSettings(self.m_modelInfo);
                        catch
                            status=0;
                            msg=sprintf('\nError in preprocessing width settings of block input ports.');

                            msg=logParamInfo(self,msg);
                            break;
                        end


                        if strcmp(self.m_modelInfo.dataType,'fixdt')
                            status=self.setParamSettings(self.m_modelInfo.modelIndependantParams);
                        else
                            status=self.setParamSettings_NFP(self.m_modelInfo.modelIndependantParams);
                        end

                        if status==0
                            msg=sprintf('\nError in setting model independent block parameters.');

                            msg=logParamInfo(self,msg);
                            break;
                        end


                        status=self.setWidthSettings(self.m_modelInfo.wmap);
                        if status==0
                            msg=sprintf('\nError in setting width of block input ports.');

                            msg=logParamInfo(self,msg);
                            break;
                        end



                        self.m_modelInfo.currentWidthSettings=self.m_portParser.getWidthSettingsForOutput(self.m_modelInfo.wmap);
                        self.m_modelInfo.currentParamSettings=self.m_paramParser.getParamPVPairs(self.m_modelInfo.modelDependantParams,...
                        self.m_modelInfo.modelIndependantParams);




                        if self.m_modelInfo.modelDependantParams.isKey('NFPCustomLatency')||...
                            self.m_modelInfo.modelDependantParams.isKey('CustomLatency')


                            evalc([self.m_modelInfo.modelName(),'([],[],[],''compile'')']);


                            try

                                if strcmp(self.m_modelInfo.implementation,'hdldefaults.RoundingFunction')
                                    custLatVal=self.m_modelInfo.modelDependantParams('NFPCustomLatency');
                                    reqLatency=custLatVal{1};
                                    maxLat=5;
                                else
                                    [reqLatency,~,maxLat]=hdlcoder.ModelChecker.getRequiredLatency(self.m_modelInfo.blockPath,'MAX',true);
                                end

                            catch
                                status=0;
                                msg=sprintf('\nError in Latency settings of the block.');

                                msg=logParamInfo(self,msg);

                                evalc([self.m_modelInfo.modelName(),'([],[],[],''term'')']);
                                break;
                            end


                            if strcmp(self.m_modelInfo.component,'nfp_div_comp')||strcmp(self.m_modelInfo.component,'nfp_recip_comp')
                                maxLat=self.getExpMaxLatency();
                            end


                            evalc([self.m_modelInfo.modelName(),'([],[],[],''term'')']);






                            if reqLatency>maxLat
                                wIter.next();
                                continue;
                            end
                            self.m_modelInfo.currentParamSettings{end+1}='Latency';
                            self.m_modelInfo.currentParamSettings{end+1}=reqLatency;
                        end



                        self.m_modelInfo=self.m_characterizationDriver.processConfig(self.m_modelInfo);





                        entryHit=self.m_characterizationDriver.findKeyInDelayMap(self.m_modelInfo);
                        if entryHit
                            wIter.next();
                            continue;
                        end


                        if(~isempty(fieldnames(self.m_characterizationDriver.m_testMode))&&self.m_characterizationDriver.m_testMode.ModelValidation)
                            break;
                        end

                        [status]=self.generateRTL();
                        if status==0
                            msg=sprintf('\nError in generating HDL Code for the model.');

                            msg=logParamInfo(self,msg);
                            break;
                        end


                        self.saveModelToRTLGoldDir();






                        self.m_modelInfo.portRegisters=self.m_portRegisters;
                        [status,logTxt]=self.m_characterizationDriver.runToolAndSaveConfigTiming(self.m_modelInfo);
                        if status==0
                            msg=sprintf('\nError in generating timing delay info.\n%s',logTxt);

                            msg=logParamInfo(self,msg);
                            break;
                        end

                        wIter.next();
                    end

                    if status==0
                        break;
                    end
                    modelIndependantIter.next();
                end


                self.cleanupWorkingDirectory();
                if status==0
                    break;
                end
                modelDependantIter.next();
            end
        end

        function status=readCharacterizationSpec(self)
            status=1;
            try

                self.m_charSpecInfo=self.m_characterizationDriver.getCharacterizationSpecInfo(self.m_modelInfo.implementation,self.m_modelInfo.component);
                self.m_modelInfo.dataType=self.m_charSpecInfo.dataType;

                self.m_paramParser=characterization.STA.CharacterizationParamParser(self.m_charSpecInfo.params);


                widthSpec={};
                if isfield(self.m_charSpecInfo,'widthSpec')
                    widthSpec=self.m_charSpecInfo.widthSpec;
                end
                portParser=characterization.STA.CharacterizationPortParser(self.m_charSpecInfo.ports,widthSpec);
                self.m_portParser=portParser;


                paramList=self.m_paramParser.getParamOrder();
                if any(strcmp(paramList,'NFPCustomLatency'))
                    self.m_derivedKeys={'Latency'};
                end

                if strcmp(self.m_modelInfo.component,'nfp_sqrt_comp')||strcmp(self.m_modelInfo.component,'nfp_rsqrt_comp')
                    self.m_derivedKeys={'Latency'};
                end

            catch
                status=0;
            end
        end

        function status=loadGoldModel(self)

            status=1;
            try
                close_system(self.m_modelInfo.modelName,0);
                copyfile([self.m_folders.goldDir,'/',self.m_modelInfo.modelName,'.slx']);


                load_system(self.m_modelInfo.modelName);
            catch
                status=0;
            end
        end

        function status=setParamSettings(self,modelParams)
            status=1;
            paramOrder=self.m_paramParser.getParamOrder();
            try
                for i=1:numel(paramOrder)
                    if~modelParams.isKey(paramOrder{i})
                        continue;
                    end
                    pvpair=modelParams(paramOrder{i});
                    if pvpair{2}==characterization.ParamDesc.SIMULINK_PARAM
                        set_param(self.m_modelInfo.blockPath,paramOrder{i},pvpair{1});
                    else
                        hdlset_param(self.m_modelInfo.blockPath,paramOrder{i},pvpair{1});
                    end
                end


                paramNames=modelParams.keys();
                for i=1:numel(paramNames)
                    pvpair=modelParams(paramNames{i});
                    if pvpair{2}==characterization.ParamDesc.SIMULINK_PARAM
                        set_param(self.m_modelInfo.blockPath,paramNames{i},pvpair{1});
                    else
                        hdlset_param(self.m_modelInfo.blockPath,paramNames{i},pvpair{1});
                    end
                end
                save_system(self.m_modelInfo.modelName);
            catch
                status=0;
            end
        end

        function status=setParamSettings_NFP(self,modelParams)
            status=1;
            try
                paramOrder=self.m_paramParser.getParamOrder();

                hdlset_param(self.m_modelInfo.modelName,'FloatingPointTargetConfiguration',...
                hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint'));


                toolName=self.m_characterizationDriver.m_synthesisDriver.m_toolInfo.toolName;
                if strcmpi(toolName,'xilinx vivado')
                    hdlset_param(self.m_modelInfo.modelName,'ResetType','Synchronous');
                else
                    hdlset_param(self.m_modelInfo.modelName,'ResetType','Asynchronous');
                end


                if strcmp(self.m_modelInfo.implementation,'hdldefaults.Gain')
                    set_param(self.m_modelInfo.blockPath,'Gain','4');
                elseif strcmp(get_param(self.m_modelInfo.blockPath,'BlockType'),'Trigonometry')
                    cordicFunc={'sin','cos','atan2','sincos'};
                    if any(strcmp(get_param(self.m_modelInfo.blockPath,'Operator'),cordicFunc))
                        set_param(self.m_modelInfo.blockPath,'ApproximationMethod','None');
                    end
                elseif strcmp(self.m_modelInfo.implementation,'hdldefaults.ReciprocalNewtonSingleRate')
                    set_param(self.m_modelInfo.blockPath,'NumberOfIterations','32');
                    hdlset_param(self.m_modelInfo.blockPath,'Architecture','ReciprocalNewtonSingleRate');
                elseif strcmp(self.m_modelInfo.implementation,'hdldefaults.DataTypeConversion')
                    set_param(self.m_modelInfo.blockPath,'OutDataTypeStr','Inherit: Inherit via back propagation');
                    set_param(self.m_modelInfo.blockPath,'RndMeth','Nearest');
                    set_param(self.m_modelInfo.blockPath,'SaturateOnIntegerOverflow','off');
                end

                self.m_modelInfo.invalidHDLParams=cell(0);
                isPartMultiplier=false;

                for i=1:numel(paramOrder)
                    if~modelParams.isKey(paramOrder{i})
                        continue;
                    end

                    pvpair=modelParams(paramOrder{i});
                    if pvpair{2}==characterization.ParamDesc.SIMULINK_PARAM
                        set_param(self.m_modelInfo.blockPath,paramOrder{i},pvpair{1});
                    else
                        try
                            if strcmp(paramOrder{i},'MantissaMultiplyStrategy')&&...
                                strcmp(pvpair{1},'PartMultiplierPartAddShift')
                                isPartMultiplier=true;
                            end

                            if strcmp(paramOrder{i},'PartAddShiftMultiplierSize')
                                if isPartMultiplier
                                    fp=hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint','MantissaMultiplyStrategy','PartMultiplierPartAddShift','PartAddShiftMultiplierSize',pvpair{1});
                                    hdlset_param(self.m_modelInfo.modelName,'FloatingPointTargetConfiguration',fp);
                                else
                                    continue;
                                end
                            else
                                hdlset_param(self.m_modelInfo.blockPath,paramOrder{i},pvpair{1});
                            end
                        catch
                            status=0;
                        end
                    end
                end

                paramNames=modelParams.keys();
                for i=1:numel(paramNames)
                    if any(strcmp(paramNames{i},paramOrder))
                        continue;
                    end
                    pvpair=modelParams(paramNames{i});
                    if pvpair{2}==characterization.ParamDesc.SIMULINK_PARAM
                        set_param(self.m_modelInfo.blockPath,paramNames{i},pvpair{1});
                    else
                        hdlset_param(self.m_modelInfo.blockPath,paramNames{i},pvpair{1});
                    end
                end
                save_system(self.m_modelInfo.modelName);
            catch
                status=0;
            end
        end

        function status=setWidthSettings(self,wmap)
            self.m_modelInfo.widthSpec=self.m_portParser.getWidthSpec(wmap);
            status=1;
            try

                if~strcmp(self.m_modelInfo.implementation,'hdldefaults.LookupTableND')
                    hdlset_param(self.m_modelInfo.modelName,'Adaptivepipelining','off');
                    get_param(self.m_modelInfo.blockPath,'InputSameDT');
                    set_param(self.m_modelInfo.blockPath,'InputSameDT','off');
                end
            catch
            end
            try
                widthKeys=wmap.keys();
                for i=1:numel(widthKeys)
                    pair=wmap(widthKeys{i});
                    widthFormat=pair{2};
                    if~contains(widthFormat,'%')
                        widthStr=widthFormat;
                    else
                        widthStr=sprintf(widthFormat,pair{1});
                    end

                    if widthKeys{i}>0
                        portId=[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/Inport_',int2str(widthKeys{i})];
                    else
                        portId=[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/Outport_',int2str(abs(widthKeys{i}))];
                    end
                    set_param(portId,'OutDataTypeStr',widthStr);

                    if numel(pair)>2&&(i<2)
                        RatioValue=pair{3};
                        pdimensionvalue=RatioValue(1);
                        if(numel(pair)>2)
                            set_param(portId,'PortDimensions',cell2mat(pdimensionvalue));
                        end
                    end

                    if strcmp(self.m_modelInfo.component,'serializer_comp')
                        pair=wmap(widthKeys{1});
                        ratval=pair{3};pdval=ratval(1);
                        sampleTime=str2num(pdval{1})*1.5;
                        set_param(portId,'SampleTime',num2str(sampleTime));
                    else
                        set_param(portId,'SampleTime','10');
                    end
                end

                save_system(self.m_modelInfo.modelName);
                set_param(self.m_modelInfo.modelName,'SimulationCommand','Update');
            catch
                status=0;
            end
        end

        function dep=hasToolDependentSettings(self)
            dep=self.m_paramParser.hasToolDependentParams();
        end

        function[status]=generateRTL(self,varargin)

            status=1;
            pWstate=warning('off','Simulink:Engine:OutputNotConnected');
            pWstate1=warning('off','Simulink:Engine:InputNotConnected');


            try
                evalc("makehdl([self.m_modelInfo.modelName '/' self.m_modelInfo.topSubsystem], 'TargetL', 'Vh');");
            catch
                status=0;
            end
            warning(pWstate.state,'Simulink:Engine:OutputNotConnected');
            warning(pWstate1.state,'Simulink:Engine:InputNotConnected');
        end

        function saveModelToRTLGoldDir(self)

            hdlDir=fullfile(['hdlsrc/',self.m_modelInfo.modelName]);


            try
                delete(fullfile(self.m_folders.rtlGoldDir,'*'));
            catch
            end


            cd(hdlDir);
            movefile('*.vhd',self.m_folders.rtlGoldDir);
            cd(self.m_folders.workingDir);
        end

        function cleanupWorkingDirectory(self)
            cd(self.m_folders.workingDir);
            close_system(['gm_',self.m_modelInfo.modelName],0)
            close_system(self.m_modelInfo.modelName,0)
            cd(self.m_folders.topDir);
            try
                if exist(self.m_folders.workingDir,'dir')
                    rmdir(self.m_folders.workingDir,'s');
                    mkdir(self.m_folders.workingDir);
                    cd(self.m_folders.workingDir);
                end
            catch
            end
        end

        function paramKey=addDerivedParameterToKey(self,paramKey)
            for i=1:numel(self.m_derivedKeys)
                if isempty(paramKey)
                    paramKey{1}=self.m_derivedKeys{i};
                else
                    paramKey{end+1}=self.m_derivedKeys{i};
                end
            end
        end




        function msg=logParamInfo(self,msg)

            if isfield(self.m_modelInfo,'modelIndependantParams')
                paramSettingsforLog=self.m_paramParser.getParamPVPairsforLog(self.m_modelInfo.modelDependantParams,...
                self.m_modelInfo.modelIndependantParams);
            else
                paramSettingsforLog=self.m_paramParser.getParamPVPairs(self.m_modelInfo.modelDependantParams);
            end

            paramSettings='';
            for i=1:2:numel(paramSettingsforLog)
                paramSettings=append(paramSettings,newline,num2str(paramSettingsforLog{i}));
                paramSettings=append(paramSettings,": '",num2str(paramSettingsforLog{i+1}),"'");
            end
            log=sprintf('\nFailed iteration details:\nParameter Settings:%s',paramSettings);
            msg=append(msg,log);
            if isfield(self.m_modelInfo,'wmap')
                widthSettingsforLog=self.m_portParser.getWidthSettingsForOutput(self.m_modelInfo.wmap);
                widthSettings='';
                for i=1:2:numel(widthSettingsforLog)
                    widthSettings=append(widthSettings,newline,num2str(widthSettingsforLog{i}));
                    widthSettings=append(widthSettings,": '",num2str(widthSettingsforLog{i+1}),"'");
                end
                log=sprintf('\nWidth Settings:%s',widthSettings);
                msg=append(msg,log);
            end
            warnmsg=sprintf('\nError in running Block Characterization stage.');
            warnmsg=append(warnmsg,msg);
            warning(message('HDLShared:hdlshared:tdbgenblockiterationfailed',[self.m_modelInfo.component,'.mat'],warnmsg));
            save_system(self.m_modelInfo.modelName);

            self.cleanupWorkingDirectory();
        end



        function expMaxLatency=getExpMaxLatency(self)





            if self.m_modelInfo.modelDependantParams.isKey('DivisionAlgorithm')
                divAlgo=self.m_modelInfo.modelDependantParams('DivisionAlgorithm');
            end


            portHandles=get_param(self.m_modelInfo.blockPath,'PortHandles');
            if~isempty(portHandles.Inport)&&~isempty(portHandles.Inport(1))

                dType=get_param(portHandles.Inport(1),'CompiledPortDataType');
            end


            if strcmp(self.m_modelInfo.component,'nfp_div_comp')
                if strcmp(dType,'single')
                    if strcmp(divAlgo{1},'Radix-2')
                        expMaxLatency=32;
                    else
                        expMaxLatency=20;
                    end
                else
                    if strcmp(divAlgo{1},'Radix-2')
                        expMaxLatency=61;
                    else
                        expMaxLatency=35;
                    end
                end
            else
                if strcmp(dType,'single')
                    if strcmp(divAlgo{1},'Radix-2')
                        expMaxLatency=31;
                    else
                        expMaxLatency=19;
                    end
                else
                    if strcmp(divAlgo{1},'Radix-2')
                        expMaxLatency=60;
                    else
                        expMaxLatency=34;
                    end
                end
            end
        end
    end
end
