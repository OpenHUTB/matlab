function height=getHeightInPointsWithoutTitle(hObj)





    height=max(hObj.Bubbles.Size)+hObj.Padding*2;


    if strcmp(hObj.Style,'vertical')
        height=max(hObj.Bubbles.Size)+min(hObj.Bubbles.Size)+hObj.Padding*3;
        if hObj.NumBubbles==3

            height=height+hObj.Padding+hObj.Bubbles.Size(3);
        end
    end

end