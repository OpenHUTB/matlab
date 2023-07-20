classdef CharacterizationDriver<handle





    properties
        m_synthesisDriver;
        m_targetInfo;
        m_folders=struct();
        m_keyGenerator;
        m_tempVar;
        m_compToSpec;
        m_implConfigCallback;
        m_compCallbacks;
        m_implCharSpecs;
        m_hdlImplDb;
        m_blockList;
        m_cumulativetimingData;
        m_blockProgress;
        m_progress;
        m_exisingMatfileList;
        m_override;
        m_testMode=struct();
    end

    methods

        function self=CharacterizationDriver(inputArgs)

            if~isempty(inputArgs.TestMode)
                self.m_testMode.testImplName=inputArgs.TestMode{1};
                self.m_testMode.testSpec=inputArgs.TestMode{2};
                self.m_testMode.ModelValidation=inputArgs.TestMode{3};
            end

            self.createDirectories(inputArgs);


            self.m_synthesisDriver=characterization.STA.SynthesisDriver(inputArgs,self.m_folders);


            self.m_keyGenerator=characterization.STA.CharacterizationKeyGenerator();


            self.m_implConfigCallback=characterization.STA.ImplementationConfigCallback();

            self.m_compToSpec=containers.Map('KeyType','char','ValueType','any');
            self.m_compCallbacks=containers.Map('KeyType','char','ValueType','any');
            self.m_implCharSpecs=containers.Map('KeyType','char','ValueType','any');
            self.m_targetInfo=containers.Map('KeyType','char','ValueType','any');
            self.m_blockProgress=containers.Map('KeyType','char','ValueType','int8');


            self.m_override=inputArgs.Override;


            self.loadHDLImplDatabase();




            self.registerCallbacks();


            self.registerCharacterizationSpecs();


            self.blockProgress();


            self.getExistingMatfileList();
        end


        function runCharacterization(self)


            generatedComps=0;
            errorComps=0;



            if~isempty(fieldnames(self.m_testMode))
                implList=self.m_testMode.testImplName;
            else
                implList=self.getImplList();
            end


            progress=0;
            if isempty(self.m_override)
                self.m_override='on';
                disp(message('HDLShared:hdlshared:tdboverridedefault','Override',self.m_override).getString);

            elseif strcmp(self.m_override,'off')
                disp(message('HDLShared:hdlshared:tdboverrideoff','Override',self.m_override).getString);

            else
                disp(message('HDLShared:hdlshared:tdboverrideon','Override',self.m_override).getString);

            end


            disp(message('HDLShared:hdlshared:tdbgenstart',self.m_synthesisDriver.m_toolInfo.deviceFullName).getString);


            for implIdx=1:length(implList)


                cd(self.m_folders.runDir);



                [status,sourceBlockPath]=self.getSourceBlockAndImplementation(implList(implIdx));



                implCompList=self.implCompList(implList(implIdx));


                if status==0
                    text='';
                    for compIdx=1:length(implCompList)
                        compName=implCompList(compIdx);
                        text=[text,' ',compName{1},'.mat'];
                    end
                    warning(message('HDLShared:hdlshared:tdbgenblockfailed',text,'Source block not found in the Simulink HDL Coder Database.'));
                    errorComps=errorComps+length(implCompList);
                    continue;
                end


                for compIdx=1:length(implCompList)
                    compName=implCompList(compIdx);




                    if strcmp(self.m_override,'off')
                        if find(strcmp(self.m_exisingMatfileList,[compName{1},'.mat']),1)
                            continue;
                        end
                    end



                    implBlockCharacterization=characterization.STA.ImplBlockCharacterization(self);



                    [status,msg]=implBlockCharacterization.createImplModel(sourceBlockPath,...
                    implList(implIdx),implCompList(compIdx));

                    if status==0
                        warnmsg=sprintf('\nError in Model Creation Stage.');
                        warnmsg=append(warnmsg,msg);
                        warning(message('HDLShared:hdlshared:tdbgenblockfailed',[compName{1},'.mat'],warnmsg));
                        errorComps=errorComps+1;
                        status=1;
                        continue;
                    end



                    [status,msg,paramKey,widthSpec]=implBlockCharacterization.runCharacterization();

                    if status==0
                        errorComps=errorComps+1;
                        status=1;
                        continue;
                    end



                    status=self.writeCharacterizationData(implCompList(compIdx),paramKey,widthSpec);
                    if status==1
                        generatedComps=generatedComps+1;
                    else
                        warning(message('HDLShared:hdlshared:tdbgenblockfailed',[compName{1},'.mat'],'Error in Mat file write stage.'));
                        errorComps=errorComps+1;
                        status=1;
                    end
                end

                impl=implList(implIdx);
                progress=progress+self.m_blockProgress(impl{1});
                disp(message('HDLShared:hdlshared:tdbreportprogress',progress).getString);
            end

            self.clearCharacterizationData();
            disp(message('HDLShared:hdlshared:tdbgencomplete',generatedComps,errorComps).getString);
        end

    end

    methods(Access=private)

        function createDirectories(self,inputArgs)

            self.m_folders.runDir=inputArgs.TimingDatabaseDirectory;


            if exist(fullfile(self.m_folders.runDir,'top'),'dir')
                rmdir(fullfile(self.m_folders.runDir,'top'),'s');
            end
            mkdir(fullfile(self.m_folders.runDir,'top'));
            self.m_folders.topDir=fullfile(self.m_folders.runDir,'top');


            if exist(fullfile(self.m_folders.topDir,'workingDir'),'dir')
                rmdir(fullfile(self.m_folders.topDir,'workingDir'),'s');
            end
            mkdir(fullfile(self.m_folders.topDir,'workingDir'));
            self.m_folders.workingDir=fullfile(self.m_folders.topDir,'workingDir');


            if exist(fullfile(self.m_folders.topDir,'goldDir'),'dir')
                rmdir(fullfile(self.m_folders.topDir,'goldDir'),'s');
            end
            mkdir(fullfile(self.m_folders.topDir,'goldDir'));
            self.m_folders.goldDir=fullfile(self.m_folders.topDir,'goldDir');


            if exist(fullfile(self.m_folders.topDir,'rtlGoldDir'),'dir')
                rmdir(fullfile(self.m_folders.topDir,'rtlGoldDir'),'s');
            end
            mkdir(fullfile(self.m_folders.topDir,'rtlGoldDir'));
            self.m_folders.rtlGoldDir=fullfile(self.m_folders.topDir,'rtlGoldDir');


            if exist(fullfile(self.m_folders.topDir,'tempDir'),'dir')
                rmdir(fullfile(self.m_folders.topDir,'tempDir'),'s');
            end
            mkdir(fullfile(self.m_folders.topDir,'tempDir'));
            self.m_folders.tempDir=fullfile(self.m_folders.topDir,'tempDir');
        end

        function loadHDLImplDatabase(self)

            self.m_hdlImplDb=slhdlcoder.HDLImplDatabase;
            self.m_hdlImplDb.buildDatabase;
            self.m_blockList=self.m_hdlImplDb.getSupportedBlocks;
        end



        function registerCallbacks(self)


            self.m_compCallbacks('bitshift_comp')=characterization.STA.ImplCallBacks.BitShiftCallback();
            self.m_compCallbacks('datatypeconvert_comp')=characterization.STA.ImplCallBacks.DataTypeConversionCallback();
            self.m_compCallbacks('deserializer_comp')=characterization.STA.ImplCallBacks.Deserializer1DCallback();
            self.m_compCallbacks('hdlcounter_comp')=characterization.STA.ImplCallBacks.HDLCounterCallback();
            self.m_compCallbacks('logic_comp')=characterization.STA.ImplCallBacks.LogicCallback();
            self.m_compCallbacks('lookuptable_comp')=characterization.STA.ImplCallBacks.LookupTableCallback();
            self.m_compCallbacks('mul_comp')=characterization.STA.ImplCallBacks.ProductCallback();
            self.m_compCallbacks('multiportswitch_comp')=characterization.STA.ImplCallBacks.MultiPortSwitchCallback();
            self.m_compCallbacks('ratetransition_comp')=characterization.STA.ImplCallBacks.RateTransitionCallback();
            self.m_compCallbacks('saturation_comp')=characterization.STA.ImplCallBacks.SaturationCallback();
            self.m_compCallbacks('serializer_comp')=characterization.STA.ImplCallBacks.Serializer1DCallback();
            self.m_compCallbacks('unitdelay_comp')=characterization.STA.ImplCallBacks.UnitDelayCallback();
            self.m_compCallbacks('unitdelayenabled_comp')=characterization.STA.ImplCallBacks.UnitDelayEnabledCallback();
            self.m_compCallbacks('unitdelayenabledresettable_comp')=characterization.STA.ImplCallBacks.UnitDelayEnabledResettableCallback();
            self.m_compCallbacks('unitdelayresettable_comp')=characterization.STA.ImplCallBacks.UnitDelayResettableCallback();

        end



        function registerCharacterizationSpecs(self)

            self.m_implCharSpecs('hdldefaults.BitOps')=@characterization.STA.CharacterizationSpecs.BitOpsCharSpec;
            self.m_implCharSpecs('hdldefaults.BitShift')=@characterization.STA.CharacterizationSpecs.BitShiftCharSpec;
            self.m_implCharSpecs('hdldefaults.Deserializer1D')=@characterization.STA.CharacterizationSpecs.Deserializer1DCharSpec;
            self.m_implCharSpecs('hdldefaults.HDLCounter')=@characterization.STA.CharacterizationSpecs.HDLCounterCharSpec;
            self.m_implCharSpecs('hdldefaults.Logic')=@characterization.STA.CharacterizationSpecs.LogicCharSpec;
            self.m_implCharSpecs('hdldefaults.LookupTableND')=@characterization.STA.CharacterizationSpecs.LookupTableNDCharSpec;
            self.m_implCharSpecs('hdldefaults.MultiPortSwitch')=@characterization.STA.CharacterizationSpecs.MultiPortSwitchCharSpec;
            self.m_implCharSpecs('hdldefaults.RateTransition')=@characterization.STA.CharacterizationSpecs.RateTransitionCharSpec;
            self.m_implCharSpecs('hdldefaults.ReciprocalNewton')=@characterization.STA.CharacterizationSpecs.ReciprocalNewtonCharSpec;
            self.m_implCharSpecs('hdldefaults.RecipSqrtNewton')=@characterization.STA.CharacterizationSpecs.RecipSqrtNewtonCharSpec;
            self.m_implCharSpecs('hdldefaults.RecipSqrtNewtonSingleRate')=@characterization.STA.CharacterizationSpecs.RecipSqrtNewtonSingleRateCharSpec;
            self.m_implCharSpecs('hdldefaults.Saturation')=@characterization.STA.CharacterizationSpecs.SaturationCharSpec;
            self.m_implCharSpecs('hdldefaults.Serializer1D')=@characterization.STA.CharacterizationSpecs.Serializer1DCharSpec;
            self.m_implCharSpecs('hdldefaults.SqrtNewton')=@characterization.STA.CharacterizationSpecs.SqrtNewtonCharSpec;
            self.m_implCharSpecs('hdldefaults.SqrtNewtonSingleRate')=@characterization.STA.CharacterizationSpecs.SqrtNewtonSingleRateCharSpec;
            self.m_implCharSpecs('hdldefaults.Switch')=@characterization.STA.CharacterizationSpecs.SwitchCharSpec;
            self.m_implCharSpecs('hdldefaults.TappedDelay')=@characterization.STA.CharacterizationSpecs.TappedDelayCharSpec;
            self.m_implCharSpecs('hdldefaults.UnitDelay')=@characterization.STA.CharacterizationSpecs.UnitDelayCharSpec;
            self.m_implCharSpecs('hdldefaults.UnitDelayEnabled')=@characterization.STA.CharacterizationSpecs.UnitDelayEnabledCharSpec;
            self.m_implCharSpecs('hdldefaults.UnitDelayResettable')=@characterization.STA.CharacterizationSpecs.UnitDelayResettableCharSpec;


            self.m_implCharSpecs('hdldefaults.MathFunction')=@characterization.STA.CharacterizationSpecs.MathFunctionCharSpecs;
            self.m_implCharSpecs('hdldefaults.NFPReinterpretCast')=@characterization.STA.CharacterizationSpecs.NFPReinterpretCastCharSpec;
            self.m_implCharSpecs('hdldefaults.Gain')=@characterization.STA.CharacterizationSpecs.GainCharSpec;
            self.m_implCharSpecs('hdldefaults.ReciprocalNewtonSingleRate')=@characterization.STA.CharacterizationSpecs.RecipNewtonSingleRateCharSpec;
            self.m_implCharSpecs('hdldefaults.RoundingFunction')=@characterization.STA.CharacterizationSpecs.RoundingFunctionCharSpec;
            self.m_implCharSpecs('hdldefaults.Signum')=@characterization.STA.CharacterizationSpecs.SignumCharSpec;
            self.m_implCharSpecs('hdldefaults.SqrtFunction')=@characterization.STA.CharacterizationSpecs.SqrtFunctionCharSpec;
            self.m_implCharSpecs('hdldefaults.TrigonometricFunction')=@characterization.STA.CharacterizationSpecs.TrigonometricFunctionCharSpec;
            self.m_implCharSpecs('hdldefaults.UnaryMinus')=@characterization.STA.CharacterizationSpecs.UnaryMinusCharSpec;


            self.m_implCharSpecs('hdldefaults.Abs')=@characterization.STA.CharacterizationSpecs.AbsCharSpec;
            self.m_implCharSpecs('hdldefaults.DataTypeConversion')=@characterization.STA.CharacterizationSpecs.DataTypeCharSpec;
            self.m_implCharSpecs('hdldefaults.Product')=@characterization.STA.CharacterizationSpecs.ProductCharSpec;
            self.m_implCharSpecs('hdldefaults.RelationalOperator')=@characterization.STA.CharacterizationSpecs.RelationalOperatorCharSpec;
            self.m_implCharSpecs('hdldefaults.Sum')=@characterization.STA.CharacterizationSpecs.SumCharSpec;








        end

        function blockProgress(self)
            self.m_blockProgress('hdldefaults.Abs')=1;
            self.m_blockProgress('hdldefaults.BitShift')=1;
            self.m_blockProgress('hdldefaults.BitOps')=3;
            self.m_blockProgress('hdldefaults.CounterFreeRunning')=1;
            self.m_blockProgress('hdldefaults.DataTypeConversion')=3;
            self.m_blockProgress('hdldefaults.Deserializer1D')=24;
            self.m_blockProgress('hdldefaults.Logic')=1;
            self.m_blockProgress('hdldefaults.LookupTableND')=1;
            self.m_blockProgress('hdldefaults.MultiPortSwitch')=1;
            self.m_blockProgress('hdldefaults.HDLCounter')=5;
            self.m_blockProgress('hdldefaults.Product')=4;
            self.m_blockProgress('hdldefaults.RateTransition')=1;
            self.m_blockProgress('hdldefaults.ReciprocalNewton')=1;
            self.m_blockProgress('hdldefaults.RecipSqrtNewton')=4;
            self.m_blockProgress('hdldefaults.RecipSqrtNewtonSingleRate')=4;
            self.m_blockProgress('hdldefaults.RelationalOperator')=3;
            self.m_blockProgress('hdldefaults.Saturation')=1;
            self.m_blockProgress('hdldefaults.Serializer1D')=2;
            self.m_blockProgress('hdldefaults.SqrtNewton')=6;
            self.m_blockProgress('hdldefaults.SqrtNewtonSingleRate')=6;
            self.m_blockProgress('hdldefaults.Sum')=2;
            self.m_blockProgress('hdldefaults.Switch')=1;
            self.m_blockProgress('hdldefaults.TappedDelay')=1;
            self.m_blockProgress('hdldefaults.UnitDelay')=1;
            self.m_blockProgress('hdldefaults.UnitDelayEnabled')=1;
            self.m_blockProgress('hdldefaults.UnitDelayEnabledResettable')=1;
            self.m_blockProgress('hdldefaults.UnitDelayResettable')=1;
            self.m_blockProgress('hdldefaults.Gain')=1;
            self.m_blockProgress('hdldefaults.MathFunction')=4;
            self.m_blockProgress('hdldefaults.NFPReinterpretCast')=0;
            self.m_blockProgress('hdldefaults.ReciprocalNewtonSingleRate')=1;
            self.m_blockProgress('hdldefaults.RoundingFunction')=2;
            self.m_blockProgress('hdldefaults.Signum')=1;
            self.m_blockProgress('hdldefaults.SqrtFunction')=1;
            self.m_blockProgress('hdldefaults.TrigonometricFunction')=7;
            self.m_blockProgress('hdldefaults.UnaryMinus')=1;
        end

        function getExistingMatfileList(self)
            folderContents=what(self.m_folders.runDir);
            self.m_exisingMatfileList=folderContents.mat;
        end
    end

    methods(Access=public)

        function implList=getImplList(self)


            implList=self.m_keyGenerator.m_matFileNameGenerator.m_nameMap.keys;
        end

        function compList=implCompList(self,implName)

            compList=self.m_keyGenerator.m_matFileNameGenerator.getCompsFromImpl(implName);
        end

        function[status,sourceBlockPath]=getSourceBlockAndImplementation(self,currentImpl)


            status=0;
            for blockIdx=1:length(self.m_blockList)
                sourceBlockPath=self.m_blockList{blockIdx};
                if(isequal(sourceBlockPath,'none'))
                    continue;
                end
                sourceBlockTokens=regexp(sourceBlockPath,'.*/([^/]*)$','tokens','once');
                try
                    sourceBlockName=sourceBlockTokens{1};
                catch
                    continue;
                end
                if(strcmp(sourceBlockName,'Math')&&~strcmp(currentImpl,'hdldefaults.MathFunction'))||strcmp(sourceBlockName,'ArithShift')
                    continue;
                end


                sourceBlockImplList=self.m_hdlImplDb.getImplementationsFromBlock(sourceBlockPath);


                for i=1:length(sourceBlockImplList)
                    sourceblockImpl=self.m_hdlImplDb.getImplementationForArch(sourceBlockPath,sourceBlockImplList{i});
                    if strcmpi(currentImpl,sourceblockImpl)
                        break;
                    end
                end

                if strcmpi(currentImpl,sourceblockImpl)
                    status=1;
                    break;
                end
            end
        end

        function charSpecInfo=getCharacterizationSpecInfo(self,implName,compName)
            if self.m_implCharSpecs.isKey(implName)
                if~isempty(fieldnames(self.m_testMode))
                    if~self.m_testMode.ModelValidation||(self.m_testMode.ModelValidation&&strcmp(implName,'hdldefaults.Product'))
                        charSpecInfoFunc=self.m_testMode.testSpec(implName);
                        charSpecInfo=charSpecInfoFunc(compName);
                    else
                        charSpecInfoFunc=self.m_implCharSpecs(implName);
                        charSpecInfo=charSpecInfoFunc(compName);
                    end

                else
                    charSpecInfoFunc=self.m_implCharSpecs(implName);
                    charSpecInfo=charSpecInfoFunc(compName);
                end
            else
                error("Characterization Specs not found");
            end
        end

        function preprocessModelDependentParams(self,modelInfo)
            if self.m_compCallbacks.isKey(modelInfo.component)
                callback=self.m_compCallbacks(modelInfo.component);
                callback.preprocessModelDependentParams(modelInfo);
            end
        end

        function modelInfo=processConfig(self,modelInfo)

            if self.m_compCallbacks.isKey(modelInfo.component)
                callback=self.m_compCallbacks(modelInfo.component);
                modelInfo=callback.processConfig(modelInfo);
            end
        end

        function preprocessWidthSettings(self,modelInfo)
            if self.m_compCallbacks.isKey(modelInfo.component)
                callback=self.m_compCallbacks(modelInfo.component);
                callback.preprocessWidthSettings(modelInfo);
            end
        end

        function preprocessModelIndependentParams(self,modelInfo)
            if self.m_compCallbacks.isKey(modelInfo.component)
                callback=self.m_compCallbacks(modelInfo.component);
                callback.preprocessModelIndependentParams(modelInfo);
            end
        end

        function[status,logTxt]=runToolAndSaveConfigTiming(self,modelInfo)

            modelInfo.compName=modelInfo.component;





            [status,logTxt,timingInfo]=self.m_synthesisDriver.runSynthesisTool(modelInfo);


            if(status==1)
                self.updateDelayMap(modelInfo,timingInfo);
            end

        end

        function updateDelayMap(self,modelInfo,timingInfo)
            widthInfo=self.getWidthSpec(modelInfo);


            compTimingKey=self.m_keyGenerator.getKey(modelInfo);









            lastIndex=numel(compTimingKey);
            currMap=self.m_targetInfo;
            prevMap=self.m_targetInfo;

            for i=1:numel(compTimingKey)

                currKey=compTimingKey{i};
                if~currMap.isKey(currKey)

                    if i~=lastIndex
                        myType=class(compTimingKey{i+1});
                        currMap(currKey)=containers.Map('KeyType',myType,'ValueType','any');
                    else
                        currMap(currKey)=struct.empty();
                    end
                end
                prevMap=currMap;
                currMap=currMap(currKey);
            end

            ddata=prevMap(compTimingKey{end});
            if isempty(ddata)
                ddata=struct('width',widthInfo,'port_delays',timingInfo);
            else
                ddata(end+1)=struct('width',widthInfo,'port_delays',timingInfo);
            end
            prevMap(compTimingKey{end})=ddata;
        end

        function widthSpec=getWidthSpec(~,modelInfo)
            widthSpec=[];
            for i=2:2:numel(modelInfo.currentWidthSettings)
                widthSpec(end+1)=modelInfo.currentWidthSettings{i};
            end

            if strcmp(modelInfo.component,'nfp_conv_fi2fl_comp')
                widthSpec(1)=2^widthSpec(1);
            elseif strcmp(modelInfo.component,'nfp_conv_fl2fi_comp')
                widthSpec(2)=2^widthSpec(2);
            elseif strcmp(modelInfo.component,{'nfp_mod_comp','nfp_rem_comp','nfp_atan2_comp','nfp_pow_comp'})
                widthSpec=[widthSpec(1),widthSpec(1)];
            end
        end

        function[status]=writeCharacterizationData(self,compName,paramKey,width_spec)

            param_spec=self.m_keyGenerator.getParamSpec(compName{1},paramKey);
            if~isempty(width_spec)&&...
                numel(width_spec)>0
                width_spec=width_spec-1;
            end

            if(~isempty(fieldnames(self.m_testMode))&&self.m_testMode.ModelValidation)
                load(fullfile(matlabroot,'toolbox','shared','hdlshared','@hdlshared','@Characterization','virtex7','1',[compName{1},'.mat']),'timing_data');
            else
                self.m_cumulativetimingData={};
                timing_map=self.m_targetInfo(compName{1});
                self.getKeyAndData(timing_map,{});
                timing_data=self.m_cumulativetimingData;
            end

            try
                save(fullfile(self.m_folders.runDir,[compName{1},'.mat']),...
                'timing_data','param_spec','width_spec');
            catch

                warnmsg=sprintf('\nError in exporting timing database mat-file.');
                warning(message('HDLShared:hdlshared:tdbgenblockfailed',[self.m_modelInfo.component,'.mat'],warnmsg));
                status=0;
            end
            status=1;

            self.m_targetInfo=containers.Map('KeyType','char','ValueType','any');
        end

        function getKeyAndData(self,timingMap,key)

            if~strcmpi(class(timingMap),'containers.Map')
                self.m_cumulativetimingData{end+1}={key,{timingMap}};
                return;
            end

            allKeys=timingMap.keys();
            for i=1:numel(allKeys)
                newKey=key;
                newKey{end+1}=allKeys{i};
                newTimingMap=timingMap(allKeys{i});
                self.getKeyAndData(newTimingMap,newKey);
            end
        end

        function clearCharacterizationData(self)
            try
                cd(self.m_folders.runDir);
                if exist(fullfile(self.m_folders.runDir,'top'),'dir')
                    rmdir(fullfile(self.m_folders.runDir,'top'),'s');
                end
            catch
            end
        end

        function entryHit=findKeyInDelayMap(self,modelInfo)

            try
                compTimingKey=self.m_keyGenerator.getKey(modelInfo);

                currMap=self.m_targetInfo;
                lastIndex=numel(compTimingKey);
                for i=1:lastIndex

                    currKey=compTimingKey{i};

                    if currMap.isKey(currKey)
                        if i~=lastIndex

                            currMap=currMap(currKey);
                        else
                            entryHit=false;

                            delayInfodb=currMap(compTimingKey{end});

                            widthInfo=self.getWidthSpec(modelInfo);
                            for portIdx=1:numel(delayInfodb)
                                widthInfodb=delayInfodb(portIdx).width;
                                innerHit=true;
                                for widthIdx=1:numel(widthInfodb)
                                    if(widthInfodb(widthIdx)~=widthInfo(widthIdx))
                                        innerHit=false;
                                        break;
                                    end
                                end
                                if innerHit==true
                                    entryHit=true;
                                    return;
                                end
                            end
                        end
                    else

                        entryHit=false;
                        break;
                    end
                end
            catch
                entryHit=false;
            end
        end

    end
end

