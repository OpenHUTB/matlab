function configurationPlotImpulse(model)
    mws=get_param(model,'ModelWorkspace');
    requiredMWSElements=["SymbolTime","SampleInterval","RowSize","Aggressors","Modulation","TargetBER","ChannelImpulse","EqualizedImpulse"];
    if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
        tempSampleInterval=mws.getVariable('SampleInterval');
        tempSampleIntervalValue=tempSampleInterval.Value;
        tempSymbolTime=mws.getVariable('SymbolTime');
        tempSymbolTimeValue=tempSymbolTime.Value;
        tempRowSize=mws.getVariable('RowSize');
        tempRowSizeValue=tempRowSize.Value;
        tempAggressors=mws.getVariable('Aggressors');
        tempAggressorsValue=tempAggressors.Value;
        tempModulation=mws.getVariable('Modulation');
        tempModulationValue=tempModulation.Value;
        tempTargetBER=mws.getVariable('TargetBER');
        tempTargetBERValue=tempTargetBER.Value;
        tempChannelImpulse=mws.getVariable('ChannelImpulse');
        tempChannelImpulseValue=tempChannelImpulse.Value;
        tempEqualizedImpulseValue=mws.getVariable('EqualizedImpulse');
        uneqImpulse=reshape(tempChannelImpulseValue(1:tempRowSizeValue*(1+tempAggressorsValue)),...
        tempRowSizeValue,1+tempAggressorsValue);
        eqImpulse=reshape(tempEqualizedImpulseValue(1:tempRowSizeValue*(1+tempAggressorsValue)),...
        tempRowSizeValue,1+tempAggressorsValue);
        SamplesPerSymbol=round(tempSymbolTimeValue/tempSampleIntervalValue);
        tp=(0:length(uneqImpulse)-1)*tempSampleIntervalValue;
        p1=impulse2pulse(uneqImpulse,SamplesPerSymbol,tempSampleIntervalValue);
        p2=impulse2pulse(eqImpulse,SamplesPerSymbol,tempSampleIntervalValue);
        numberOfWaves=size(p2,2);

        dataPattern=zeros(1,127);
        stimulus=serdes.Stimulus(...
        "SampleInterval",1,...
        "SymbolTime",1,...
        "Modulation",tempModulationValue,...
        "Specification","PAMn");
        for stimIdx=1:127
            dataPattern(stimIdx)=step(stimulus);
        end
        w1=pulse2wave(p1,dataPattern,SamplesPerSymbol);
        w2=pulse2wave(p2,dataPattern,SamplesPerSymbol);
        tw=(0:length(w1)-1)*tempSampleIntervalValue;


        txTree=mws.getVariable('TxTree');
        [TxDCD,TxDCDUnit]=serdes.internal.callbacks.getJitterValues(txTree.getReservedParameter('Tx_DCD'),1);
        [TxDj,TxDjUnit]=serdes.internal.callbacks.getJitterValues(txTree.getReservedParameter('Tx_Dj'),1);
        [TxSj,TxSjUnit]=serdes.internal.callbacks.getJitterValues(txTree.getReservedParameter('Tx_Sj'),1);
        [TxRj,TxRjUnit]=serdes.internal.callbacks.getJitterValues(txTree.getReservedParameter('Tx_Rj'),1);

        rxTree=mws.getVariable('RxTree');
        [RxDCD,RxDCDUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_DCD'),1);
        [RxDj,RxDjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Dj'),1);
        [RxSj,RxSjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Sj'),1);
        [RxRj,RxRjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Rj'),1);

        [RxCRDCD,RxCRDCDUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_DCD'),1);
        [RxCRDj,RxCRDjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Dj'),1);
        [RxCRSj,RxCRSjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Sj'),1);
        [RxCRRj,RxCRRjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Rj'),1);
        [RxCRMean,RxCRMeanUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Mean'),1);

        RxGaussianNoise=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_GaussianNoise'),1);
        RxUniformNoise=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_UniformNoise'),1);
        TxDCDObj=SimpleJitter('Value',TxDCD,'Include',true,'Type',TxDCDUnit);
        TxRjObj=SimpleJitter('Value',TxRj,'Include',true,'Type',TxRjUnit);
        TxDjObj=SimpleJitter('Value',TxDj,'Include',true,'Type',TxDjUnit);
        TxSjObj=SimpleJitter('Value',TxSj,'Include',true,'Type',TxSjUnit);
        RxDCDObj=SimpleJitter('Value',RxDCD,'Include',true,'Type',RxDCDUnit);
        RxRjObj=SimpleJitter('Value',RxRj,'Include',true,'Type',RxRjUnit);
        RxDjObj=SimpleJitter('Value',RxDj,'Include',true,'Type',RxDjUnit);
        RxSjObj=SimpleJitter('Value',RxSj,'Include',true,'Type',RxSjUnit);
        RxClockRecoveryMeanObj=SimpleJitter('Value',RxCRMean,'Include',true,'Type',RxCRMeanUnit);
        RxClockRecoveryRjObj=SimpleJitter('Value',RxCRRj,'Include',true,'Type',RxCRRjUnit);
        RxClockRecoveryDjObj=SimpleJitter('Value',RxCRDj,'Include',true,'Type',RxCRDjUnit);
        RxClockRecoverySjObj=SimpleJitter('Value',RxCRSj,'Include',true,'Type',RxCRSjUnit);
        RxClockRecoveryDCDObj=SimpleJitter('Value',RxCRDCD,'Include',true,'Type',RxCRDCDUnit);

        utilitiesMaskNamesValues=serdes.internal.callbacks.getUtilitiesMaskValues(model,'Configuration');

        jitter=JitterAndNoise(...
        'Tx_DCD',TxDCDObj,...
        'Tx_Rj',TxRjObj,...
        'Tx_Dj',TxDjObj,...
        'Tx_Sj',TxSjObj,...
        'Rx_DCD',RxDCDObj,...
        'Rx_Rj',RxRjObj,...
        'Rx_Dj',RxDjObj,...
        'Rx_Sj',RxSjObj,...
        'Rx_Clock_Recovery_Mean',RxClockRecoveryMeanObj,...
        'Rx_Clock_Recovery_Rj',RxClockRecoveryRjObj,...
        'Rx_Clock_Recovery_Dj',RxClockRecoveryDjObj,...
        'Rx_Clock_Recovery_Sj',RxClockRecoverySjObj,...
        'Rx_Clock_Recovery_DCD',RxClockRecoveryDCDObj,...
        'Rx_GaussianNoise',RxGaussianNoise,...
        'Rx_UniformNoise',RxUniformNoise,...
        'RxClockMode',utilitiesMaskNamesValues.EyeDiagramClockMode);
        channel=ChannelData('Impulse',eqImpulse,'dt',tempSampleIntervalValue);

        sys=SerdesSystem(...
        'ChannelData',channel,...
        'JitterAndNoise',jitter,...
        'SymbolTime',tempSymbolTimeValue,...
        'SamplesPerSymbol',SamplesPerSymbol,...
        'Modulation',tempModulationValue,...
        'Signaling','Differential',...
        'BERtarget',tempTargetBERValue);

        localEye=sys.Eye;
        stateye=localEye.Stateye;
        localClockPDF=localEye.ClockPDF;
        vh=localEye.Vh;
        th2=localEye.Th2;
        [eyeLinearity,VEC,contours,bathtubs,EH,~,~,~,~,~,~,~,EW,~,eyeAreas,~,COM]=...
        serdes.utilities.calculatePAMnEye(tempModulationValue,tempTargetBERValue,...
        th2(1),th2(length(th2)),vh(1),vh(length(vh)),stateye);

        BERplotFloor=1e-20;

        localClockPDF=localClockPDF/sum(localClockPDF);
        localClockPDF(localClockPDF==0)=BERplotFloor/10;

        BERwaveFloor=log10(BERplotFloor/10);
        bathtubs(bathtubs==0)=BERwaveFloor;
        bathtubs(isnan(bathtubs))=BERwaveFloor;
        serdesAnalysisFigureTag=['SimulinkSerDesAnalysisFigure',model];
        serdesStatPanelTag=['SimulinkStatPlotPanel',model];
        serdesTDPanelTag=['SimulinkTDPlotPanel',model];
        serdesStatPanel=findobj(groot,'Tag',serdesStatPanelTag);
        serdesTDPanel=findobj(groot,'Tag',serdesTDPanelTag);
        if~isempty(serdesStatPanel)
            analysisFigure=serdesStatPanel.Parent;

            figure(analysisFigure)

            delete(serdesStatPanel)

            if~isempty(serdesTDPanel)
                delete(serdesTDPanel)
            end
            [pulseResAxes,prbsAxes,statEyeAxes,statReportAxes]=setupStatFigure(analysisFigure,serdesAnalysisFigureTag,serdesStatPanelTag);
        elseif~isempty(serdesTDPanel)
            analysisFigure=serdesTDPanel.Parent;

            figure(analysisFigure)

            delete(serdesTDPanel)
            [pulseResAxes,prbsAxes,statEyeAxes,statReportAxes]=setupStatFigure(analysisFigure,serdesAnalysisFigureTag,serdesStatPanelTag);
        else
            [pulseResAxes,prbsAxes,statEyeAxes,statReportAxes]=setupStatFigure('',serdesAnalysisFigureTag,serdesStatPanelTag);
        end

        plot(pulseResAxes,tp,p1,tp,p2),
        legendCell=getWaveLegend(numberOfWaves,0);
        legend(pulseResAxes,legendCell(:));
        title(pulseResAxes,'Pulse Response')
        xlabel(pulseResAxes,'[s]')
        ylabel(pulseResAxes,'[V]')
        grid(pulseResAxes,'on')
        pulseResAxes.Tag='PulseRes';

        plot(prbsAxes,tw,w1,tw,w2),
        legend(prbsAxes,legendCell(:));
        title(prbsAxes,'Waveform Derived from Pulse Response')
        xlabel(prbsAxes,'[s]')
        ylabel(prbsAxes,'[V]')
        grid(prbsAxes,'on')
        prbsAxes.Tag='PulseResDerived';


        si_eyecmap=serdes.utilities.SignalIntegrityColorMap;
        title(statEyeAxes,'Statistical Eye')
        yyaxis(statEyeAxes,'right')
        linecolor=[0.75,0,0.75];
        semilogy(statEyeAxes,th2,10.^bathtubs,'-',...
        th2,localClockPDF,'-',...
        'color',linecolor,'linewidth',2)
        axis(statEyeAxes,[th2(1),th2(end)+th2(2),...
        BERplotFloor,1])
        set(statEyeAxes,'YColor',linecolor)
        ylabel(statEyeAxes,'[Probability]')

        yyaxis(statEyeAxes,'left')
        hold(statEyeAxes,'on')
        [mincval,maxcval]=serdes.internal.colormapToScale(stateye,si_eyecmap,1e-18);

        imagesc(statEyeAxes,th2,vh,stateye,[mincval,maxcval]);
        axis(statEyeAxes,'xy');
        colormap(statEyeAxes,si_eyecmap)
        plot(statEyeAxes,th2,contours,'m-','linewidth',2)
        xlabel(statEyeAxes,['[',localEye.tprefix,']'])
        ylabel(statEyeAxes,'[V]')
        statEyeAxes.Tag='StatEye';
        statEyeAxes.XLim=[min(th2),max(th2)];

        if tempModulationValue==4
            disptable=cell(12,2);
            disptable(:,1)={'Eye Height Upper (V)','Eye Height Center (V)','Eye Height Lower (V)',...
            'Eye Width Upper (ps)','Eye Width Center (ps)','Eye Width Lower (ps)',...
            'Eye Area Upper (V*ps)','Eye Area Center (V*ps)','Eye Area Lower (V*ps)',...
            'COM','VEC','Eye Linearity'};

            EH=flipud(EH);
            EW=flipud(EW);
            eyeAreas=flipud(eyeAreas);
            disptable(:,2)=num2cell([EH;EW;eyeAreas;COM;VEC;eyeLinearity]);
        elseif tempModulationValue==3
            disptable=cell(9,2);
            disptable(:,1)={'Eye Height Upper (V)','Eye Height Lower (V)',...
            'Eye Width Upper (ps)','Eye Width Lower (ps)',...
            'Eye Area Upper (V*ps)','Eye Area Lower (V*ps)',...
            'COM','VEC','Eye Linearity'};

            EH=flipud(EH);
            EW=flipud(EW);
            eyeAreas=flipud(eyeAreas);
            disptable(:,2)=num2cell([EH;EW;eyeAreas;COM;VEC;eyeLinearity]);
        elseif tempModulationValue==2
            disptable=cell(5,2);
            disptable(:,1)={'Eye Height (V)','Eye Width (ps)','Eye Area (V*ps)','COM','VEC'};
            disptable(:,2)=num2cell([EH(1),EW(1),eyeAreas(1),COM,VEC]');
        else
            disptable=cell(5,2);
            disptable(:,1)={'Eye Height (V)','Eye Width (ps)','Eye Area (V*ps)','COM','VEC'};
            tableData={mat2str(EH',3);mat2str(EW',3);mat2str(eyeAreas',3);mat2str(COM,3);mat2str(VEC,3)};
            disptable(:,2)=tableData;
            tableDataWidth=max(cellfun(@length,tableData));
            statReportAxes.ColumnWidth={120,tableDataWidth*6};
            statReportAxes.Tooltip='Height, width, and area ordered from lower to upper eye';
        end

        statReportAxes.Data=disptable;
        statReportAxes.ColumnName={'Statistical Metric       ','Data'};
        statReportAxes.RowName={};
        statReportAxes.Tag='StatReport';

        StatResults=struct(...
        'th',th2,...
        'vh',vh,...
        'contours',contours,...
        'bathtubs',bathtubs,...
        'clockPDF',localClockPDF,...
        'eye',stateye,...
        'timeStamp',now);
        StatResults.summary=disptable;
        results=struct('Statistical',StatResults);
        mws.assignin('SerDesResults',results);

    end
end


function legendCell=getWaveLegend(numberOfWaves,ChannelFlag)

    legendCell=cell(numberOfWaves,2);
    if numberOfWaves==1
        legendCell{1,1}='Unequalized';
        legendCell{1,2}='Equalized';
    else
        legendCell{1,1}='Unequalized primary';
        legendCell{1,2}='Equalized primary';
    end
    if ChannelFlag==3&&numberOfWaves==3
        legendCell{2,1}='Unequalized FEXT';
        legendCell{2,2}='Equalized FEXT';
        legendCell{3,1}='Unequalized NEXT';
        legendCell{3,2}='Equalized NEXT';
    else
        for ii=2:numberOfWaves
            legendCell{ii,1}=sprintf('Unequalized agr%i',ii-1);
            legendCell{ii,2}=sprintf('Equalized agr%i',ii-1);
        end
    end
end


function[pulseResAxes,prbsAxes,statEyeAxes,statReportAxes]=setupStatFigure(existingAnalysisFigure,serdesAnalysisFigureTag,serdesStatPanelTag)

    if~isempty(existingAnalysisFigure)
        analysisFigure=existingAnalysisFigure;
        currentAnalysisFigurePosition=analysisFigure.Position;

        if currentAnalysisFigurePosition(4)<0.30
            newAnalysisFigurePosition=currentAnalysisFigurePosition;
            heightBump=0.30-currentAnalysisFigurePosition(4);

            newAnalysisFigurePosition(2)=currentAnalysisFigurePosition(2)-heightBump;
            newAnalysisFigurePosition(4)=currentAnalysisFigurePosition(4)+heightBump;
            analysisFigure.Position=newAnalysisFigurePosition;
        end
    else
        analysisFigure=figure('Units','normalized');

        analysisFigure.Position=[0.2,0.5,0.3,0.3];
        analysisFigure.NumberTitle='off';
        analysisFigure.IntegerHandle='off';
        analysisFigure.Tag=serdesAnalysisFigureTag;
    end
    analysisFigure.Name=getString(message('serdes:callbacks:SimulinkStatTitle'));

    statPanel=uipanel(analysisFigure,...
    'Title','Stat Analysis',...
    'FontSize',12,...
    'BackgroundColor','white',...
    'Units','normalized',...
    'Position',[0,0,1,1]);
    statPanel.Tag=serdesStatPanelTag;

    pulseResAxes=axes(statPanel,...
    'Units','normalized',...
    'OuterPosition',[0,0.5,0.5,0.5]);
    prbsAxes=axes(statPanel,...
    'Units','normalized',...
    'OuterPosition',[0.5,0.5,0.5,0.5]);
    statEyeAxes=axes(statPanel,...
    'Units','normalized',...
    'OuterPosition',[0,0,0.5,0.5]);

    statReportAxes=uitable(statPanel,...
    'Units','normalized',...
    'OuterPosition',[0.56,0,0.44,0.5]);
end