function processOpenData(obj,newData,~)




    obj.pWaveform=[];


    for reg=obj.pRegistrations.Children
        thisName=replace(reg.Name,newline,' ');
        if strcmp(thisName,newData.Waveform.Type)||...
            (~isempty(reg.PropertySet.findProp('OldNames'))&&any(strcmp(newData.Waveform.Type,reg.PropertySet.getPropValue('OldNames'))))
            newData.Waveform.Type=thisName;
            fullName=reg.Name;
        end
    end

    waveformTypeChange(obj,fullName);
    newData.Waveform.Type=replace(newData.Waveform.Type,newline,' ');


    newData=obj.pParameters.CurrentDialog.mapToNewRelease(newData);

    obj.pParameters.CurrentDialog.customLoadActions(newData);
    obj.pParameters.CurrentDialog.applyConfiguration(newData.Waveform.Configuration.waveform);


    genDialog=obj.pParameters.GenerationDialog();
    if isfield(newData.Waveform.Configuration,'generation')&&~isempty(genDialog)
        obj.pParameters.GenerationDialog.applyConfiguration(newData.Waveform.Configuration.generation);
        genDialog.layoutUIControls();

    elseif isfield(newData.Waveform.Configuration,'input')
        obj.pParameters.ModulatorDialog.applyConfiguration(newData.Waveform.Configuration.input);
        layoutUIControls(obj.pParameters.ModulatorDialog);
    end
    if isfield(newData.Waveform.Configuration,'filtering')
        obj.pParameters.FilteringDialog.applyConfiguration(newData.Waveform.Configuration.filtering);
        layoutUIControls(obj.pParameters.FilteringDialog);
    end

    obj.pImpairBtn.Value=newData.Impairments.Enabled;
    if newData.Impairments.Enabled&&isempty(obj.pImpairmentsFig)
        toggleImpairments(obj);
    end
    if~isempty(obj.pImpairmentsFig)
        obj.pImpairmentsFig.Visible=newData.Impairments.Enabled;
        obj.pParameters.ImpairDialog.applyConfiguration(newData.Impairments);
    end

    if isfield(newData,'HardwareConfig')&&isfield(newData.HardwareConfig,'Hardware')
        if isempty(obj.pRadioFig)

            if obj.useAppContainer
                document=matlab.ui.internal.FigurePanel(...
                'Title',getString(message('comm:waveformGenerator:RadioFig')),...
                'Tag','RadioFig');
                addPanel(obj.AppContainer,document);
                document.Opened=false;
                obj.pRadioFig=document.Figure;
                obj.pRadioFig.Tag='RadioFig';
                obj.pParameters.LayoutTransmitter=uigridlayout(obj.pRadioFig,[1,1]);
                obj.pParameters.AccordionTransmitter=matlab.ui.container.internal.Accordion('Parent',obj.pParameters.LayoutTransmitter);
            else
                obj.pRadioFig=figure('Name',getString(message('comm:waveformGenerator:RadioFig')),...
                'NumberTitle','off','HandleVisibility','off','Tag','RadioFig');
                obj.ToolGroup.addFigure(obj.pRadioFig);
                obj.pRadioFig.Visible='off';
            end
        end

        if isfield(newData.HardwareConfig,'TransmitterType')

            obj.pCurrentHWType=newData.HardwareConfig.TransmitterType;
            if isfield(newData.HardwareConfig,'TransmitterTag')
                obj.pCurrentHWTag=newData.HardwareConfig.TransmitterTag;
                obj.radioTypeChange(newData.HardwareConfig.TransmitterTag,newData.HardwareConfig.TransmitterType)
            end
            obj.radioTypeChange(newData.HardwareConfig.TransmitterType)
        end



        obj.pParameters.RadioDialog.applyConfiguration(newData.HardwareConfig.Hardware);
        obj.pParameters.TxWaveformDialog.applyConfiguration(newData.HardwareConfig.TxProp);
    end

    obj.pPlotTimeScope=newData.Visualization.TimeScope;
    obj.pPlotSpectrum=newData.Visualization.SpectrumAnalyzer;
    obj.pPlotConstellation=newData.Visualization.Constellation;
    if isfield(newData.Visualization,'EyeDiagram')
        obj.pPlotEyeDiagram=newData.Visualization.EyeDiagram;
    else
        obj.pPlotEyeDiagram=false;
    end
    if isfield(newData.Visualization,'CCDF')
        obj.pPlotCCDF=newData.Visualization.CCDF.Plot;
        obj.pCCDFBurstMode=newData.Visualization.CCDF.BurstMode;
    else
        obj.pPlotCCDF=false;
    end

    currDialog=obj.pParameters.CurrentDialog;
    for k=1:length(currDialog.visualNames)
        thisVis=currDialog.visualNames{k};
        if isfield(newData.Visualization,currDialog.getFigureTag(thisVis))
            currDialog.setVisualState(thisVis,newData.Visualization.(currDialog.getFigureTag(thisVis)));
        end
    end

    obj.setScopeLayout();
    clearScopes(obj);
    layoutUIControls(obj.pParameters.CurrentDialog);
    layoutPanels(obj.pParameters.CurrentDialog);
