function SerdesReplacements(obj)







    if isReleaseOrEarlier(obj.ver,'R2022a')








        mws=get_param(obj.modelName,'ModelWorkspace');

        if~isempty(mws)&&mws.hasVariable('Modulation')
            modulationParameter=mws.getVariable('Modulation');
            modulation=modulationParameter.Value;

            if~isempty(modulation)&&modulation>4
                modulation=2;
                modulationString=serdes.internal.callbacks.convertModulation(modulation);

                configurationBlock=obj.findBlocksWithMaskType('Configuration');
                if~isempty(configurationBlock)
                    set_param(configurationBlock{1},'Modulation',modulationString);
                end


                channelBlock=obj.findBlocksWithMaskType('AnalogChannel');
                if~isempty(channelBlock)
                    maskObj=Simulink.Mask.get(channelBlock{1});
                    maskNames={maskObj.Parameters.Name};
                    maskValues={maskObj.Parameters.Value};
                    maskNamesValues=cell2struct(maskValues,maskNames,2);
                    propSuffix={'FEXT','NEXT','1','2','3','4','5','6'};
                    changeMade=false;
                    for ii=1:length(propSuffix)
                        targetMaskName="Modulation"+propSuffix{ii};

                        modval=serdes.internal.callbacks.convertModulation(maskNamesValues.(targetMaskName));
                        if modval>4
                            maskObj.Parameters(strcmp(maskNames,targetMaskName)).Value='NRZ';
                            changeMade=true;
                        end
                    end
                    if changeMade
                        serdes.internal.callbacks.analogChannelUpdate(channelBlock{1},"Initialization");
                    end
                end
            end



            if mws.hasVariable('TxTree')&&mws.hasVariable('RxTree')
                txTree=mws.getVariable('TxTree');
                rxTree=mws.getVariable('RxTree');
                if isempty(rxTree.getReservedParameter("Modulation"))
                    txTree.removeModulationParameters;
                    rxTree.removeModulationParameters;

                    txTree.addLegacyModulationParameters;
                    rxTree.addLegacyModulationParameters;

                    modulationString=serdes.internal.callbacks.convertModulation(modulation);
                    txTree.setReservedParameterCurrentValue('Modulation',modulationString);
                    rxTree.setReservedParameterCurrentValue('Modulation',modulationString);

                    serdes.internal.callbacks.initializeFunUpdate([obj.modelName,'/Rx/Init/Initialize Function'])
                end
            end



            busSelectors=obj.findBlocks('Name','Bus Selector');
            if~isempty(busSelectors)
                for blkIdx=1:length(busSelectors)
                    currentOutputSignals=get_param(busSelectors{blkIdx},'OutputSignals');
                    if contains(currentOutputSignals,'PAMThreshold')
                        old={'PAMThreshold',',PAMThreshold,',',PAMThreshold','PAMThreshold,'};
                        new={'',',','',''};
                        newOutputSignals=replace(currentOutputSignals,old,new);
                        set_param(busSelectors{blkIdx},'OutputSignals',newOutputSignals);
                    end
                end
            end
            pamThresholdsBlks=obj.findBlocks('Name','PAM_Thresholds');
            if~isempty(pamThresholdsBlks)
                for blkIdx=1:length(pamThresholdsBlks)

                    h=get_param(pamThresholdsBlks{blkIdx},'LineHandles');
                    delete_line(h.Inport(1));

                    delete_block(pamThresholdsBlks{blkIdx});
                end
            end
        end
    end

    if isR2021bOrEarlier(obj.ver)


        ctleBlks=obj.findBlocksWithMaskType('CTLE');
        for iblk=1:length(ctleBlks)
            gpzFieldValue=get_param(ctleBlks{iblk},'GPZ');
            if~isempty(gpzFieldValue)
                gpz=slResolve(gpzFieldValue,bdroot(ctleBlks{iblk}));
                gpzStr=mat2str(gpz);
                set_param(ctleBlks{iblk},'GPZ',gpzStr);
            end
        end
    end

    if isR2020bOrEarlier(obj.ver)



        ctleBlks=obj.findBlocksWithMaskType('CTLE');
        if~isempty(ctleBlks)
            for blk=ctleBlks
                fromPats={sprintf('\n%sInit.PerformanceCriteria = [^;]*;',get_param(blk{1},'Name')),...
                sprintf('\n%sInit.FilterMethod = [^;]*;',get_param(blk{1},'Name'))};
                try
                    mlFcnName=[get_param(blk{1},'Parent'),'/Init/Initialize Function/MATLAB Function'];
                    emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);
                    newScript=regexprep(emChart.Script,fromPats,{'',''});
                    if~strcmp(newScript,emChart.Script)
                        emChart.Script=char(newScript);
                    end
                catch
                end
            end
        end
    end

    if isR2020aOrEarlier(obj.ver)

        obj.removeLibraryLinksTo('serdesUtilities/IBIS-AMI clock_times');

        dfeBlks=obj.findBlocksWithMaskType('DFECDR');
        if~isempty(dfeBlks)
            for blk=dfeBlks
                fromPat=sprintf('\n%sInit.Taps2x = [^;]*;',get_param(blk{1},'Name'));
                try
                    mlFcnName=[get_param(blk{1},'Parent'),'/Init/Initialize Function/MATLAB Function'];
                    emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);
                    newScript=regexprep(emChart.Script,fromPat,'');
                    if~strcmp(newScript,emChart.Script)
                        emChart.Script=char(newScript);
                    end
                catch
                end
            end
        end

        R2020bCallback='serdes.internal.callbacks.datapathUndoDelete(gcb);';
        datapathMaskTypes={'AGC','CDR','CTLE','DFECDR','FFE','PassThrough','SaturatingAmplifier','VGA'};
        for maskType=datapathMaskTypes
            blks=obj.findBlocksWithMaskType(maskType{:});
            if~isempty(blks)
                for blk=blks
                    curFcn=get_param(blk,'UndoDeleteFcn');
                    if any(contains(curFcn,R2020bCallback))
                        newFcn=strrep(curFcn,R2020bCallback,'');
                        set_param(blk{1},'UndoDeleteFcn',char(newFcn));
                    end
                end
            end
        end

        maskTypes={'CTLE','FFE','SaturatingAmplifier'};
        for maskType=maskTypes
            blks=obj.findBlocksWithMaskType(maskType{1});
            if~isempty(blks)
                for blk=blks
                    maskObj=get_param(blk{1},'MaskObject');

                    maskObj.removeDialogControl('Container4');
                end
            end
        end
    end

    if isR2019bOrEarlier(obj.ver)

        dfeBlks=obj.findBlocksWithMaskType('DFECDR');
        eqSteps=transpose(cellfun(@(b)get_param(b,'EqualizationStep'),dfeBlks,'UniformOutput',false));

        warnIdxs=find(contains(eqSteps,'['));
        for i=warnIdxs

            try
                vValue=eval(eqSteps{i});
                sValue=min(vValue(vValue>0));
                if isempty(sValue)||sValue==0
                    sValue=1e-6;
                end
                sValue=string(sValue);
            catch
                sValue="1e-6";
            end


            maskObj=Simulink.Mask.get(dfeBlks{i});
            parameters=maskObj.Parameters;
            idxEqStep=strcmp({parameters.Name},'EqualizationStep');
            parameters(idxEqStep).Value=sValue;



            fromString=sprintf('%sInit.EqualizationStep = %s',get_param(dfeBlks{i},'Name'),eqSteps{i});
            toString=sprintf('%sInit.EqualizationStep = %s',get_param(dfeBlks{i},'Name'),sValue);
            mlFcnName=[get_param(dfeBlks{i},'Parent'),'/Init/Initialize Function/MATLAB Function'];
            emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);
            script=strrep(emChart.Script,fromString,toString);
            emChart.Script=char(script);

            obj.reportWarning('serdes:simulink:EqStepVectorToScalar',dfeBlks{i},eqSteps{i},char(sValue));
        end
    end

    if isR2018bOrEarlier(obj.ver)

        obj.removeLibraryLinksTo('serdesUtilities/Analog Channel');
        obj.removeLibraryLinksTo('serdesUtilities/Configuration');
        obj.removeLibraryLinksTo('serdesUtilities/Stimulus');
    end


