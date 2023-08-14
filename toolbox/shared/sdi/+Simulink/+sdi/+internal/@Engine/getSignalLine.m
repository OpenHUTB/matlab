function out=getSignalLine(this,id)
    out.Color=this.getSignalLineColor(id);
    out.Style=this.getSignalLineDashed(id);
    markerStr=this.getSignalMarker(id);
    out.Marker=Simulink.sdi.internal.Util.resolveMarker(markerStr);
    out.Width=this.getSignalLineWidth(id);
end