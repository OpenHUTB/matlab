function updateYAxis(this)





    updateYLabel(this);

    this.Plotter.MinYLim=evalPropertyValue(this,'MinYLim');
    this.Plotter.MaxYLim=evalPropertyValue(this,'MaxYLim');
end
