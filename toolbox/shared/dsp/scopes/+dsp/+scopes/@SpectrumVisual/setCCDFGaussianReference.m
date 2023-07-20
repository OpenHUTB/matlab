function setCCDFGaussianReference(this,enable)




    if isCCDFMode(this)&&~isempty(this.Plotter)
        setCCDFGaussianReferenceLine(this.Plotter,enable);
    end
end
