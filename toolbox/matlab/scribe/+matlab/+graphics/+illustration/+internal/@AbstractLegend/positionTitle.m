function positionTitle(hObj,legendHeight,titleHeight)






    titleX=.5;
    titleY=1-((titleHeight/2)/(legendHeight+titleHeight));

    hObj.Title.Position=[titleX,titleY];

    separatorY=1-(titleHeight/(legendHeight+titleHeight));
    hObj.TitleSeparator.VertexData=single([0,1;separatorY,separatorY;0,0]);

end

