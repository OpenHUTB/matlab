function initToolTip(p)




    c=internal.ToolTip(p.hFigure);
    p.hToolTip=c;
    c.BackgroundColor=[255,255,225]./255;
    c.ForegroundColor='k';
    c.ShowAfter=1;
    c.RemainFor=4;
    c.Location='pointer';
    c.String='';
