function xyzExtents=getXYZExtents(this)



    if this.CCDFMode
        xyzExtents=[this.XExtents;this.YExtents;-1,1];
    else
        xyzExtents=[calculateXLim(this);this.YExtents;-1,1];
    end
end
