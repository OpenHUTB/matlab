function new_pt=getPointInPixels(hFig,old_pt)




    if~strcmpi(hFig.Units,'Pixels')
        ptrect=hgconvertunits(hFig,[0,0,old_pt],hFig.Units,'Pixels',hFig);
        new_pt=ptrect(3:4);
    else
        new_pt=old_pt;
    end
