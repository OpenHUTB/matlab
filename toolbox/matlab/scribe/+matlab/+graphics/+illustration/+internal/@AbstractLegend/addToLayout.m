function[list,side]=addToLayout(hObj)





    list='';
    side='';

    location=hObj.Location;
    orientation=hObj.Orientation;

    switch location
    case{'eastoutside','northeastoutside','southeastoutside'}
        list='outer';
        side='east';
    case{'east','northeast','southeast'}
        list='inner';
        side='east';
    case{'westoutside','northwestoutside','southwestoutside'}
        list='outer';
        side='west';
    case{'west','northwest','southwest'}
        list='inner';
        side='west';
    case 'northoutside'
        list='outer';
        side='north';
    case 'north'
        list='inner';
        side='north';
    case 'southoutside'
        list='outer';
        side='south';
    case 'south'
        list='inner';
        side='south';
    case 'none'

    end

