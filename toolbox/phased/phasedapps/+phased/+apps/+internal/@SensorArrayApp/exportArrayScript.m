function exportArrayScript(obj)








    sw=StringWriter;
    dateTimeStr=datestr(now);
    ml=ver('matlab');
    pat=ver('phased');
    addcr(sw)
    addcr(sw,'% MATLAB Code from Sensor Array Analyzer App')
    addcr(sw);
    add(sw,'% Generated by MATLAB ')
    add(sw,ml.Version)
    add(sw,' and Phased Array System Toolbox ')
    addcr(sw,pat.Version)
    addcr(sw)
    add(sw,'% Generated on ')
    addcr(sw,dateTimeStr)
    addcr(sw)


    gencode(obj.ParametersPanel.ArrayDialog,sw);
    addcr(sw);


    elementDialog=getElementDialogName(obj);


    gencode(elementDialog,sw);


    if obj.IsSubarray
        gencode(obj.ParametersPanel.AdditionalConfigDialog,sw);
    end




    Frequency=obj.SignalFrequencies;
    PropSpeed=obj.PropagationSpeed;
    SteerAngles=obj.SteeringAngle;
    SubarraySteerAngles=obj.SubarraySteeringAngle;
    PhaseShiftBits=getCurrentPhaseQuanBits(obj);
    ElementWeights=obj.ElementWeights;

    NumSteerAngles=size(SteerAngles,2);
    NumFrequency=length(Frequency);
    NumPhaseShiftBits=length(PhaseShiftBits);


    [SteerAngles,Frequency,PhaseShiftBits]=obj.makeEqualLength(SteerAngles,Frequency,...
    PhaseShiftBits,NumSteerAngles,NumFrequency,NumPhaseShiftBits);

    isOnlyArrayGeo=obj.ToolStripDisplay.PlotButtons{1}.Value&&...
    ~obj.ToolStripDisplay.PlotButtons{4}.Value&&...
    ~obj.ToolStripDisplay.PlotButtons{2}.Value&&...
    ~obj.ToolStripDisplay.Plot2DItems{1}.Value&&...
    ~obj.ToolStripDisplay.Plot2DItems{2}.Value&&...
    ~obj.ToolStripDisplay.Plot2DItems{3}.Value;

    if~isOnlyArrayGeo


        isGLDiag=obj.ToolStripDisplay.PlotButtons{4}.Value;
        isPlot2d3d=obj.ToolStripDisplay.PlotButtons{2}.Value||...
        obj.ToolStripDisplay.Plot2DItems{1}.Value||...
        obj.ToolStripDisplay.Plot2DItems{2}.Value||...
        obj.ToolStripDisplay.Plot2DItems{3}.Value;

        addcr(sw,'% Assign Frequencies and Propagation Speed');
        addcr(sw,['Frequency = ',mat2str(Frequency),';']);
        addcr(sw,['PropagationSpeed = ',num2str(PropSpeed),';']);
        addcr(sw);
        if isGLDiag

            addcr(sw,'% Assign Steering Angles');
            addcr(sw,['SteeringAngles = ',mat2str(SteerAngles),';']);
        end
        if isPlot2d3d
            if any(SteerAngles,'all')
                if~isGLDiag


                    addcr(sw,'% Assign Steering Angles');
                    addcr(sw,['SteeringAngles = ',mat2str(SteerAngles),';']);
                end
                addcr(sw,'% Assign Phase shift quantization bits');
                addcr(sw,['PhaseShiftBits = ',mat2str(PhaseShiftBits),';']);
            end

            if obj.IsSubarray
                if~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                    getString(message('phased:apps:arrayapp:nosubarraysteering')))&&...
                    ~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                    getString(message('phased:apps:arrayapp:customsubarraysteering')))
                    addcr(sw,['SubarraySteerAngles = ',mat2str(SubarraySteerAngles),';']);
                elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                    getString(message('phased:apps:arrayapp:customsubarraysteering')))
                    addcr(sw,['CustomElementWeights = ',mat2str(ElementWeights),';']);
                end
            end
            addcr(sw);
        end
    end
    if~obj.IsSubarray
        currentElement=obj.CurrentArray.Element;
    else
        if isa(obj.CurrentArray,'phased.ReplicatedSubarray')
            currentElement=obj.CurrentArray.Subarray.Element;
        else
            currentElement=obj.CurrentArray.Array.Element;
        end
    end

    isCustomAntenna=false;
    isCustomMicrophone=false;
    switch class(currentElement)
    case 'phased.CustomAntennaElement'
        isCustomAntenna=true;
    case 'phased.CustomMicrophoneElement'
        isCustomMicrophone=true;
    end

    if~isCustomAntenna&&...
        ~isCustomMicrophone&&...
        max(Frequency)>max(currentElement.FrequencyRange)
        addcr(sw,'% Expand Frequency Range');
        addcr(sw,'Array.Element.FrequencyRange(2) = max(Frequency);');
    end

    addcr(sw,'% Create Figure');
    addcr(sw);

    exportPlots(obj,sw)
    editorDoc=matlab.desktop.editor.newDocument(sw.string);
    editorDoc.smartIndentContents;
end