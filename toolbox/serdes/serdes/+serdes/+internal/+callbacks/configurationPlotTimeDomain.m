






function configurationPlotTimeDomain(model,varargin)





    clearPlot=false;
    if~isempty(varargin)&&nargin==2
        if islogical(varargin{1})
            clearPlot=varargin{1};
        end
    end

    mws=get_param(model,'ModelWorkspace');
    requiredMWSElements=["SymbolTime","SampleInterval","Modulation","TargetBER","TxTree","RxTree"];
    if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))

        sampleInterval=mws.getVariable('SampleInterval');
        sampleIntervalValue=sampleInterval.Value;
        symbolTime=mws.getVariable('SymbolTime');
        symbolTimeValue=symbolTime.Value;
        modulation=mws.getVariable('Modulation');
        modulationValue=modulation.Value;
        targetBER=mws.getVariable('TargetBER');
        targetBERValue=targetBER.Value;

        waveforms=getWaveformsFromWS(model);

        if isfield(waveforms,'rxTD')
            rxTD=waveforms.rxTD;

            if isempty(rxTD)
                return
            end
        else
            return
        end
        if isfield(waveforms,'clockValidTD')&&isfield(waveforms,'clockTimeTD')
            clockAvailable=true;
        else
            clockAvailable=false;
        end





        sps=symbolTimeValue/sampleIntervalValue;
        rxTDLength=length(rxTD);
        rxTDSymbols=rxTDLength/sps;


        ignoreSymbols=serdes.internal.callbacks.getIgnoreBits(mws);
        if ignoreSymbols>=rxTDSymbols
            warning(message('serdes:callbacks:IgnoreBitsGreaterThanTotalBits'));
            return
        end


        rxTree=mws.getVariable('RxTree');
        [RxDCD,RxDCDUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_DCD'));
        [RxDj,RxDjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Dj'));
        [RxSj,RxSjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Sj'));
        [RxRj,RxRjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Rj'));

        [RxCRDCD,RxCRDCDUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_DCD'));
        [RxCRDj,RxCRDjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Dj'));
        [RxCRSj,RxCRSjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Sj'));
        [RxCRRj,RxCRRjUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Rj'));
        [RxCRMean,RxCRMeanUnit]=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_Clock_Recovery_Mean'));

        RxGaussianNoise=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_GaussianNoise'));
        RxUniformNoise=serdes.internal.callbacks.getJitterValues(rxTree.getReservedParameter('Rx_UniformNoise'));

        utilitiesMaskNamesValues=serdes.internal.callbacks.getUtilitiesMaskValues(model,'Configuration');


        waveMax=max([max(waveforms.rxTD),1e-3]);
        ea=serdes.EyeAnalyzer('SymbolTime',symbolTimeValue,...
        'SampleInterval',sampleIntervalValue,...
        'DCD',RxDCD,'DCDUnit',RxDCDUnit,...
        'Dj',RxDj,'DjUnit',RxDjUnit,...
        'Sj',RxSj,'SjUnit',RxSjUnit,...
        'Rj',RxRj,'RjUnit',RxRjUnit,...
        'ClockRecoveryDCD',RxCRDCD,'CRDCDUnit',RxCRDCDUnit,...
        'ClockRecoveryDj',RxCRDj,'CRDjUnit',RxCRDjUnit,...
        'ClockRecoverySj',RxCRSj,'CRSjUnit',RxCRSjUnit,...
        'ClockRecoveryRj',RxCRRj,'CRRjUnit',RxCRRjUnit,...
        'ClockRecoveryMean',RxCRMean,'CRMeanUnit',RxCRMeanUnit,...
        'GaussianNoise',RxGaussianNoise,...
        'UniformNoise',RxUniformNoise,...
...
        'MaxVoltage',waveMax,...
        'ClockMode',utilitiesMaskNamesValues.EyeDiagramClockMode,...
        'IgnoreSymbols',ignoreSymbols);


        Signaling=utilitiesMaskNamesValues.Signaling;
        if strcmpi(Signaling,'single-ended')
            waveMin=min(waveforms.rxTD);
            ea.Signaling=Signaling;
            ea.MinVoltage=waveMin;
        else
            ea.Signaling=Signaling;
            waveMin=-waveMax;
        end
        dv=(waveMax-waveMin)/modulationValue;
        Dthreshold=(waveMin+dv):dv:(waveMax-dv);
        thresholds=repmat(Dthreshold,length(waveforms.rxTD),1);

        if clockAvailable
            ea.ClockIsInput=true;
            ea.ThresholdIsInput=true;
            ea(waveforms.rxTD,...
            waveforms.clockTimeTD,...
            waveforms.clockValidTD,...
            thresholds);
        else
            ea.ClockIsInput=false;
            ea.ThresholdIsInput=true;
            ea(waveforms.rxTD,thresholds);
        end


        [~,prefixstr,Y2]=serdes.utilities.num2prefix(symbolTimeValue);

        tBins=ea.EyeTime*Y2;
        vBins=fliplr(ea.EyeVoltage)';
        histEyeSmooth=ea.EyeHistogram;

        BERplotFloor=1e-20;

        localClockPDF=ea.ClockPDF;
        localClockPDF=localClockPDF/sum(localClockPDF);
        localClockPDF(localClockPDF==0)=BERplotFloor/10;


        if all(histEyeSmooth(1)==histEyeSmooth(:))||all(isnan(histEyeSmooth(:)))


            eyeLinearity=NaN;
            VEC=NaN;
            contours=NaN(256,2*(modulationValue-1));
            bathtubs=NaN(256,modulationValue-1);
            EH=NaN(modulationValue-1,1);
            EW=NaN(modulationValue-1,1);
            eyeAreas=NaN(modulationValue-1,1);
            COM=NaN;
        else
            [eyeLinearity,VEC,contours,bathtubs,EH,~,~,~,~,~,~,~,EW,~,eyeAreas,~,COM]=...
            serdes.utilities.calculatePAMnEye(modulationValue,targetBERValue,...
            tBins(1),tBins(end),vBins(end),vBins(1),histEyeSmooth);
        end


        BERwaveFloor=log10(BERplotFloor/10);
        bathtubs(bathtubs==0)=BERwaveFloor;
        bathtubs(isnan(bathtubs))=BERwaveFloor;


        lowestBERCalculated=1/(rxTDSymbols-ignoreSymbols);
        if lowestBERCalculated>targetBERValue
            metricsBER=lowestBERCalculated;
        else
            metricsBER=targetBERValue;
        end


        serdesAnalysisFigureTag=['SimulinkSerDesAnalysisFigure',model];
        serdesStatPanelTag=['SimulinkStatPlotPanel',model];
        serdesTDPanelTag=['SimulinkTDPlotPanel',model];
        serdesStatPanel=findobj(groot,'Tag',serdesStatPanelTag);
        serdesTDPanel=findobj(groot,'Tag',serdesTDPanelTag);
        statEyeYLimit=[];
        if~isempty(serdesStatPanel)&&~clearPlot
            statEyeAxes=findobj(groot,'Tag','StatEye');
            statEyeYLimit=statEyeAxes.YLim;
        end
        if~isempty(serdesStatPanel)&&~isempty(serdesTDPanel)

            analysisFigure=serdesStatPanel.Parent;

            figure(analysisFigure)

            if clearPlot
                delete(serdesStatPanel)
                serdesStatPanel='';
            end

            delete(serdesTDPanel)
            [tdEyeAxes,tdReportAxes]=setupTimeDomainFigure(analysisFigure,serdesAnalysisFigureTag,serdesStatPanel,serdesTDPanelTag);
        elseif~isempty(serdesStatPanel)
            analysisFigure=serdesStatPanel.Parent;

            figure(analysisFigure)

            if clearPlot
                delete(serdesStatPanel)
                serdesStatPanel='';
            end
            [tdEyeAxes,tdReportAxes]=setupTimeDomainFigure(analysisFigure,serdesAnalysisFigureTag,serdesStatPanel,serdesTDPanelTag);
        elseif~isempty(serdesTDPanel)
            analysisFigure=serdesTDPanel.Parent;
            figure(analysisFigure)
            delete(serdesTDPanel)
            [tdEyeAxes,tdReportAxes]=setupTimeDomainFigure(analysisFigure,serdesAnalysisFigureTag,'',serdesTDPanelTag);
        else
            [tdEyeAxes,tdReportAxes]=setupTimeDomainFigure('',serdesAnalysisFigureTag,'',serdesTDPanelTag);
        end


        title(tdEyeAxes,'Time Domain Eye')

        yyaxis(tdEyeAxes,'right')
        linecolor=[0.75,0,0.75];
        semilogy(tdEyeAxes,...
        tBins,10.^bathtubs,'-',...
        tBins,localClockPDF,'-',...
        'color',linecolor,'linewidth',2)


        ax=axis(tdEyeAxes);
        ax(3)=BERplotFloor;
        axis(tdEyeAxes,ax);

        set(tdEyeAxes,'YColor',linecolor)
        ylabel(tdEyeAxes,'[Probability]')


        yyaxis(tdEyeAxes,'left')
        hold(tdEyeAxes,'on')
        displayVBins=flip(vBins');


        [mincval,maxcval]=serdes.internal.colormapToScale(...
        histEyeSmooth,serdes.utilities.SignalIntegrityColorMap,1e-18);

        imagesc(tdEyeAxes,tBins,displayVBins,histEyeSmooth,[mincval,maxcval]);
        axis(tdEyeAxes,'xy');

        colormap(tdEyeAxes,serdes.utilities.SignalIntegrityColorMap)

        plot(tdEyeAxes,tBins,contours,'m-','linewidth',2)
        xlabel(tdEyeAxes,"["+prefixstr+"]")
        ylabel(tdEyeAxes,'[V]')
        tdEyeAxes.Tag='TimeDomainEye';

        if~isempty(statEyeYLimit)
            tdEyeAxes.YLim=statEyeYLimit;
        end

        tdEyeAxes.XLim=[min(tBins),max(tBins)];
        hold(tdEyeAxes,'off')

        if modulationValue==4
            disptable=cell(15,2);
            disptable(:,1)={'Eye Height Upper (V)','Eye Height Center (V)','Eye Height Lower (V)',...
            'Eye Width Upper (ps)','Eye Width Center (ps)','Eye Width Lower (ps)',...
            'Eye Area Upper (V*ps)','Eye Area Center (V*ps)','Eye Area Lower (V*ps)',...
            'COM','VEC','Eye Linearity','Minimum BER','Ignore Symbols','Total Symbols'};

            EH=flipud(EH);
            EW=flipud(EW);
            eyeAreas=flipud(eyeAreas);
            disptable(:,2)=num2cell([EH;EW;eyeAreas;COM;VEC;eyeLinearity;metricsBER;...
            ignoreSymbols;rxTDSymbols]);
        elseif modulationValue==3
            disptable=cell(12,2);
            disptable(:,1)={'Eye Height Upper (V)','Eye Height Lower (V)',...
            'Eye Width Upper (ps)','Eye Width Lower (ps)',...
            'Eye Area Upper (V*ps)','Eye Area Lower (V*ps)',...
            'COM','VEC','Eye Linearity','Minimum BER','Ignore Symbols','Total Symbols'};

            EH=flipud(EH);
            EW=flipud(EW);
            eyeAreas=flipud(eyeAreas);
            disptable(:,2)=num2cell([EH;EW;eyeAreas;COM;VEC;eyeLinearity;metricsBER;...
            ignoreSymbols;rxTDSymbols]);
        elseif modulationValue==2
            disptable=cell(8,2);
            disptable(:,1)={'Eye Height (V)','Eye Width (ps)','Eye Area (V*ps)','COM','VEC','Minimum BER',...
            'Ignore Symbols','Total Symbols'};
            disptable(:,2)=num2cell([EH(1),EW(1),eyeAreas(1),COM,VEC,metricsBER,...
            ignoreSymbols,rxTDSymbols]');
        else
            disptable=cell(8,2);
            disptable(:,1)={'Eye Height (V)','Eye Width (ps)','Eye Area (V*ps)','COM','VEC','Minimum BER',...
            'Ignore Symbols','Total Symbols'};

            tableData={mat2str(EH',3);mat2str(EW',3);mat2str(eyeAreas',3);mat2str(COM,3);mat2str(VEC,3);...
            mat2str(metricsBER,3);mat2str(ignoreSymbols,3);mat2str(rxTDSymbols,3)};
            disptable(:,2)=tableData;
            tableDataWidth=max(cellfun(@length,tableData));
            tdReportAxes.ColumnWidth={120,tableDataWidth*6};
            tdReportAxes.Tooltip='Height, width, and area ordered from lower to upper eye';
        end

        tdReportAxes.Data=disptable;
        tdReportAxes.ColumnName={'Time Domain Metric ','Data'};
        tdReportAxes.RowName={};
        tdReportAxes.Tag='TDReport';


        if mws.hasVariable('SerDesResults')
            results=mws.getVariable('SerDesResults');
        else
            results=struct;
        end
        TDResults=struct(...
        'th',tBins,...
        'vh',displayVBins,...
        'contours',contours,...
        'bathtubs',bathtubs,...
        'clockPDF',localClockPDF,...
        'eye',histEyeSmooth,...
        'timeStamp',now);
        TDResults.summary=disptable;
        results.TimeDomain=TDResults;
        mws.assignin('SerDesResults',results);

    end
end


function waveforms=getWaveformsFromWS(model)
    waveforms='';







    simulation=Simulink.sdi.getCurrentSimulationRun(model);
    if isempty(simulation)
        return
    end
    simulation=Simulink.sdi.getRun(simulation.id);
    if isempty(simulation)
        return
    end

    rxTD=getWaveformFromSimulation(simulation,'rxOut','Rx');
    clockValidTD=getWaveformFromSimulation(simulation,'clockValidOnRising','Unknown');
    clockTimeTD=getWaveformFromSimulation(simulation,'clockTime','Unknown');

    if~isempty(rxTD)
        waveforms.rxTD=rxTD;
    end
    if~isempty(clockValidTD)
        waveforms.clockValidTD=clockValidTD;
    end
    if~isempty(clockTimeTD)
        waveforms.clockTimeTD=clockTimeTD;
    end
end

function waveform=getWaveformFromSimulation(simulation,signalName,blockName)

    waveform=[];
    signal=simulation.getSignalsByName(signalName);
    if~isempty(signal)
        signalSize=size(signal,2);
        if signalSize>1&&strcmp(blockName,'Rx')
            foundBlock=false;
            for signalIdx=1:signalSize
                if strcmp(signal(signalIdx).BlockName,blockName)
                    signal=signal(signalIdx);
                    foundBlock=true;
                    break
                end
            end
            if~foundBlock
                error(message('serdes:callbacks:LoggedDataNotAvailable',blockName))
            end
        elseif signalSize>1
            error(message('serdes:callbacks:DuplicateSignalName',signalName))
        end
        waveform=signal.Values.Data;


        waveformDimensions=ndims(waveform);

        if waveformDimensions==2

            [~,waveformMaxDimension]=max(size(waveform));
            if waveformMaxDimension==2
                waveform=waveform';
            end
        elseif waveformDimensions==3

            waveform=squeeze(waveform);

            waveformDimensions=ndims(waveform);
            if waveformDimensions~=2
                error(message('serdes:callbacks:LoggedDataWrongFormat',signalName))
            end

            [~,waveformMaxDimension]=max(size(waveform));
            if waveformMaxDimension==2
                waveform=waveform';
            end
        else
            error(message('serdes:callbacks:LoggedDataWrongFormat',signalName))
        end

        if~isempty(waveform)
            waveform(1)=[];
        end
    end
end


function[tdEyeAxes,tdReportAxes]=setupTimeDomainFigure(existingAnalysisFigure,serdesAnalysisFigureTag,serdesStatPanel,serdesTDPanelTag)

    if~isempty(existingAnalysisFigure)
        analysisFigure=existingAnalysisFigure;

        if~isempty(serdesStatPanel)
            currentAnalysisFigurePosition=analysisFigure.Position;


            if currentAnalysisFigurePosition(4)<0.45
                newAnalysisFigurePosition=currentAnalysisFigurePosition;
                heightBump=0.45-currentAnalysisFigurePosition(4);

                newAnalysisFigurePosition(2)=currentAnalysisFigurePosition(2)-heightBump;
                newAnalysisFigurePosition(4)=currentAnalysisFigurePosition(4)+heightBump;
                analysisFigure.Position=newAnalysisFigurePosition;
            end

            tdPanelHeight=0.35;
            statPanelHeight=1-tdPanelHeight;
            serdesStatPanel.Position=[0,tdPanelHeight,1,statPanelHeight];

            tdPanelPosition=[0,0,1,tdPanelHeight];

            analysisFigure.Name=getString(message('serdes:callbacks:SimulinkStatAndTDTitle'));
        else
            currentAnalysisFigurePosition=analysisFigure.Position;

            if currentAnalysisFigurePosition(4)<0.15
                newAnalysisFigurePosition=currentAnalysisFigurePosition;
                heightBump=0.15-currentAnalysisFigurePosition(4);

                newAnalysisFigurePosition(2)=currentAnalysisFigurePosition(2)-heightBump;
                newAnalysisFigurePosition(4)=currentAnalysisFigurePosition(4)+heightBump;
                analysisFigure.Position=newAnalysisFigurePosition;
            end

            tdPanelPosition=[0,0,1,1];

            analysisFigure.Name=getString(message('serdes:callbacks:SimulinkTDTitle'));
        end
    else
        analysisFigure=figure('Units','normalized');

        analysisFigure.Position=[0.2,0.5,0.3,0.15];
        analysisFigure.NumberTitle='off';
        analysisFigure.IntegerHandle='off';
        analysisFigure.Tag=serdesAnalysisFigureTag;
        analysisFigure.Name=getString(message('serdes:callbacks:SimulinkTDTitle'));

        tdPanelPosition=[0,0,1,1];
    end

    tdPanel=uipanel(analysisFigure,...
    'Title','Time Domain Analysis',...
    'FontSize',12,...
    'BackgroundColor','white',...
    'Units','normalized',...
    'Position',tdPanelPosition);
    tdPanel.Tag=serdesTDPanelTag;

    tdEyeAxes=axes(tdPanel,...
    'Units','normalized',...
    'OuterPosition',[0,0,0.5,1]);
    tdReportAxes=uitable(tdPanel,...
    'Units','normalized',...
    'OuterPosition',[0.56,0,0.44,1]);
end