function createCanvas(this)




    this.TreeFigure=uifigure('Visible','off');
    this.TreeAxes=uiaxes(this.TreeFigure,'Visible','off');
    this.TreeAxes.Position=[this.TreeAxes.Position(1:2)...
    ,(this.TreeFigure.Position(3:4)-2*this.TreeAxes.Position(1:2))];
    this.TreeAxes.BackgroundColor=this.BackgroundColor;
    disableDefaultInteractivity(this.TreeAxes);
    this.TreeAxes.Toolbar.Visible='off';
    this.TreeAxes.XLimMode='manual';
    this.TreeAxes.YLimMode='manual';
    this.TreeAxes.XColor=this.BackgroundColor;
    this.TreeAxes.YColor=this.BackgroundColor;
    this.TreeAxes.Visible='on';
end
