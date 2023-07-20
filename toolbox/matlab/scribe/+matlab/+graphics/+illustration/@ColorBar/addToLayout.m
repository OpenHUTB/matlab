function[list,side]=addToLayout(hObj)



    list='';
    side='';

    switch hObj.Location
    case 'eastoutside'
        list='outer';
        side='east';
    case 'east'
        list='inner';
        side='east';
    case 'westoutside'
        list='outer';
        side='west';
    case 'west'
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
    case 'manual'

    end


