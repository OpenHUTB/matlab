function h=angleMarker(p,markerType,markerIdx,dataIdx,datasetIndex)










    if isempty(datasetIndex)
        dsm='auto';
        datasetIndex=1;
    else
        dsm='manual';
    end


















    if p.IncludeMagUnitsInMarkerDisplay
        detailDataFcn=@(m)internal.polariAngleMarker.markerDetailDataStrFcn(m,true);
        detailTypeFcn=@(m)internal.polariAngleMarker.markerDetailMagOnlyStrFcn(m,true);
    else
        detailDataFcn=@(m)internal.polariAngleMarker.markerDetailDataStrFcn(m,false);
        detailTypeFcn=@(m)internal.polariAngleMarker.markerDetailMagOnlyStrFcn(m,false);
    end
    detailIndexFcn=@internal.polariAngleMarker.markerDetailAngleStrFcn;

    if isscalar(dataIdx)


        magIdx=[];
    else


        magIdx=dataIdx(2);
        dataIdx=dataIdx(1);
    end

    h=internal.polariAngleMarker(p,...
    'DataIndex',dataIdx,...
    'MagIndex',magIdx,...
    'DataSetIndex',datasetIndex,...
    'DataSetMode',dsm,...
    'DataDot',p.KeepCursorDataDotVisible,...
    'DataDotLegend',false,...
    'Type',markerType,...
    'Index',markerIdx,...
    'Length',0.2,...
    'Tip',0.0625,...
    'TipOverlap',p.AngleMarkerTipOverlap,...
    'DetailWidth',.4,...
    'WidthMode','auto',...
    'Width',0.125,...
    'OriginLineColorMode','auto',...
    'DetailDataStr',detailDataFcn,...
    'DetailIndexStr',detailIndexFcn,...
    'DetailTypeStr',detailTypeFcn,...
    'StringDirection','width',...
    'ShowDetail',1,...
    'Z',0.3);
