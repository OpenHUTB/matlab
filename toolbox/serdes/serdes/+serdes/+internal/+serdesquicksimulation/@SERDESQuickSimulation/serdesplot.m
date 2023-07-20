function serdesplot(obj,fld)




    if~isempty(obj)

        if~obj.refreshValuesFromWorkspaceVariables()
            return;
        end
    end

    sys=[];
    dt=[];
    if nargin==1
        fld='Pout';
    else
        if iscell(fld)
            view=fld{2};
            if numel(fld)==6

                sys=fld{3};
                dt=fld{4};
                mismatchedValuesBlocksCTLE=fld{5};
                mismatchedValuesBlocksDFECDR=fld{6};
            end
            fld=fld{1};
        else
            view=[];
        end
        validateattributes(fld,{'char','string'},{'nonempty','row'})
    end
    str=validatestring(fld,{...
    'DirtyState',...
    'Update',...
    'Pulse Response',...
    'Impulse Response',...
    'STAT Eye',...
    'PRBS Waveform',...
    'Contours',...
    'Bathtub',...
    'BER',...
    'COM',...
    'Report',...
    'CTLE Transfer Function',...
    'All'});


    if isempty(view)
        fig=figure;
        set(fig,'Name',str);
    else
        if isprop(view,'SerdesDesignerTool')
            view.SerdesDesignerTool.setStatus('Plotting...');
        end
        isDirty=wasDirtyState(view);
        switch lower(fld)
        case 'dirtystate'

            dirtyColor=[0.7,0.7,0.7];
            for i=1:numel(view.PlotsFig_All_NonBlank)

                try
                    if view.PlotsFig_All_NonBlank(i)==view.PlotsFig_Report
                        view.PlotsFig_All_NonBlank(i).Children.ForegroundColor=dirtyColor;
                    elseif view.PlotsFig_All_NonBlank(i)==view.PlotsFig_CTLE
                        if~isempty(view.PlotsFig_CTLE.Children)
                            plots=view.PlotsFig_CTLE.Children.Children;
                            if~isempty(plots)
                                for j=1:length(plots)
                                    plots(j).BackgroundColor=dirtyColor;
                                end
                            end
                        end
                    else
                        view.PlotsFig_All_NonBlank(i).CurrentAxes.XColor=dirtyColor;
                        view.PlotsFig_All_NonBlank(i).CurrentAxes.YColor=dirtyColor;
                        view.PlotsFig_All_NonBlank(i).CurrentAxes.Title.Color=dirtyColor;
                        view.PlotsFig_All_NonBlank(i).CurrentAxes.XLabel.Color=dirtyColor;
                        view.PlotsFig_All_NonBlank(i).CurrentAxes.YLabel.Color=dirtyColor;
                        children=view.PlotsFig_All_NonBlank(i).Children.Children;
                        if~isempty(children)&&numel(children)>0
                            for j=1:numel(children)
                                if isa(children(j),'matlab.graphics.chart.primitive.Line')
                                    set(children(j),'color',dirtyColor);
                                end
                            end
                        end
                    end
                catch

                end
            end
            if~isempty(view.PlotsFig_StatEye)
                colormap(view.PlotsFig_StatEye,'gray');
            end
            if~isempty(view.PlotsFig_BER)
                colormap(view.PlotsFig_BER,'gray');
            end
            if ismethod(view,'enableDisableAutoUpdateButtonAndCheckbox')
                view.enableDisableAutoUpdateButtonAndCheckbox();
            end
            if isprop(view,'SerdesDesignerTool')
                view.SerdesDesignerTool.setStatus('');
            end
            return;
        case 'update'
            currentDoc=[];
            currentFig=[];
            visiblePlotDocs=view.getVisiblePlotDocs();
            if isempty(visiblePlotDocs)
                currentDoc=view.PlotsDoc_Blank;
                currentFig=view.PlotsFig_Blank;
            else
                for i=1:length(visiblePlotDocs)
                    if visiblePlotDocs{i}.Selected

                        currentDoc=visiblePlotDocs{i};
                        currentFig=visiblePlotDocs{i}.Figure;
                        break;
                    end
                end
            end
            if view.isPlot(currentFig)

                doc=currentDoc;
                fig=currentFig;
            else

                doc=view.getSelectedPlotDoc();
                if~isempty(doc)
                    fig=doc.Figure;
                else
                    fig=view.PlotsFig_Blank;
                end
            end
            if isDirty
                view=initPlotAndAxes_All(view);
            end
        case{'pulse response'}
            view=initPlotAndAxes_PulseResponse(view);
            doc=view.PlotsDoc_PulseRes;
            fig=view.PlotsFig_PulseRes;
        case{'impulse response'}
            view=initPlotAndAxes_ImpulseResponse(view);
            doc=view.PlotsDoc_ImpulseRes;
            fig=view.PlotsFig_ImpulseRes;
        case{'stat eye'}
            view=initPlotAndAxes_StatEye(view);
            doc=view.PlotsDoc_StatEye;
            fig=view.PlotsFig_StatEye;
        case{'prbs waveform'}
            view=initPlotAndAxes_PRBSWaveform(view);
            doc=view.PlotsDoc_PrbsWaveform;
            fig=view.PlotsFig_PrbsWaveform;
        case{'contours'}
            view=initPlotAndAxes_Contours(view);
            doc=view.PlotsDoc_Contours;
            fig=view.PlotsFig_Contours;
        case{'bathtub'}
            view=initPlotAndAxes_Bathtub(view);
            doc=view.PlotsDoc_Bathtub;
            fig=view.PlotsFig_Bathtub;
        case{'ber'}
            view=initPlotAndAxes_BER(view);
            doc=view.PlotsDoc_BER;
            fig=view.PlotsFig_BER;
        case{'com'}
            view=initPlotAndAxes_COM(view);
            doc=view.PlotsDoc_COM;
            fig=view.PlotsFig_COM;
        case{'report'}
            view=initPlotAndAxes_Report(view);
            doc=view.PlotsDoc_Report;
            fig=view.PlotsFig_Report;
        case{'ctle transfer function'}
            doc=view.PlotsDoc_CTLE;
            fig=view.PlotsFig_CTLE;
        case{'all'}
            view=initPlotAndAxes_All(view);
            doc=[];
            fig=[];
        otherwise
            doc=view.PlotsDoc_Blank;
            fig=view.PlotsFig_Blank;
        end
        if~isempty(fig)&&~isempty(doc)&&...
            (~doc.Phantom||~strcmpi(fld,'update')||doc~=view.getSelectedPlotDoc())
            doc.Phantom=false;
            for i=1:length(view.PlotsDoc_All_NonBlank)
                view.PlotsDoc_All_NonBlank(i).Selected=view.PlotsDoc_All_NonBlank(i)==doc;
            end

            if isprop(view,'PlotsFig_Blank')&&fig~=view.PlotsFig_Blank
                view.PlotsDoc_Blank.Phantom=true;
            end
        end
        if ismethod(view,'enableDisableAutoUpdateButtonAndCheckbox')
            view.enableDisableAutoUpdateButtonAndCheckbox();
        end
    end

    if~isempty(fig)&&isprop(view,'PlotsFig_Blank')&&fig==view.PlotsFig_Blank||...
        ~strcmpi(fld,'Update')&&isprop(view,'Toolstrip')&&~view.Toolstrip.isAutoUpdate()&&...
isDirty
        if isprop(view,'SerdesDesignerTool')
            view.SerdesDesignerTool.setStatus('');
        end
        return;
    end


    if isempty(sys)
        b=clone(obj);
        [sys,dt,mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR]=computeQuickSimulation(b);
    end
    if isempty(sys)||isempty(dt)
        return;
    end
    if~isempty(mismatchedValuesBlocksCTLE)||~isempty(mismatchedValuesBlocksDFECDR)
        serdes.internal.apps.serdesdesigner.Model.showMismatchedValuesDialog(mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR);
        if isprop(view,'SerdesDesignerTool')
            view.SerdesDesignerTool.setStatus('');
        end
        return;
    end

    h=matlabshared.application.IgnoreWarnings;
    h.RethrowWarning=false;
    try
        waveResults=analysis(sys);
        [str,~]=lastwarn;
        if~isempty(str)
            showWarning(str);
        end
        delete(h);
    catch ex
        [str,~]=lastwarn;
        if~isempty(str)
            showWarning(str);
        end
        delete(h);
        title=message('serdes:serdesdesigner:BadComputedResultsTitle');
        h=errordlg(ex.message,getString(title),'modal');
        uiwait(h);
        if isprop(view,'SerdesDesignerTool')
            view.SerdesDesignerTool.setStatus('');
        end
        obj.serdesplot({'DirtyState',view,sys,dt,mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR});
        return;
    end

    impulse2=waveResults.impulse;
    pulse2=waveResults.pulse;
    wave2=waveResults.wave;
    outparams=waveResults.outparams;


    stateye=sys.Eye.Stateye;
    th2=sys.Eye.Th2;
    vh=sys.Eye.Vh;



    localClockPDF=sys.Eye.ClockPDF;
    ndx0=localClockPDF==0;
    minNot0=min(localClockPDF(~ndx0));
    localClockPDF(ndx0)=min([sys.BERPlotFloor/10,minNot0]);
    lowerbound=sys.BERPlotFloor;



    [eyeLinearity,VEC,contours,bathtubs,vHeight,aHeight,...
    bestEyeHeight,bestEyeHeightVoltage,bestEyeHeightTime,...
    bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
    vmidWidth,vmidThreshold,eyeAreas,eyeAreaMetric,COM]=...
    serdes.utilities.calculatePAMnEye(sys.Modulation,sys.BERtarget,th2(1),th2(end),vh(1),vh(end),stateye);


    ndx0=isnan(bathtubs);
    minNot0=min(bathtubs(~ndx0));
    bathtubs(ndx0)=min([log10(sys.BERPlotFloor/10),minNot0]);


    si_eyecmap=serdes.utilities.SignalIntegrityColorMap;


    view.ChannelFlag=sys.ChannelData.OptionSel;


    eyexlabel=sys.Eye.tprefix;


    drawnow;
    switch lower(fld)
    case 'update'
        updateDisplayedPlots(view,dt,impulse2,pulse2,wave2,stateye,si_eyecmap,vh,th2,...
        eyeLinearity,VEC,contours,bathtubs,vHeight,aHeight,...
        bestEyeHeight,bestEyeHeightVoltage,bestEyeHeightTime,...
        bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
        vmidWidth,vmidThreshold,eyeAreas,eyeAreaMetric,COM,...
        sys.Modulation,outparams,fig,sys,localClockPDF,lowerbound,eyexlabel);
    case{'pulse response'}
        plotPulseResponse(view,dt,pulse2);
    case{'impulse response'}
        plotImpulseResponse(view,dt,impulse2);
    case{'stat eye'}
        plotStatEye(view,stateye,si_eyecmap,vh,th2,eyexlabel);
    case{'prbs waveform'}
        plotPrbsWaveform(view,dt,wave2);
    case{'contours'}
        plotContours(view,vh,th2,contours,eyexlabel);
    case{'bathtub'}
        plotBathtub(view,th2,bathtubs,localClockPDF,lowerbound,eyexlabel);
    case{'ber'}
        plotBer(view,stateye,si_eyecmap,vh,th2,contours,bathtubs,localClockPDF,lowerbound,eyexlabel);
    case{'com'}
        plotCom(4,view);
    case{'report'}
        plotReport(view,eyeLinearity,VEC,vHeight,aHeight,...
        bestEyeHeight,bestEyeHeightVoltage,bestEyeHeightTime,...
        bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
        vmidWidth,vmidThreshold,eyeAreas,eyeAreaMetric,COM,...
        sys.Modulation,outparams);
    case{'ctle transfer function'}
        plotCTLE_TransferFunction(view,sys);
    case{'all'}
        plotPulseResponse(view,dt,pulse2);
        plotImpulseResponse(view,dt,impulse2);
        plotStatEye(view,stateye,si_eyecmap,vh,th2,eyexlabel);
        plotPrbsWaveform(view,dt,wave2);
        plotContours(view,vh,th2,contours,eyexlabel);
        plotBathtub(view,th2,bathtubs,localClockPDF,lowerbound,eyexlabel);
        plotBer(view,stateye,si_eyecmap,vh,th2,contours,bathtubs,localClockPDF,lowerbound,eyexlabel);

        plotReport(view,eyeLinearity,VEC,vHeight,aHeight,...
        bestEyeHeight,bestEyeHeightVoltage,bestEyeHeightTime,...
        bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
        vmidWidth,vmidThreshold,eyeAreas,eyeAreaMetric,COM,...
        sys.Modulation,outparams);
        plotCTLE_TransferFunction(view,sys);
        view.PlotsDoc_Blank.Phantom=true;
        drawnow;
        view.togglePlotsDocSelection();
        if ismethod(view,'enableDisableAutoUpdateButtonAndCheckbox')
            view.enableDisableAutoUpdateButtonAndCheckbox();
        end
    end

    if~isempty(fig)&&...
        (isprop(view,'PlotsFig_Blank')&&fig~=view.PlotsFig_Blank)&&...
        (isprop(view,'PlotsFig_Report')&&fig~=view.PlotsFig_Report)&&~strcmpi(fld,'Report')&&...
        (isprop(view,'PlotsFig_CTLE')&&fig~=view.PlotsFig_CTLE)&&~strcmpi(fld,'CTLE Transfer Function')
        fig.CurrentAxes.Toolbar.Visible='on';
    end
    if isprop(view,'SerdesDesignerTool')
        view.SerdesDesignerTool.setStatus('');
    end
end
function showWarning(str)
    if~isempty(str)

        opts=struct('WindowStyle','modal','Interpreter','tex');
        h=warndlg(str,'Warning',opts);
        uiwait(h);
    end
end

function view=initPlotAndAxes_All(view)
    view=initPlotAndAxes_PulseResponse(view);
    view=initPlotAndAxes_StatEye(view);
    view=initPlotAndAxes_PRBSWaveform(view);
    view=initPlotAndAxes_Contours(view);
    view=initPlotAndAxes_Bathtub(view);

    view=initPlotAndAxes_Report(view);
    view=initPlotAndAxes_BER(view);
    view=initPlotAndAxes_ImpulseResponse(view);
    view.PlotsDoc_CTLE.Phantom=false;
end
function view=initPlotAndAxes_PulseResponse(view)
    view.Plot_PulseRes=[];
    view.PlotAxes_PulseRes=[];
    view.PlotsDoc_PulseRes.Phantom=false;
end
function view=initPlotAndAxes_ImpulseResponse(view)
    view.Plot_ImpulseRes=[];
    view.PlotAxes_ImpulseRes=[];
    view.PlotsDoc_ImpulseRes.Phantom=false;
end
function view=initPlotAndAxes_StatEye(view)
    view.Plot_StatEye=[];
    view.PlotAxes_StatEye=[];
    view.PlotsDoc_StatEye.Phantom=false;
end
function view=initPlotAndAxes_PRBSWaveform(view)
    view.Plot_PrbsWaveform=[];
    view.PlotAxes_PrbsWaveform=[];
    view.PlotsDoc_PrbsWaveform.Phantom=false;
end
function view=initPlotAndAxes_Contours(view)
    view.Plot_Contours=[];
    view.PlotAxes_Contours=[];
    view.PlotsDoc_Contours.Phantom=false;
end
function view=initPlotAndAxes_Bathtub(view)
    view.Plot_Bathtub=[];
    view.PlotAxes_Bathtub=[];
    view.PlotsDoc_Bathtub.Phantom=false;
end
function view=initPlotAndAxes_COM(view)
    view.Plot_COM=[];
    view.PlotAxes_COM=[];
    view.PlotsDoc_COM.Phantom=false;
end
function view=initPlotAndAxes_Report(view)
    view.Plot_Report=[];
    view.PlotAxes_Report=[];
    view.PlotsDoc_Report.Phantom=false;
end
function view=initPlotAndAxes_BER(view)
    view.Plot_BER=[];
    view.PlotAxes_BER=[];
    view.PlotsDoc_BER.Phantom=false;
end

function isDirty=wasDirtyState(view)
    if~isprop(view,'PlotsFig_All_NonBlank')

        isDirty=false;
        return;
    end
    dirtyColor=[0.7,0.7,0.7];
    for i=1:numel(view.PlotsFig_All_NonBlank)
        if view.PlotsDoc_All_NonBlank(i).Visible==true
            if view.PlotsFig_All_NonBlank(i)==view.PlotsFig_Report
                if isequal(dirtyColor,view.PlotsFig_All_NonBlank(i).Color)
                    isDirty=true;
                    return;
                end
            elseif~isempty(view.PlotsFig_All_NonBlank(i).CurrentAxes)
                if isequal(dirtyColor,view.PlotsFig_All_NonBlank(i).CurrentAxes.XColor)||...
                    isequal(dirtyColor,view.PlotsFig_All_NonBlank(i).CurrentAxes.YColor)||...
                    isequal(dirtyColor,view.PlotsFig_All_NonBlank(i).CurrentAxes.Title.Color)||...
                    isequal(dirtyColor,view.PlotsFig_All_NonBlank(i).CurrentAxes.XLabel.Color)||...
                    isequal(dirtyColor,view.PlotsFig_All_NonBlank(i).CurrentAxes.YLabel.Color)
                    isDirty=true;
                    return;
                end
            end
        end
    end
    isDirty=false;
end

function updateDisplayedPlots(view,dt,impulse,pulse,wave,stateye,si_eyecmap,vh,th2,...
    eyeLinearity,VEC,contours,bathtubs,vHeight,aHeight,...
    bestEyeHeight,bestEyeHeightVoltage,bestEyeHeightTime,...
    bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
    vmidWidth,vmidThreshold,eyeAreas,eyeAreaMetric,COM,...
    modulation,outparams,doc,sys,clockPDF,lowerbound,eyexlabel)
    visiblePlotDocs=view.getVisiblePlotDocs();
    if~isempty(visiblePlotDocs)
        for i=1:numel(visiblePlotDocs)
            switch visiblePlotDocs{i}.Figure
            case view.PlotsFig_PulseRes
                plotPulseResponse(view,dt,pulse);
            case view.PlotsFig_ImpulseRes
                plotImpulseResponse(view,dt,impulse);
            case view.PlotsFig_StatEye
                plotStatEye(view,stateye,si_eyecmap,vh,th2,eyexlabel);
            case view.PlotsFig_PrbsWaveform
                plotPrbsWaveform(view,dt,wave);
            case view.PlotsFig_Contours
                plotContours(view,vh,th2,contours,eyexlabel);
            case view.PlotsFig_Bathtub
                plotBathtub(view,th2,bathtubs,clockPDF,lowerbound,eyexlabel);
            case view.PlotsFig_BER
                plotBer(view,stateye,si_eyecmap,vh,th2,contours,bathtubs,clockPDF,lowerbound,eyexlabel);
            case view.PlotsFig_COM
                plotCom(4,view);
            case view.PlotsFig_Report
                plotReport(view,eyeLinearity,VEC,vHeight,aHeight,...
                bestEyeHeight,bestEyeHeightVoltage,bestEyeHeightTime,...
                bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
                vmidWidth,vmidThreshold,eyeAreas,eyeAreaMetric,COM,...
                modulation,outparams);
            case view.PlotsFig_CTLE
                plotCTLE_TransferFunction(view,sys);
            end
        end
        if~isempty(doc)
            for i=1:numel(visiblePlotDocs)

                visiblePlotDocs{i}.Selected=visiblePlotDocs{i}==doc;
            end
        end
    end
end

function legendCell=getWaveLegend(numberOfWaves,ChannelFlag)

    legendCell=cell(numberOfWaves,2);
    legendCell{1,1}='Unequalized primary';
    legendCell{1,2}='Equalized primary';
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

function plotPulseResponse(view,dt,pulse)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_PulseRes=true;
    if strcmpi(view.PlotsFig_PulseRes.Visible,'off')
        view.PlotsFig_PulseRes.Visible='on';
    end
    t=dt*(0:length(pulse)-1);
    if isempty(view.Plot_PulseRes)||isempty(view.PlotAxes_PulseRes)||length(view.Plot_PulseRes)~=size(pulse,2)

        if isempty(view.PlotsFig_PulseRes.CurrentAxes)
            view.PlotsFig_PulseRes.CurrentAxes=axes('Parent',view.PlotsFig_PulseRes);
        end
        view.PlotAxes_PulseRes=view.PlotsFig_PulseRes.CurrentAxes;
        view.Plot_PulseRes=plot(view.PlotAxes_PulseRes,t,pulse);
        xlabel(view.PlotAxes_PulseRes,'[ s ]');
        ylabel(view.PlotAxes_PulseRes,'[ V ]');

        numberOfWaves=size(pulse,2)/2;
        if numberOfWaves==1
            legend(view.PlotAxes_PulseRes,'Unequalized','Equalized');
        else
            legendCell=getWaveLegend(numberOfWaves,view.ChannelFlag);
            legend(view.PlotAxes_PulseRes,legendCell(:));
        end
        title(view.PlotAxes_PulseRes,getString(message('serdes:serdesdesigner:PulseResponseText')));



        set(view.PlotAxes_PulseRes,'xlim',[0,t(end)],'ylim',[min(-0.01,1.05*min(pulse(:))),1.05*max(pulse(:))]);
        grid(view.PlotAxes_PulseRes,'on');
    else

        for ii=1:size(pulse,2)
            set(view.Plot_PulseRes(ii),'xdata',t,'ydata',pulse(:,ii));
        end
    end
end

function plotImpulseResponse(view,dt,impulse)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_ImpulseRes=true;
    if strcmpi(view.PlotsFig_ImpulseRes.Visible,'off')
        view.PlotsFig_ImpulseRes.Visible='on';
    end
    t=dt*(0:length(impulse)-1);
    if isempty(view.Plot_ImpulseRes)||isempty(view.PlotAxes_ImpulseRes)||length(view.Plot_ImpulseRes)~=size(impulse,2)

        if isempty(view.PlotsFig_ImpulseRes.CurrentAxes)
            view.PlotsFig_ImpulseRes.CurrentAxes=axes('Parent',view.PlotsFig_ImpulseRes);
        end
        view.PlotAxes_ImpulseRes=view.PlotsFig_ImpulseRes.CurrentAxes;
        view.Plot_ImpulseRes=plot(view.PlotAxes_ImpulseRes,t,impulse);
        xlabel(view.PlotAxes_ImpulseRes,'[ s ]');
        ylabel(view.PlotAxes_ImpulseRes,'[ V ]');

        numberOfWaves=size(impulse,2)/2;
        if numberOfWaves==1
            legend(view.PlotAxes_ImpulseRes,'Unequalized','Equalized');
        else
            legendCell=getWaveLegend(numberOfWaves,view.ChannelFlag);
            legend(view.PlotAxes_ImpulseRes,legendCell(:));
        end
        title(view.PlotAxes_ImpulseRes,getString(message('serdes:serdesdesigner:ImpulseResponseText')));



        set(view.PlotAxes_ImpulseRes,'xlim',[0,t(end)],'ylim',[min(-0.01,1.05*min(impulse(:))),1.05*max(impulse(:))]);
        grid(view.PlotAxes_ImpulseRes,'on');
    else

        for ii=1:size(impulse,2)
            set(view.Plot_ImpulseRes(ii),'xdata',t,'ydata',impulse(:,ii));
        end
    end
end

function plotStatEye(view,stateye,si_eyecmap,vh,th2,eyexlabel)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_StatEye=true;
    if strcmpi(view.PlotsFig_StatEye.Visible,'off')
        view.PlotsFig_StatEye.Visible='on';
    end
    if isempty(view.Plot_StatEye)||isempty(view.PlotAxes_StatEye)

        if isempty(view.PlotsFig_StatEye.CurrentAxes)
            view.PlotsFig_StatEye.CurrentAxes=axes('Parent',view.PlotsFig_StatEye);
        end
        view.PlotAxes_StatEye=view.PlotsFig_StatEye.CurrentAxes;
        cla(view.PlotAxes_StatEye,'reset');
        view.Plot_StatEye=imagesc(view.PlotAxes_StatEye,'XData',th2,'YData',vh,'CData',stateye);


        view.PlotsFig_StatEye.CurrentAxes.XColor='k';
        view.PlotsFig_StatEye.CurrentAxes.YColor='k';
        view.PlotsFig_StatEye.CurrentAxes.Title.Color='k';
        view.PlotsFig_StatEye.CurrentAxes.XLabel.Color='k';
        view.PlotsFig_StatEye.CurrentAxes.YLabel.Color='k';
    else

        cla(view.PlotAxes_StatEye,'reset');
        imagesc(view.PlotAxes_StatEye,'XData',th2,'YData',vh,'CData',stateye);
    end


    [th2Min,th2Max,vhMin,vhMax]=getXYMinMaxDisplayLimits(th2,vh);
    set(view.PlotAxes_StatEye,'xlim',[th2Min,th2Max],'ylim',[vhMin,vhMax]);


    [mincval,maxcval]=serdes.internal.colormapToScale(stateye,si_eyecmap,1e-18);
    caxis(view.PlotAxes_StatEye,[mincval,maxcval])
    colormap(view.PlotsFig_StatEye,si_eyecmap);

    xlabel(view.PlotAxes_StatEye,['[ ',eyexlabel,' ]']);
    ylabel(view.PlotAxes_StatEye,'[ V ]');
    title(view.PlotAxes_StatEye,getString(message('serdes:serdesdesigner:StatEyeText')));
    box(view.PlotAxes_StatEye,'on');
end

function[xMin,xMax,yMin,yMax]=getXYMinMaxDisplayLimits(x,y)
    if min(x)<0
        xMin=min(x)*1.005;
    elseif min(x)>0
        xMin=min(x)*0.995;
    else
        xMin=-max(x)*.005;
    end

    if max(x)>0
        xMax=max(x)*1.005;
    elseif min(x)<0
        xMax=max(x)*0.995;
    else
        xMax=-min(x)*.005;
    end

    if min(y)<0
        yMin=min(y)*1.005;
    elseif min(y)>0
        yMin=min(y)*0.995;
    else
        yMin=-max(y)*.0005;
    end

    if max(y)>0
        yMax=max(y)*1.01;
    elseif min(y)<0
        yMax=max(y)*0.99;
    else
        yMax=-min(y)*.001;
    end

end


































function plotPrbsWaveform(view,dt,wave)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_PrbsWaveform=true;
    if strcmpi(view.PlotsFig_PrbsWaveform.Visible,'off')
        view.PlotsFig_PrbsWaveform.Visible='on';
    end
    t2=dt*(0:length(wave)-1);
    if isempty(view.Plot_PrbsWaveform)||isempty(view.PlotAxes_PrbsWaveform)||length(view.Plot_PrbsWaveform)~=size(wave,2)

        if isempty(view.PlotsFig_PrbsWaveform.CurrentAxes)
            view.PlotsFig_PrbsWaveform.CurrentAxes=axes('Parent',view.PlotsFig_PrbsWaveform);
        end
        view.PlotAxes_PrbsWaveform=view.PlotsFig_PrbsWaveform.CurrentAxes;
        view.Plot_PrbsWaveform=plot(view.PlotAxes_PrbsWaveform,t2,wave);
        xlabel(view.PlotAxes_PrbsWaveform,'[ s ]');
        ylabel(view.PlotAxes_PrbsWaveform,'[ V ]');

        numberOfWaves=size(wave,2)/2;
        if numberOfWaves==1
            legend(view.PlotAxes_PrbsWaveform,'Unequalized','Equalized');
        else
            legendCell=getWaveLegend(numberOfWaves,view.ChannelFlag);
            legend(view.PlotAxes_PrbsWaveform,legendCell(:));
        end

        title(view.PlotAxes_PrbsWaveform,getString(message('serdes:serdesdesigner:PrbsWaveformText')));

        set(view.PlotAxes_PrbsWaveform,'xlim',[0,t2(end)],'ylim',[min(wave(:))*1.05,1.05*max(wave(:))]);
        grid(view.PlotAxes_PrbsWaveform,'on');

    else

        for ii=1:size(wave,2)
            set(view.Plot_PrbsWaveform(ii),'xdata',t2,'ydata',wave(:,ii));
        end
    end
end

function plotContours(view,vh,th2,contours,eyexlabel)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_Contours=true;
    if strcmpi(view.PlotsFig_Contours.Visible,'off')
        view.PlotsFig_Contours.Visible='on';
    end
    linecolor=[0.75,0,0.75];

    if isempty(view.Plot_Contours)||isempty(view.PlotAxes_Contours)

        if isempty(view.PlotsFig_Contours.CurrentAxes)
            view.PlotsFig_Contours.CurrentAxes=axes('Parent',view.PlotsFig_Contours);
        end
        view.PlotAxes_Contours=view.PlotsFig_Contours.CurrentAxes;
        view.Plot_Contours=plot(view.PlotAxes_Contours,th2,contours,'m-','color',linecolor,'linewidth',2);
        title(view.PlotAxes_Contours,getString(message('serdes:serdesdesigner:ContoursText')));
    else

        [~,columnCount]=size(contours);
        if columnCount~=numel(get(view.Plot_Contours,'ydata'))

            view.PlotAxes_Contours=view.PlotsFig_Contours.CurrentAxes;
            view.Plot_Contours=plot(view.PlotAxes_Contours,th2,contours,'m-','color',linecolor,'linewidth',2);
            title(view.PlotAxes_Contours,getString(message('serdes:serdesdesigner:ContoursText')));
        else
            set(view.Plot_Contours,'xdata',th2,{'ydata'},num2cell(contours,1)');
        end
    end

    grid(view.PlotAxes_Contours,'on');
    xlabel(view.PlotAxes_Contours,['[ ',eyexlabel,' ]']);
    ylabel(view.PlotAxes_Contours,'[ V ]');
end

function plotBathtub(view,th2,bathtubs,clockPDF,lowerbound,eyexlabel)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_Bathtub=true;
    if strcmpi(view.PlotsFig_Bathtub.Visible,'off')
        view.PlotsFig_Bathtub.Visible='on';
    end
    linecolor=[0.75,0,0.75];

    [~,columnCount]=size(bathtubs);
    if isempty(view.Plot_Bathtub)||isempty(view.PlotAxes_Bathtub)

        if isempty(view.PlotsFig_Bathtub.CurrentAxes)
            view.PlotsFig_Bathtub.CurrentAxes=axes('Parent',view.PlotsFig_Bathtub);
        end
        view.PlotAxes_Bathtub=view.PlotsFig_Bathtub.CurrentAxes;
        view.Plot_Bathtub=semilogy(view.PlotAxes_Bathtub,th2,10.^bathtubs,th2,clockPDF,...
        'color',linecolor,'linewidth',2);
        title(view.PlotAxes_Bathtub,getString(message('serdes:serdesdesigner:BathtubText')));
    else

        [rowCount,~]=size(get(view.Plot_Bathtub,'ydata'));
        if rowCount~=(columnCount+1)

            view.PlotAxes_Bathtub=view.PlotsFig_Bathtub.CurrentAxes;
            view.Plot_Bathtub=semilogy(view.PlotAxes_Bathtub,th2,10.^bathtubs,th2,clockPDF,...
            'color',linecolor,'linewidth',2);
            title(view.PlotAxes_Bathtub,getString(message('serdes:serdesdesigner:BathtubText')));
        else
            set(view.Plot_Bathtub,'xdata',th2,{'ydata'},[num2cell(10.^bathtubs,1)';clockPDF]);
        end
    end
    grid(view.PlotAxes_Bathtub,'on');
    set(view.PlotAxes_Bathtub,'xlim',[th2(1),th2(end)+th2(2)],'ylim',[lowerbound,1]);
    xlabel(view.PlotAxes_Bathtub,['[ ',eyexlabel,' ]']);
    ylabel(view.PlotAxes_Bathtub,'[ Probability ]');
end

function plotBer(view,stateye,si_eyecmap,vh,th2,contours,bathtubs,clockPDF,lowerbound,eyexlabel)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_BER=true;
    if strcmpi(view.PlotsFig_BER.Visible,'off')
        view.PlotsFig_BER.Visible='on';
    end
    linecolor=[0.75,0,0.75];

    [~,columnCount]=size(bathtubs);
    if isempty(view.Plot_BER)||isempty(view.PlotAxes_BER)

        if isempty(view.PlotsFig_BER.CurrentAxes)
            view.PlotsFig_BER.CurrentAxes=axes('Parent',view.PlotsFig_BER);
        end
        view.PlotAxes_BER=view.PlotsFig_BER.CurrentAxes;
        yyaxis(view.PlotAxes_BER,'right');
        view.Plot_BER=semilogy(view.PlotAxes_BER,th2,10.^bathtubs,th2,clockPDF,...
        'color',linecolor,'linewidth',2);


        view.PlotsFig_BER.CurrentAxes.XColor='k';
        view.PlotsFig_BER.CurrentAxes.Title.Color='k';
        view.PlotsFig_BER.CurrentAxes.XLabel.Color='k';
        view.PlotAxes_BER.LineStyleOrder='-';

        set(view.PlotAxes_BER,'YColor',linecolor);
        ylabel(view.PlotAxes_BER,'[ Probability ]');
        title(view.PlotAxes_BER,getString(message('serdes:serdesdesigner:BerText')));

        axis(view.PlotAxes_BER,[0,th2(end),lowerbound,0.5]);


        axesHandlesToChildObjects=findobj(view.PlotAxes_BER,'Type','image');
        if~isempty(axesHandlesToChildObjects)
            delete(axesHandlesToChildObjects);
        end


        yyaxis(view.PlotAxes_BER,'left');
        imagesc(view.PlotAxes_BER,'XData',th2,'YData',vh,'CData',stateye);


        [mincval,maxcval]=serdes.internal.colormapToScale(stateye,si_eyecmap,1e-18);
        caxis(view.PlotAxes_BER,[mincval,maxcval])
        colormap(view.PlotsFig_BER,si_eyecmap);

        axis(view.PlotAxes_BER,[th2(1),th2(end),vh(1),vh(end)]);
        hold(view.PlotAxes_BER,'on');


        view.Plot_BERContour=plot(view.PlotAxes_BER,th2,contours,'m-','color',linecolor,'linewidth',2);
        view.PlotsFig_BER.CurrentAxes.YColor='k';
        view.PlotsFig_BER.CurrentAxes.YLabel.Color='k';
    else

        [rowCount,~]=size(get(view.Plot_BER,'ydata'));
        yyaxis(view.PlotAxes_BER,'right');
        if rowCount~=(columnCount+1)

            view.PlotAxes_BER=view.PlotsFig_BER.CurrentAxes;
            cla(view.PlotAxes_BER,'reset');
            yyaxis(view.PlotAxes_BER,'right');
            view.Plot_BER=semilogy(view.PlotAxes_BER,th2,10.^bathtubs,th2,clockPDF,...
            'color',linecolor,'linewidth',2);
            set(view.PlotAxes_BER,'YColor',linecolor);
            ylabel(view.PlotAxes_BER,'[ Probability ]');
            title(view.PlotAxes_BER,getString(message('serdes:serdesdesigner:BerText')));
        else
            set(view.Plot_BER,'xdata',th2,{'ydata'},[num2cell(10.^bathtubs,1)';clockPDF]);
        end
        axis(view.PlotAxes_BER,[0,th2(end),lowerbound,0.5]);
        view.PlotAxes_BER.LineStyleOrder='-';


        axesHandlesToChildObjects=findobj(view.PlotAxes_BER,'Type','image');
        if~isempty(axesHandlesToChildObjects)
            delete(axesHandlesToChildObjects);
        end


        yyaxis(view.PlotAxes_BER,'left');
        imagesc(view.PlotAxes_BER,'XData',th2,'YData',vh,'CData',stateye);


        [mincval,maxcval]=serdes.internal.colormapToScale(stateye,si_eyecmap,1e-18);
        caxis(view.PlotAxes_BER,[mincval,maxcval])
        colormap(view.PlotsFig_BER,si_eyecmap);

        hold(view.PlotAxes_BER,'on');


        delete(view.Plot_BERContour);
        view.Plot_BERContour=plot(view.PlotAxes_BER,th2,contours,'m-','color',linecolor,'linewidth',2);

    end
    xlabel(view.PlotAxes_BER,['[ ',eyexlabel,' ]']);
    ylabel(view.PlotAxes_BER,'[ V ]');
    box(view.PlotAxes_BER,'on');
    hold(view.PlotAxes_BER,'off');
end

function plotCom(dummy,view)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_COM=true;
    if strcmpi(view.PlotsFig_COM.Visible,'off')
        view.PlotsFig_COM.Visible='on';
    end

    if isempty(view.Plot_COM)||isempty(view.PlotAxes_COM)

        if isempty(view.PlotsFig_COM.CurrentAxes)
            view.PlotsFig_COM.CurrentAxes=axes('Parent',view.PlotsFig_COM);
        end
        view.PlotAxes_COM=view.PlotsFig_COM.CurrentAxes;
        view.Plot_COM=plot(view.PlotAxes_COM,dummy,dummy);
        title(view.PlotAxes_COM,'TODO in class serdesplot.m');
    else

        set(view.Plot_COM,'xdata',dummy,'ydata',dummy);
    end

    grid(view.PlotAxes_COM,'on');
end

function plotReport(view,eyeLinearity,VEC,vHeight,aHeight,...
    bestEyeHeight,bestEyeHeightVoltage,bestEyeHeightTime,...
    bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
    vmidWidth,vmidThreshold,eyeAreas,eyeAreaMetric,COM,...
    modulation,outparams)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_Report=true;

    columns=2;
    if numel(vHeight)==1||numel(vHeight)>3
        rows=5;
    elseif numel(vHeight)==2
        rows=9;
    else
        rows=12;
    end


    d=cell(rows,columns);



    paramSet=[];
    paramSetCount=0;
    if~isempty(outparams)
        for i=1:length(outparams)
            if~isempty(outparams{i})
                paramSetCount=paramSetCount+1;
                paramSet{paramSetCount}=serdes.utilities.FlattenStruct(outparams{i});%#ok<AGROW>
                rows=rows+length(outparams{i})+1;
            end
        end
    end


    if numel(vHeight)==1

        d(1,1)={'Eye Height (V)'};
        d(2,1)={'Eye Width (ps)'};
        d(3,1)={'Eye Area (V*ps)'};
        d(4,1)={'COM'};
        d(5,1)={'VEC'};
        d(1,2)={num2str(vHeight)};
        d(2,2)={num2str(vmidWidth)};
        d(3,2)={num2str(eyeAreas)};
        d(4,2)={num2str(COM)};
        d(5,2)={num2str(VEC)};
    elseif numel(vHeight)==2

        d(1,1)={'Eye Height Upper (V)'};
        d(2,1)={'Eye Height Lower (V)'};
        d(3,1)={'Eye Width Upper (ps)'};
        d(4,1)={'Eye Width Lower (ps)'};
        d(5,1)={'Eye Area Upper (V*ps)'};
        d(6,1)={'Eye Area Lower (V*ps)'};
        d(7,1)={'COM'};
        d(8,1)={'VEC'};
        d(9,1)={'Eye Linearity'};
        d(1,2)={num2str(vHeight(2))};
        d(2,2)={num2str(vHeight(1))};
        d(3,2)={num2str(vmidWidth(2))};
        d(4,2)={num2str(vmidWidth(1))};
        d(5,2)={num2str(eyeAreas(2))};
        d(6,2)={num2str(eyeAreas(1))};
        d(7,2)={num2str(COM)};
        d(8,2)={num2str(VEC)};
        d(9,2)={num2str(eyeLinearity)};
    elseif numel(vHeight)==3

        d(1,1)={'Eye Height Upper (V)'};
        d(2,1)={'Eye Height Center (V)'};
        d(3,1)={'Eye Height Lower (V)'};
        d(4,1)={'Eye Width Upper (ps)'};
        d(5,1)={'Eye Width Center (ps)'};
        d(6,1)={'Eye Width Lower (ps)'};
        d(7,1)={'Eye Area Upper (V*ps)'};
        d(8,1)={'Eye Area Center (V*ps)'};
        d(9,1)={'Eye Area Lower (V*ps)'};
        d(10,1)={'COM'};
        d(11,1)={'VEC'};
        d(12,1)={'Eye Linearity'};
        d(1,2)={num2str(vHeight(3))};
        d(2,2)={num2str(vHeight(2))};
        d(3,2)={num2str(vHeight(1))};
        d(4,2)={num2str(vmidWidth(3))};
        d(5,2)={num2str(vmidWidth(2))};
        d(6,2)={num2str(vmidWidth(1))};
        d(7,2)={num2str(eyeAreas(3))};
        d(8,2)={num2str(eyeAreas(2))};
        d(9,2)={num2str(eyeAreas(1))};
        d(10,2)={num2str(COM)};
        d(11,2)={num2str(VEC)};
        d(12,2)={num2str(eyeLinearity)};
    else

        d(1,1)={'Eye Height (V)'};
        d(2,1)={'Eye Width (ps)'};
        d(3,1)={'Eye Area (V*ps)'};
        d(4,1)={'COM'};
        d(5,1)={'VEC'};
        d(1,2)={num2str(vHeight')};
        d(2,2)={num2str(vmidWidth')};
        d(3,2)={num2str(eyeAreas')};
        d(4,2)={num2str(COM)};
        d(5,2)={num2str(VEC)};
    end


    if numel(vHeight)==1||numel(vHeight)>3
        rowCount=5;
    elseif numel(vHeight)==2
        rowCount=9;
    elseif numel(vHeight)==3
        rowCount=12;
    end
    if paramSetCount>0
        for i=1:paramSetCount
            isFirstRow=true;
            sout=paramSet{i};
            for j=1:size(sout,1)
                if endsWith(sout(j,1),':')

                    temp=sout(j,1);
                    sout(j,1)=extractBetween(temp{1},1,length(temp{1})-1);
                    if startsWith(sout(j,1),'AGC')&&endsWith(sout(j,1),':Gain')
                        sout{j,1}='AGC:Gain (V)';
                    elseif startsWith(sout(j,1),'DFECDR')
                        if endsWith(sout(j,1),':TapWeights')||...
                            endsWith(sout(j,1),':Interior:PAM4Threshold')&&modulation==4
                            sout{j,1}=strcat(sout{j,1},' (V)');
                        elseif endsWith(sout(j,1),':Interior:PAMThreshold')&&(modulation==3||modulation>4)
                            sout{j,1}=strcat(sout{j,1},' (V)');


                            commas=strfind(sout{j,2},',');
                            if~isempty(commas)
                                stopPosition=commas(modulation-1)-1;
                                sout{j,2}=sout{j,2}(1:stopPosition);
                            end
                        else
                            continue;
                        end
                    elseif startsWith(sout(j,1),'CDR')
                        if endsWith(sout(j,1),':Interior:PAM4Threshold')&&modulation==4
                            sout{j,1}=strcat(sout{j,1},' (V)');
                        elseif endsWith(sout(j,1),':Interior:PAMThreshold')&&(modulation==3||modulation>4)
                            sout{j,1}=strcat(sout{j,1},' (V)');


                            commas=strfind(sout{j,2},',');
                            if~isempty(commas)
                                stopPosition=commas(modulation-1)-1;
                                sout{j,2}=sout{j,2}(1:stopPosition);
                            end
                        else
                            continue;
                        end
                    end
                end
                if contains(sout(j,2),",")

                    for k=1:length(sout{j,2})
                        if strcmp(sout{j,2}(k:k),',')
                            sout{j,2}(k:k)=' ';
                        elseif strcmp(sout{j,2}(k:k),'.')
                            exceeds4places=true;
                            for m=k+1:k+4
                                if m>length(sout{j,2})||strcmp(sout{j,2}(m:m),',')||strcmp(sout{j,2}(m:m),' ')
                                    exceeds4places=false;
                                    break;
                                end
                            end
                            if exceeds4places
                                for m=k+5:length(sout{j,2})
                                    if strcmp(sout{j,2}(m:m),',')||strcmp(sout{j,2}(m:m),' ')
                                        k=m;
                                        break;
                                    end
                                    sout{j,2}(m:m)=' ';
                                end
                            end
                        end
                    end
                    sout{j,2}=strtrim(sout{j,2});
                    sout{j,2}=regexprep(sout{j,2},' +',' ');
                    sout(j,2)=strcat('[',sout(j,2));
                    sout(j,2)=strcat(sout(j,2),']');
                end
                if isFirstRow
                    isFirstRow=false;
                    rowCount=rowCount+1;
                    for k=1:columns
                        d(rowCount,columns)={''};
                    end
                end
                rowCount=rowCount+1;
                d(rowCount,1)=sout(j,1);
                d(rowCount,2)=sout(j,2);
            end
        end
    end


    if isempty(view.Plot_Report)||rows~=view.Plot_Report_RowCount||columns~=view.Plot_Report_ColumnCount

        if isempty(view.PlotsFig_Report.Children)
            uigridlayout(view.PlotsFig_Report,'RowHeight',{'1x'},'ColumnWidth',{'1x'},'Scrollable','on');
        end
        if~isempty(view.PlotsFig_Report.Children.Children)
            delete(view.PlotsFig_Report.Children.Children);
        end
        if~isempty(view.Plot_Report)
            delete(view.Plot_Report);
        end
        view.Plot_Report=uitable(view.PlotsFig_Report.Children,...
        'ColumnName',{'Name';'Data'},...
        'Data',d);
        view.Plot_Report_RowCount=rows;
        view.Plot_Report_ColumnCount=columns;
    else

        set(view.Plot_Report,'Data',d);
    end
end

function plotCTLE_TransferFunction(view,sys)
    view.SerdesDesignerTool.Model.SerdesDesign.PlotVisible_CTLE=true;
    if strcmpi(view.PlotsFig_CTLE.Visible,'off')
        view.PlotsFig_CTLE.Visible='on';
    end
    if~isempty(view.PlotsFig_CTLE.Children)
        if~isempty(view.PlotsFig_CTLE.Children.Children)

            plots=view.PlotsFig_CTLE.Children.Children;
            for i=length(plots):-1:1
                plots(i).delete;
                plots(i)=[];
            end
        end

        view.PlotsFig_CTLE.Children.delete;
        view.PlotsFig_CTLE.Children=[];
    end
    lastIndexCTLE=-1;
    containsLastEdited=false;
    elements=getElementsCTLE(view,sys);
    if~isempty(elements)


        view.PlotsFig_CTLE.HandleVisibility='on';
        view.PlotsFig_CTLE.Internal=false;





        set(groot,'CurrentFigure',view.PlotsFig_CTLE);

        view.PlotsFigLayout_CTLE=uigridlayout(view.PlotsFig_CTLE,'RowHeight',{'1x'},'ColumnWidth',{'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
        tabGroup=uitabgroup(view.PlotsFigLayout_CTLE,'TabLocation','left');


        tabGroup.SelectionChangedFcn=@(h,~)actionSelectionChanged(view.PlotsFig_CTLE);
        for i=1:length(elements)
            ctle=elements{i};
            thisTab=uitab(tabGroup,'Title',ctle.Name,'Tag',ctle.Name,'AutoResizeChildren','off');
            axes('Parent',thisTab);
            if ctle.IsLastEdited
                containsLastEdited=true;
                tabGroup.SelectedTab=thisTab;
                view.PlotsFig_CTLE.Name=[getString(message('serdes:serdesdesigner:CTLEText')),':   ',ctle.Name];
            elseif~containsLastEdited
                tabGroup.SelectedTab=thisTab;
            end
            if lastIndexCTLE==-1
                set(groot,'CurrentFigure',view.PlotsFig_CTLE);
            end
            plot(ctle);
            lastIndexCTLE=i;
        end




        view.PlotsFig_CTLE.HandleVisibility='callback';
        view.PlotsFig_CTLE.Internal=true;
    end
    if lastIndexCTLE<1
        view.PlotsFig_CTLE.Name=[getString(message('serdes:serdesdesigner:CTLEText')),':   No CTLE in design.'];
    elseif~containsLastEdited
        view.PlotsFig_CTLE.Name=[getString(message('serdes:serdesdesigner:CTLEText')),':   ',elements{lastIndexCTLE}.Name];
    end
end
function elementsCTLE=getElementsCTLE(view,sys)
    elementsCTLE=[];
    if isprop(view.SerdesDesignerTool.Model.SerdesDesign,'Elements')

        elements=view.SerdesDesignerTool.Model.SerdesDesign.Elements;
        if~isempty(elements)
            for i=1:length(elements)
                if isa(elements{i},'serdes.CTLE')
                    if isempty(elementsCTLE)
                        elementsCTLE={elements{i}};%#ok<CCAT1> % Initialize cell array with 1st element.
                        elementsCTLE{1}.SymbolTime=sys.SymbolTime;
                    else
                        elementsCTLE{end+1}=elements{i};%#ok<AGROW> % Append nth element to cell array.
                        elementsCTLE{length(elementsCTLE)}.SymbolTime=sys.SymbolTime;%#ok<AGROW>
                    end
                end
            end
        end
    elseif~isempty(sys)

        if~isempty(sys.TxModel)&&~isempty(sys.TxModel.Blocks)
            for i=1:length(sys.TxModel.Blocks)
                if isa(sys.TxModel.Blocks{i},'serdes.CTLE')
                    if isempty(elementsCTLE)
                        elementsCTLE={sys.TxModel.Blocks{i}};%#ok<CCAT1> % Initialize cell array with 1st element.
                    else
                        elementsCTLE{end+1}=sys.TxModel.Blocks{i};%#ok<AGROW> % Append nth element to cell array.
                    end
                end
            end
        end

        if~isempty(sys.RxModel)&&~isempty(sys.RxModel.Blocks)
            for i=1:length(sys.RxModel.Blocks)
                if isa(sys.RxModel.Blocks{i},'serdes.CTLE')
                    if isempty(elementsCTLE)
                        elementsCTLE={sys.RxModel.Blocks{i}};%#ok<CCAT1> % Initialize cell array with 1st element.
                    else
                        elementsCTLE{end+1}=sys.RxModel.Blocks{i};%#ok<AGROW> % Append nth element to cell array.
                    end
                end
            end
        end
    end
end









function actionSelectionChanged(PlotsFig_CTLE)
    if~isempty(PlotsFig_CTLE)&&...
        ~isempty(PlotsFig_CTLE.Children)&&...
        ~isempty(PlotsFig_CTLE.Children.Children)&&...
        ~isempty(PlotsFig_CTLE.Children.Children.SelectedTab)
        PlotsFig_CTLE.Name=[getString(message('serdes:serdesdesigner:CTLEText')),':   ',PlotsFig_CTLE.Children.Children.SelectedTab.Title];
    end
end
