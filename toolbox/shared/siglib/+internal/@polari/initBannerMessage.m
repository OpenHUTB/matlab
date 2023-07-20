function initBannerMessage(p)




    c=internal.BannerMessage(p.hFigure);
    p.hBannerMessage=c;
    c.BackgroundColor=[255,255,225]./255;
    c.ForegroundColor='k';
    c.HighlightColor='k';
    c.RemainFor=8;

    c.Location='top';
