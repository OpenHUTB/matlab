function SpectrumAnalyzerBlock(obj)





    if isR2022aOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ScopeFrameLocation:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><WasSavedAsWebScope:remove>>');


        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><InputDomain:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectrumType:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ViewType:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><Method:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SampleRateSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SampleRate:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><PlotAsTwoSidedSpectrum:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyScale:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><PlotType:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesScaling:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesScalingNumUpdates:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencySpan:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><Span:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CenterFrequency:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><StartFrequency:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><StopFrequency:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><InputUnits:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><YLabel:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyVectorSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyVector:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyResolutionMethod:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><RBWSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><RBW:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><WindowLength:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FFTLengthSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FFTLength:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><NumTapsPerBand:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><Window:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CustomWindow:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SidelobeAttenuation:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><OverlapPercent:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AveragingMethod:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectralAverages:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ForgettingFactor:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><VBWSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><VBW:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectrumUnits:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FullScaleSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FullScale:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ReferenceLoad:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyOffset:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectrogramChannel:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><TimeResolutionSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><TimeResolution:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><TimeSpanSource:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><TimeSpan:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><MaximizeAxes:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><PlotNormalTrace:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><PlotMaxHoldTrace:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><PlotMinHoldTrace:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><Title:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><YLabel:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><YLimits:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ColorLimits:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ShowGrid:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ShowLegend:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ShowColorbar:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ChannelNames:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesLayout:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ExpandToolstrip:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SelectedToolstripTab:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><MeasurementChannel:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><GraphicalSettings:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><WindowPosition:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><OpenAtSimulationStart:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrameBasedProcessing:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><Visible:remove>>');
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><IsFloating:remove>>');


        saBlks=find_scopes(obj);
        for idx=1:numel(saBlks)

            mapScopeParameters(obj,saBlks{idx},obj.modelName);
        end
    end

    if isR2018bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AveragingMethod:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ForgettingFactor:remove>>');
    end

    if isR2018aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectrogramChannel:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><MeasurementChannel:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><PeakFinder:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CursorMeasurements:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ChannelMeasurements:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><DistortionMeasurements:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CCDFMeasurements:remove>>');
    end

    if isR2017bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><InputDomain:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyVector:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyVectorSource:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><InputUnits:remove>>');

        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)


            changeBlockToEmptySubsystemIfFrequencyDomain(obj,saBlks{jndx},obj.modelName);
        end

    end

    if isR2017aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesScaling:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesScalingNumUpdates:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CustomWindow:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FullScaleSource:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FullScale:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><Method:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><NumTapsPerBand:remove>>');

        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)

            changeCustomWindow(saBlks{jndx},obj.origModelName);

            changedBFSTodBm(saBlks{jndx},obj.origModelName);


            changeBlockToEmptySubsystemIfFilterBank(obj,saBlks{jndx},obj.modelName);
        end
    end

    if isR2016bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ViewType:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesLayout:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectrumUnits:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><RMSUnits:remove>>');


        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)
            changeSpectrumTypeAndAxesProps(saBlks{jndx},obj.origModelName);
        end
    end

    if isR2016aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectralMaskProperties:remove>>');
    end

    if isR2015bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><NumInputPorts:remove>>');



        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)
            [~,origBlock]=strtok(saBlks{jndx},'/');
            parentSys=get_param(saBlks{jndx},'Parent');
            numInputPorts=get_param([obj.origModelName,origBlock],'NumInputPorts');
            if str2double(numInputPorts)>1
                currBlk=saBlks{jndx};


                saPorts=get_param(currBlk,'PortHandles');
                hLines=-ones(length(saPorts.Inport),1);
                hLineSrcPort=-ones(length(saPorts.Inport),1);
                for indx=1:length(saPorts.Inport)
                    hLines(indx)=get_param(saPorts.Inport(indx),'Line');
                    if hLines(indx)~=-1
                        hLineSrcPort(indx)=get_param(hLines(indx),'SrcPortHandle');
                    end
                end


                set_param(currBlk,'NumInputPorts','1');


                pos=get_param(currBlk,'Position');
                concatPos=pos;
                saPos=pos;
                switch get_param(currBlk,'Orientation')
                case 'up'
                    saPos=pos-[0,30,0,30];
                    concatPos(2)=concatPos(4)-10;
                case 'down'
                    saPos=pos+[0,30,0,30];
                    concatPos(4)=concatPos(2)+10;
                case 'left'
                    saPos=pos-[30,0,30,0];
                    concatPos(1)=concatPos(3)-10;
                case 'right'
                    saPos=pos+[30,0,30,0];
                    concatPos(3)=concatPos(1)+10;
                end
                set_param(currBlk,'Position',saPos);





                load_system('dspmtrx3');
                concatBlk=add_block('dspmtrx3/Matrix Concatenate',...
                [currBlk,'_MatrixConcatenator'],...
                'MakeNameUnique','on',...
                'ShowName','off',...
                'NumInputs',numInputPorts,...
                'Mode','Multidimensional array',...
                'ConcatenateDimension','2',...
                'Orientation',get_param(currBlk,'Orientation'),...
                'Position',concatPos);





                concatPorts=get_param(concatBlk,'PortHandles');
                for indx=1:length(concatPorts.Inport)
                    if hLines(indx)~=-1
                        hLine_Concat=get_param(concatPorts.Inport(indx),'Line');
                        if hLineSrcPort(indx)~=-1




                            if hLine_Concat==-1||...
                                ~isequal(get_param(hLine_Concat,'SrcPortHandle'),hLineSrcPort(indx))
                                lineName=get_param(hLines(indx),'Name');
                                delete_line(hLines(indx));
                                newLine=add_line(parentSys,hLineSrcPort(indx),...
                                concatPorts.Inport(indx),'autorouting','on');
                                set_param(newLine,'Name',lineName);
                            end
                        else


                            delete_line(hLines(indx));
                        end
                    end
                end


                saPorts=get_param(currBlk,'PortHandles');
                add_line(parentSys,concatPorts.Outport(1),saPorts.Inport(1),...
                'autorouting','on');
            end
        end
    end

    if isR2014aOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ScopeSpecificationString:remove>>');

        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)
            scopeSpec=get_param(saBlks{jndx},'ScopeSpecificationObject');
            if~isempty(scopeSpec)

                scopeSpec=copy(scopeSpec);

                set_param(saBlks{jndx},...
                'ScopeSpecification',scopeSpec,...
                'ScopeSpecificationObject',scopeSpec);
                scopeSpec.SaveAsString=false;
                if isempty(scopeSpec.ScopeCLI)
                    scopeSpec.ScopeCLI=uiscopes.ScopeCLI;
                end
                if~isempty(scopeSpec.CurrentConfiguration)
                    cc=scopeSpec.CurrentConfiguration.Children;
                    for indx=1:numel(cc)
                        if isempty(cc(indx).PropertySet)
                            cc(indx).PropertySet=extmgr.PropertySet;
                        end
                    end
                end
            end
        end
    end
end

function saBlks=find_scopes(obj)

    saBlks=obj.findBlocksOfType('SpectrumAnalyzer');
    saBlks_viewers=obj.findBlocksOfType('SpectrumAnalyzer','IOType','viewer');
    saBlks=[saBlks;saBlks_viewers];
end

function mapScopeParameters(~,saBlk,~)

    wasSavedAsWebScope=utils.onOffToLogical(get_param(saBlk,'WasSavedAsWebScope'));
    if wasSavedAsWebScope
        set_param(saBlk,'ScopeSpecificationString',Simulink.scopes.SpectrumAnalyzerUtils.toScopeSpecificationString(saBlk));

        set_param(saBlk,'DefaultConfigurationName','spbscopes.SpectrumAnalyzerBlockCfg');
    end
end

function changeSpectrumTypeAndAxesProps(saBlks,modelName)
    [~,origBlock]=strtok(saBlks,'/');
    origScfg=get_param([modelName,origBlock],'ScopeConfiguration');




    viewType=origScfg.ViewType;
    spectrumType=origScfg.SpectrumType;
    axesProps=getParameter(origScfg,'AxesProperties');

    currBlk=saBlks;
    currScfg=get_param(currBlk,'ScopeConfiguration');
    switch spectrumType

    case{'Power','RMS'}
        switch viewType
        case 'Spectrum'
            currScfg.SpectrumType='Power';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        case 'Spectrogram'
            currScfg.SpectrumType='Spectrogram';
            setScopeParameter(currScfg,'AxesProperties',axesProps(2));
        case 'Spectrum and spectrogram'
            currScfg.SpectrumType='Power';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        end

    case 'Power density'
        switch viewType
        case 'Spectrum'
            currScfg.SpectrumType='Power density';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        case 'Spectrogram'
            currScfg.SpectrumType='Spectrogram';
            setScopeParameter(currScfg,'AxesProperties',axesProps(2));
        case 'Spectrum and spectrogram'
            currScfg.SpectrumType='Power density';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        end
    end
end

function changeCustomWindow(saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');




    windowOption=origScfg.Window;
    currBlk=saBlk;
    currScfg=get_param(currBlk,'ScopeConfiguration');


    if strcmp(windowOption,'Custom')
        currScfg.Window='Hann';
    end
end

function changedBFSTodBm(saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');

    spectrumUnits=origScfg.SpectrumUnits;
    currBlk=saBlk;
    currScfg=get_param(currBlk,'ScopeConfiguration');

    if strcmp(spectrumUnits,'dBFS')
        currScfg.SpectrumUnits='dBm';
    end
end

function changeBlockToEmptySubsystemIfFilterBank(obj,saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');
    method=origScfg.Method;
    if strcmp(method,'Filter bank')


        obj.replaceWithEmptySubsystem(saBlk);
    end
end

function changeBlockToEmptySubsystemIfFrequencyDomain(obj,saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');
    domain=origScfg.InputDomain;
    if strcmp(domain,'Frequency')


        obj.replaceWithEmptySubsystem(saBlk);
    end
end
