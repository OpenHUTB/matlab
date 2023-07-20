function loc=getPreferredLocation(hObj)

    loc=[.5,.5];

    switch hObj.Location
    case{'north','northoutside','south','southoutside'}
        loc(1)=.5;
    case{'northeast','northwest','northeastoutside','northwestoutside'}
        loc(2)=1;
    case{'east','west','eastoutside','westoutside'}
        loc(2)=.5;
    case{'southeast','southwest','southeastoutside','southwestoutside'}
        loc(2)=0;
    case 'none'

    end

