function[textPos,vertAlign]=calculateTextPosition(hObj,pos)


    sw=hObj.Margin;
    sh=hObj.Margin-1;


    topadj=1;


    dxy=0;

    X=pos(1)+pos(3)/2+dxy;
    Y=pos(2)+pos(4)/2+dxy;
    W=pos(3)-2*dxy;
    H=pos(4)-2*dxy;

    Xl=X-W/2+sw;
    Xr=X+W/2-sw;

    switch(hObj.VerticalAlignment)
    case{'top','cap'}
        vertAlign='top';
        Ytop=Y+H/2-sh+topadj;
        switch(hObj.HorizontalAlignment)
        case 'left'
            textPos=[Xl,Ytop];
        case 'right'
            textPos=[Xr,Ytop];
        case 'center'
            textPos=[X,Ytop];
        end
    case{'bottom','baseline'}
        vertAlign='bottom';
        Ybottom=Y-H/2+sh+topadj;
        switch(hObj.HorizontalAlignment)
        case 'left'
            textPos=[Xl,Ybottom];
        case 'right'
            textPos=[Xr,Ybottom];
        case 'center'
            textPos=[X,Ybottom];
        end
    case 'middle'
        vertAlign='middle';
        Ymiddle=Y+topadj;
        switch(hObj.HorizontalAlignment)
        case 'left'
            textPos=[Xl,Ymiddle];
        case 'right'
            textPos=[Xr,Ymiddle];
        case 'center'
            textPos=[X,Ymiddle];
        end
    end