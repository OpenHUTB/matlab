function xyzExtents=getXYZExtents(this)




    if isempty(this.Plotter)
        xyzExtents=[NaN,NaN;[NaN,NaN];-1,1];
    else
        xyzExtents=getXYZExtents(this.Plotter);
        if isSpectrogramMode(this)||isCombinedViewMode(this)
            xyzExtents(2,:)=this.PowerColorExtents;
        end
    end
end
