function updateArrayCharTable(obj)






    fig=obj.ArrayCharacteristicFig;


    arrayObj=obj.CurrentArray;

    if strcmp(obj.Container,'ToolGroup')

        Panel=uipanel(...
        'Parent',fig,...
        'Title','',...
        'Tag','allPropertyContent',...
        'BorderType','none',...
        'HighlightColor',[.5,.5,.5],...
        'HandleVisibility','off',...
        'Visible','on');


        layout=matlabshared.application.layout.ScrollableGridBagLayout(...
        Panel,...
        'VerticalGap',0,...
        'HorizontalGap',0);
    else
        if~isempty(obj.ArrayCharTable)
            delete(obj.ArrayCharTable);
        end
        layout=uigridlayout(fig,'Scrollable','on','ColumnWidth',{'1x'});
    end

    if~obj.IsSubarray
        if~strcmp(obj.Container,'ToolGroup')
            layout.RowHeight={183};
        end
        tblData(:,1)={getString(message('phased:apps:arrayapp:ArrayDirectivity'));...
        getString(message('phased:apps:arrayapp:ArraySpan'));...
        getString(message('phased:apps:arrayapp:TotalNumElements'));...
        getString(message('phased:apps:arrayapp:HPBW'));...
        getString(message('phased:apps:arrayapp:FNBW'));...
        getString(message('phased:apps:arrayapp:SLL'));...
        getString(message('phased:apps:arrayapp:ElementPolarization'))};
    else
        if~strcmp(obj.Container,'ToolGroup')
            layout.RowHeight={205};
        end
        tblData(:,1)={getString(message('phased:apps:arrayapp:ArrayDirectivity'));...
        getString(message('phased:apps:arrayapp:ArraySpan'));...
        getString(message('phased:apps:arrayapp:TotalNumSubarrays'));...
        getString(message('phased:apps:arrayapp:TotalNumElements'));...
        getString(message('phased:apps:arrayapp:HPBW'));...
        getString(message('phased:apps:arrayapp:FNBW'));...
        getString(message('phased:apps:arrayapp:SLL'));...
        getString(message('phased:apps:arrayapp:ElementPolarization'))};
    end


    columnWidth={175-10*ispc};
    columnFormat(1)={'char'};
    columnEditable(1)=false;

    for i=1:numel(obj.SignalFrequencies)
        [y,~,u]=engunits(obj.SignalFrequencies(i));
        columnName(i+1)={['@ ',num2str(y),' ',u...
        ,getString(message('phased:apps:arrayapp:Hz'))]};
        tblData(:,i+1)=getArrayCharacteristics(obj,arrayObj,i);

        columnFormat(i+1)={'char'};
        columnEditable(i+1)=false;
    end

    if strcmp(obj.Container,'ToolGroup')
        parent=Panel;
    else
        parent=layout;
    end

    obj.ArrayCharTable=uitable('Parent',parent,...
    'Data',tblData,...
    'RowName',{},...
    'ColumnName',columnName,...
    'ColumnWidth',columnWidth,...
    'ColumnFormat',columnFormat,...
    'ColumnEditable',columnEditable,...
    'Units','pixels',...
    'Tag','arrayCharTable');

    if strcmp(obj.Container,'ToolGroup')

        obj.ArrayCharTable.Position=[0,0,obj.ArrayCharTable.Extent(3)...
        ,obj.ArrayCharTable.Extent(4)];

        row=1;

        add(layout,obj.ArrayCharTable,row,1,...
        'Fill','Both',...
        'MinimumHeight',21*length(obj.ArrayCharTable.Data(1:end,1)),...
        'Anchor','north');

        layout.VerticalWeights(end,1)=1;
    end
end




function arrayCharacteristics=getArrayCharacteristics(obj,arrayObj,freqIdx)



    NumElement=getNumElements(arrayObj);
    Freq=obj.SignalFrequencies;
    PropSpeed=obj.PropagationSpeed;
    Steerang=obj.SteeringAngle;
    phaseBits=getCurrentPhaseQuanBits(obj);
    subarraySteerAng=obj.SubarraySteeringAngle;
    subarrayPhaseShiftBits=obj.SubarrayPhaseQuanBits;
    subarrayPhaseShiftFreq=obj.SubarrayPhaseShifterFreq;



    NumSA=size(Steerang,2);
    NumF=length(Freq);
    NumPSB=length(phaseBits);


    [Steerang,Freq]=obj.makeEqualLength(Steerang,Freq,phaseBits,NumSA,NumF,NumPSB);


    w=computeWeights(obj);


    cutAngleAz=0;
    cutAngleEl=0;






    warning('off','siglib:polarpattern:FindLobesFinite');
    fig1=figure('Visible','off');
    harrayObj=clone(arrayObj);

    azAng=-180:0.01:180;
    try
        if strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,'None')
            patternAzimuth(harrayObj,Freq(freqIdx),cutAngleEl,'Azimuth',azAng,...
            'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx));
        elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,'Custom')
            patternAzimuth(harrayObj,Freq(freqIdx),cutAngleEl,'Azimuth',azAng,...
            'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx),...
            'ElementWeights',obj.ElementWeights);
        else
            patternAzimuth(harrayObj,Freq(freqIdx),cutAngleEl,'Azimuth',azAng,...
            'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx),...
            'SteerAngle',subarraySteerAng);
        end
    catch
    end

    patternAzTemp=polarpattern('gco');



    fAzPlane=patternAzTemp.findLobes;
    backLobe=fAzPlane.backLobe;
    sideLobe=fAzPlane.sideLobes;





    if~isempty(backLobe.magnitude)
        if(backLobe.magnitude>=sideLobe.magnitude)
            patternAz=excludeBackLobe(patternAzTemp,backLobe,azAng);
        else
            patternAz=patternAzTemp;
        end

    else
        patternAz=patternAzTemp;
    end

    fAzPlane.SLL=patternAz.findLobes.SLL;
    obj.AzLobe=fAzPlane;

    try
        if strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,'None')
            patternElevation(harrayObj,Freq(freqIdx),cutAngleAz,...
            'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx));
        elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,'Custom')
            patternElevation(harrayObj,Freq(freqIdx),cutAngleAz,...
            'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx),...
            'ElementWeights',obj.ElementWeights);
        else
            patternElevation(harrayObj,Freq(freqIdx),cutAngleAz,...
            'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx),...
            'SteerAngle',subarraySteerAng);
        end
    catch
    end

    patternElTemp=polarpattern('gco');

    fElPlane=patternElTemp.findLobes;
    backLobe=fElPlane.backLobe;
    sideLobe=fElPlane.sideLobes;



    if~isempty(backLobe.magnitude)
        if(backLobe.magnitude>=sideLobe.magnitude)
            patternEl=excludeBackLobe(patternElTemp,backLobe,-180:180);
        else
            patternEl=patternElTemp;
        end

    else
        patternEl=patternElTemp;
    end

    fElPlane.SLL=patternEl.findLobes.SLL;
    obj.ElLobe=fElPlane;


    HPBW_Az=fAzPlane.HPBW;
    HPBW_El=fElPlane.HPBW;


    FNBW_Az=fAzPlane.FNBW;
    FNBW_El=fElPlane.FNBW;


    SLL_Az=fAzPlane.SLL;
    SLL_El=fElPlane.SLL;


    if strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,'None')
        ArrayDirectivity=directivity(harrayObj,...
        Freq(freqIdx),Steerang(:,freqIdx),...
        'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx));
    elseif strcmp(obj.ToolStripDisplay.SubarraySteerPopup.Value,'Custom')
        ArrayDirectivity=directivity(harrayObj,...
        Freq(freqIdx),Steerang(:,freqIdx),...
        'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx),...
        'ElementWeights',obj.ElementWeights);
    else
        ArrayDirectivity=directivity(harrayObj,...
        Freq(freqIdx),Steerang(:,freqIdx),...
        'PropagationSpeed',PropSpeed,'Weights',w(:,freqIdx),...
        'SteerAngle',subarraySteerAng);
    end

    ArraydirectivityStr=...
    sprintf(getString(message('phased:apps:arrayapp:ArrayCharDirectivity',...
    sprintf('%0.2f',ArrayDirectivity),...
    num2str(Steerang(1)),...
    num2str(Steerang(2)))));

    obj.ArrayDir=ArrayDirectivity;


    ElementsPosition=getElementPosition(harrayObj);



    xspan=abs(max(ElementsPosition(1,:))-min(ElementsPosition(1,:)));
    yspan=abs(max(ElementsPosition(2,:))-min(ElementsPosition(2,:)));
    zspan=abs(max(ElementsPosition(3,:))-min(ElementsPosition(3,:)));

    obj.XSpan=xspan;
    obj.YSpan=yspan;
    obj.ZSpan=zspan;

    [xspan,~,Prefix{1}]=engunits(xspan);
    [yspan,~,Prefix{2}]=engunits(yspan);
    [zspan,~,Prefix{3}]=engunits(zspan);

    Span{1}=num2str(round(xspan,2));
    Span{2}=num2str(round(yspan,2));
    Span{3}=num2str(round(zspan,2));
    Span=regexprep(Span,'(\.\d{2})\d*','$1');

    SpanStr=sprintf(...
    getString(message('phased:apps:arrayapp:ArrayCharSpan',...
    num2str(Span{1}),Prefix{1},...
    num2str(Span{2}),Prefix{2},...
    num2str(Span{3}),Prefix{3})));


    HPBWStr=sprintf(...
    getString(message('phased:apps:arrayapp:ArrayCharBeamWidth',...
    sprintf('%0.2f',HPBW_Az),char(176),...
    sprintf('%0.2f',HPBW_El))));

    if isempty(FNBW_Az)
        FNBW_Az='-';
        fmtaz='%s';
    else
        fmtaz='%0.2f';
    end

    if isempty(FNBW_El)
        FNBW_El='-';
        fmt='%s';
    else
        fmt='%0.2f';
    end

    FNBWStr=sprintf(...
    getString(message('phased:apps:arrayapp:ArrayCharBeamWidth',...
    sprintf(fmtaz,FNBW_Az),char(176),...
    sprintf(fmt,FNBW_El))));

    if isempty(SLL_El)
        SLL_El='-';
        fmt='%s';
    else
        fmt='%0.2f';
    end

    if isempty(SLL_Az)
        SLL_Az='-';
        fmtaz='%s';
    else
        fmtaz='%0.2f';
    end

    SLLStr=sprintf(...
    getString(message('phased:apps:arrayapp:ArrayCharSLL',...
    sprintf(fmtaz,SLL_Az),'dB',...
    sprintf(fmt,SLL_El))));

    elementpath=fullfile(matlabroot,'toolbox','phased',...
    'phasedapps','+phased','+apps','+internal',...
    'elementpolarization.csv');
    table=readtable(elementpath,'Format','auto');
    Names=table.name;
    if~isempty(obj.importData)
        index=strmatch(class(obj.importData),Names,'exact');
    else
        index=strmatch(class(obj.CurrentElement),Names,'exact');
    end

    if~isempty(index)
        ElementPolarization=table.polarization{index};
        if strcmp(ElementPolarization,'Linear')
            obj.ElementPolarization=getString(message('phased:apps:arrayapp:ArrayCharLinear'));
        else
            obj.ElementPolarization=getString(message('phased:apps:arrayapp:ArrayCharCircular'));
        end
    elseif isa(obj.CurrentElement,'phased.CrossedDipoleAntennaElement')
        if strcmp(obj.CurrentElement.Polarization,'RHCP')
            obj.ElementPolarization=getString(message('phased:apps:arrayapp:ArrayCharRHCP'));
        elseif strcmp(obj.CurrentElement.Polarization,'LHCP')
            obj.ElementPolarization=getString(message('phased:apps:arrayapp:ArrayCharLHCP'));
        else
            obj.ElementPolarization=getString(message('phased:apps:arrayapp:ArrayCharLinear'));
        end
    elseif isa(obj.CurrentElement,'phased.CustomAntennaElement')&&isPolarizationCapable(obj.CurrentElement)
        obj.ElementPolarization=getString(message('phased:apps:arrayapp:ArrayCharCustom'));
    else
        obj.ElementPolarization=getString(message('phased:apps:arrayapp:ArrayCharNone'));
    end
    PolarizationStr=sprintf(obj.ElementPolarization);


    if~obj.IsSubarray
        arrayCharacteristics={ArraydirectivityStr,SpanStr,NumElement,...
        HPBWStr,FNBWStr,SLLStr,PolarizationStr};
    else
        NumSubarrays=getNumSubarrays(arrayObj);
        arrayCharacteristics={ArraydirectivityStr,SpanStr,NumSubarrays,...
        NumElement,HPBWStr,FNBWStr,SLLStr,PolarizationStr};
    end


    close(fig1);

    warning('on','siglib:polarpattern:FindLobesFinite');
end

function varargout=excludeBackLobe(pp,BL,ang)
    pat=pp.MagnitudeData;
    if~isempty(BL.magnitude)
















        if BL.extent(2)>BL.extent(1)
            pat(BL.extent(1):BL.extent(2))=min(pat);
            nullBLPat=pat;
        else
            pat(1:BL.extent(2))=min(pat);
            pat(BL.extent(1):end)=min(pat);
            nullBLPat=pat;
        end

        replace(pp,ang,nullBLPat);
    end
    if nargin
        varargout{1}=pp;
    end
end
