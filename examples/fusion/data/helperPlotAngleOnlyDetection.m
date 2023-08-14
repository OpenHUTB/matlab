function helperPlotAngleOnlyDetection(globeViewer,angleOnlyDets,varargin)
    p=inputParser;
    p.addParameter('Color',[1,0,0]);
    p.parse(varargin{:});
    color=p.Results.Color;

    persistent viewer
    if isempty(viewer)||~isvalid(viewer)
        s=warning('off');
        globePvt=struct(globeViewer);
        viewer=globePvt.Viewer;
        warning(s);
    end
    NMax=20;


    N=numel(angleOnlyDets);

    for i=1:N
        linePos=irLine(angleOnlyDets{i});
        lla=fusion.internal.frames.ecef2lla(linePos);
        viewer.Viewer.lineCollection({lla},...
        'ID',['myCollection',num2str(i)],...
        'Indices',{{1}},...
        'Width',1,...
        'Color',color,...
        'WaitForResponse',false);
    end

    for i=(N+1):NMax
        viewer.Viewer.lineCollection({[0,0,0;0,0,0]},...
        'ID',['myCollection',num2str(i)],...
        'Indices',{{1}},...
        'Width',1,...
        'Color',color,...
        'WaitForResponse',false);
    end

end


function linePos=irLine(detection)

    [~,startPt]=matlabshared.tracking.internal.fusion.parseMeasurementParameters(detection.MeasurementParameters,'irLine','double');

    detection.Measurement(3)=5000;
    detection.MeasurementParameters(1).HasRange=true;
    endPos=matlabshared.tracking.internal.fusion.parseDetectionForInitFcn(detection,'irLine','double');
    linePos=[startPt,endPos]';
end