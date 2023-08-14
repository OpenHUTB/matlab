function updateUI(obj,dialogTags)







    import matlab.ui.container.internal.appcontainer.*;
    import matlab.ui.container.internal.AppContainer;
    import matlab.ui.internal.*;


    obj.IsSubarray=numel(dialogTags)==3;

    if obj.IsSubarray
        if isempty(obj.ParametersPanel.AdditionalConfigDialog)
            obj.ParametersPanel.AdditionalConfigDialog=phased.apps.internal.arrayDialogs.SubarrayConfigurationDialog(obj.ParametersPanel);
        else
            delete(obj.ParametersPanel.AdditionalConfigDialog.Panel);
            obj.ParametersPanel.AdditionalConfigDialog=phased.apps.internal.arrayDialogs.SubarrayConfigurationDialog(obj.ParametersPanel);
        end
        if strcmp(dialogTags{3},'replicatedsubarray')

            obj.ParametersPanel.AdditionalConfigDialog.SubarrayType=...
            getString(message('phased:apps:arrayapp:replicatesubarray'));
            obj.ToolStripDisplay.ArrayButton.Value=false;
            obj.ToolStripDisplay.PartitionArrayButton.Value=false;
            obj.ToolStripDisplay.ReplicateSubarrayButton.Value=true;
            closeDefineSubarrayFig(obj);
        else

            obj.ParametersPanel.AdditionalConfigDialog.SubarrayType=...
            getString(message('phased:apps:arrayapp:partitionarray'));
            obj.ToolStripDisplay.ArrayButton.Value=false;
            obj.ToolStripDisplay.PartitionArrayButton.Value=true;
            obj.ToolStripDisplay.ReplicateSubarrayButton.Value=false;
        end

        layoutUIControls(obj.ParametersPanel.AdditionalConfigDialog);
    else
        obj.ToolStripDisplay.ArrayButton.Value=true;
        obj.ToolStripDisplay.PartitionArrayButton.Value=false;
        obj.ToolStripDisplay.ReplicateSubarrayButton.Value=false;
        closeDefineSubarrayFig(obj);
    end

    if isa(obj.importData,'em.Antenna')
        isATAntenna=true;
        sensorData=obj.importData;
    else
        if isa(obj.importData,'phased.internal.AbstractSensorOperation')
            if isa(obj.importData.Sensor,'em.Antenna')
                isATAntenna=true;
            else
                isATAntenna=false;
            end
            if~obj.IsSubarray
                sensorData=obj.importData.Sensor;
            else
                subarray=obj.importData.Sensor;
                if strcmp(dialogTags{3},'replicatedsubarray')
                    sensorData=obj.importData.Sensor.Subarray;
                else
                    sensorData=obj.importData.Sensor.Array;
                end
            end
        else
            isATAntenna=false;
            if~obj.IsSubarray
                sensorData=obj.importData;
            else
                subarray=obj.importData;
                if strcmp(dialogTags{3},'replicatedsubarray')
                    sensorData=obj.importData.Subarray;
                else
                    sensorData=obj.importData.Array;
                end
            end
        end
    end


    if~isscalar(dialogTags)
        arr=sensorData;
        elem=arr.Element;

        if isa(elem,'em.Antenna')
            isATAntenna=true;
        end


        selectArrayItem(obj.ToolStripDisplay,dialogTags{1});
        if~isempty(obj.ParametersPanel.ArrayDialog)
            obj.ParametersPanel.ArrayType='';
        end
        obj.ParametersPanel.ArrayType=dialogTags{1};

        if strcmp(dialogTags{1},'ula')
            if strcmp(obj.Container,'ToolGroup')
                obj.ParametersPanel.ArrayDialog.TaperPopup.Value=7;
                notify(obj.ParametersPanel.ArrayDialog.TaperPopup,'Action');
            else
                obj.ParametersPanel.ArrayDialog.TaperPopup.Value=getString(message('phased:apps:arrayapp:Custom'));
                obj.ParametersPanel.ArrayDialog.Taper=obj.ParametersPanel.ArrayDialog.TaperPopup.Value;
                layoutUIControls(obj.ParametersPanel.ArrayDialog);
            end
        elseif strcmp(dialogTags{1},'ura')
            if strcmp(obj.Container,'ToolGroup')
                obj.ParametersPanel.ArrayDialog.TaperTypePopup.Value=2;
                notify(obj.ParametersPanel.ArrayDialog.TaperTypePopup,'Action');
            else
                obj.ParametersPanel.ArrayDialog.TaperTypePopup.Value=getString(message('phased:apps:arrayapp:Custom'));
                obj.ParametersPanel.ArrayDialog.TaperInputType=obj.ParametersPanel.ArrayDialog.TaperTypePopup.Value;
                layoutUIControls(obj.ParametersPanel.ArrayDialog);
            end
        end

        elemTag=dialogTags{2};
    else

        elem=sensorData;
        elemTag=dialogTags{1};
    end


    selectElementItem(obj.ToolStripDisplay,elemTag);
    if~isempty(obj.ParametersPanel.ElementDialog)
        obj.ParametersPanel.ElementType='';
    end
    obj.ParametersPanel.ElementType=elemTag;


    switch dialogTags{1}
    case 'ula'
        obj.ParametersPanel.ArrayDialog.NumElements=sensorData.NumElements;
        obj.ParametersPanel.ArrayDialog.ArrayAxis=sensorData.ArrayAxis;
        obj.ParametersPanel.ArrayDialog.CustomTaper=sensorData.Taper;
        obj.ParametersPanel.ArrayDialog.ElementSpacing=sensorData.ElementSpacing;
    case 'ura'
        obj.ParametersPanel.ArrayDialog.Size=sensorData.Size;
        obj.ParametersPanel.ArrayDialog.ArrayNormal=sensorData.ArrayNormal;
        obj.ParametersPanel.ArrayDialog.Lattice=sensorData.Lattice;
        obj.ParametersPanel.ArrayDialog.CustomTaper=sensorData.Taper;
        obj.ParametersPanel.ArrayDialog.ElementSpacing=sensorData.ElementSpacing;
    case 'uca'
        obj.ParametersPanel.ArrayDialog.NumElements=sensorData.NumElements;
        obj.ParametersPanel.ArrayDialog.ArrayNormal=sensorData.ArrayNormal;
        obj.ParametersPanel.ArrayDialog.Taper=sensorData.Taper;
        obj.ParametersPanel.ArrayDialog.Radius=sensorData.Radius;
    case 'arbitraryarray'
        obj.ParametersPanel.ArrayDialog.ElementNormal=sensorData.ElementNormal;
        obj.ParametersPanel.ArrayDialog.Taper=sensorData.Taper;
        obj.ParametersPanel.ArrayDialog.ElementPosition=sensorData.ElementPosition;
    end



    if~obj.pFromSimulink&&~isATAntenna&&~any(strcmp(elemTag,{'customantenna','custommicrophone','custompolarizedantenna'}))
        if min(elem.FrequencyRange)==0
            obj.ParametersPanel.ElementDialog.SignalFreq=max(elem.FrequencyRange);
        else
            obj.ParametersPanel.ElementDialog.SignalFreq=elem.FrequencyRange;
        end
    elseif obj.pFromSimulink
        obj.ParametersPanel.ElementDialog.SignalFreq=obj.importData.OperatingFrequency;
        obj.ParametersPanel.ElementDialog.PropSpeed=obj.importData.PropagationSpeed;
    end

    switch elemTag
    case 'isotropicantenna'
        obj.ParametersPanel.ElementDialog.BackBaffled=elem.BackBaffled;
    case 'customantenna'


        if isATAntenna


            [pat,az,el]=pattern(elem,obj.SignalFrequencies(1));
            obj.ParametersPanel.ElementDialog.AzimuthAngles=az;
            obj.ParametersPanel.ElementDialog.ElevationAngles=el;
            obj.ParametersPanel.ElementDialog.MagnitudePattern=pat;
            obj.ParametersPanel.ElementDialog.PhasePattern=zeros(size(pat));
        else
            if strcmp(elem.PatternCoordinateSystem,'az-el')
                obj.ParametersPanel.ElementDialog.FrequencyVector=elem.FrequencyVector;
                obj.ParametersPanel.ElementDialog.FrequencyResponse=elem.FrequencyResponse;
                obj.ParametersPanel.ElementDialog.AzimuthAngles=elem.AzimuthAngles;
                obj.ParametersPanel.ElementDialog.ElevationAngles=elem.ElevationAngles;
                obj.ParametersPanel.ElementDialog.MagnitudePattern=elem.MagnitudePattern;
                obj.ParametersPanel.ElementDialog.PhasePattern=elem.PhasePattern;
                obj.ParametersPanel.ElementDialog.MatchArrayNormal=elem.MatchArrayNormal;
            else
                obj.ParametersPanel.ElementDialog.FrequencyVector=elem.FrequencyVector;
                obj.ParametersPanel.ElementDialog.FrequencyResponse=elem.FrequencyResponse;
                obj.ParametersPanel.ElementDialog.PatternCoordinate=elem.PatternCoordinateSystem;
                obj.ParametersPanel.ElementDialog.PhiAngles=elem.PhiAngles;
                obj.ParametersPanel.ElementDialog.ThetaAngles=elem.ThetaAngles;
                obj.ParametersPanel.ElementDialog.MagnitudePattern=elem.MagnitudePattern;
                obj.ParametersPanel.ElementDialog.PhasePattern=elem.PhasePattern;
                obj.ParametersPanel.ElementDialog.MatchArrayNormal=elem.MatchArrayNormal;
            end
        end
    case 'custompolarizedantenna'


        if isATAntenna


            pat_h=pattern(elem,obj.SignalFrequencies(1),'Polarization','H');
            [pat_v,az,el]=pattern(elem,obj.SignalFrequencies(1),'Polarization','V');
            obj.ParametersPanel.ElementDialog.AzimuthAngles=az;
            obj.ParametersPanel.ElementDialog.ElevationAngles=el;
            obj.ParametersPanel.ElementDialog.HorizontalMagnitudePattern=pat_h;
            obj.ParametersPanel.ElementDialog.HorizontalPhasePattern=zeros(size(pat_h));
            obj.ParametersPanel.ElementDialog.VerticalMagnitudePattern=pat_v;
            obj.ParametersPanel.ElementDialog.VerticalPhasePattern=zeros(size(pat_v));
        else
            if strcmp(elem.PatternCoordinateSystem,'az-el')
                obj.ParametersPanel.ElementDialog.FrequencyVector=elem.FrequencyVector;
                obj.ParametersPanel.ElementDialog.FrequencyResponse=elem.FrequencyResponse;
                obj.ParametersPanel.ElementDialog.AzimuthAngles=elem.AzimuthAngles;
                obj.ParametersPanel.ElementDialog.ElevationAngles=elem.ElevationAngles;
                obj.ParametersPanel.ElementDialog.HorizontalMagnitudePattern=elem.HorizontalMagnitudePattern;
                obj.ParametersPanel.ElementDialog.HorizontalPhasePattern=elem.HorizontalPhasePattern;
                obj.ParametersPanel.ElementDialog.VerticalMagnitudePattern=elem.VerticalMagnitudePattern;
                obj.ParametersPanel.ElementDialog.VerticalPhasePattern=elem.VerticalPhasePattern;
                obj.ParametersPanel.ElementDialog.MatchArrayNormal=elem.MatchArrayNormal;
            else
                obj.ParametersPanel.ElementDialog.FrequencyVector=elem.FrequencyVector;
                obj.ParametersPanel.ElementDialog.FrequencyResponse=elem.FrequencyResponse;
                obj.ParametersPanel.ElementDialog.PatternCoordinate=elem.PatternCoordinateSystem;
                obj.ParametersPanel.ElementDialog.PhiAngles=elem.PhiAngles;
                obj.ParametersPanel.ElementDialog.ThetaAngles=elem.ThetaAngles;
                obj.ParametersPanel.ElementDialog.HorizontalMagnitudePattern=elem.HorizontalMagnitudePattern;
                obj.ParametersPanel.ElementDialog.HorizontalPhasePattern=elem.HorizontalPhasePattern;
                obj.ParametersPanel.ElementDialog.VerticalMagnitudePattern=elem.VerticalMagnitudePattern;
                obj.ParametersPanel.ElementDialog.VerticalPhasePattern=elem.VerticalPhasePattern;
                obj.ParametersPanel.ElementDialog.MatchArrayNormal=elem.MatchArrayNormal;
            end
        end
    case 'cosineantenna'
        obj.ParametersPanel.ElementDialog.CosinePower=elem.CosinePower;

    case 'omnidirectionalmicrophone'
        obj.ParametersPanel.ElementDialog.BackBaffled=elem.BackBaffled;

    case 'custommicrophone'
        obj.ParametersPanel.ElementDialog.FrequencyVector=elem.FrequencyVector;
        obj.ParametersPanel.ElementDialog.FrequencyResponse=elem.FrequencyResponse;
        obj.ParametersPanel.ElementDialog.PolarPattern=elem.PolarPattern;
        obj.ParametersPanel.ElementDialog.PolarPatternAng=elem.PolarPatternAngles;
        obj.ParametersPanel.ElementDialog.PolarPatternFreq=elem.PolarPatternFrequencies;

    case 'hydrophone'
        obj.ParametersPanel.ElementDialog.BackBaffled=elem.BackBaffled;
        obj.ParametersPanel.ElementDialog.VoltageSensitivity=elem.VoltageSensitivity;

    case 'projector'
        obj.ParametersPanel.ElementDialog.BackBaffled=elem.BackBaffled;
        obj.ParametersPanel.ElementDialog.VoltageResponse=elem.VoltageResponse;
    case 'cardioidantenna'
        obj.ParametersPanel.ElementDialog.NullAxisDirection=elem.NullAxisDirection;
    case 'gaussianantenna'
        obj.ParametersPanel.ElementDialog.AzBeamwidth=elem.Beamwidth(1);
        obj.ParametersPanel.ElementDialog.ElBeamwidth=elem.Beamwidth(2);
    case 'sincantenna'
        obj.ParametersPanel.ElementDialog.AzBeamwidth=elem.Beamwidth(1);
        obj.ParametersPanel.ElementDialog.ElBeamwidth=elem.Beamwidth(2);
    case 'nrantenna'
        obj.ParametersPanel.ElementDialog.PolarizationAngle=elem.PolarizationAngle;
        if strcmp(obj.Container,'ToolGroup')
            if elem.PolarizationModel==1
                obj.ParametersPanel.ElementDialog.PolarizationModelEdit.Value=1;
            elseif elem.PolarizationModel==2
                obj.ParametersPanel.ElementDialog.PolarizationModelEdit.Value=2;
            end
        else
            if elem.PolarizationModel==1
                obj.ParametersPanel.ElementDialog.PolarizationModelEdit.Value='1';
            elseif elem.PolarizationModel==2
                obj.ParametersPanel.ElementDialog.PolarizationModelEdit.Value='2';
            end
        end
        obj.ParametersPanel.ElementDialog.AzBeamwidth=elem.Beamwidth(1);
        obj.ParametersPanel.ElementDialog.ElBeamwidth=elem.Beamwidth(2);
        obj.ParametersPanel.ElementDialog.AzSidelobeLevel=elem.SidelobeLevel(1);
        obj.ParametersPanel.ElementDialog.ElSidelobeLevel=elem.SidelobeLevel(2);
        obj.ParametersPanel.ElementDialog.MaximumAttenuation=elem.MaximumAttenuation;
        obj.ParametersPanel.ElementDialog.MaximumGain=elem.MaximumGain;
    case 'shortdipoleantenna'
        if strcmp(obj.Container,'ToolGroup')
            if strcmp(elem.AxisDirection,'X')
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value=1;
            elseif strcmp(elem.AxisDirection,'Y')
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value=2;
            elseif strcmp(elem.AxisDirection,'Z')
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value=3;
            else
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value=4;
            end
        else
            if strcmp(elem.AxisDirection,'X')
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value='x';
            elseif strcmp(elem.AxisDirection,'Y')
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value='y';
            elseif strcmp(elem.AxisDirection,'Z')
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value='z';
            else
                obj.ParametersPanel.ElementDialog.AxisDirectionPopup.Value='Custom';
            end
        end
        obj.ParametersPanel.ElementDialog.CustomAxisDirection=elem.CustomAxisDirection;
    case 'crosseddipoleantenna'
        obj.ParametersPanel.ElementDialog.RotationAngle=elem.RotationAngle;
        if strcmp(obj.Container,'ToolGroup')
            if strcmp(elem.Polarization,'RHCP')
                obj.ParametersPanel.ElementDialog.PolarizationEdit.Value=1;
            elseif strcmp(elem.Polarization,'LHCP')
                obj.ParametersPanel.ElementDialog.PolarizationEdit.Value=2;
            else
                obj.ParametersPanel.ElementDialog.PolarizationEdit.Value=3;
            end
        else
            if strcmp(elem.Polarization,'RHCP')
                obj.ParametersPanel.ElementDialog.PolarizationEdit.Value='RHCP';
            elseif strcmp(elem.Polarization,'LHCP')
                obj.ParametersPanel.ElementDialog.PolarizationEdit.Value='LHCP';
            else
                obj.ParametersPanel.ElementDialog.PolarizationEdit.Value='Linear';
            end
        end
    end


    if obj.IsSubarray
        switch dialogTags{3}
        case 'replicatedsubarray'
            if strcmp(subarray.Layout,getString(message('phased:apps:arrayapp:rectgrid')))


                if ischar(subarray.GridSpacing)
                    if isa(subarray.Subarray,'phased.ULA')
                        spacing=[1,getNumElements(subarray.Subarray)]*...
                        subarray.Subarray.ElementSpacing;
                    elseif isa(subarray.Subarray,'phased.URA')
                        spacing=subarray.Subarray.Size.*subarray.Subarray.ElementSpacing;
                    end
                else
                    spacing=subarray.GridSpacing;
                end
                obj.ParametersPanel.AdditionalConfigDialog.SubarrayType=getString(message('phased:apps:arrayapp:replicatesubarray'));
                obj.ParametersPanel.AdditionalConfigDialog.GridLayout=subarray.Layout;
                obj.ParametersPanel.AdditionalConfigDialog.GridSize=subarray.GridSize;
                obj.ParametersPanel.AdditionalConfigDialog.GridSpacing=spacing;
            else
                obj.ParametersPanel.AdditionalConfigDialog.SubarrayType=getString(message('phased:apps:arrayapp:replicatesubarray'));
                obj.ParametersPanel.AdditionalConfigDialog.GridLayout=subarray.Layout;
                obj.ParametersPanel.AdditionalConfigDialog.SubarrayPosition=subarray.SubarrayPosition;
                obj.ParametersPanel.AdditionalConfigDialog.SubarrayNormal=subarray.SubarrayNormal;
            end
        case 'partitionedarray'
            obj.ParametersPanel.AdditionalConfigDialog.SubarrayType=getString(message('phased:apps:arrayapp:partitionarray'));
            obj.ParametersPanel.AdditionalConfigDialog.SubarraySelection=subarray.SubarraySelection;
            if~isempty(obj.SubarrayLabels)
                clear(obj.SubarrayLabels);
            end
            selMatrix=obj.ParametersPanel.AdditionalConfigDialog.SubarraySelection;
            obj.ElementIndex=[];
            obj.SubarrayElementWeights=[];
            obj.StoreData=[];
            obj.StoreNames=[];
            obj.StoreDataIndex=[];
            for i=1:size(selMatrix,1)
                obj.ElementIndex{i}=find(selMatrix(i,:)');
                obj.SubarrayElementWeights{i}=selMatrix(i,obj.ElementIndex{i});
            end
            if~obj.pFromSimulink
                if strcmp(obj.Container,'ToolGroup')
                    if isempty(obj.SubarrayPartitionFig)||~isvalid(obj.SubarrayPartitionFig)
                        obj.SubarrayPartitionFig=figure('NumberTitle','off',...
                        'Visible','off',...
                        'HandleVisibility','off','IntegerHandle','off',...
                        'Name',getString(message('phased:apps:arrayapp:subarraypanelname')),...
                        'Tag','subarrayparamsfig',...
                        'SizeChangedFcn',@(~,~)resize(obj.SubarrayLabels,obj.SubarrayPartitionFig.Position));
                        obj.ToolGroup.addFigure(obj.SubarrayPartitionFig);

                        drawnow;
                        matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                        prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
                        state=java.lang.Boolean.FALSE;
                        matDsk.getClient(obj.SubarrayPartitionFig.Name,obj.ToolGroup.Name).putClientProperty(prop,state);
                    end
                else
                    if isempty(obj.SubarrayPartitionFig)||~isvalid(obj.SubarrayPartitionFig)
                        subarrayFigOptions.Title=getString(message('phased:apps:arrayapp:subarraypanelname'));
                        subarrayFigOptions.Tag='subarrayparamsfig';
                        obj.DefineSubarrayDoc=FigureDocument(subarrayFigOptions);
                        obj.DefineSubarrayDoc.DocumentGroupTag='parameterSettings';
                        obj.SubarrayPartitionFig=obj.DefineSubarrayDoc.Figure;
                        obj.SubarrayPartitionFig.Internal=false;
                        obj.DefineSubarrayDoc.Closable=false;
                        obj.SubarrayPartitionFig.AutoResizeChildren="off";
                        obj.ToolGroup.add(obj.DefineSubarrayDoc);
                    end
                end
                Labelposition=[0,0,obj.SubarrayPartitionFig.Position(3:4)];
                obj.SubarrayLabels=phased.apps.internal.interaction.SubarrayLabels(obj,Labelposition);
                obj.SubarrayPartitionFig.SizeChangedFcn=@(x,y)resize(obj.SubarrayLabels,obj.SubarrayPartitionFig.Position);
            end
        end
    end


    updateElementObject(obj.ParametersPanel.ElementDialog)
    if~obj.IsSubarray
        updateArrayObject(obj.ParametersPanel.ArrayDialog)
    else
        updateArrayObject(obj.ParametersPanel.AdditionalConfigDialog)
    end

    obj.ParametersPanel.ArrayDialog.Panel.Title=...
    assignArrayDialogTitle(obj.ParametersPanel.ArrayDialog);
    if obj.IsSubarray


        switch subarray.SubarraySteering
        case 'None'
            obj.ToolStripDisplay.SubarraySteerPopup.SelectedIndex=1;
            enableSubarraySteeringOptions(obj)
        case 'Time'
            obj.ToolStripDisplay.SubarraySteerPopup.SelectedIndex=2;
            enableSubarraySteeringOptions(obj)
        case 'Phase'
            obj.ToolStripDisplay.SubarraySteerPopup.SelectedIndex=3;
            obj.SubarrayPhaseQuanBits=subarray.NumPhaseShifterBits;
            obj.SubarrayPhaseShifterFreq=subarray.PhaseShifterFrequency;
            enableSubarraySteeringOptions(obj)

            obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Value=mat2str(obj.SubarrayPhaseQuanBits);
            obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Value=mat2str(obj.SubarrayPhaseShifterFreq);
        case 'Custom'
            obj.ToolStripDisplay.SubarraySteerPopup.SelectedIndex=4;
            enableSubarraySteeringOptions(obj);
            computeElementWeights(obj,obj.ElementWeights);
            obj.ToolStripDisplay.SubarrayCustomWeightEdit.Value=mat2str(obj.ElementWeights);
        end


        updateSubarraySteering(obj);
    else

        disableSubarraySteeringOptions(obj);
    end
    generateAndApplyLayout(obj,obj.pFromSimulink);


    adjustLayout(obj)


    updateArrayCharTable(obj);


    disablAndEnableGratingLobe(obj)


    notify(obj.ToolStripDisplay,'NewPlotRequest',...
    phased.apps.internal.controller.NewPlotEventData('arrayGeoFig'));
end

function closeDefineSubarrayFig(obj)

    if strcmp(obj.Container,'ToolGroup')
        if(~isempty(obj.SubarrayPartitionFig)&&isvalid(obj.SubarrayPartitionFig))
            close(obj.SubarrayPartitionFig);
        end
    else
        if(~isempty(obj.SubarrayPartitionFig)&&isvalid(obj.SubarrayPartitionFig))
            closeDocument(obj.ToolGroup,"parameterSettings","subarrayparamsfig");
        end
    end
end