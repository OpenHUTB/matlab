function figOut=viewArraySettings(obj,toolStrip,figHandle,sensorArray)






    figHandle.Name=...
    getString(message('phased:apps:arrayapp:arrayGeometryfigure'));
    figHandle.Tag='arrayGeoFig';
    figHandle.HandleVisibility='on';


    set(groot,'CurrentFigure',figHandle);

    drawnow();


    if toolStrip.IdxCheck.Value==1
        showI='All';
    else
        showI='None';
    end


    figHandle.Visible='on';


    if obj.IsSubarray
        viewAngle=figHandle.CurrentAxes.View;
    else
        viewAngle=[45,45];
    end

    if isa(obj.CurrentArray,'phased.PartitionedArray')&&~isempty(obj.SubarrayLabels)
        viewArray(sensorArray,...
        'SubarrayColorOrder',obj.SubarrayLabels.ColorOrder,...
        'ShowAnnotation',false,...
        'ShowNormal',toolStrip.NormalCheck.Value,...
        'ShowTaper',toolStrip.TaperCheck.Value,'ShowIndex',showI,...
        'ShowLocalCoordinates',toolStrip.LocalCoordinateArrayCheck.Value,...
        'ShowAnnotation',toolStrip.AnnotationCheck.Value,...
        'Orientation',str2num(toolStrip.ArrayOrientationEdit.Value));
    else
        viewArray(sensorArray,...
        'ShowAnnotation',false,...
        'ShowNormal',toolStrip.NormalCheck.Value,...
        'ShowTaper',toolStrip.TaperCheck.Value,'ShowIndex',showI,...
        'ShowLocalCoordinates',toolStrip.LocalCoordinateArrayCheck.Value,...
        'ShowAnnotation',toolStrip.AnnotationCheck.Value,...
        'Orientation',str2num(toolStrip.ArrayOrientationEdit.Value));
    end


    axtoolbar(figHandle.CurrentAxes,{'export',...
    'rotate','pan','zoomin','zoomout','restoreview'});

    figHandle.HandleVisibility='off';


    view(figHandle.CurrentAxes,viewAngle);

    figOut=figHandle;
