function loadFromBlock(h)







    h.CMapStr=h.Block.CMapStr;
    h.YMin=h.Block.YMin;
    h.YMax=h.Block.YMax;
    h.AxisColorbar=strcmpi(h.Block.AxisColorbar,'on');

    h.AxisOrigin=h.Block.AxisOrigin;
    h.XLabel=h.Block.XLabel;
    h.YLabel=h.Block.YLabel;
    h.ZLabel=h.Block.ZLabel;
    h.AxisTickMode=h.Block.AxisTickMode;
    h.XTickRange=h.Block.XTickRange;
    h.YTickRange=h.Block.YTickRange;
    h.FigPos=h.Block.FigPos;
    h.AxisZoom=strcmpi(h.Block.AxisZoom,'on');


