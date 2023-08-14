function exportPlots(obj,sw)






    [isArrayGeoFig,is3DPatternFig,isAzPatternFig,...
    isElPatternFig,isUPatternFig,isGLDiagFig]=getOpenPlots(obj);

    if isArrayGeoFig

        if obj.ToolStripDisplay.IdxCheck.Value
            showIndex='All';
        else
            showIndex='None';
        end

        if obj.ToolStripDisplay.NormalCheck.Value
            showNormal='true';
        else
            showNormal='false';
        end

        if obj.ToolStripDisplay.TaperCheck.Value
            showTaper='true';
        else
            showTaper='false';
        end
        if obj.ToolStripDisplay.LocalCoordinateArrayCheck.Value
            showLocalCoordinates='true';
        else
            showLocalCoordinates='false';
        end
        if obj.ToolStripDisplay.AnnotationCheck.Value
            showAnnotation='true';
        else
            showAnnotation='false';
        end
        orientation=obj.ToolStripDisplay.ArrayOrientationEdit.Value;
        addcr(sw,'% Plot Array Geometry')
        addcr(sw,'figure;')
        if~obj.IsSubarray
            addcr(sw,['viewArray(Array,''ShowNormal'',',showNormal,',...']);
            addcr(sw,['  ''ShowTaper'',',showTaper,',''ShowIndex'',''',showIndex,''',...']);
            addcr(sw,['  ''ShowLocalCoordinates'',',showLocalCoordinates,',''ShowAnnotation'',',showAnnotation,',...']);
            addcr(sw,['  ''Orientation'',',orientation,');']);
        else
            addcr(sw,['viewArray(Array,''ShowNormal'',',showNormal,',...']);
            addcr(sw,['  ''ShowTaper'',',showTaper,',''ShowIndex'',''',showIndex,''',...']);
            addcr(sw,['  ''ShowLocalCoordinates'',',showLocalCoordinates,',''ShowAnnotation'',',showAnnotation,',...']);
            addcr(sw,['  ''ShowSubarray'',''All'',''Orientation'',',orientation,');']);

        end
        addcr(sw);
    end

    if is3DPatternFig
        if obj.ToolStripDisplay.ArrayCheck.Value
            showArray='true';
        else
            showArray='false';
        end
        if obj.ToolStripDisplay.LocalCoordinateCheck.Value
            showLocalCoordinates='true';
        else
            showLocalCoordinates='false';
        end
        if obj.ToolStripDisplay.ColorbarCheck.Value
            showColorbar='true';
        else
            showColorbar='false';
        end
        orientation=obj.ToolStripDisplay.OrientationEdit.Value;
        PhaseShiftBits=obj.PhaseQuanBits;
        addcr(sw,'% Calculate Steering Weights');
        addcr(sw);
        Freq3D=obj.ToolStripDisplay.Freq3D;
        addcr(sw,['Freq3D = ',mat2str(Freq3D),';'])
        addcr(sw,'% Find the weights');
        if any(any(obj.SteeringAngle~=0))
            if~obj.IsSubarray
                addcr(sw,'w = zeros(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = zeros(getNumSubarrays(Array), length(Frequency));');
            end
            if PhaseShiftBits(1)>0
                addcr(sw,'SteerVector = phased.SteeringVector(''SensorArray'', Array,...');
                addcr(sw,' ''PropagationSpeed'', PropagationSpeed, ''NumPhaseShifterBits'', PhaseShiftBits(1));');
            else
                addcr(sw,'SteerVector = phased.SteeringVector(''SensorArray'', Array,...');
                addcr(sw,' ''PropagationSpeed'', PropagationSpeed);');
            end
            addcr(sw,'for idx = 1:length(Frequency)');
            addcr(sw,'    w(:, idx) = step(SteerVector, Frequency(idx), SteeringAngles(:, idx));');
            addcr(sw,'end');
            addcr(sw);
        else
            if~obj.IsSubarray
                addcr(sw,'w = ones(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = ones(getNumSubarrays(Array), length(Frequency));');
            end
            addcr(sw);
        end
        weight_str=',''weights'', w(:,1)';
        addcr(sw,'% Plot 3d graph');
        if strcmpi(obj.ToolStripDisplay.CoordDropDown3D.Value,...
            getString(message('phased:apps:arrayapp:coordLine')))
            format='rectangular';
        elseif strcmpi(obj.ToolStripDisplay.CoordDropDown3D.Value,...
            getString(message('phased:apps:arrayapp:coordUV')))
            format='uv';
        else
            format='polar';
        end
        addcr(sw,['format = ''',format,''';']);
        if strcmpi(obj.ToolStripDisplay.TypeDropDown.Value,...
            getString(message('phased:apps:arrayapp:Directivity')))
            plotType='Directivity';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDown.Value,...
            getString(message('phased:apps:arrayapp:efield')))
            plotType='Efield';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDown.Value,...
            getString(message('phased:apps:arrayapp:Power')))
            plotType='Power';
        else
            plotType='PowerDB';
        end
        addcr(sw,['plotType = ''',plotType,''';']);

        if obj.ToolStripDisplay.PolarizationDropDown.Enabled
            if strcmpi(obj.ToolStripDisplay.PolarizationDropDown.Value,...
                getString(message('phased:apps:arrayapp:Combined')))
                polarization='Combined';
            elseif strcmpi(obj.ToolStripDisplay.PolarizationDropDown.Value,...
                getString(message('phased:apps:arrayapp:H')))
                polarization='H';
            else
                polarization='V';
            end
            addcr(sw,['polarization = ''',polarization,''';']);
        end

        if obj.ToolStripDisplay.NormalizeCheck.Value
            normalize='true';
        else
            normalize='false';
        end
        addcr(sw,'figure;')
        addcr(sw,'pattern(Array, Freq3D , ''PropagationSpeed'', PropagationSpeed,...')
        if obj.IsSubarray
            if~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:nosubarraysteering')))&&...
                ~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''SteerAngle'', SubarraySteerAngles, ...')
            elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''ElementWeights'', CustomElementWeights, ...')
            end
        end
        addcr(sw,[' ''CoordinateSystem'', format',weight_str,',...']);
        if~strcmp(format,'polar')
            addcr(sw,['  ''ShowColorbar'',',showColorbar,',...']);
        else
            addcr(sw,['  ''ShowArray'',',showArray,',''ShowLocalCoordinates'',',showLocalCoordinates,',...']);
            addcr(sw,['  ''ShowColorbar'',',showColorbar,',''Orientation'',',orientation,',...']);
        end
        if~strcmp(obj.ToolStripDisplay.TypeDropDown.Value,getString(message('phased:apps:arrayapp:Directivity')))
            addcr(sw,['  ''Normalize'', ',normalize,',...']);
        end
        if~strcmp(obj.ToolStripDisplay.TypeDropDown.Value,getString(message('phased:apps:arrayapp:Directivity')))&&isPolarizationCapable(obj.ToolStripDisplay.AppHandle.CurrentElement)
            addcr(sw,['  ''Polarization'', polarization ',',...']);
        end
        addcr(sw,['  ''Type'', plotType',');']);
        addcr(sw);
    end
    if isAzPatternFig
        addcr(sw,'% Find the weights');
        if any(any(obj.SteeringAngle~=0))
            if~obj.IsSubarray
                addcr(sw,'w = zeros(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = zeros(getNumSubarrays(Array), length(Frequency));');
            end
            addcr(sw,'for idx = 1:length(Frequency)');
            addcr(sw,'    SteerVector = phased.SteeringVector(''SensorArray'', Array,...');
            addcr(sw,'      ''PropagationSpeed'', PropagationSpeed, ...');
            addcr(sw,'      ''NumPhaseShifterBits'', PhaseShiftBits(idx));');
            addcr(sw,'    w(:, idx) = step(SteerVector, Frequency(idx), SteeringAngles(:, idx));');
            addcr(sw,'end');
            addcr(sw);
        else
            if~obj.IsSubarray
                addcr(sw,'w = ones(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = ones(getNumSubarrays(Array), length(Frequency));');
            end
            addcr(sw);
        end

        weight_str=',''weights'', w';
        addcr(sw,'% Plot 2d azimuth graph');
        if strcmpi(obj.ToolStripDisplay.CoordDropDown2DAz.Value,...
            getString(message('phased:apps:arrayapp:coordPolar')))
            format='polar';
        else
            format='rectangular';
        end
        addcr(sw,['format = ''',format,''';']);
        cutAngle=obj.ToolStripDisplay.CutAngleEditAz.Value;
        addcr(sw,['cutAngle = ',num2str(cutAngle),';']);
        if strcmpi(obj.ToolStripDisplay.TypeDropDown2DAz.Value,...
            getString(message('phased:apps:arrayapp:Directivity')))
            plotType='Directivity';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDown2DAz.Value,...
            getString(message('phased:apps:arrayapp:efield')))
            plotType='Efield';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDown2DAz.Value,...
            getString(message('phased:apps:arrayapp:Power')))
            plotType='Power';
        else
            plotType='PowerDB';
        end
        addcr(sw,['plotType = ''',plotType,''';']);

        if obj.ToolStripDisplay.PolarizationDropDown2DAz.Enabled
            if strcmpi(obj.ToolStripDisplay.PolarizationDropDown2DAz.Value,...
                getString(message('phased:apps:arrayapp:Combined')))
                polarization='Combined';
            elseif strcmpi(obj.ToolStripDisplay.PolarizationDropDown2DAz.Value,...
                getString(message('phased:apps:arrayapp:H')))
                polarization='H';
            else
                polarization='V';
            end
            addcr(sw,['polarization = ''',polarization,''';']);
        end
        if obj.ToolStripDisplay.NormalizeCheck2DAz.Value
            normalize='true';
        else
            normalize='false';
        end
        if strcmpi(obj.ToolStripDisplay.PlotStyleDropDown2DAz.Value,...
            getString(message('phased:apps:arrayapp:Overlay')))
            plotStyle='Overlay';
        else
            plotStyle='Waterfall';
        end
        addcr(sw,['plotStyle = ''',plotStyle,''';']);
        addcr(sw,'figure;');
        addcr(sw,'pattern(Array, Frequency, -180:180, cutAngle, ''PropagationSpeed'', PropagationSpeed,...')
        if obj.IsSubarray
            if~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:nosubarraysteering')))&&...
                ~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''SteerAngle'', SubarraySteerAngles, ...')
            elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''ElementWeights'', CustomElementWeights, ...')
            end
        end
        addcr(sw,[' ','''CoordinateSystem'', format ',weight_str,', ...']);
        if~strcmp(obj.ToolStripDisplay.TypeDropDown2DAz.Value,getString(message('phased:apps:arrayapp:Directivity')))
            addcr(sw,['  ''Normalize'', ',normalize,',...']);
        end
        if~strcmp(obj.ToolStripDisplay.TypeDropDown2DAz.Value,getString(message('phased:apps:arrayapp:Directivity')))&&isPolarizationCapable(obj.ToolStripDisplay.AppHandle.CurrentElement)
            addcr(sw,['  ''Polarization'', polarization ',',...']);
        end
        addcr(sw,['  ''Type'', plotType, ''PlotStyle'', plotStyle',');']);
        addcr(sw);
    end
    if isElPatternFig
        addcr(sw,'% Find the weights');
        if any(any(obj.SteeringAngle~=0))
            if~obj.IsSubarray
                addcr(sw,'w = zeros(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = zeros(getNumSubarrays(Array), length(Frequency));');
            end
            addcr(sw,'for idx = 1:length(Frequency)');
            addcr(sw,'    SteerVector = phased.SteeringVector(''SensorArray'', Array,...');
            addcr(sw,'       ''PropagationSpeed'', PropagationSpeed,...')
            addcr(sw,'       ''NumPhaseShifterBits'', PhaseShiftBits(idx));')
            addcr(sw,'    w(:, idx) = step(SteerVector, Frequency(idx), SteeringAngles(:, idx));');
            addcr(sw,'end');
            addcr(sw);
        else
            if~obj.IsSubarray
                addcr(sw,'w = ones(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = ones(getNumSubarrays(Array), length(Frequency));');
            end
            addcr(sw);
        end
        weight_str=',''weights'', w';
        addcr(sw,'% Plot 2d elevation graph');
        if strcmpi(obj.ToolStripDisplay.CoordDropDown2DEl.Value,...
            getString(message('phased:apps:arrayapp:coordPolar')))
            format='polar';
        else
            format='rectangular';
        end
        addcr(sw,['format = ''',format,''';']);
        cutAngle=obj.ToolStripDisplay.CutAngleEditEl.Value;
        addcr(sw,['cutAngle = ',num2str(cutAngle),';']);
        if strcmpi(obj.ToolStripDisplay.TypeDropDown2DEl.Value,...
            getString(message('phased:apps:arrayapp:Directivity')))
            plotType='Directivity';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDown2DEl.Value,...
            getString(message('phased:apps:arrayapp:efield')))
            plotType='Efield';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDown2DEl.Value,...
            getString(message('phased:apps:arrayapp:Power')))
            plotType='Power';
        else
            plotType='PowerDB';
        end
        addcr(sw,['plotType = ''',plotType,''';']);

        if obj.ToolStripDisplay.PolarizationDropDown2DEl.Enabled
            if strcmpi(obj.ToolStripDisplay.PolarizationDropDown2DEl.Value,...
                getString(message('phased:apps:arrayapp:Combined')))
                polarization='Combined';
            elseif strcmpi(obj.ToolStripDisplay.PolarizationDropDown2DEl.Value,...
                getString(message('phased:apps:arrayapp:H')))
                polarization='H';
            else
                polarization='V';
            end
            addcr(sw,['polarization = ''',polarization,''';']);
        end
        if obj.ToolStripDisplay.NormalizeCheck2DEl.Value
            normalize='true';
        else
            normalize='false';
        end
        if strcmpi(obj.ToolStripDisplay.PlotStyleDropDown2DEl.Value,...
            getString(message('phased:apps:arrayapp:Overlay')))
            plotStyle='Overlay';
        else
            plotStyle='Waterfall';
        end
        addcr(sw,['plotStyle = ''',plotStyle,''';']);
        addcr(sw,'figure;')
        addcr(sw,'pattern(Array, Frequency, cutAngle, -90:90, ''PropagationSpeed'', PropagationSpeed,...')
        if obj.IsSubarray
            if~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:nosubarraysteering')))&&...
                ~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''SteerAngle'', SubarraySteerAngles, ...')
            elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''ElementWeights'', CustomElementWeights, ...')
            end
        end
        addcr(sw,[' ''CoordinateSystem'', format ',weight_str,', ...']);
        if~strcmp(obj.ToolStripDisplay.TypeDropDown2DEl.Value,getString(message('phased:apps:arrayapp:Directivity')))
            addcr(sw,['  ''Normalize'', ',normalize,',...']);
        end
        if~strcmp(obj.ToolStripDisplay.TypeDropDown2DEl.Value,getString(message('phased:apps:arrayapp:Directivity')))&&isPolarizationCapable(obj.ToolStripDisplay.AppHandle.CurrentElement)
            addcr(sw,['  ''Polarization'', polarization ',',...']);
        end
        addcr(sw,['  ''Type'', plotType, ''PlotStyle'', plotStyle',');']);
        addcr(sw);
    end

    if isUPatternFig
        addcr(sw,'% Find the weights');
        if any(any(obj.SteeringAngle~=0))
            if~obj.IsSubarray
                addcr(sw,'w = zeros(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = zeros(getNumSubarrays(Array), length(Frequency));');
            end
            addcr(sw,'for idx = 1:length(Frequency)');
            addcr(sw,'    SteerVector = phased.SteeringVector(''SensorArray'', Array,...');
            addcr(sw,'       ''PropagationSpeed'', PropagationSpeed,...')
            addcr(sw,'       ''NumPhaseShifterBits'', PhaseShiftBits(idx));')
            addcr(sw,'    w(:, idx) = step(SteerVector, Frequency(idx), SteeringAngles(:, idx));');
            addcr(sw,'end');
            addcr(sw);
        else
            if~obj.IsSubarray
                addcr(sw,'w = ones(getNumElements(Array), length(Frequency));');
            else
                addcr(sw,'w = ones(getNumSubarrays(Array), length(Frequency));');
            end
            addcr(sw);
        end

        weight_str=',''weights'', w';
        addcr(sw,'% Plot U Pattern');
        format='uv';
        addcr(sw,['format = ''',format,''';']);
        if strcmpi(obj.ToolStripDisplay.TypeDropDownUV.Value,...
            getString(message('phased:apps:arrayapp:Directivity')))
            plotType='Directivity';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDownUV.Value,...
            getString(message('phased:apps:arrayapp:efield')))
            plotType='Efield';
        elseif strcmpi(obj.ToolStripDisplay.TypeDropDownUV.Value,...
            getString(message('phased:apps:arrayapp:Power')))
            plotType='Power';
        else
            plotType='PowerDB';
        end
        addcr(sw,['plotType = ''',plotType,''';']);

        if obj.ToolStripDisplay.PolarizationDropDownUV.Enabled
            if strcmpi(obj.ToolStripDisplay.PolarizationDropDownUV.Value,...
                getString(message('phased:apps:arrayapp:Combined')))
                polarization='Combined';
            elseif strcmpi(obj.ToolStripDisplay.PolarizationDropDownUV.Value,...
                getString(message('phased:apps:arrayapp:H')))
                polarization='H';
            else
                polarization='V';
            end
            addcr(sw,['polarization = ''',polarization,''';']);
        end
        if obj.ToolStripDisplay.NormalizeCheckUV.Value
            normalize='true';
        else
            normalize='false';
        end
        if strcmpi(obj.ToolStripDisplay.PlotStyleDropDownUV.Value,...
            getString(message('phased:apps:arrayapp:Overlay')))
            plotStyle='Overlay';
        else
            plotStyle='Waterfall';
        end
        addcr(sw,['plotStyle = ''',plotStyle,''';']);
        addcr(sw,'figure;')
        addcr(sw,'pattern(Array, Frequency, -1:0.01:1, 0, ''PropagationSpeed'', PropagationSpeed,...')
        if obj.IsSubarray
            if~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:nosubarraysteering')))&&...
                ~strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''SteerAngle'', SubarraySteerAngles, ...')
            elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,...
                getString(message('phased:apps:arrayapp:customsubarraysteering')))
                addcr(sw,' ''ElementWeights'', CustomElementWeights, ...')
            end
        end
        addcr(sw,['''CoordinateSystem'', format',weight_str,', ...']);
        if~strcmp(obj.ToolStripDisplay.TypeDropDownUV.Value,getString(message('phased:apps:arrayapp:Directivity')))
            addcr(sw,['  ''Normalize'', ',normalize,',...']);
        end
        if~strcmp(obj.ToolStripDisplay.TypeDropDownUV.Value,getString(message('phased:apps:arrayapp:Directivity')))&&isPolarizationCapable(obj.ToolStripDisplay.AppHandle.CurrentElement)
            addcr(sw,['  ''Polarization'', polarization ',',...']);
        end
        addcr(sw,['  ''Type'', plotType, ''PlotStyle'', plotStyle',');']);
        addcr(sw);
    end
    if isGLDiagFig
        isUHA=false;
        isCircPlanar=false;
        if~obj.pFromSimulink
            isUHA=obj.ToolStripDisplay.ArrayGalleryItems{4}.Value;
            isCircPlanar=obj.ToolStripDisplay.ArrayGalleryItems{5}.Value;
        end
        arr=obj.CurrentArray;

        addcr(sw,'% Plot Grating Lobe Diagram');

        if isa(arr,'phased.ULA')||isa(arr,'phased.URA')
            addcr(sw,'figure;')
            addcr(sw,'plotGratingLobeDiagram(Array,Frequency(1),SteeringAngles(:,1),PropagationSpeed);');
        elseif(isa(arr,'phased.ConformalArray')&&...
            (isUHA||isCircPlanar))


            PropSpeed=obj.PropagationSpeed;
            Freq=obj.SignalFrequencies(1);
            usingLambda=obj.ParametersPanel.isUsingLambda(obj.ParametersPanel.ArrayDialog.ElementSpacingUnits);
            if usingLambda
                ratio=PropSpeed/Freq;
            else
                ratio=1;
            end

            elemSpacing=...
            obj.ParametersPanel.ArrayDialog.ElementSpacing*ratio;


            if isUHA
                addcr(sw,['RowSpacing = ',num2str(elemSpacing/2*sqrt(3)),';']);
                addcr(sw,['ColSpacing = ',num2str(elemSpacing),';']);
                lattice='Triangular';
            elseif isCircPlanar
                addcr(sw,['RowSpacing = ',num2str(elemSpacing),';']);
                addcr(sw,['ColSpacing = ',num2str(elemSpacing),';']);
                templattice=obj.ParametersPanel.ArrayDialog.Lattice;
                if strcmp(templattice,...
                    getString(message('phased:apps:arrayapp:Triangular')))
                    lattice='Triangular';
                else
                    lattice='Rectangular';
                end
            end
            addcr(sw,'figure;')
            addcr(sw,['phased.apps.internal.plotGratingLobeDiagramPlanar(RowSpacing,ColSpacing,''',lattice,''',Frequency(1),...'])
            addcr(sw,'SteeringAngles(:,1),PropagationSpeed);');
            addcr(sw);
        end
    end
end
