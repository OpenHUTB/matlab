function c=getPointsNextPlotColor(p)











    colorOrder=p.pColorOrder;



    idx=mod(p.ColorOrderIndex-1,size(colorOrder,1))+1;
    c=colorOrder(idx,:);







    p.ColorOrderIndex=idx+1;
