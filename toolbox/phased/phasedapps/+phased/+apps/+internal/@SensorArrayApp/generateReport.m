function generateReport(obj)






    sw=StringWriter;
    dateTimeStr=datestr(now);
    mlVer=ver('matlab');
    pstVer=ver('phased');
    add(sw,'% Sensor Array Analyzer Report')
    addcr(sw)
    addcr(sw,'%')
    add(sw,'% Generated by MATLAB ')
    add(sw,mlVer.Version)
    add(sw,' and Phased Array System Toolbox ')
    add(sw,pstVer.Version)
    addcr(sw)
    addcr(sw,'%')
    add(sw,'% Generated on ')
    add(sw,dateTimeStr)
    addcr(sw)
    addcr(sw,'%')


    if~obj.IsSubarray
        genreport(obj.ParametersPanel.ArrayDialog,sw);
    else
        genreport(obj.ParametersPanel.AdditionalConfigDialog,sw);
    end

    elementDialog=getElementDialogName(obj);


    genreport(elementDialog,sw);


    directivity=obj.ArrayDir;
    ArrayXSpan=obj.XSpan;
    ArrayYSpan=obj.YSpan;
    ArrayZSpan=obj.ZSpan;
    AzimuthLobe=obj.AzLobe;
    ElevationLobe=obj.ElLobe;
    ElementPolarization=obj.ElementPolarization;
    addcr(sw,['% Directivity at Steering Angle (dBi)................... ',sprintf('%0.2f',directivity)])
    addcr(sw,['% X-Axis Array Span (m)................................. ',num2str(round(ArrayXSpan,2))])
    addcr(sw,['% Y-Axis Array Span (m)................................. ',num2str(round(ArrayYSpan,2))])
    addcr(sw,['% Z-Axis Array Span (m)................................. ',num2str(round(ArrayZSpan,2))])


    if~obj.IsSubarray
        NumElements=obj.ArrayCharTable.Data{3,2};
        addcr(sw,['% Total Number of Elements ............................. ',num2str(NumElements)])
    else
        NumSubarrays=obj.ArrayCharTable.Data{3,2};
        NumElements=obj.ArrayCharTable.Data{4,2};
        if isa(obj.CurrentArray,'phased.ReplicatedSubarray')
            ElementsInSubarray=NumElements/NumSubarrays;
            addcr(sw,['% Total Number of Subarrays ............................ ',num2str(NumSubarrays)])
            addcr(sw,['% Total Number of Elements ............................. ',num2str(NumElements)])
            addcr(sw,['% Number of Elements in a Subarray ..................... ',num2str(ElementsInSubarray)])
        else
            addcr(sw,['% Total Number of Subarrays ............................ ',num2str(NumSubarrays)])
            addcr(sw,['% Total Number of Elements ............................. ',num2str(NumElements)])
        end
    end
    if isempty(AzimuthLobe.HPBW)
        AzimuthLobe.HPBW='NA';
        addcr(sw,['% Half Power BeamWidth (HPBW) along Az plane (deg)...... ',sprintf(AzimuthLobe.HPBW)])
    else
        addcr(sw,['% Half Power BeamWidth (HPBW) along Az plane (deg)...... ',sprintf('%0.2f',AzimuthLobe.HPBW)])
    end

    if isempty(ElevationLobe.HPBW)
        ElevationLobe.HPBW='NA';
        addcr(sw,['% Half Power BeamWidth (HPBW) along El plane (deg)...... ',sprintf(ElevationLobe.HPBW)])
    else
        addcr(sw,['% Half Power BeamWidth (HPBW) along El plane (deg)...... ',sprintf('%0.2f',ElevationLobe.HPBW)])
    end

    if isempty(AzimuthLobe.FNBW)
        AzimuthLobe.FNBW='NA';
        addcr(sw,['% First Null BeamWidth (FNBW) along Az plane (deg)...... ',sprintf(AzimuthLobe.FNBW)])
    else
        addcr(sw,['% First Null BeamWidth (FNBW) along Az plane (deg)...... ',sprintf('%0.2f',AzimuthLobe.FNBW)])
    end

    if isempty(ElevationLobe.FNBW)
        ElevationLobe.FNBW='NA';
        addcr(sw,['% First Null BeamWidth (FNBW) along El plane (deg)...... ',sprintf(ElevationLobe.FNBW)])
    else
        addcr(sw,['% First Null BeamWidth (FNBW) along El plane (deg)...... ',sprintf('%0.2f',ElevationLobe.FNBW)])
    end

    if isempty(AzimuthLobe.SLL)
        AzimuthLobe.SLL='NA';
        addcr(sw,['% Side Lobe Level (SLL) along Az plane (dB)............. ',sprintf(AzimuthLobe.SLL)])
    else
        addcr(sw,['% Side Lobe Level (SLL) along Az plane (dB)............. ',sprintf('%0.2f',AzimuthLobe.SLL)])
    end

    if isempty(ElevationLobe.SLL)
        ElevationLobe.SLL='NA';
        addcr(sw,['% Side Lobe Level (SLL) along El plane (dB)............. ',sprintf(ElevationLobe.SLL)])
    else
        addcr(sw,['% Side Lobe Level (SLL) along El plane (dB)............. ',sprintf('%0.2f',ElevationLobe.SLL)])
    end
    addcr(sw,['% Element Polarization ................................. ',ElementPolarization])

    matlab.desktop.editor.newDocument(sw.string);

end