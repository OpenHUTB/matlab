function drawSpectralMask(this)





    if~isempty(this.MaskPlotter)
        draw(this.MaskPlotter);
        updateMaskColor(this.MaskPlotter);
    end
