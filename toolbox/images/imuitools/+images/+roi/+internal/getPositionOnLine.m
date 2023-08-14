function insertPos=getPositionOnLine(xLine,yLine,pos)














    v1=[diff(xLine),diff(yLine)];


    v2=[pos(1)-xLine(1),pos(2)-yLine(1)];



    insertPos=(dot(v1,v2)./dot(v1,v1)).*v1+[xLine(1),yLine(1)];

end