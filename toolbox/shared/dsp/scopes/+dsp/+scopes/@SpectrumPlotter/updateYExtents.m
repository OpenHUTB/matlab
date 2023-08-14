function updateYExtents(this)





    yExtents=this.SpectrumYExtents;
    if~strcmp(this.SpectralMaskVisibility,'None')
        maskYExtents=getMaskYExtents(this.MaskPlotter);
        yExtents=[min(yExtents(1),maskYExtents(1)),max(yExtents(2),maskYExtents(2))];
    end
    this.YExtents=yExtents;